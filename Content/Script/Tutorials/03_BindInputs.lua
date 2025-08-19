--[[ ⌨️
    설명: 키나 Action을 모니터링해야 할 때는 반환되는 table에 {KeyName}_Pressed / {KeyName}_Released를 선언하기만 하면 됩니다.

    예시:
    function M:SpaceBar_Pressed()
    end

    {KeyName}은 EKeys 문서를 참조하세요:
    https://docs.unrealengine.com/4.26/en-US/API/Runtime/InputCore/EKeys/
    
    또는 소스 코드:
    \Engine\Source\Runtime\InputCore\Classes\InputCoreTypes.h
]]--

local Screen = require "Tutorials.Screen"

local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local msg =
        [[
    다음 입력들을 시도해 보세요:

    알파벳, 숫자, 숫자 패드, 방향키, 마우스

    —— 이 예제는 "Content/Script/Tutorials.03_BindInputs.lua"에서 가져왔습니다.
    ]]
    Screen.Print(msg)
end

local function SetupKeyBindings()
    local key_names = {
        -- 알파벳
        "A", "B", --[["C",]] "D", "E","F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", --[["V", ]] "W", "X", "Y", "Z",
        -- 숫자
        "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
        -- 숫자 패드
        "NumPadOne", "NumPadTwo", "NumPadThree", "NumPadFour", "NumPadFive", "NumPadSix", "NumPadSeven", "NumPadEight", "NumPadNine",
        -- 방향키
        "Up", "Down", "Left", "Right",
        -- ProjectSettings -> Engine - Input -> Action Mappings
        "Fire", "Aim",
    }
    
    for _, key_name in ipairs(key_names) do
        M[key_name .. "_Pressed"] = function(self, key)
            Screen.Print(string.format("%s를 눌렀습니다", key.KeyName))
        end
    end
end

local function SetupAxisBindings()
    -- ProjectSettings -> Engine - Input -> Axis Mappings
    local axis_names = {
        "MoveForward", "MoveRight", "Turn", "LookUp", "LookUpRate", "TurnRate"
    }
    for _, axis_name in ipairs(axis_names) do
        M[axis_name] = function(self, value)
            if value ~= 0 then
                Screen.Print(string.format("%s(%f)", axis_name, value))
            end
        end
    end
end

SetupKeyBindings()
SetupAxisBindings()

--[[ 🎮
    UnLua.Input.BindXXX 인터페이스를 사용하면 더 세밀한 입력 바인딩 제어를 구현할 수 있습니다.

    자세한 내용은 다음을 참조하세요:
    UnLua\Plugins\UnLua\Content\Script\UnLua\Input.lua
]]

local BindKey = UnLua.Input.BindKey

BindKey(M, "C", "Pressed", function(self, Key)
    Screen.Print("C를 눌렀습니다")
end)

BindKey(M, "C", "Pressed", function(self, Key)
    Screen.Print("복사")
end, { Ctrl = true })

BindKey(M, "V", "Pressed", function(self, Key)
    Screen.Print("V를 눌렀습니다")
end)

BindKey(M, "V", "Pressed", function(self, Key)
    Screen.Print("붙여넣기")
end, { Ctrl = true })

return M
