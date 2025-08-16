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
    
    print(string.format("BP_GameManager_C: 게임 초기화 완료 - 목표: %d개 큐브 수집", self.TotalCubes))
    
    -- 전역 게임 매니저 참조 설정 (다른 스크립트에서 접근 가능하도록)
    self:SetGlobalReference()
    
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
    print(string.format("BP_GameManager_C: 큐브 수집! (%d/%d)", self.CollectedCubes, self.TotalCubes))
    
    -- UI 업데이트
    self:UpdateUI()
    
    -- 승리 조건 확인
    if self.CollectedCubes >= self.TotalCubes then
        self:OnGameCompleted()
    end
end

function BP_GameManager_C:UpdateUI()
    -- UI 업데이트 (나중에 위젯 연결 시 구현)
    local ProgressText = string.format("수집한 큐브: %d/%d", self.CollectedCubes, self.TotalCubes)
    print("BP_GameManager_C: UI 업데이트:", ProgressText)
    
    -- 나중에 UI 위젯에 전달
    -- if self.GameHUDWidget then
    --     self.GameHUDWidget:UpdateScore(self.CollectedCubes, self.TotalCubes)
    -- end
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
    print("BP_GameManager_C: 승리 화면 표시 (TODO: UI 위젯 구현)")
    
    -- 나중에 UI 위젯 표시
    -- if self.VictoryWidget then
    --     self.VictoryWidget:ShowVictory(self.CollectedCubes, CompletionTime)
    -- end
end

-- 게임 재시작 함수 (나중에 구현)
function BP_GameManager_C:RestartGame()
    print("BP_GameManager_C: 게임 재시작")
    
    -- 게임 상태 리셋
    self.CollectedCubes = 0
    self.GameCompleted = false
    
    -- 큐브들 다시 스폰 (나중에 구현)
    self:RespawnAllCubes()
    
    -- UI 업데이트
    self:UpdateUI()
end

function BP_GameManager_C:RespawnAllCubes()
    print("BP_GameManager_C: 큐브 재스폰 (TODO: 큐브 스폰 시스템 구현)")
    -- 나중에 구현
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