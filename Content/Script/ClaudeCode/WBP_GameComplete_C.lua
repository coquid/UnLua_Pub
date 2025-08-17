-- @type WBP_GameComplete_C
-- 캐주얼 큐브 수집 게임 - 게임 완료 화면 위젯
-- 게임 완료 시 축하 메시지, 점수, 재시작 버튼 표시

local WBP_GameComplete_C = Class()

function WBP_GameComplete_C:Construct()
    
    -- 버튼 이벤트 바인딩
    if self.RestartButton then
        self.RestartButton.OnClicked:Add(self, self.OnRestartButtonClicked)
    end
    if self.MainMenuButton then
        self.MainMenuButton.OnClicked:Add(self, self.OnMainMenuButtonClicked)
    end
    
    -- 게임 매니저 참조 찾기
    self:FindGameManager()
    
    -- 초기 설정
    self:SetupUI()
end

function WBP_GameComplete_C:Destruct()
    
    -- 델리게이트 정리 (메모리 누수 방지)
    if self.RestartButton then
        self.RestartButton.OnClicked:Remove(self, self.OnRestartButtonClicked)
    end
    if self.MainMenuButton then
        self.MainMenuButton.OnClicked:Remove(self, self.OnMainMenuButtonClicked)
    end
end

function WBP_GameComplete_C:FindGameManager()
    -- 게임 매니저 찾기
    local World = self:GetWorld()
    if World and World.GameManagerInstance then
        self.GameManager = World.GameManagerInstance
        print("WBP_GameComplete_C: GameManager 참조 설정 완료")
        
        -- GameManager에 Victory 위젯 참조 등록
        if self.GameManager.SetVictoryWidget then
            self.GameManager:SetVictoryWidget(self)
            print("WBP_GameComplete_C: GameManager에 Victory 위젯 등록 완료")
        end
    else
        print("WBP_GameComplete_C: GameManager를 찾을 수 없음 - 대체 방법 시도")
        self:FindGameManagerAlternative()
    end
end

function WBP_GameComplete_C:FindGameManagerAlternative()
    -- 모든 액터를 순회해서 GameManager 찾기
    local World = self:GetWorld()
    if World then
        local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.AActor)
        for i = 1, AllActors:Length() do
            local Actor = AllActors:Get(i)
            if Actor and Actor:GetName():find("GameManager") then
                print("WBP_GameComplete_C: GameManager 발견:", Actor:GetName())
                self.GameManager = Actor
                
                -- GameManager에 Victory 위젯 참조 등록
                if Actor.SetVictoryWidget then
                    Actor:SetVictoryWidget(self)
                    print("WBP_GameComplete_C: GameManager에 Victory 위젯 등록 완료")
                end
                return
            end
        end
        print("WBP_GameComplete_C: GameManager를 찾을 수 없음")
    end
end

function WBP_GameComplete_C:SetupUI()
    -- 초기 상태 설정
    print("WBP_GameComplete_C: UI 초기 설정")
    
    if self.RestartButton then
        print("WBP_GameComplete_C: 재시작 버튼 발견됨")
    else
        print("WBP_GameComplete_C: RestartButton 위젯을 찾을 수 없음 (Blueprint에서 생성 필요)")
    end
    
    if self.MainMenuButton then
        print("WBP_GameComplete_C: 메인 메뉴 버튼 발견됨")
    end
end

-- 버튼 클릭 이벤트 핸들러들 (올바른 델리게이트 바인딩 방식)

-- 게임 완료 화면 표시
function WBP_GameComplete_C:ShowVictory(CollectedCubes, TotalCubes, CompletionTime)
    self.CollectedCubes = CollectedCubes or 10
    self.TotalCubes = TotalCubes or 10
    self.CompletionTime = CompletionTime or 0
    
    -- 축하 메시지 업데이트
    self:UpdateVictoryMessage()
    
    -- 점수 표시 업데이트
    self:UpdateScoreDisplay()
    
    -- 완료 시간 표시 (나중에 구현)
    self:UpdateTimeDisplay()
    
    -- 마우스 커서 표시 및 UI 모드로 전환
    self:EnableUIMode()
    
    -- 위젯을 화면에 표시
    self:SetVisibility(UE.ESlateVisibility.Visible)
end

-- UI 모드 활성화 (마우스 커서 표시)
function WBP_GameComplete_C:EnableUIMode()
    local PlayerController = UE.UGameplayStatics.GetPlayerController(self:GetWorld(), 0)
    if PlayerController then
        PlayerController.bShowMouseCursor = true
    end
end

function WBP_GameComplete_C:UpdateVictoryMessage()
    -- 축하 메시지 텍스트 업데이트
    if self.VictoryText then
        local VictoryMessage = "🎉 축하합니다!\n모든 큐브를 수집했습니다!"
        self.VictoryText:SetText(VictoryMessage)
        print("WBP_GameComplete_C: 승리 메시지 업데이트")
    else
        print("WBP_GameComplete_C: VictoryText 위젯을 찾을 수 없음 (Blueprint에서 생성 필요)")
    end
