// Tencent is pleased to support the open source community by making UnLua available.
// 
// Copyright (C) 2019 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the MIT License (the "License"); 
// you may not use this file except in compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, 
// software distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and limitations under the License.

#include "ChaosMoverBlueprintLibrary.h"

#include "Engine/World.h"
#include "Kismet/KismetSystemLibrary.h"
#include "ChaosMover/Character/ChaosCharacterMoverComponent.h"
#include "ChaosMover/ChaosMoverSimulation.h" 
#include "ChaosMover/Character/Effects/ChaosCharacterApplyVelocityEffect.h"
#include "ChaosMover/ChaosMoverLog.h"

// 🎯 단일 캐릭터에게 힘 적용
FChaosMoverForceResult UChaosMoverBlueprintLibrary::ApplyForceToCharacter(
    AActor* TargetCharacter,
    const FVector& Force,
    EChaosMoverForceMode ForceMode,
    bool bAutoSwitchToFalling,
    const FString& DebugContext)
{
    FChaosMoverForceResult Result;
    
    if (!IsValid(TargetCharacter))
    {
        UE_LOG(LogChaosMover, Warning, TEXT("[%s] Invalid target character provided"), *DebugContext);
        return Result;
    }

    if (Force.IsNearlyZero())
    {
        UE_LOG(LogChaosMover, Warning, TEXT("[%s] Force vector is nearly zero, skipping application"), *DebugContext);
        return Result;
    }

    UChaosCharacterMoverComponent* MoverComp = TargetCharacter->GetComponentByClass<UChaosCharacterMoverComponent>();
    if (!IsValid(MoverComp))
    {
        UE_LOG(LogChaosMover, Warning, TEXT("[%s] Target character '%s' does not have ChaosMover component"), 
            *DebugContext, *TargetCharacter->GetName());
        return Result;
    }

    // 적용 전 상태 기록 📋
    Result.PreviousMovementMode = MoverComp->GetCurrentMovementModeName();
    
    bool bSuccess = ApplyForceToChaosMover(MoverComp, Force, ForceMode, bAutoSwitchToFalling, Result);
    
    if (bSuccess)
    {
        Result.bSuccess = true;
        Result.AppliedForce = Force;
        Result.AffectedCharacterCount = 1;
        Result.NewMovementMode = MoverComp->GetCurrentMovementModeName();
        
        UE_LOG(LogChaosMover, Log, TEXT("[%s] Successfully applied force (%.2f, %.2f, %.2f) to character '%s' [%s -> %s]"), 
            *DebugContext, Force.X, Force.Y, Force.Z, *TargetCharacter->GetName(),
            *Result.PreviousMovementMode.ToString(), *Result.NewMovementMode.ToString());
    }

    return Result;
}

// 💥 방사형 폭발 힘 적용
TArray<FChaosMoverForceResult> UChaosMoverBlueprintLibrary::ApplyRadialForce(
    UObject* WorldContextObject,
    const FVector& ExplosionCenter,
    float ExplosionRadius,
    float ExplosionStrength,
    EChaosMoverForceMode ForceMode,
    bool bUseLinearFalloff,
    float MinForcePercent,
    bool bAutoSwitchToFalling,
    TSubclassOf<AActor> TargetClass,
    const FString& DebugContext)
{
    TArray<FChaosMoverForceResult> Results;
    
    if (!IsValid(WorldContextObject))
    {
        UE_LOG(LogChaosMover, Error, TEXT("[%s] Invalid world context object"), *DebugContext);
        return Results;
    }

    if (ExplosionRadius <= 0.0f || ExplosionStrength <= 0.0f)
    {
        UE_LOG(LogChaosMover, Warning, TEXT("[%s] Invalid explosion parameters (Radius: %.2f, Strength: %.2f)"), 
            *DebugContext, ExplosionRadius, ExplosionStrength);
        return Results;
    }

    // 대상 액터들 찾기 🔍
    TArray<AActor*> TargetActors = FindChaosMoverCharactersInRadius(
        WorldContextObject, ExplosionCenter, ExplosionRadius, TargetClass, true);

    UE_LOG(LogChaosMover, Log, TEXT("[%s] Found %d ChaosMover characters in radius %.2f"), 
        *DebugContext, TargetActors.Num(), ExplosionRadius);

    // 각 대상에게 개별적으로 방사형 힘 적용 🎯
    for (AActor* TargetActor : TargetActors)
    {
        if (!IsValid(TargetActor)) continue;

        // 방사형 힘 계산
        FVector RadialForce = CalculateRadialForce(
            ExplosionCenter, TargetActor->GetActorLocation(), 
            ExplosionRadius, ExplosionStrength, 
            bUseLinearFalloff, MinForcePercent);

        // 개별 힘 적용
        FChaosMoverForceResult Result = ApplyForceToCharacter(
            TargetActor, RadialForce, ForceMode, bAutoSwitchToFalling, 
            FString::Printf(TEXT("%s_Radial"), *DebugContext));

        Results.Add(Result);
    }

    return Results;
}

