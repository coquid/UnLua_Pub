-- @type BP_GameManager_C
-- 캐주얼 큐브 수집 게임 - 게임 매니저
-- 큐브 수집 추적, 승리 조건 관리, UI 업데이트

local BP_GameManager_C = Class()

function BP_GameManager_C:ReceiveBeginPlay()
    -- 부모 클래스의 BeginPlay 호출
    self.Overridden.ReceiveBeginPlay(self)
    
    print("BP_GameManager_C: 게임 매니저 시작")
    
    -- 게임 상태 초기화
    self:InitializeGame()
end

function BP_GameManager_C:InitializeGame()
    -- 게임 설정
    self.TotalCubes = 10          -- 총 큐브 개수
    self.CollectedCubes = 0       -- 수집된 큐브 개수
    self.GameCompleted = false    -- 게임 완료 여부
    self.GameStartTime = 0        -- 게임 시작 시간 (나중에 구현)
    self.SpawnedCubes = {}        -- 스폰된 큐브들 추적
    
    print(string.format("BP_GameManager_C: 게임 초기화 완료 - 목표: %d개 큐브 수집", self.TotalCubes))
    
    -- 전역 게임 매니저 참조 설정 (다른 스크립트에서 접근 가능하도록)
    self:SetGlobalReference()
    
    -- 큐브 스폰
    self:SpawnAllCubes()
    
    -- UI 업데이트
    self:UpdateUI()
end

function BP_GameManager_C:SetGlobalReference()
    -- World에 게임 매니저 참조 저장
    local World = self:GetWorld()
    if World then
        -- GameState나 GameInstance에 저장하는 것이 더 좋지만, 간단하게 World에 저장
        World.GameManagerInstance = self
        print("BP_GameManager_C: 전역 참조 설정 완료")
    end
end

-- 큐브 수집 처리 함수 (BP_Cube에서 호출)
function BP_GameManager_C:OnCubeCollected(CubeActor)
    if self.GameCompleted then
        return -- 게임이 이미 완료됨
    end
    
    self.CollectedCubes = self.CollectedCubes + 1
    self:UpdateUI()
    
    -- 승리 조건 확인
    if self.CollectedCubes >= self.TotalCubes then
        self:OnGameCompleted()
    end
end

function BP_GameManager_C:UpdateUI()
    -- UI 업데이트
    local ProgressText = string.format("수집한 큐브: %d/%d", self.CollectedCubes, self.TotalCubes)
    print("BP_GameManager_C: UI 업데이트:", ProgressText)
    
    -- HUD 위젯에 전달
    if self.GameHUDWidget then
        self.GameHUDWidget:UpdateScore(self.CollectedCubes, self.TotalCubes)
    else
        print("BP_GameManager_C: HUD 위젯이 연결되지 않음")
    end
end

function BP_GameManager_C:OnGameCompleted()
    if self.GameCompleted then
        return -- 중복 호출 방지
    end
    
    self.GameCompleted = true
    print("🎉 BP_GameManager_C: 게임 완료! 모든 큐브를 수집했습니다!")
    
    -- 완료 시간 계산 (나중에 구현)
    -- local CompletionTime = self:GetGameTime() - self.GameStartTime
    
    -- 승리 화면 표시 (나중에 구현)
    self:ShowVictoryScreen()
end

function BP_GameManager_C:ShowVictoryScreen()
    print("BP_GameManager_C: 승리 화면 표시")
    
    -- HUD에 게임 완료 알림
    if self.GameHUDWidget then
        self.GameHUDWidget:OnGameCompleted()
    end
    
    -- 별도 승리 위젯 표시
    if self.VictoryWidget then
        self.VictoryWidget:OnGameCompleted()
    else
        print("BP_GameManager_C: VictoryWidget이 연결되지 않음")
    end
end

-- HUD 위젯 설정 함수 (WBP_GameHUD에서 호출)
function BP_GameManager_C:SetHUDWidget(HUDWidget)
    self.GameHUDWidget = HUDWidget
    print("BP_GameManager_C: HUD 위젯 연결 완료")
    
    -- 현재 상태로 UI 업데이트
    self:UpdateUI()
end

-- Victory 위젯 설정 함수 (WBP_GameComplete에서 호출)
function BP_GameManager_C:SetVictoryWidget(VictoryWidget)
    self.VictoryWidget = VictoryWidget
    print("BP_GameManager_C: Victory 위젯 연결 완료")
end

-- 게임 재시작 함수
function BP_GameManager_C:RestartGame()
    print("BP_GameManager_C: 게임 재시작")
    
    -- 게임 상태 리셋
    self.CollectedCubes = 0
    self.GameCompleted = false
    
    -- 큐브들 다시 스폰
    self:RespawnAllCubes()
    
    -- UI 업데이트
    self:UpdateUI()
    
    -- HUD 재시작 알림
    if self.GameHUDWidget then
        self.GameHUDWidget:OnGameRestart()
    end
    
    print("BP_GameManager_C: 게임 재시작 완료")
end

