# ⚠️ Known Issues & Workarounds

## 🔴 Critical Issues

### 1. Construction Script에서 Lua 호출 불가
**문제**: Blueprint의 Construction Script에서 Lua 함수 호출 시 크래시
**원인**: Construction Script는 에디터 타임에 실행되며, UnLua는 런타임에만 동작
```lua
-- ❌ 이렇게 하면 안됨
function M:UserConstructionScript()
    self:InitializeLuaData()  -- 크래시!
end
```
**해결책**: BeginPlay에서 초기화
```lua
-- ✅ 올바른 방법
function M:ReceiveBeginPlay()
    self.Super:ReceiveBeginPlay()
    self:InitializeLuaData()  -- 안전함
end
```

### 2. Native C++ 함수 접근 불가
**문제**: 리플렉션되지 않은 C++ 함수/변수 접근 시 nil 반환
```lua
-- ❌ Native 전용 함수는 접근 불가
local Result = Actor:GetPrivateNativeFunction()  -- nil
```
**해결책**: BlueprintCallable/BlueprintReadWrite 마크된 것만 사용
```cpp
// C++에서 노출 필요
UFUNCTION(BlueprintCallable)
void MyAccessibleFunction();

UPROPERTY(BlueprintReadWrite)
float MyAccessibleProperty;
```

### 3. Lua 테이블의 Actor 참조 GC 문제
**문제**: Lua 테이블에 Actor 직접 참조 시 가비지 컬렉션 후에도 메모리 유지
```lua
-- ❌ 메모리 누수 가능
self.ActorCache = {}
self.ActorCache[ActorName] = ActorRef  -- 직접 참조
```
**해결책**: Weak Reference 사용 또는 ID 기반 관리
```lua
-- ✅ Weak Table 사용
self.ActorCache = {}
setmetatable(self.ActorCache, {__mode = "v"})

-- ✅ 또는 ID 기반 관리
self.ActorIDs = {}
self.ActorIDs[ActorName] = Actor:GetUniqueID()
```

## 🟡 Performance Issues

### 1. Tick 함수 과다 사용
**문제**: 많은 Actor에서 Tick 사용 시 성능 저하
```lua
-- ❌ 모든 Actor에서 매 프레임 실행
function M:ReceiveTick(DeltaTime)
    self:UpdatePosition()
    self:CheckCollisions()
    self:UpdateUI()
end
```
**해결책**: Timer 사용 또는 이벤트 기반으로 변경
```lua
-- ✅ Timer로 주기적 업데이트
function M:ReceiveBeginPlay()
    self:SetTimer("UpdatePosition", 0.1, true)
    -- 충돌은 이벤트로 처리
    self.OnActorBeginOverlap:Add(self, self.HandleCollision)
end
```

### 2. 매 프레임 GetAllActorsOfClass 호출
**문제**: 런타임에 Actor 목록을 자주 검색하면 성능 저하
```lua
-- ❌ 매 프레임 검색
function M:ReceiveTick()
    local Enemies = UE.UGameplayStatics.GetAllActorsOfClass(
        self:GetWorld(), UE.AEnemy
    )
end
```
**해결책**: 캐싱 및 이벤트 기반 업데이트
```lua
-- ✅ 캐싱과 이벤트 활용
function M:ReceiveBeginPlay()
    self.EnemyList = {}
    -- Enemy 스폰/제거 시 이벤트로 리스트 업데이트
end

function M:OnEnemySpawned(Enemy)
    table.insert(self.EnemyList, Enemy)
end
```

### 3. 문자열 연결 성능
**문제**: 루프에서 문자열 연결 시 성능 저하
```lua
-- ❌ 비효율적
local Result = ""
for i = 1, 1000 do
    Result = Result .. Data[i] .. ","
end
```
**해결책**: table.concat 사용
```lua
-- ✅ 효율적
local Parts = {}
for i = 1, 1000 do
    Parts[i] = Data[i]
end
local Result = table.concat(Parts, ",")
```

## 🟠 Network Issues

### 1. RPC 함수를 Lua에서 직접 정의 불가
**문제**: Server/Client RPC는 Blueprint에서만 정의 가능
```lua
-- ❌ Lua에서 RPC 정의 불가능
function M:ServerDoSomething_Implementation()  -- 동작 안함
end
```
**해결책**: Blueprint에서 RPC 정의 후 Lua에서 호출
```lua
-- ✅ Blueprint에서 정의된 RPC 호출
function M:RequestServerAction(Data)
    if not self:HasAuthority() then
        self:ServerDoSomething(Data)  -- BP에 정의된 RPC
    end
end
```

### 2. Replicated Property 초기화 타이밍
**문제**: Replicated 속성이 클라이언트에서 즉시 사용 불가
```lua
-- ❌ BeginPlay에서 즉시 사용
function M:ReceiveBeginPlay()
    print(self.ReplicatedHealth)  -- 0 또는 기본값
end
```
**해결책**: OnRep 함수 사용
```lua
-- ✅ OnRep 함수에서 처리
function M:OnRep_ReplicatedHealth()
    self:UpdateHealthUI(self.ReplicatedHealth)
end
```

### 3. Authority 체크 누락
**문제**: 서버/클라이언트 구분 없이 로직 실행
```lua
-- ❌ 모든 클라이언트에서 실행
function M:SpawnReward()
    local Reward = self:GetWorld():SpawnActor(...)
end
```
**해결책**: Authority 체크 필수
```lua
-- ✅ 서버에서만 실행
function M:SpawnReward()
    if not self:HasAuthority() then return end
    local Reward = self:GetWorld():SpawnActor(...)
end
```

