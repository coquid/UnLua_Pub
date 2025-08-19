--[[ 📦
    설명: 네이티브 컸테이너를 생성할 때는 일반적으로 매개변수 타입을 지정하여 컸테이너에 저장될 데이터 타입을 결정해야 합니다.
    
    예시:
    local array = TArray({ElementType})
    local set = TSet({ElementType})
    local map = TMap({KeyType}, {ValueType})

    매개변수 타입    예시             실제 타입
    boolean        true             Boolean
    number         0                Interger
    string         ""               String
    table          FVector          Vector
    userdata       FVector(1,1,1)   Vector

    생성 완료 후, 기존 네이티브 컸테이너 타입과 동일한 방식으로 사용할 수 있습니다. 더 많은 인터페이스는 소스 코드를 참조하세요:
    TArray      Plugins\UnLua\Source\UnLua\Private\BaseLib\LuaLib_Array.cpp
    TSet        Plugins\UnLua\Source\UnLua\Private\BaseLib\LuaLib_Set.cpp
    TMap        Plugins\UnLua\Source\UnLua\Private\BaseLib\LuaLib_Map.cpp
]] --

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

local function print_intro()
    local msg =
        [[
다음 키를 사용하여 각 예제를 실행하고 콘솔에서 출력을 확인하세요:

숫자 1: TArray
숫자 2: TSet
숫자 3: TMap

—— 이 예제는 "Content/Script/Tutorials.06_NativeContainers.lua"에서 가져왔습니다.
]] ..
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    Screen.Print(msg)
end

function M:ReceiveBeginPlay()
    print_intro()
end

local function dump_array(array)
    local ret = {}
    for i = 1, array:Length() do
        table.insert(ret, array:Get(i))
    end
    return "[" .. table.concat(ret, ",") .. "]"
end

function M:One_Pressed()
    print_intro()
    Screen.Print("TArray")

    print("========== TArray ==========")
    print("주의: 인덱스는 1부터 시작합니다")

    local array = UE.TArray(0)
    print("New:          ", dump_array(array))

    array:Add(1)
    array:Add(2)
    array:Add(3)
    array:Add(3)
    print("Add:          ", dump_array(array))

    local index = array:AddUnique(1)
    print("AddUnique(1): ", dump_array(array), "Returns:", index)

    array:Remove(1)
    print("Remove(1):    ", dump_array(array))

    array:RemoveItem(3)
    print("RemoveItem(3):", dump_array(array))

    array:Insert(4, 1)
    print("Insert(1, 4): ", dump_array(array))

    array:Shuffle()
    print("Shuffle():    ", dump_array(array))

    array:Clear()
    print("Clear:        ", dump_array(array))
end

local function dump_set(set)
    local array = set:ToArray()
    local ret = {}
    for i = 1, array:Length() do
        table.insert(ret, array:Get(i))
    end
    return "(" .. table.concat(ret, ",") .. ")"
end

function M:Two_Pressed()
    print_intro()
    Screen.Print("TSet")

    print("========== TSet ==========")
    local set = UE.TSet(0)
    print("New:          ", dump_set(set))

    set:Add(1)
    set:Add(1)
    set:Add(2)
    set:Add(2)
    set:Add(3)
    set:Add(3)
    print("Add:          ", dump_set(set))
    print("Length:       ", set:Length())
    print("Contains(3):  ", set:Contains(3))

    set:Clear()
    print("Clear:        ", dump_set(set))
end

local function dump_map(map)
    local ret = {}
    local keys = map:Keys()
    for i = 1, keys:Length() do
        local key = keys:Get(i)
        local value = map:Find(key)
        table.insert(ret, key .. ":" .. tostring(value))
    end
    return "{" .. table.concat(ret, ",") .. "}"
end

function M:Three_Pressed()
    print_intro()
    Screen.Print("TMap")

    print("========== TMap ==========")
    local map = UE.TMap(0, true)
    print("New:          ", dump_map(map))

    map:Add(1, true)
    map:Add(2, false)
    map:Add(3, true)
    print("Add:          ", dump_map(map))

    map:Remove(2)
    print("Remove(2):    ", dump_map(map))

    local value = map:Find(3)
    print("Find(3):      ", dump_map(map), "Returns:", value)

    map:Clear()
    print("Clear:        ", dump_map(map))
end

return M
