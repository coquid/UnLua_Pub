--[[ 📂
    설명: FUnLuaDelegates::CustomLoadLuaFile을 바인딩하여 사용자 정의 Lua 로더를 구현할 수 있습니다.

    참고를 위해 두 가지 일반적인 구현 방식을 시연합니다:

    방식 1: 고정된 검색 경로, 더 나은 성능
    방식 2: package.path를 통해 검색, 더 유연함

    이 예제의 C++ 소스 코드:
    Source\TPSProject\TutorialBlueprintFunctionLibrary.cpp
]]

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

local function print_intro()
    local msg =
        [[

—— 이 예제는 "Content/Script/Tutorials.12_CustomLoader.lua"에서 가져왔습니다.
]]
    Screen.Print(msg)
end

function M:ReceiveBeginPlay()
    print_intro()

    UE.UTutorialBlueprintFunctionLibrary.SetupCustomLoader(1)
    Screen.Print(string.format("FromCustomLoader1:%s", require("Tutorials")))
    
    package.loaded["Tutorials"] = nil

    package.path = package.path .. ";./?/Index.lua"
    UE.UTutorialBlueprintFunctionLibrary.SetupCustomLoader(2)
    Screen.Print(string.format("FromCustomLoader2:%s", require("Tutorials")))

    UE.UTutorialBlueprintFunctionLibrary.SetupCustomLoader(0)
end

return M
