--[[ 🌐
    설명: 네트워크 리플리케이션 예제
    
    {함수명}_RPC를 사용하여 블루프린트의 RPC 함수 구현을 오버라이드할 수 있습니다.
    OnRep_{변수명}을 사용하여 블루프린트의 변수 동기화 메시지 처리를 오버라이드할 수 있습니다.

    블루프린트 예제:
    Content/Tutorials/10_Replications/ChatCharacter.uasset

    스크립트 예제:
    Content/Script/Tutorials/ChatCharacter.lua
]] --

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    if not self:HasAuthority() then
        return
    end
    local msg = [[

    멀티플레이어 모드로 예제를 실행해 보세요!

    방향키: 이동
    스페이스바: 점프

    —— 이 예제는 "Content/Script/Tutorials.10_Replications.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)
end

return M