## 🔵 Editor/Development Issues

### 1. Hot Reload 후 Lua 상태 유지
**문제**: 에디터에서 Hot Reload 시 이전 Lua 상태가 남아있음
```lua
-- 전역 변수가 리로드 후에도 유지됨
GlobalCounter = (GlobalCounter or 0) + 1
```
**해결책**: 명시적 초기화
```lua
-- ✅ 모듈별 초기화
local M = UnLua.Class()
M.Counter = 0  -- 매번 초기화

function M:Initialize()
    M.Counter = 0  -- 명시적 초기화
end
```

### 2. PIE 멀티플레이 테스트 시 로그 혼재
**문제**: 여러 PIE 인스턴스의 로그가 섞여서 디버깅 어려움
```lua
print("Player action")  -- 어느 인스턴스인지 불명확
```
**해결책**: 인스턴스 구분자 추가
```lua
-- ✅ 인스턴스 구분
local NetMode = self:GetWorld():GetNetMode()
local Prefix = NetMode == UE.ENetMode.NM_DedicatedServer and "[Server]" or "[Client]"
print(string.format("%s Player action", Prefix))
```

## 🟣 Type & Casting Issues

### 1. 잘못된 타입 캐스팅
**문제**: Lua는 타입 체크가 느슨해서 런타임 에러 발생 가능
```lua
-- ❌ 타입 체크 없이 사용
local Pawn = Actor  -- Actor가 Pawn이 아닐 수 있음
Pawn:GetController()  -- 크래시 가능
```
**해결책**: IsA() 또는 Cast 사용
```lua
-- ✅ 타입 확인
if Actor:IsA(UE.APawn) then
    local Pawn = Actor
    local Controller = Pawn:GetController()
end

-- 또는 Cast 사용
local Pawn = Actor:Cast(UE.APawn)
if Pawn then
    local Controller = Pawn:GetController()
end
```

### 2. nil 체크 부재
**문제**: nil 참조로 인한 크래시
```lua
-- ❌ nil 체크 없음
local Location = self.TargetActor:GetActorLocation()
```
**해결책**: IsValid 체크
```lua
-- ✅ 유효성 체크
if UE.UKismetSystemLibrary.IsValid(self.TargetActor) then
    local Location = self.TargetActor:GetActorLocation()
end
```

## 🟢 Workaround Patterns

### 1. DataTable 행 반복 처리
**문제**: DataTable 전체 행 순회가 직접 지원되지 않음
```lua
-- DataTable 모든 행 가져오기 (Workaround)
function M:GetAllDataTableRows(DataTable)
    local Rows = {}
    local RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTable)
    
    for i = 1, RowNames:Length() do
        local RowName = RowNames:Get(i)
        local Row = UE.UDataTableFunctionLibrary.GetDataTableRow(
            DataTable, RowName, ""
        )
        if Row then
            Rows[RowName] = Row
        end
    end
    
    return Rows
end
```

### 2. 지연 초기화 패턴
**문제**: 일부 컴포넌트가 BeginPlay에서 준비되지 않음
```lua
-- 지연 초기화 패턴
function M:ReceiveBeginPlay()
    self.Super:ReceiveBeginPlay()
    
    -- 한 프레임 대기 후 초기화
    self:SetTimer("DelayedInit", 0.01, false)
end

function M:DelayedInit()
    -- 모든 컴포넌트가 준비된 후 실행
    self:InitializeComponents()
end
```

### 3. 커스텀 이벤트 시스템
**문제**: Lua 간 직접 통신이 제한적
```lua
-- 전역 이벤트 시스템 구현
G_EventSystem = G_EventSystem or {}

function G_EventSystem:Subscribe(EventName, Listener, Callback)
    self[EventName] = self[EventName] or {}
    self[EventName][Listener] = Callback
end

function G_EventSystem:Broadcast(EventName, ...)
    if not self[EventName] then return end
    
    for Listener, Callback in pairs(self[EventName]) do
        if UE.UKismetSystemLibrary.IsValid(Listener) then
            Callback(Listener, ...)
        else
            -- 무효한 리스너 제거
            self[EventName][Listener] = nil
        end
    end
end
```

## 📋 Quick Reference Table

| 이슈 유형 | 심각도 | 주요 원인 | 해결 방법 |
|---------|--------|----------|----------|
| Construction Script 크래시 | 🔴 Critical | 에디터/런타임 차이 | BeginPlay 사용 |
| Native 함수 접근 불가 | 🔴 Critical | 리플렉션 부재 | BlueprintCallable 마크 |
| Actor GC 문제 | 🟡 Major | 강한 참조 | Weak Table 사용 |
| Tick 성능 | 🟡 Major | 과다 사용 | Timer/Event 전환 |
| RPC 정의 불가 | 🟠 Major | UnLua 제약 | Blueprint에서 정의 |
| Hot Reload 상태 | 🔵 Minor | 상태 유지 | 명시적 초기화 |
| nil 참조 | 🟣 Common | 체크 부재 | IsValid 사용 |

## 💡 디버깅 팁

1. **로그 레벨 설정**: 
```ini
[/Script/UnLua.UnLuaSettings]
LogLevel=Warning
```

2. **성능 프로파일링**:
```
stat unlua
stat game
```

3. **메모리 추적**:
```lua
-- 메모리 사용량 체크
local Memory = collectgarbage("count")
print(string.format("Lua Memory: %.2f KB", Memory))
```