end

function WBP_GameComplete_C:UpdateScoreDisplay()
    -- 점수 표시 업데이트
    if self.ScoreText then
        local ScoreMessage = string.format("수집한 큐브: %d/%d", self.CollectedCubes, self.TotalCubes)
        self.ScoreText:SetText(ScoreMessage)
        print("WBP_GameComplete_C: 점수 표시 업데이트:", ScoreMessage)
    else
        print("WBP_GameComplete_C: ScoreText 위젯을 찾을 수 없음 (Blueprint에서 생성 필요)")
    end
end

function WBP_GameComplete_C:UpdateTimeDisplay()
    -- 완료 시간 표시 (나중에 구현)
    if self.TimeText and self.CompletionTime > 0 then
        local TimeMessage = string.format("완료 시간: %.1f초", self.CompletionTime)
        self.TimeText:SetText(TimeMessage)
        print("WBP_GameComplete_C: 시간 표시 업데이트:", TimeMessage)
    end
end

-- 재시작 버튼 클릭 이벤트
function WBP_GameComplete_C:OnRestartButtonClicked()
    
    -- 완전한 레벨 재시작 (레벨 새로 로드)
    self:RestartLevel()
end

-- 메인 메뉴 버튼 클릭 이벤트 (선택사항)
function WBP_GameComplete_C:OnMainMenuButtonClicked()
    print("WBP_GameComplete_C: 메인 메뉴 버튼 클릭됨")
    
    -- 메인 메뉴로 이동 (나중에 구현)
    self:GoToMainMenu()
end

function WBP_GameComplete_C:RestartLevel()
    -- 여러 방식으로 레벨 재시작 시도
    print("WBP_GameComplete_C: 레벨 재시작 시작")
    
    local World = self:GetWorld()
    if World then
        -- 방법 1: RestartLevel 콘솔 명령어 사용
        UE.UKismetSystemLibrary.ExecuteConsoleCommand(World, "RestartLevel")
        print("WBP_GameComplete_C: RestartLevel 콘솔 명령어 실행")
        
        -- 방법 2가 필요하면 추가할 수 있음
        -- local CurrentLevel = UE.UGameplayStatics.GetCurrentLevelName(World)
        -- UE.UGameplayStatics.OpenLevel(World, CurrentLevel)
    else
        print("WBP_GameComplete_C: World를 찾을 수 없음")
    end
end

function WBP_GameComplete_C:GoToMainMenu()
    print("WBP_GameComplete_C: 메인 메뉴로 이동 (TODO: 메인 메뉴 레벨 구현)")
    
    -- 나중에 메인 메뉴 레벨이 있을 때 구현
    -- local World = self:GetWorld()
    -- UE.UGameplayStatics.OpenLevel(World, "MainMenu")
end

-- 승리 화면 숨기기
function WBP_GameComplete_C:HideVictoryScreen()
    print("WBP_GameComplete_C: 승리 화면 숨기기")
    
    -- 게임 모드로 복구 (마우스 커서 숨기고 플레이어 조작 활성화)
    self:RestoreGameMode()
    
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

-- 게임 모드 복구
function WBP_GameComplete_C:RestoreGameMode()
    local PlayerController = UE.UGameplayStatics.GetPlayerController(self:GetWorld(), 0)
    if PlayerController then
        PlayerController.bShowMouseCursor = false
    end
end

-- 게임 매니저에서 호출되는 함수 (자동 표시)
function WBP_GameComplete_C:OnGameCompleted()
    print("WBP_GameComplete_C: 게임 완료 이벤트 수신")
    
    -- 게임 매니저에서 데이터 가져와서 표시
    if self.GameManager then
        local CollectedCubes = self.GameManager:GetCollectedCubes()
        local TotalCubes = self.GameManager:GetTotalCubes()
        self:ShowVictory(CollectedCubes, TotalCubes, 0)
    else
        -- 기본값으로 표시
        self:ShowVictory(10, 10, 0)
    end
end

-- 디버그용 함수들
function WBP_GameComplete_C:TestVictoryScreen()
    print("WBP_GameComplete_C: 승리 화면 테스트")
    self:ShowVictory(10, 10, 42.5)
end

function WBP_GameComplete_C:PrintUIStatus()
    print("WBP_GameComplete_C: UI 상태:")
    print("  - GameManager:", self.GameManager and "연결됨" or "없음")
    print("  - VictoryText:", self.VictoryText and "존재함" or "없음")
    print("  - ScoreText:", self.ScoreText and "존재함" or "없음")
    print("  - RestartButton:", self.RestartButton and "존재함" or "없음")
    print("  - 가시성:", self:GetVisibility())
end

return WBP_GameComplete_C