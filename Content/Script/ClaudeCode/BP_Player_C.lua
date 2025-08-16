-- @type BP_Player_C
-- 캐주얼 큐브 수집 게임 - 플레이어 캐릭터 제어
-- Enhanced Input 시스템을 사용한 이동 및 시점 제어

local BP_Player_C = Class()

-- Enhanced Input 모듈 로드
local EnhancedInput = require "UnLua.EnhancedInput"

function BP_Player_C:ReceiveBeginPlay()
    -- 부모 클래스의 BeginPlay 호출 (Blueprint BeginPlay 실행)
    self.Overridden.ReceiveBeginPlay(self)
    
    print("BP_Player_C: 플레이어 초기화 완료")
end

-- Input Axis 핸들러들 (DefaultInput.ini의 AxisMappings와 매치)
function BP_Player_C:MoveForward(AxisValue)
    if AxisValue ~= 0 then
        local ForwardVector = self:GetActorForwardVector()
        self:AddMovementInput(ForwardVector, AxisValue)
    end
end

function BP_Player_C:MoveRight(AxisValue)
    if AxisValue ~= 0 then
        local RightVector = self:GetActorRightVector()
        self:AddMovementInput(RightVector, AxisValue)
    end
end

function BP_Player_C:Turn(AxisValue)
    if AxisValue ~= 0 then
        self:AddControllerYawInput(AxisValue)
    end
end

function BP_Player_C:LookUp(AxisValue)
    if AxisValue ~= 0 then
        self:AddControllerPitchInput(AxisValue)
    end
end

-- Gamepad용 추가 (필요시)
function BP_Player_C:LookUpRate(AxisValue)
    if AxisValue ~= 0 then
        self:AddControllerPitchInput(AxisValue)
    end
end

function BP_Player_C:TurnRate(AxisValue)
    if AxisValue ~= 0 then
        self:AddControllerYawInput(AxisValue)
    end
end

function BP_Player_C:BindInputActions()
    print("BP_Player_C: Enhanced Input 액션 바인딩 중...")
    
    -- Input Action 경로 (하드코딩)
    local IA_Move_Path = "/Game/ClaudeCode/Input/IA_Move"
    local IA_Look_Path = "/Game/ClaudeCode/Input/IA_Look"
    
    -- Input Action 로드 확인
    local MoveAction = UE.UObject.Load(IA_Move_Path)
    local LookAction = UE.UObject.Load(IA_Look_Path)
    
    if not MoveAction then
        print("BP_Player_C: 경고! IA_Move를 로드할 수 없음:", IA_Move_Path)
        return
    end
    
    if not LookAction then
        print("BP_Player_C: 경고! IA_Look를 로드할 수 없음:", IA_Look_Path)
        return
    end
    
    print("BP_Player_C: Input Actions 로드 성공")
    
    -- Move 액션 바인딩
    print("BP_Player_C: Move 액션 바인딩 시작:", IA_Move_Path)
    EnhancedInput.BindAction(self, IA_Move_Path, "Triggered", function(ActionValue)
        print("BP_Player_C: *** Move 액션 트리거됨! ***")
        local MoveVector = ActionValue:Get2DAxisValue()
        self:HandleMoveInput(MoveVector)
    end)
    print("BP_Player_C: Move 액션 바인딩 완료")
    
    -- Look 액션 바인딩
    print("BP_Player_C: Look 액션 바인딩 시작:", IA_Look_Path)
    EnhancedInput.BindAction(self, IA_Look_Path, "Triggered", function(ActionValue)
        print("BP_Player_C: *** Look 액션 트리거됨! ***")
        local LookVector = ActionValue:Get2DAxisValue()
        self:HandleLookInput(LookVector)
    end)
    print("BP_Player_C: Look 액션 바인딩 완료")
    
    print("BP_Player_C: 모든 Enhanced Input 바인딩 완료")
end

function BP_Player_C:HandleMoveInput(MoveVector)
    print("BP_Player_C: HandleMoveInput 호출됨")
    
    if not MoveVector then
        print("BP_Player_C: MoveVector가 nil입니다")
        return
    end
    
    print(string.format("BP_Player_C: MoveVector = (%.2f, %.2f)", MoveVector.X, MoveVector.Y))
    
    if MoveVector.X == 0 and MoveVector.Y == 0 then
        print("BP_Player_C: MoveVector가 0,0입니다")
        return
    end
    
    -- 전방/후방 이동 (MoveVector.Y)
    if MoveVector.Y ~= 0 then
        local ForwardVector = self:GetActorForwardVector()
        print(string.format("BP_Player_C: 전방 이동 - Y=%.2f, ForwardVector=(%.2f,%.2f,%.2f)", 
              MoveVector.Y, ForwardVector.X, ForwardVector.Y, ForwardVector.Z))
        self:AddMovementInput(ForwardVector, MoveVector.Y)
    end
    
    -- 좌/우 이동 (MoveVector.X)
    if MoveVector.X ~= 0 then
        local RightVector = self:GetActorRightVector()
        print(string.format("BP_Player_C: 좌우 이동 - X=%.2f, RightVector=(%.2f,%.2f,%.2f)", 
              MoveVector.X, RightVector.X, RightVector.Y, RightVector.Z))
        self:AddMovementInput(RightVector, MoveVector.X)
    end
end

function BP_Player_C:HandleLookInput(LookVector)
    if not LookVector or (LookVector.X == 0 and LookVector.Y == 0) then
        return
    end
    
    -- 마우스 X축 이동 -> 좌우 회전 (Yaw)
    if LookVector.X ~= 0 then
        self:AddControllerYawInput(LookVector.X)
    end
    
    -- 마우스 Y축 이동 -> 상하 회전 (Pitch)
    if LookVector.Y ~= 0 then
        self:AddControllerPitchInput(LookVector.Y)
    end
end

-- 디버그용 Tick 이벤트
function BP_Player_C:ReceiveTick(DeltaTime)
    -- 현재는 비어있음, 필요시 디버그 정보 출력
end

-- 충돌 감지 (큐브 수집용 - 나중에 BP_Cube 구현시 사용)
function BP_Player_C:ReceiveActorBeginOverlap(OtherActor)
    if OtherActor then
        print(string.format("BP_Player_C: %s와 충돌함", OtherActor:GetName()))
        
        -- 나중에 큐브 수집 로직 추가 예정
        -- if OtherActor:IsA(UE.ABP_Cube_C) then
        --     self:CollectCube(OtherActor)
        -- end
    end
end

return BP_Player_C