-- 모든 큐브 스폰
function BP_GameManager_C:SpawnAllCubes()
    print("BP_GameManager_C: 큐브 스폰 시작")
    
    -- 기존 큐브들 제거 (재시작 시)
    self:ClearAllCubes()
    
    -- 큐브 스폰 위치 정의 (10개 위치)
    local SpawnPositions = self:GetCubeSpawnPositions()
    
    -- 각 위치에 큐브 스폰
    for i = 1, self.TotalCubes do
        if SpawnPositions[i] then
            local CubeActor = self:SpawnCubeAt(SpawnPositions[i])
            if CubeActor then
                table.insert(self.SpawnedCubes, CubeActor)
                print(string.format("BP_GameManager_C: 큐브 %d/%d 스폰 완료", i, self.TotalCubes))
            end
        end
    end
    
    print(string.format("BP_GameManager_C: 총 %d개 큐브 스폰 완료", #self.SpawnedCubes))
end

-- 큐브 스폰 위치들 반환
function BP_GameManager_C:GetCubeSpawnPositions()
    -- 10개 큐브를 배치할 위치들 (X, Y, Z)
    local Positions = {
        {X = 500,  Y = 500,  Z = 100},   -- 1번 큐브
        {X = -500, Y = 500,  Z = 100},   -- 2번 큐브
        {X = 500,  Y = -500, Z = 100},   -- 3번 큐브
        {X = -500, Y = -500, Z = 100},   -- 4번 큐브
        {X = 0,    Y = 800,  Z = 100},   -- 5번 큐브
        {X = 0,    Y = -800, Z = 100},   -- 6번 큐브
        {X = 800,  Y = 0,    Z = 100},   -- 7번 큐브
        {X = -800, Y = 0,    Z = 100},   -- 8번 큐브
        {X = 300,  Y = 300,  Z = 200},   -- 9번 큐브 (높은 곳)
        {X = -300, Y = -300, Z = 200},   -- 10번 큐브 (높은 곳)
    }
    
    -- FVector로 변환
    local FVectorPositions = {}
    for i, pos in ipairs(Positions) do
        FVectorPositions[i] = UE.FVector(pos.X, pos.Y, pos.Z)
    end
    
    return FVectorPositions
end

-- 특정 위치에 큐브 스폰
function BP_GameManager_C:SpawnCubeAt(Position)
    local World = self:GetWorld()
    if not World then
        print("BP_GameManager_C: World를 찾을 수 없음")
        return nil
    end
    
    -- BP_Cube 클래스 찾기 (Blueprint 경로 설정 필요)
    local CubeClass = UE.UClass.Load("/Game/ClaudeCode/BP_Cube.BP_Cube_C")
    if not CubeClass then
        print("BP_GameManager_C: BP_Cube 클래스를 찾을 수 없음")
        return nil
    end
    
    -- 스폰 파라미터 설정
    local SpawnTransform = UE.FTransform()
    SpawnTransform:SetLocation(Position)
    SpawnTransform:SetRotation(UE.FQuat(0, 0, 0, 1))
    SpawnTransform:SetScale3D(UE.FVector(1, 1, 1))
    
    -- 큐브 스폰
    local SpawnedCube = UE.UGameplayStatics.BeginDeferredActorSpawnFromClass(
        World, CubeClass, SpawnTransform, UE.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn
    )
    
    if SpawnedCube then
        -- 스폰 완료
        UE.UGameplayStatics.FinishSpawningActor(SpawnedCube, SpawnTransform)
        print(string.format("BP_GameManager_C: 큐브 스폰 성공 - 위치: (%.0f, %.0f, %.0f)", 
              Position.X, Position.Y, Position.Z))
        return SpawnedCube
    else
        print("BP_GameManager_C: 큐브 스폰 실패")
        return nil
    end
end

-- 모든 큐브 제거
function BP_GameManager_C:ClearAllCubes()
    print("BP_GameManager_C: 기존 큐브들 제거")
    
    for i, cube in ipairs(self.SpawnedCubes) do
        if cube and cube:IsValidLowLevel() then
            cube:Destroy()
        end
    end
    
    self.SpawnedCubes = {}
end

function BP_GameManager_C:RespawnAllCubes()
    print("BP_GameManager_C: 큐브 재스폰")
    self:SpawnAllCubes()
end

-- 현재 게임 상태 조회 함수들
function BP_GameManager_C:GetCollectedCubes()
    return self.CollectedCubes
end

function BP_GameManager_C:GetTotalCubes()
    return self.TotalCubes
end

function BP_GameManager_C:GetProgress()
    return self.CollectedCubes / self.TotalCubes
end

function BP_GameManager_C:IsGameCompleted()
    return self.GameCompleted
end

-- 디버그용 함수들
function BP_GameManager_C:AddTestCube()
    print("BP_GameManager_C: 테스트 큐브 추가")
    self:OnCubeCollected(nil)
end

function BP_GameManager_C:PrintGameStatus()
    print(string.format("BP_GameManager_C: 게임 상태 - 수집: %d/%d, 완료: %s", 
          self.CollectedCubes, self.TotalCubes, tostring(self.GameCompleted)))
end

return BP_GameManager_C