// 🌪️ 방향성 힘 적용
TArray<FChaosMoverForceResult> UChaosMoverBlueprintLibrary::ApplyDirectionalForce(
    UObject* WorldContextObject,
    const TArray<AActor*>& TargetCharacters,
    const FVector& ForceDirection,
    float ForceStrength,
    EChaosMoverForceMode ForceMode,
    bool bNormalizeDirection,
    bool bAutoSwitchToFalling,
    const FString& DebugContext)
{
    TArray<FChaosMoverForceResult> Results;
    
    if (TargetCharacters.Num() == 0)
    {
        UE_LOG(LogChaosMover, Warning, TEXT("[%s] No target characters provided"), *DebugContext);
        return Results;
    }

    // 방향 벡터 정규화 처리 📐
    FVector NormalizedDirection = ForceDirection;
    if (bNormalizeDirection)
    {
        NormalizedDirection = ForceDirection.GetSafeNormal();
    }
    
    FVector FinalForce = NormalizedDirection * ForceStrength;

    UE_LOG(LogChaosMover, Log, TEXT("[%s] Applying directional force (%.2f, %.2f, %.2f) to %d characters"), 
        *DebugContext, FinalForce.X, FinalForce.Y, FinalForce.Z, TargetCharacters.Num());

    // 각 캐릭터에게 동일한 방향으로 힘 적용 🎯
    for (AActor* TargetActor : TargetCharacters)
    {
        FChaosMoverForceResult Result = ApplyForceToCharacter(
            TargetActor, FinalForce, ForceMode, bAutoSwitchToFalling,
            FString::Printf(TEXT("%s_Directional"), *DebugContext));
            
        Results.Add(Result);
    }

    return Results;
}

// 🎯 고급: 사용자 정의 힘 적용
TArray<FChaosMoverForceResult> UChaosMoverBlueprintLibrary::ApplyCustomForceToActors(
    const TArray<AActor*>& TargetActors,
    const TArray<FVector>& ForcesToApply,
    EChaosMoverForceMode ForceMode,
    bool bAutoSwitchToFalling,
    const FString& DebugContext)
{
    TArray<FChaosMoverForceResult> Results;
    
    if (TargetActors.Num() != ForcesToApply.Num())
    {
        UE_LOG(LogChaosMover, Error, TEXT("[%s] Mismatch between actor count (%d) and force count (%d)"), 
            *DebugContext, TargetActors.Num(), ForcesToApply.Num());
        return Results;
    }

    // 각 액터-힘 쌍에 대해 개별 적용 🎯
    for (int32 i = 0; i < TargetActors.Num(); ++i)
    {
        if (!IsValid(TargetActors[i])) continue;

        FChaosMoverForceResult Result = ApplyForceToCharacter(
            TargetActors[i], ForcesToApply[i], ForceMode, bAutoSwitchToFalling,
            FString::Printf(TEXT("%s_Custom[%d]"), *DebugContext, i));
            
        Results.Add(Result);
    }

    return Results;
}

// 🔍 유틸리티: ChaosMover 캐릭터 찾기
TArray<AActor*> UChaosMoverBlueprintLibrary::FindChaosMoverCharactersInRadius(
    UObject* WorldContextObject,
    const FVector& Center,
    float Radius,
    TSubclassOf<AActor> ActorClass,
    bool bIgnoreActorsWithoutChaosMover)
{
    TArray<AActor*> FoundActors;
    TArray<AActor*> Result;
    
    if (!IsValid(WorldContextObject))
    {
        return Result;
    }

    // Sphere overlap으로 대상들 찾기 🔍
    TArray<UPrimitiveComponent*> IgnoredComponents;
    TArray<TEnumAsByte<EObjectTypeQuery>> ObjectTypes;
    ObjectTypes.Add(UEngineTypes::ConvertToObjectType(ECollisionChannel::ECC_Pawn));

    UKismetSystemLibrary::SphereOverlapActors(
        WorldContextObject, Center, Radius, ObjectTypes, 
        ActorClass, IgnoredComponents, FoundActors);

    // ChaosMover 컴포넌트 필터링 🛡️
    for (AActor* Actor : FoundActors)
    {
        if (!IsValid(Actor)) continue;
        
        if (bIgnoreActorsWithoutChaosMover)
        {
            if (IsValidChaosMoverCharacter(Actor))
            {
                Result.Add(Actor);
            }
        }
        else
        {
            Result.Add(Actor);
        }
    }

    return Result;
}

