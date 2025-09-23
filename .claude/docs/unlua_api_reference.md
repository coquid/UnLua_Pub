# 📖 UnLua API Reference

## Core Functions

### Actor Lifecycle
```lua
-- 초기화
function M:Initialize()
    -- Actor 생성 직후, BeginPlay 이전
end

function M:ReceiveBeginPlay()
    -- BeginPlay 이벤트
    self.Overridden.ReceiveBeginPlay(self)  -- 연결된 블루프린트 호출
    self.Super:ReceiveBeginPlay() -- 부모 Lua 호출
end

function M:ReceiveEndPlay(Reason)
    -- EndPlay 이벤트
end

function M:ReceiveDestroyed()
    -- Actor 파괴 직전
end
```

### Property Access
```lua
-- 프로퍼티 읽기/쓰기
local Health = self.Health  -- BlueprintReadWrite 프로퍼티
self.Health = 100

-- 컴포넌트 접근
local Mesh = self.MeshComponent
local AllComps = self:GetComponents()

-- (c++ 컴포넌트 찾기)
local Comp = self:GetComponentByClass(UE.UStaticMeshComponent)
-- (blueprint 컴포넌트 찾기)
local BlueprintClass = UE.UClass.Load("/Game/{Path}/BP_{Name}.BP_{Name}_C")
local BPComp = self:GetComponentByClass(BlueprintClass)
```

### Function Calls
```lua
-- Blueprint 함수 호출
self:MyBlueprintFunction(param1, param2)

-- Static 함수 호출
UE.UKismetSystemLibrary.PrintString(self, "Hello")
UE.UGameplayStatics.GetPlayerController(self, 0)

-- RPC 호출 (Blueprint에서 정의된 경우)
self:ServerRPC(data)
self:MulticastRPC(data)
```

## Timer System

## Event Binding
```lua
-- Delegate 바인딩
self.OnActorBeginOverlap:Add(self, self.OnOverlap)
self.OnActorEndOverlap:Remove(self, self.OnOverlap)

-- Event Dispatcher 바인딩
self.MyDispatcher:Add(self, function(self, ...)
    print("Event fired!")
end)
```

## Input Handling
```lua
-- Input 바인딩 (Enable Input 필요)
function M:SetupPlayerInputComponent(InputComponent)
    InputComponent:BindAction("Jump", UE.EInputEvent.IE_Pressed, self, self.Jump)
    InputComponent:BindAxis("MoveForward", self, self.MoveForward)
end

function M:Jump()
    -- Jump 로직
end

function M:MoveForward(Value)
    -- Movement 로직
end
```

## World & Gameplay
```lua
-- World 접근
local World = self:GetWorld()
local GameMode = World:GetAuthGameMode()
local GameState = World:GetGameState()

-- 플레이어 접근
local PC = UE.UGameplayStatics.GetPlayerController(World, 0)
local Pawn = PC:GetPawn()
local PlayerState = PC:GetPlayerState()

-- Actor 스폰
local SpawnParams = UE.FActorSpawnParameters()
local NewActor = World:SpawnActor(UE.ABP_MyActor, Transform, SpawnParams)
```

## Collision & Physics
```lua
-- Line Trace
local Start = self:GetActorLocation()
local End = Start + self:GetActorForwardVector() * 1000
local HitResult = UE.FHitResult()
local bHit = UE.UKismetSystemLibrary.LineTraceSingle(
    World,
    Start, End,
    UE.ETraceTypeQuery.MyTraceType, -- DefaultEngine.ini 에 정의된 이름 그대로 사용 가능.
    false,  -- bTraceComplex
    {self}, -- ActorsToIgnore
    UE.EDrawDebugTrace.ForDuration,
    HitResult,
    true    -- bIgnoreSelf
)

-- Overlap 체크
local OverlappingActors = {}
self:GetOverlappingActors(OverlappingActors, UE.APawn)
```

## Data Tables & Assets
```lua
-- DataTable 읽기
local DataTable = UE.UObject.Load("/Game/Data/DT_Items")
local Row = UE.UDataTableFunctionLibrary.GetDataTableRow(
    DataTable, 
    "ItemID_001", 
    "ContextString"
)

-- Asset 로드
local Asset = UE.UObject.Load("/Game/Materials/M_Metal")
self.MeshComponent:SetMaterial(0, Asset)
```

## Utility Functions
```lua
-- 로깅
UE.UKismetSystemLibrary.PrintString(World, "Debug Message", true, true, UE.FLinearColor(1, 0, 0, 1), 2.0)
print("Lua print:", value)

-- 타입 체크
if self:IsA(UE.APawn) then
    -- Pawn 타입
end

-- 유효성 체크
if UE.UKismetSystemLibrary.IsValid(Actor) then
    -- 유효한 Actor
end

-- 거리 계산
local Distance = UE.UKismetMathLibrary.Vector_Distance(
    self:GetActorLocation(),
    Target:GetActorLocation()
)
```
