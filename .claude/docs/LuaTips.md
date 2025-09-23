# UnLua 팁
## Coroutine 팁
- Lua에서 코루틴을 사용하는데 동시에 Blueprint에서도 LatentAction 기능을 사용하는 노드(Delay)를 사용하면 에디터가 멈춰버리는 이슈가 있다. 이것을 명심해야함.

## UnLua + Blueprint 멀티플레이어 개발 핵심 팁 정리



### 📦 구조체(Struct) 사용 전략

### 개발 단계별 접근

```
Phase 1 (프로토타이핑): Blueprint Struct 사용
  ↓ (GUID 이름 감수, 빠른 이터레이션)
Phase 2 (개발): 계속 BP Struct 유지
  ↓ (IntelliSense는 지원됨)
Phase 3 (최적화): C++ Struct로 이동
  ↓ (GUID 제거, 가독성 향상)
Phase 4 (배포): LiveCoding 절대 금지!

```

### ⚠️ 리플리케이션 주의사항

### 1. **PushModel 사용 시**

```lua
-- 변수 변경 후 반드시 Dirty 마킹
self.Health = 100
if UE.UNetPushModelHelpers then
    UE.UNetPushModelHelpers.MarkPropertyDirty(self, "Health")
end

```

### 2. **Fast Array Replication**

```lua
-- 배열 전체를 교체해야 함
local newArray = {}
for i, v in ipairs(self.ReplicatedArray) do
    table.insert(newArray, v)
end
table.insert(newArray, newItem)
self.ReplicatedArray = newArray  -- 전체 교체!

```

### 🐛 트러블슈팅

### 1. **LiveCoding 절대 금지**

- Header 수정 시 리플렉션 이름 깨짐
- 반드시 에디터 재시작 또는 전체 빌드

### 2. **코루틴 + LatentAction 충돌**

```lua
-- ❌ 에디터 멈춤
coroutine.wrap(function()
    UE.UKismetSystemLibrary.Delay(self, 1.0)  -- 위험!
end)()

-- ✅ Timer 사용
self:K2_SetTimerDelegate({self, self.DelayedFunc}, 1.0, false)

```

### 3. **TArray, TMap, TSet 처리**

UnLua는 **언리얼 컨테이너(TArray, TSet, TMap)를 Lua에서 네이티브처럼 직접 생성하고 조작**할 수 있으며, 언리얼→Lua 변환은 `ToTable()`로 가능하지만, **Lua→언리얼 직접 변환 함수는 없어서 반복문으로 수동 추가**해야 합니다. 
단, UFUNCTION 매개변수로 전달 시에는 자동 변환되며, 성능 저하가 있을 수 있으니 갯수가 10개 이상인 경우 **변환 없이 언리얼 컨테이너를 직접 사용**하는 것이 권장됩니다.

```lua
-- 1. 언리얼 컨테이너 직접 사용 (권장)
local array = UE.TArray(0)          -- Integer 배열
array:Add(10)
array:Add(20)
local map = UE.TMap("", UE.FVector) -- String-Vector 맵
map:Add("pos", UE.FVector(1,2,3))

-- 2. 언리얼 → Lua 변환
local luaTable = array:ToTable()    -- {10, 20}
local luaMap = map:ToTable()        -- {pos=FVector(1,2,3)}

-- 3. Lua → 언리얼 변환 (수동)
local myTable = {30, 40, 50}
local newArray = UE.TArray(0)
for _, v in ipairs(myTable) do
    newArray:Add(v)
end

-- 4. UFUNCTION 호출 시 자동 변환
self:ProcessArray({1,2,3})  -- Lua 테이블이 TArray 매개변수로 자동 변환
```

```lua
-- ❌ Lua 테이블처럼 접근
array[1] = newValue

-- 선언부
---@type UE.TArray<UE.AActor>
local MyArray = UE.TArray(UE.AActor)

-- ✅ 전용 메서드 사용
array:Set(0, newValue)  -- 0-based index!
array:Add(newItem)

-- TMap 순회 (Lua에서 index는 1부터 시작)
local keys = map:Keys()
for i = 1, keys:Length() do
    local key = keys:Get(i)
    local value = map:Find(key)
end
```

### 4. Collision profile 관련

```lua
-- DefaultEngine.ini에 정의된 유저 커스텀 Trace, Object, CollisionProfile의 타입을 그대로 쓸 수 있음.

-- e.g
local MyTraceType = UE.ETraceTypeQuery.MyTraceType
-- e.g 
local MyObjectType = UE.EObjectTypeQuery.MyObjectType
-- e.g
local MyCollisionChannel = UE.ECollisionChannel.MyCollisionChannel
```

### 5. HitResult 처리

```lua
-- FHitResult에서 Actor를 바로 가져올 수 없음. Component를 통해 가져오거나, BreakHitResult 함수를 이용해야함.

-- e.g1
---@type FHitResult
local HitResult = OutHitResults[i]
---@type AActor
local HitActor = HitResult.Component and HitResult.Component:GetOwner()

-- e.g2
---@type FHitResult
local HitResult = OutHitResults[i]
local bBlockingHit, bInitialOverlap, Time, Distance, Location, ImpactPoint, Normal, ImpactNormal,
      PhysMat, HitActor, HitComponent, HitBoneName, HitItem, ElementIndex, FaceIndex, TraceStart, TraceEnd 
      = UE.UGameplayStatics.BreakHitResult(HitResult)
-- e.g3
local _, _, _, _, _, _, _, _, _, HitActor = UE.UGameplayStatics.BreakHitResult(HitResult)
```

### 6. UClass, IsA

```lua
-- Blueprint 클래스 가져오기
local MyBPClass = UE.UClass.Load("")
-- Cpp Natice 클래스 가져오기
local MyNativceCppClass = UE.UMyClass

local SomeUObject = Something
local IsMyBPClass = SomeUObject:IsA(MyBPClass)
local IsMyNativeCppClass = SomeUObject:IsA(MyNativeCppClass)
```

### 💡 Best Practices

### 1. **네이밍 컨벤션**

```markdown
- 파일명: BP_MyActor_C.lua (Blueprint와 일치)
- Server 함수 : Server_FunctionName
- Client 함수 : Client_FunctionName
- Client,Server 공용 함수 : FunctionName
- RPC: ServerRPC_FunctionName, MulticastRPC_FunctionName, ClientRPC_FunctionName
- RPC override: ServerRPC_FunctionName_RPC ...
- RepNotify: OnRep_VariableName
- 내부 함수: _PrivateFunction
```

### 🚀 권장 워크플로우

1. **초반**: BP + Lua로 빠른 프로토타이핑
2. **중반**: 안정된 구조는 C++로 이동 (LiveCoding X)
3. **후반**: 성능 병목 C++ 이동, Struct 정리
4. **배포**: 디버그 코드 제거, 최종 최적화
