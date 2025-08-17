-- @type WBP_GameHUD_C
-- 캐주얼 큐브 수집 게임 - 게임 HUD 위젯
-- 수집한 큐브 개수 및 게임 진행 상황 표시

local WBP_GameHUD_C = Class()

function WBP_GameHUD_C:Construct()
    self:FindGameManager()
    self:UpdateDisplay()
end

function WBP_GameHUD_C:FindGameManager()
    -- 게임 매니저 찾기
    local World = self:GetWorld()
    if World and World.GameManagerInstance then
        self.GameManager = World.GameManagerInstance
        print("WBP_GameHUD_C: GameManager 참조 설정 완료")
        
        -- GameManager에 UI 참조 등록
        if self.GameManager.SetHUDWidget then
            self.GameManager:SetHUDWidget(self)
        end
    else
        print("WBP_GameHUD_C: GameManager를 찾을 수 없음 - 대체 방법 시도")
        self:FindGameManagerAlternative()
    end
end

function WBP_GameHUD_C:FindGameManagerAlternative()
    -- 모든 액터를 순회해서 GameManager 찾기
    local World = self:GetWorld()
    if World then
        local AllActors = UE.UGameplayStatics.GetAllActorsOfClass(World, UE.AActor)
        for i = 1, AllActors:Length() do
            local Actor = AllActors:Get(i)
            if Actor and Actor:GetName():find("GameManager") then
                print("WBP_GameHUD_C: GameManager 발견:", Actor:GetName())
                self.GameManager = Actor
                
                -- GameManager에 UI 참조 등록
                if Actor.SetHUDWidget then
                    Actor:SetHUDWidget(self)
                end
                return
            end
        end
        print("WBP_GameHUD_C: GameManager를 찾을 수 없음")
    end
end

-- 게임 매니저에서 호출되는 UI 업데이트 함수
function WBP_GameHUD_C:UpdateScore(CollectedCubes, TotalCubes)
    self.CollectedCubes = CollectedCubes or 0
    self.TotalCubes = TotalCubes or 10
    
    print(string.format("WBP_GameHUD_C: UI 업데이트 - %d/%d 큐브", self.CollectedCubes, self.TotalCubes))
    
    -- UI 텍스트 업데이트
    self:UpdateScoreText()
    self:UpdateProgressBar()
end

function WBP_GameHUD_C:UpdateScoreText()
    -- ScoreText 위젯이 있다면 업데이트 (Blueprint에서 생성해야 함)
    if self.ScoreText then
        local ScoreString = string.format("큐브: %d/%d", self.CollectedCubes, self.TotalCubes)
        self.ScoreText:SetText(ScoreString)
        print("WBP_GameHUD_C: 점수 텍스트 업데이트:", ScoreString)
    else
        print("WBP_GameHUD_C: ScoreText 위젯을 찾을 수 없음 (Blueprint에서 생성 필요)")
    end
end

function WBP_GameHUD_C:UpdateProgressBar()
    -- ProgressBar 위젯이 있다면 업데이트
    if self.ProgressBar then
        local Progress = 0
        if self.TotalCubes > 0 then
            Progress = self.CollectedCubes / self.TotalCubes
        end
        self.ProgressBar:SetPercent(Progress)
        print(string.format("WBP_GameHUD_C: 진행률 바 업데이트: %.1f%%", Progress * 100))
    else
        print("WBP_GameHUD_C: ProgressBar 위젯을 찾을 수 없음 (Blueprint에서 생성 필요)")
    end
end

-- 현재 상태로 UI 업데이트 (게임 매니저에서 데이터 가져오기)
function WBP_GameHUD_C:UpdateDisplay()
    if self.GameManager then
        local CollectedCubes = self.GameManager:GetCollectedCubes()
        local TotalCubes = self.GameManager:GetTotalCubes()
        self:UpdateScore(CollectedCubes, TotalCubes)
    else
        print("WBP_GameHUD_C: GameManager가 없어 UI를 업데이트할 수 없음")
        -- 기본값으로 표시
        self:UpdateScore(0, 10)
    end
end

-- 게임 완료 시 호출되는 함수
function WBP_GameHUD_C:OnGameCompleted()
    print("WBP_GameHUD_C: 게임 완료!")
    
    -- 완료 텍스트 표시
    if self.CompletionText then
        self.CompletionText:SetText("🎉 모든 큐브 수집 완료!")
        self.CompletionText:SetVisibility(UE.ESlateVisibility.Visible)
    end
    
    -- 진행률 바를 100%로 설정
    if self.ProgressBar then
        self.ProgressBar:SetPercent(1.0)
    end
end

-- 게임 재시작 시 UI 리셋
function WBP_GameHUD_C:OnGameRestart()
    print("WBP_GameHUD_C: 게임 재시작 - UI 리셋")
    
    -- 완료 텍스트 숨기기
    if self.CompletionText then
        self.CompletionText:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    
    -- UI 초기 상태로 리셋
    self:UpdateScore(0, 10)
end

-- Tick 이벤트 (필요시 실시간 업데이트)
function WBP_GameHUD_C:Tick(MyGeometry, InDeltaTime)
    -- 현재는 필요 없음, 이벤트 기반으로 업데이트
end

-- 디버그용 함수들
function WBP_GameHUD_C:PrintUIStatus()
    print("WBP_GameHUD_C: UI 상태:")
    print("  - GameManager:", self.GameManager and "연결됨" or "없음")
    print("  - ScoreText:", self.ScoreText and "존재함" or "없음")
    print("  - ProgressBar:", self.ProgressBar and "존재함" or "없음")
    print("  - 현재 점수:", string.format("%d/%d", self.CollectedCubes or 0, self.TotalCubes or 10))
end

function WBP_GameHUD_C:TestUIUpdate()
    print("WBP_GameHUD_C: UI 테스트 업데이트")
    self:UpdateScore(5, 10)
end

return WBP_GameHUD_C