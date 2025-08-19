--[[ 📖
    설명: 블루프린트에서 UnLuaInterface 인터페이스를 구현하고, GetModuleName을 통해 스크립트 경로를 지정하면 Lua에 바인딩됩니다.

    예시:
    이 스크립트는 "Content/Tutorials/01_HelloWorld/HelloWorld.map"의 레벨 블루프린트에 바인딩되었습니다.
]]

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

-- 🚀 Lua에 바인딩된 모든 객체는 초기화 시 Initialize 인스턴스 메서드를 호출합니다
function M:Initialize()
    local msg = [[
    Hello World!

    —— 이 예제는 "Content/Script/Tutorials/01_HelloWorld.lua"에서 가져왔습니다
    ]]
    print(msg)
    Screen.Print(msg)
end

return M
