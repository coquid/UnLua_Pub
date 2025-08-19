--[[ ⏱️
    설명: Lua 코루틴에서 UE4의 Latent 함수를 편리하게 사용하여 지연 실행 효과를 구현할 수 있습니다.
]] --

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

local function run(self, name)
    Screen.Print(string.format("코루틴 %s: 시작", name))
    for i = 1, 5 do
        UE.UKismetSystemLibrary.Delay(self, 1)
        Screen.Print(string.format("코루틴 %s: %d", name, i))
    end
    Screen.Print(string.format("코루틴 %s: 종료", name))
end

function M:ReceiveBeginPlay()
    local msg = [[
    —— 이 예제는 "Content/Script/Tutorials.07_CallLatentFunction.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)

    coroutine.resume(coroutine.create(run), self, "A")
    coroutine.resume(coroutine.create(run), self, "B")
end

return M
