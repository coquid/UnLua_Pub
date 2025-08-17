-- @type BP_LevelManager_C
-- 캐주얼 큐브 수집 게임 - 레벨 환경 관리
-- 조명, 스카이박스, 환경 설정 관리

local BP_LevelManager_C = Class()

function BP_LevelManager_C:ReceiveBeginPlay()
    -- 부모 클래스의 BeginPlay 호출
    self.Overridden.ReceiveBeginPlay(self)
    
    print("BP_LevelManager_C: 레벨 매니저 시작")
    
    -- 레벨 환경 초기화
    self:InitializeLevelEnvironment()
end

function BP_LevelManager_C:InitializeLevelEnvironment()
    print("BP_LevelManager_C: 레벨 환경 초기화 시작")
    
    -- 조명 설정
    self:SetupLighting()
    
    -- 스카이박스/환경 설정
    self:SetupEnvironment()
    
    -- 포스트 프로세싱 설정
    self:SetupPostProcessing()
    
    print("BP_LevelManager_C: 레벨 환경 초기화 완료")
end

-- 조명 시스템 설정
function BP_LevelManager_C:SetupLighting()
    print("BP_LevelManager_C: 조명 설정 시작")
    
    -- 디렉셔널 라이트 찾기 및 설정
    self:SetupDirectionalLight()
    
    -- 스카이 라이트 설정
    self:SetupSkyLight()
    
    -- 추가 포인트 라이트 (필요시)
    self:SetupAdditionalLights()
    
    print("BP_LevelManager_C: 조명 설정 완료")
end

function BP_LevelManager_C:SetupDirectionalLight()
    -- 디렉셔널 라이트 찾기
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ADirectionalLight)
    if AllActors:Length() > 0 then
        local DirectionalLight = AllActors:Get(1)
        if DirectionalLight then
            print("BP_LevelManager_C: 디렉셔널 라이트 발견, 설정 적용")
            
            -- 라이트 컴포넌트 가져오기
            local LightComponent = DirectionalLight:GetLightComponent()
            if LightComponent then
                -- 조명 강도 설정 (밝은 낮 조명)
                LightComponent:SetIntensity(3.0)
                
                -- 조명 색상 설정 (따뜻한 흰색)
                local LightColor = UE.FLinearColor(1.0, 0.95, 0.8, 1.0)
                LightComponent:SetLightColor(LightColor)
                
                -- 그림자 설정
                LightComponent:SetCastShadows(true)
                
                print("BP_LevelManager_C: 디렉셔널 라이트 설정 완료")
            end
            
            -- 라이트 각도 설정 (45도 각도로 자연스러운 조명)
            local LightRotation = UE.FRotator(-45, 45, 0)
            DirectionalLight:K2_SetActorRotation(LightRotation, false)
        end
    else
        print("BP_LevelManager_C: 디렉셔널 라이트를 찾을 수 없음 - 새로 생성")
        self:CreateDirectionalLight()
    end
end

function BP_LevelManager_C:CreateDirectionalLight()
    -- 디렉셔널 라이트 생성
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local DirectionalLightClass = UE.UClass.Load("/Script/Engine.DirectionalLight")
    if not DirectionalLightClass then
        print("BP_LevelManager_C: 디렉셔널 라이트 클래스를 로드할 수 없음")
        return
    end
    
    local SpawnTransform = UE.FTransform()
    SpawnTransform:SetLocation(UE.FVector(0, 0, 500))
    SpawnTransform:SetRotation(UE.FRotator(-45, 45, 0).Quaternion)
    
    local DirectionalLight = UE.UGameplayStatics.BeginDeferredActorSpawnFromClass(
        World, DirectionalLightClass, SpawnTransform
    )
    
    if DirectionalLight then
        UE.UGameplayStatics.FinishSpawningActor(DirectionalLight, SpawnTransform)
        
        -- 라이트 설정
        local LightComponent = DirectionalLight:GetLightComponent()
        if LightComponent then
            LightComponent:SetIntensity(3.0)
            LightComponent:SetLightColor(UE.FLinearColor(1.0, 0.95, 0.8, 1.0))
            LightComponent:SetCastShadows(true)
        end
        
        print("BP_LevelManager_C: 디렉셔널 라이트 생성 완료")
    end
end