// 🛡️ ChaosMover 유효성 검사
bool UChaosMoverBlueprintLibrary::IsValidChaosMoverCharacter(AActor* Actor)
{
    if (!IsValid(Actor))
    {
        return false;
    }

    UChaosCharacterMoverComponent* MoverComp = Actor->GetComponentByClass<UChaosCharacterMoverComponent>();
    return IsValid(MoverComp);
}

// 🔧 내부 구현: 실제 힘 적용 로직
bool UChaosMoverBlueprintLibrary::ApplyForceToChaosMover(
    UChaosCharacterMoverComponent* MoverComponent,
    const FVector& Force,
    EChaosMoverForceMode ForceMode,
    bool bAutoSwitchToFalling,
    FChaosMoverForceResult& OutResult)
{
    if (!IsValid(MoverComponent))
    {
        return false;
    }

    // Launch 모드는 기존 Launch 함수 사용 🚀
    if (ForceMode == EChaosMoverForceMode::Launch)
    {
        EChaosMoverVelocityEffectMode LaunchMode = EChaosMoverVelocityEffectMode::AdditiveVelocity;
        MoverComponent->Launch(Force, LaunchMode);
        return true;
    }

    // InstantMovementEffect 방식 사용 💪
    UChaosMoverSimulation* Simulation = MoverComponent->GetSimulation<UChaosMoverSimulation>();
    if (!IsValid(Simulation))
    {
        UE_LOG(LogChaosMover, Warning, TEXT("No ChaosMover simulation found on component"));
        return false;
    }

    // ForceMode에 따른 VelocityEffectMode 결정 🎯
    EChaosMoverVelocityEffectMode VelocityMode;
    switch (ForceMode)
    {
        case EChaosMoverForceMode::AddVelocity:
            VelocityMode = EChaosMoverVelocityEffectMode::AdditiveVelocity;
            break;
        case EChaosMoverForceMode::SetVelocity:
            VelocityMode = EChaosMoverVelocityEffectMode::OverrideVelocity;
            break;
        case EChaosMoverForceMode::AddImpulse:
            VelocityMode = EChaosMoverVelocityEffectMode::Impulse;
            break;
        default:
            VelocityMode = EChaosMoverVelocityEffectMode::AdditiveVelocity;
            break;
    }

    // InstantMovementEffect 생성 및 적용 ⚡
    TSharedPtr<FChaosCharacterApplyVelocityEffect> ForceEffect = MakeShared<FChaosCharacterApplyVelocityEffect>();
    ForceEffect->VelocityOrImpulseToApply = Force;
    ForceEffect->Mode = VelocityMode;

    Simulation->QueueInstantMovementEffect(ForceEffect);

    // 자동 Falling 모드 전환 🌟
    if (bAutoSwitchToFalling && !Force.IsNearlyZero())
    {
        // Z 성분이 있거나 수평 힘이 충분히 클 때만 Falling으로 전환
        if (Force.Z > 100.0f || FVector2D(Force.X, Force.Y).Size() > 200.0f)
        {
            MoverComponent->QueueNextMode(FName("Falling"));
        }
    }

    return true;
}

// 📐 방사형 힘 계산
FVector UChaosMoverBlueprintLibrary::CalculateRadialForce(
    const FVector& ExplosionCenter,
    const FVector& TargetLocation,
    float ExplosionRadius,
    float ExplosionStrength,
    bool bUseLinearFalloff,
    float MinForcePercent)
{
    FVector DirectionToTarget = (TargetLocation - ExplosionCenter);
    float DistanceToTarget = DirectionToTarget.Size();
    
    // 폭발 중심에 있는 경우 위쪽으로 힘 적용 ⬆️
    if (DistanceToTarget < 1.0f)
    {
        return FVector(0, 0, ExplosionStrength);
    }

    DirectionToTarget.Normalize();

    // 거리 기반 힘 감쇠 계산 📉
    float ForceMultiplier = 1.0f;
    if (bUseLinearFalloff)
    {
        ForceMultiplier = FMath::Max(MinForcePercent, 1.0f - (DistanceToTarget / ExplosionRadius));
    }
    else
    {
        // 제곱 역비례 감쇠
        ForceMultiplier = FMath::Max(MinForcePercent, 1.0f - FMath::Square(DistanceToTarget / ExplosionRadius));
    }

    return DirectionToTarget * ExplosionStrength * ForceMultiplier;
}