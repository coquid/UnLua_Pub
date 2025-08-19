--[[ 🔗
    설명: 델리게이트 네이티브 인터페이스를 호출하여 UI 이벤트를 모니터링할 수 있습니다.

    팁: 💡
    바인딩/언바인딩을 쌍으로 사용하는 것은 코드 작성의 좋은 습관입니다.
]]--

local FLinearColor = UE.FLinearColor

local M = UnLua.Class()

function M:Construct()
    self.ClickMeButton.OnClicked:Add(self, self.OnButtonClicked)
    self.ClickMeCheckBox.OnCheckStateChanged:Add(self, self.OnCheckBoxToggled)

    -- 블루프린트의 Set Timer by Event와 동일합니다
    self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({ self, self.OnTimer }, 1, true)
end

function M:OnButtonClicked()
    local r = math.random()
    local g = math.random()
    local b = math.random()

    self.ClickMeButton:SetBackgroundColor(FLinearColor(r, g, b, 1))
end

function M:OnCheckBoxToggled(on)
    if on then
        self.CheckBoxText:SetText("선택됨")
    else
        self.CheckBoxText:SetText("선택 안됨")
    end
end

function M:OnTimer()
    local seconds = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self)
    self.GameTimeTextBlock:SetText(string.format("게임 시간: %d초", math.floor(seconds)))
end

function M:Destruct()
    -- UMG가 소멸될 때 바인딩된 델리게이트를 가능한 한 정리하세요. 정리하지 않으면 맵 전환 시 자동으로 정리됩니다.
    self.ClickMeButton.OnClicked:Remove(self, self.OnButtonClicked)
    self.ClickMeCheckBox.OnCheckStateChanged:Remove(self, self.OnCheckBoxToggled)

    -- 블루프린트의 Clear and Invalidate Timer by Handle과 동일합니다
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TimerHandle)
end

return M