function BP_LevelManager_C:SetupSkyLight()
    -- 스카이 라이트 찾기
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ASkyLight)
    if AllActors:Length() > 0 then
        local SkyLight = AllActors:Get(1)
        if SkyLight then
            print("BP_LevelManager_C: 스카이 라이트 발견, 설정 적용")
            
            local SkyLightComponent = SkyLight:GetLightComponent()
            if SkyLightComponent then
                -- 스카이 라이트 강도 설정
                SkyLightComponent:SetIntensity(1.0)
                
                -- 환경광 색상 설정
                local SkyColor = UE.FLinearColor(0.8, 0.9, 1.0, 1.0)
                SkyLightComponent:SetLightColor(SkyColor)
                
                print("BP_LevelManager_C: 스카이 라이트 설정 완료")
            end
        end
    else
        print("BP_LevelManager_C: 스카이 라이트를 찾을 수 없음")
    end
end

function BP_LevelManager_C:SetupAdditionalLights()
    -- 큐브 주변에 포인트 라이트 추가 (선택사항)
    print("BP_LevelManager_C: 추가 조명 설정 (현재는 스킵)")
    
    -- 나중에 필요시 큐브 위치 주변에 미세한 포인트 라이트 추가
    -- 게임의 분위기를 더 좋게 만들 수 있음
end

-- 환경 설정
function BP_LevelManager_C:SetupEnvironment()
    print("BP_LevelManager_C: 환경 설정 시작")
    
    -- 스카이박스 설정
    self:SetupSkybox()
    
    -- 안개 설정
    self:SetupFog()
    
    print("BP_LevelManager_C: 환경 설정 완료")
end

function BP_LevelManager_C:SetupSkybox()
    -- 레벨의 World Settings에서 스카이박스 설정
    local World = self:GetWorld()
    if World then
        local WorldSettings = World:GetWorldSettings()
        if WorldSettings then
            print("BP_LevelManager_C: 월드 설정 접근 성공")
            
            -- 기본 스카이박스 유지 (더 나은 스카이박스로 교체 가능)
            -- WorldSettings 조작은 Blueprint에서 하는 것이 더 안전함
        end
    end
end

function BP_LevelManager_C:SetupFog()
    -- 대기 안개 설정 (분위기 개선)
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.AAtmosphericFog)
    if AllActors:Length() > 0 then
        local FogActor = AllActors:Get(1)
        if FogActor then
            print("BP_LevelManager_C: 대기 안개 발견, 설정 적용")
            
            -- 안개 컴포넌트 설정 (UE5에서는 다를 수 있음)
            -- 기본 설정 유지
        end
    else
        print("BP_LevelManager_C: 대기 안개 액터를 찾을 수 없음")
    end
end

-- 포스트 프로세싱 설정
function BP_LevelManager_C:SetupPostProcessing()
    print("BP_LevelManager_C: 포스트 프로세싱 설정")
    
    -- Post Process Volume 찾기 및 설정
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.APostProcessVolume)
    if AllActors:Length() > 0 then
        local PostProcessVolume = AllActors:Get(1)
        if PostProcessVolume then
            print("BP_LevelManager_C: 포스트 프로세스 볼륨 발견")
            
            -- 기본 포스트 프로세싱 설정 유지
            -- 필요시 색상 보정, 명도 조정 등 추가
        end
    else
        print("BP_LevelManager_C: 포스트 프로세스 볼륨을 찾을 수 없음")
    end
end

-- 디버그 함수들
function BP_LevelManager_C:PrintLightingInfo()
    print("BP_LevelManager_C: 조명 정보:")
    
    local World = self:GetWorld()
    if not World then
        return
    end
    
    -- 디렉셔널 라이트 정보
    local DirectionalLights = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ADirectionalLight)
    print("  - 디렉셔널 라이트 개수:", DirectionalLights:Length())
    
    -- 스카이 라이트 정보
    local SkyLights = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ASkyLight)
    print("  - 스카이 라이트 개수:", SkyLights:Length())
    
    -- 포인트 라이트 정보
    local PointLights = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.APointLight)
    print("  - 포인트 라이트 개수:", PointLights:Length())
end

function BP_LevelManager_C:ToggleLighting()
    print("BP_LevelManager_C: 조명 토글 (테스트용)")
    
    -- 모든 라이트의 on/off 토글
    local World = self:GetWorld()
    if not World then
        return
    end
    
    local AllLights = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ALight)
    for i = 1, AllLights:Length() do
        local Light = AllLights:Get(i)
        if Light then
            local LightComponent = Light:GetLightComponent()
            if LightComponent then
                local CurrentVisibility = LightComponent:GetVisibleFlag()
                LightComponent:SetVisibility(not CurrentVisibility)
            end
        end
    end
end

return BP_LevelManager_C