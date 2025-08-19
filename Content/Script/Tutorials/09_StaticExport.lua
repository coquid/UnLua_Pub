--[[ 💾
    설명: 정적 익스포트를 통한 C++ 객체 사용 예제

    이 예제의 C++ 소스 코드:
    \Source\TPSProject\TutorialObject.cpp
]]--

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local msg =
        [[

    —— 이 예제는 "Content/Script/Tutorials.09_StaticExport.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)
    
    local tutorial = UE.FTutorialObject("튜토리얼")
    msg = string.format("tutorial -> %s\n\ntutorial:GetTitle() -> %s", tostring(tutorial), tutorial:GetTitle())
    Screen.Print(msg)
end

return M
