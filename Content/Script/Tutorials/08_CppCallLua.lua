--[[ 🔄
    설명: C++에서 Lua를 호출해야 할 경우, UnLua 모듈을 {프로젝트명}.Build.cs의 의존성 설정에 추가해야 합니다.

    Lua 네이티브 API에 접근해야 하는 경우, Lua 모듈도 추가해야 합니다.

    예시:
    PrivateDependencyModuleNames.AddRange(new string[]
    {
        "UnLua",
        "Lua",
    });

    이 예제의 C++ 소스 코드:
    Source\TPSProject\TutorialBlueprintFunctionLibrary.cpp
]]--

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local msg =
        [[

    —— 이 예제는 "Content/Script/Tutorials.08_CppCallLua.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)
    UE.UTutorialBlueprintFunctionLibrary.CallLuaByGlobalTable()
    Screen.Print("=================")
    UE.UTutorialBlueprintFunctionLibrary.CallLuaByFLuaTable()
end

function M.CallMe(a, b)
    local ret = a + b
    local msg = string.format("[Lua] C++에서 호출을 받았습니다. a=%f b=%f, 반환값=%f", a, b, ret)
    Screen.Print(msg)
    return ret
end

return M
