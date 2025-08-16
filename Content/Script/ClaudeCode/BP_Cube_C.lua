-- @type BP_Cube_C
-- 캐주얼 큐브 수집 게임 - 수집 가능한 큐브
-- 플레이어와 충돌 시 수집되는 큐브 액터

local BP_Cube_C = Class()

-- Constructor 함수 - 가장 이른 시점에서 Tick 설정
function BP_Cube_C:Initialize()
    print("BP_Cube_C: Initialize 호출됨")
    
    -- Constructor에서 Tick 활성화
    if self.PrimaryActorTick then
        self.PrimaryActorTick.bCanEverTick = true
        self.PrimaryActorTick.bStartWithTickEnabled = true
        print("BP_Cube_C: Constructor에서 Tick 설정")
    end
end

function BP_Cube_C:ReceiveBeginPlay()
    -- 부모 클래스의 BeginPlay 호출
    self.Overridden.ReceiveBeginPlay(self)
    
    print("BP_Cube_C: 큐브 생성됨 -", self:GetName())
    
    -- 모든 방법으로 Tick 활성화 시도
    self:SetActorTickEnabled(true)
    
    -- PrimaryActorTick 직접 설정
    local PrimaryTick = self.PrimaryActorTick
    if PrimaryTick then
        PrimaryTick.bCanEverTick = true
        PrimaryTick.bStartWithTickEnabled = true
        PrimaryTick.bTickEvenWhenPaused = false
        print("BP_Cube_C: PrimaryActorTick 설정 완료")
    else
        print("BP_Cube_C: PrimaryActorTick을 찾을 수 없음")
    end
    
    -- Tick 상태 확인
    local IsTickEnabled = self:IsActorTickEnabled()
    print("BP_Cube_C: Tick 활성화 상태:", IsTickEnabled)
    
    -- 큐브 초기 설정
    self:SetupCube()
    
    -- Tick 준비 완료 (로그 정리)
    -- print("BP_Cube_C: Tick 준비 완료")
end

function BP_Cube_C:ForceEnableTick()
    -- 가장 직접적인 방법: 직접 회전 시작
    print("BP_Cube_C: 직접 회전 시작!")
    self:StartManualRotation()
end

function BP_Cube_C:StartManualRotation()
    -- 수동 회전 시작
    self.bShouldRotate = true
    self.RotationAccumulator = 0
    print("BP_Cube_C: 수동 회전 모드 활성화!")
    
    -- DoRotation 호출 제거 - 에러 발생 지점
    -- self:DoRotation(0.016)
    
    -- Blueprint의 Timeline이나 다른 방법 사용 시도
    self:TryAlternativeRotation()
end

function BP_Cube_C:DoRotation(DeltaTime)
    if self.bShouldRotate and self.bIsCollectable then
        local CurrentRotation = self:GetActorRotation()
        local NewYaw = CurrentRotation.Yaw + (self.RotationSpeed * DeltaTime)
        local NewRotation = UE.FRotator(CurrentRotation.Pitch, NewYaw, CurrentRotation.Roll)
        self:SetActorRotation(NewRotation)
        
        self.RotationAccumulator = self.RotationAccumulator + DeltaTime
        if self.RotationAccumulator > 1.0 then -- 1초마다 로그
            print(string.format("BP_Cube_C: 회전 중... 현재 Yaw: %.1f", NewYaw))
            self.RotationAccumulator = 0
        end
    end
end

function BP_Cube_C:TryAlternativeRotation()
    print("BP_Cube_C: Tick 활성화 준비 완료!")
    print("BP_Cube_C: Blueprint에서 Event Tick을 연결하면 ReceiveTick이 호출됩니다")
end

function BP_Cube_C:SetupCube()
    -- 큐브가 수집 가능한 상태임을 표시
    self.bIsCollectable = true
    
    -- 시각적 효과를 위한 회전 (선택적)
    self:StartRotation()
end

function BP_Cube_C:StartRotation()
    -- 큐브가 Y축을 중심으로 천천히 회전하도록 설정
    self.RotationSpeed = 90.0 -- 초당 90도
    print("BP_Cube_C: 회전 시작")
end

-- Tick 이벤트 - 큐브 회전 (K2_ 함수 사용)
function BP_Cube_C:ReceiveTick(DeltaTime)
    if self.bIsCollectable and self.RotationSpeed then
        -- K2_ 함수를 사용한 Y축 회전
        local Success = pcall(function()
            local CurrentRotation = self:K2_GetActorRotation()
            local NewYaw = CurrentRotation.Yaw + (self.RotationSpeed * DeltaTime)
            local NewRotation = UE.FRotator(CurrentRotation.Pitch, NewYaw, CurrentRotation.Roll)
            self:K2_SetActorRotation(NewRotation, false)
        end)
    end
end

-- 플레이어와 충돌 감지
function BP_Cube_C:ReceiveActorBeginOverlap(OtherActor)
    if not self.bIsCollectable then
        return
    end
    
    -- 플레이어와의 충돌인지 확인
    if OtherActor and OtherActor:IsA(UE.APawn) then
        local PlayerController = OtherActor:GetController()
        if PlayerController and PlayerController:IsA(UE.APlayerController) then
            print("BP_Cube_C: 플레이어와 충돌! 큐브 수집")
            self:CollectCube(OtherActor)
        end
    end
end

function BP_Cube_C:CollectCube(Player)
    if not self.bIsCollectable then
        return
    end
    
    -- 수집 불가능 상태로 변경 (중복 수집 방지)
    self.bIsCollectable = false
    
    print("BP_Cube_C: 큐브 수집됨!")
    
    -- 게임 매니저에게 수집 알림 (나중에 구현)
    self:NotifyGameManager()
    
    -- 큐브 제거
    self:DestroyCube()
end

function BP_Cube_C:NotifyGameManager()
    -- 게임 매니저 찾기 및 큐브 수집 알림
    local World = self:GetWorld()
    if World and World.GameManagerInstance then
        World.GameManagerInstance:OnCubeCollected(self)
    else
        -- 다른 방법으로 게임 매니저 찾기
        self:FindGameManagerAlternative()
    end
end

function BP_Cube_C:FindGameManagerAlternative()
    -- 모든 액터를 순회해서 GameManager 찾기
    local World = self:GetWorld()
    if World then
        local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.AActor)
        for i = 1, AllActors:Length() do
            local Actor = AllActors:Get(i)
            if Actor and Actor:GetName():find("GameManager") then
                print("BP_Cube_C: GameManager 발견:", Actor:GetName())
                if Actor.OnCubeCollected then
                    Actor:OnCubeCollected(self)
                    return
                end
            end
        end
        print("BP_Cube_C: GameManager를 찾을 수 없음")
    end
end

function BP_Cube_C:DestroyCube()
    print("BP_Cube_C: 큐브 제거 시작")
    
    -- 즉시 큐브를 숨기고 충돌 비활성화
    self:SetActorHiddenInGame(true)
    self:SetActorEnableCollision(false)
    print("BP_Cube_C: 큐브 숨김 및 충돌 비활성화 완료")
    
    -- 액터 완전 제거
    self:K2_DestroyActor()
    print("BP_Cube_C: 큐브 제거 완료")
end

-- 디버그용 함수
function BP_Cube_C:GetCollectableStatus()
    return self.bIsCollectable
end

return BP_Cube_C