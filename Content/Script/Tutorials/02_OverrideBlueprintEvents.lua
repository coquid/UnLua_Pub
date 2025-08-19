--[[ 🛠️
    설명: 블루프린트 이벤트를 오버라이드할 때는 반환되는 table에 Receive{EventName}을 선언하기만 하면 됩니다.

    예시:
    function M:ReceiveBeginPlay()
    end

    블루프린트 이벤트 외에도 {FunctionName}을 직접 선언하여 Function을 오버라이드할 수 있습니다.
    오버라이드된 블루프린트 Function을 호출해야 하는 경우, self.Overridden.{FunctionName}(self, ...)을 통해 접근할 수 있습니다.

    예시:
    function M:SayHi(name)
        self.Overridden.SayHi(self, name)
    end

    주의: 여기서 self.Overridden:SayHi(name)으로 쓸 수 없습니다.
]] --

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local msg = self:SayHi("낯선 사람")
    Screen.Print(msg)
end

function M:SayHi(name)
    local origin = self.Overridden.SayHi(self, name)
    return origin .. "\n\n" ..
        [[이제 우리는 서로 친해졌습니다. 이것은 Lua에서 보내는 인사입니다.

        —— 이 예제는 "Content/Script/Tutorials.02_OverrideBlueprintEvents.lua"에서 가져왔습니다.
    ]]
end

return M
