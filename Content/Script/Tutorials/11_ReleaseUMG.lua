--[[ 🗑️
    설명: UMG 객체 해제 과정

    UMG 객체의 해제 흐름:
    1. self:Release() 호출로 C++측 LuaTable 참조 해제
    2. Lua측에서 LuaTable의 다른 참조가 없는지 확인하여 Lua GC 트리거
    3. C++측이 UObject_Delete 콜백을 받아 UMG의 C++측 참조 해제
    4. C++측에서 UMG의 다른 참조가 없는지 확인하여 UE GC 트리거

    팁: 💡

    콘솔 명령으로 객체와 클래스의 참조 상황 확인:
    
    지정된 클래스의 참조 목록 보기: Obj List Class=ReleaseUMG_Root_C
    지정된 객체의 참조 체인 보기: Obj Refs Name=ReleaseUMG_Root_C_0
]] --

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

local function print_intro()
    local msg =
        [[
다음 키를 사용하여 강제 가비지 컬렉션을 실행하세요:

C: 강제 C++ GC
L: 강제 Lua GC

—— 이 예제는 "Content/Script/Tutorials.11_ReleaseUMG.lua"에서 가져왔습니다.
]]
    Screen.Print(msg)
end

function M:ReceiveBeginPlay()
    local widget_class = UE.UClass.Load("/Game/Tutorials/11_ReleaseUMG/ReleaseUMG_Root.ReleaseUMG_Root_C")
    local widget_root = NewObject(widget_class, self)
    widget_root:AddToViewport()

    print_intro()
end

function M:L_Pressed()
    collectgarbage("collect")
    Screen.Print('collectgarbage("collect")')
end

function M:C_Pressed()
    UE.UKismetSystemLibrary.CollectGarbage()
    Screen.Print("UKismetSystemLibrary.CollectGarbage()")
end

return M
