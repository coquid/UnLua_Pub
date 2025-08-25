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

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "Engine/World.h"
#include "Components/ActorComponent.h"
#include "ChaosMover/ChaosMoverSimulationTypes.h"
#include "ChaosMoverBlueprintLibrary.generated.h"

class UChaosCharacterMoverComponent;
class AActor;

// 📋 힘 적용 모드 - Blueprint에서 쉽게 선택 가능
UENUM(BlueprintType)
enum class EChaosMoverForceMode : uint8
{
    /** 현재 속도에 추가되는 속도 적용 (기본값) */
    AddVelocity         UMETA(DisplayName = "Add Velocity"),
    
    /** 현재 속도를 완전히 덮어쓰는 속도 적용 */
    SetVelocity         UMETA(DisplayName = "Set Velocity"), 
    
    /** 질량 기반 임펄스 적용 (물리적으로 정확함) */
    AddImpulse          UMETA(DisplayName = "Add Impulse"),
    
    /** Launch 시스템 사용 (자동 상태 전환 포함) */
    Launch              UMETA(DisplayName = "Launch Character")
};

// 🎯 힘 적용 결과 정보
USTRUCT(BlueprintType)
struct FChaosMoverForceResult
{
    GENERATED_BODY()

    /** 힘이 성공적으로 적용되었는지 여부 */
    UPROPERTY(BlueprintReadOnly, Category = "Force Result")
    bool bSuccess = false;

    /** 실제로 적용된 힘의 크기 */
    UPROPERTY(BlueprintReadOnly, Category = "Force Result")
    FVector AppliedForce = FVector::ZeroVector;

    /** 힘을 적용받은 캐릭터들의 수 */
    UPROPERTY(BlueprintReadOnly, Category = "Force Result")
    int32 AffectedCharacterCount = 0;

    /** 적용 전 캐릭터의 이동 모드 */
    UPROPERTY(BlueprintReadOnly, Category = "Force Result")
    FName PreviousMovementMode = NAME_None;

    /** 적용 후 캐릭터의 이동 모드 */
    UPROPERTY(BlueprintReadOnly, Category = "Force Result")
    FName NewMovementMode = NAME_None;
};

/**
 * 🔧 ChaosMover용 범용 힘/임펄스 적용 Blueprint Function Library
 * 서버에서 안전하게 캐릭터들에게 힘을 가할 수 있는 시스템
 */
UCLASS()
class TPSPROJECT_API UChaosMoverBlueprintLibrary : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()

public:
    // 🎯 단일 캐릭터에게 힘 적용 (가장 기본적인 함수)
    UFUNCTION(BlueprintCallable, Category = "ChaosMover|Force Application", 
        CallInEditor = true, meta = (Keywords = "force impulse velocity launch push"))
    static FChaosMoverForceResult ApplyForceToCharacter(
        AActor* TargetCharacter,
        const FVector& Force,
        EChaosMoverForceMode ForceMode = EChaosMoverForceMode::AddVelocity,
        bool bAutoSwitchToFalling = true,
        const FString& DebugContext = TEXT("Manual Force Application")
    );

    // 💥 폭발형: 중심점 기준 반경 내 모든 캐릭터에게 방사형 힘 적용
    UFUNCTION(BlueprintCallable, Category = "ChaosMover|Force Application", 
        CallInEditor = true, meta = (Keywords = "explosion bomb blast radial force"))
    static TArray<FChaosMoverForceResult> ApplyRadialForce(
        UObject* WorldContextObject,
        const FVector& ExplosionCenter,
        float ExplosionRadius,
        float ExplosionStrength,
        EChaosMoverForceMode ForceMode = EChaosMoverForceMode::AddImpulse,
        bool bUseLinearFalloff = true,
        float MinForcePercent = 0.1f,
        bool bAutoSwitchToFalling = true,
        TSubclassOf<AActor> TargetClass = nullptr,
        const FString& DebugContext = TEXT("Radial Force")
    );

    // 🌪️ 방향성 힘: 특정 방향으로 모든 대상에게 동일한 힘 적용 
    UFUNCTION(BlueprintCallable, Category = "ChaosMover|Force Application",
        CallInEditor = true, meta = (Keywords = "wind push directional uniform"))
    static TArray<FChaosMoverForceResult> ApplyDirectionalForce(
        UObject* WorldContextObject,
        const TArray<AActor*>& TargetCharacters,
        const FVector& ForceDirection,
        float ForceStrength,
        EChaosMoverForceMode ForceMode = EChaosMoverForceMode::AddVelocity,
        bool bNormalizeDirection = true,
        bool bAutoSwitchToFalling = false,
        const FString& DebugContext = TEXT("Directional Force")
    );

    // 🎯 고급: 사용자 정의 필터링과 개별 힘 계산
    UFUNCTION(BlueprintCallable, Category = "ChaosMover|Force Application",
        CallInEditor = true, meta = (Keywords = "custom advanced filter"))
    static TArray<FChaosMoverForceResult> ApplyCustomForceToActors(
        const TArray<AActor*>& TargetActors,
        const TArray<FVector>& ForcesToApply,
        EChaosMoverForceMode ForceMode = EChaosMoverForceMode::AddVelocity,
        bool bAutoSwitchToFalling = true,
        const FString& DebugContext = TEXT("Custom Force")
    );

    // 🔍 유틸리티: 특정 범위 내 ChaosMover 캐릭터들 찾기
    UFUNCTION(BlueprintCallable, BlueprintPure, Category = "ChaosMover|Utilities",
        meta = (Keywords = "find characters radius sphere"))
    static TArray<AActor*> FindChaosMoverCharactersInRadius(
        UObject* WorldContextObject,
        const FVector& Center,
        float Radius,
        TSubclassOf<AActor> ActorClass = nullptr,
        bool bIgnoreActorsWithoutChaosMover = true
    );

    // 🛡️ 안전성 체크: ChaosMover 컴포넌트 유효성 검사
    UFUNCTION(BlueprintCallable, BlueprintPure, Category = "ChaosMover|Utilities",
        meta = (Keywords = "validate check component"))
    static bool IsValidChaosMoverCharacter(AActor* Actor);

private:
    // 내부 구현 함수들
    static bool ApplyForceToChaosMover(
        UChaosCharacterMoverComponent* MoverComponent, 
        const FVector& Force, 
        EChaosMoverForceMode ForceMode,
        bool bAutoSwitchToFalling,
        FChaosMoverForceResult& OutResult
    );

    static FVector CalculateRadialForce(
        const FVector& ExplosionCenter,
        const FVector& TargetLocation, 
        float ExplosionRadius,
        float ExplosionStrength,
        bool bUseLinearFalloff,
        float MinForcePercent
    );
};