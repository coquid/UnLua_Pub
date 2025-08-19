--[[ ⚡
    설명: UnLuaInterface를 구현하는 정적 바인딩 방식 외에도, 런타임에 동적으로 객체를 Lua에 바인딩할 수 있습니다.

    Actor 클래스의 경우, SpawnActor 인터페이스를 사용할 수 있습니다. 예시:
    World:SpawnActor(SpawnClass, Transform, AlwaysSpawn, self, self, "Tutorials.GravitySphereActor")

    비-Actor 클래스의 경우, NewObject 인터페이스를 사용할 수 있습니다. 예시:
    NewObject(WidgetClass, self, nil, "Tutorials.IconWidget")

    주의: 어떤 바인딩 방식이든 스크립트 파일 경로를 지정해야 합니다. 이는 {프로젝트 디렉터리}/Content/Script 하위의 상대 경로입니다.
]]--

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local msg =
        [[
    마우스 왼쪽 버튼: 동적 바인딩된 Actor 생성

    마우스 오른쪽 버튼: 동적 바인딩된 Object 생성

    —— 이 예제는 "Content/Script/Tutorials.04_DynamicBinding.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)
end

function M:LeftMouseButton_Pressed()
    local World = self:GetWorld()
    local SpawnClass = self.SpawnClass
    local Transform = self.SpawnPointActor:GetTransform()
    local AlwaysSpawn = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    World:SpawnActor(SpawnClass, Transform, AlwaysSpawn, self, self, "Tutorials.GravitySphereActor")
end

function M:RightMouseButton_Pressed()
    local WidgetClass = self.WidgetClass
    local img = NewObject(WidgetClass, self, nil, "Tutorials.IconWidget")
    img:AddToViewport()
    img:RandomPosition()
end

return M
