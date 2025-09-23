# 🎯 Code Patterns & Best Practices

## 📝 Naming Convention

### Lua Files
```lua
-- Actor 바인딩
BP_PlayerCharacter.lua    -- BP_PlayerCharacter 블루프린트와 바인딩
BP_EnemyAI.lua            -- BP_EnemyAI 블루프린트와 바인딩

-- Static 라이브러리
G_GameplayUtils.lua       -- 게임플레이 유틸리티
G_NetworkHelper.lua       -- 네트워크 헬퍼 함수
G_MathExtensions.lua      -- 수학 확장 함수

-- Component 바인딩  
Comp_HealthComponent.lua  -- Health Component 로직
Comp_InventorySystem.lua  -- Inventory System
```

### Variables & Functions
```lua
-- 변수 네이밍
local MaxHealth = 100          -- 로컬 변수: CamelCase
self.CurrentHealth = 75         -- 프로퍼티: CamelCase
local _internalCache = {}       -- 내부 변수: _로 시작

-- 함수 네이밍
function M:PublicFunction()     -- Public 함수: CamelCase
end

function M:_PrivateHelper()     -- Private 함수: _로 시작
end

function M:OnEventName()        -- 이벤트 핸들러: On으로 시작
end

function M:Handle_Collision()   -- 언리얼 이벤트: Handle_ prefix
end
```

## 🎮 Player Character Pattern

```lua
-- BP_PlayerCharacter.lua
local M = UnLua.Class()

-- 초기화 패턴: 변수 선언 및 기본값 설정
function M:Initialize()
    -- 캐싱할 컴포넌트 참조
    self._CachedComponents = {}
    
    -- 상태 변수 초기화
    self._IsInitialized = false
    self._CurrentCombo = 0
    self._LastActionTime = 0
    
    print("[Player] Initialize called")
end

function M:ReceiveBeginPlay()
    -- 반드시 Super 호출
    self.Super:ReceiveBeginPlay()
    
    -- 컴포넌트 캐싱
    self:_CacheComponents()
    
    -- 이벤트 바인딩
    self:_BindEvents()
    
    -- 타이머 설정
    self:_SetupTimers()
    
    -- 초기 상태 설정
    if self:HasAuthority() then
        self.Health = self.MaxHealth
        self.Stamina = self.MaxStamina
    end
    
    self._IsInitialized = true
    print("[Player] BeginPlay completed")
end

-- 컴포넌트 캐싱 패턴
function M:_CacheComponents()
    self._CachedComponents.CapsuleComponent = self.CapsuleComponent
    self._CachedComponents.CharacterMovement = self:GetCharacterMovement()
    self._CachedComponents.SkeletalMesh = self:GetMesh()
    
    -- nil 체크
    for name, comp in pairs(self._CachedComponents) do
        if not UE.UKismetSystemLibrary.IsValid(comp) then
            print(string.format("[Player] Warning: %s is invalid", name))
        end
    end
end

-- 이벤트 바인딩 패턴
function M:_BindEvents()
    -- Collision 이벤트
    if self.CapsuleComponent then
        self.CapsuleComponent.OnComponentBeginOverlap:Add(self, self.OnCapsuleOverlap)
    end
    
    -- Custom Delegate 바인딩
    if self.OnHealthChanged then
        self.OnHealthChanged:Add(self, self.OnHealthUpdated)
    end
end

-- 타이머 관리 패턴
function M:_SetupTimers()
    -- 상태 체크 타이머
    self:SetTimer("CheckStatus", 1.0, true)
    
    -- 리젠 타이머
    if self:HasAuthority() then
        self:SetTimer("RegenerateHealth", 0.5, true)
    end
end

-- Input 처리 패턴
function M:SetupPlayerInputComponent(InputComponent)
    -- Action 바인딩
    InputComponent:BindAction("Jump", UE.EInputEvent.IE_Pressed, self, self.OnJumpPressed)
    InputComponent:BindAction("Jump", UE.EInputEvent.IE_Released, self, self.OnJumpReleased)
    InputComponent:BindAction("Attack", UE.EInputEvent.IE_Pressed, self, self.OnAttackPressed)
    
    -- Axis 바인딩
    InputComponent:BindAxis("MoveForward", self, self.OnMoveForward)
    InputComponent:BindAxis("MoveRight", self, self.OnMoveRight)
    InputComponent:BindAxis("Turn", self, self.OnTurn)
end

-- Movement 처리 패턴
function M:OnMoveForward(Value)
    if math.abs(Value) < 0.1 then return end
    
    local Rotation = self:GetControlRotation()
    local ForwardVector = UE.UKismetMathLibrary.GetForwardVector(
        UE.FRotator(0, Rotation.Yaw, 0)
    )
    self:AddMovementInput(ForwardVector, Value)
end

-- Combat 패턴 (콤보 시스템)
function M:OnAttackPressed()
    -- 클라이언트에서 예측
    self:PlayAttackMontage(self._CurrentCombo)
    
    -- 서버에 요청
    if not self:HasAuthority() then
        self:ServerRequestAttack(self._CurrentCombo)
    else
        self:ExecuteAttack(self._CurrentCombo)
    end
    
    -- 콤보 카운터 업데이트
    self._CurrentCombo = (self._CurrentCombo + 1) % 3
    self._LastActionTime = UE.UGameplayStatics.GetTimeSeconds(self)
    
    -- 콤보 리셋 타이머
    self:SetTimer("ResetCombo", 1.5, false)
end

-- 데미지 처리 패턴
function M:ReceiveDamage(DamageAmount, DamageType, InstigatedBy, DamageCauser)
    if not self:HasAuthority() then return end
    
    -- 데미지 계산
    local ActualDamage = self:CalculateDamage(DamageAmount, DamageType)
    
    -- 체력 감소
    local OldHealth = self.Health
    self.Health = math.max(0, self.Health - ActualDamage)
    
    -- 이벤트 브로드캐스트
    if self.OnHealthChanged then
        self.OnHealthChanged:Broadcast(OldHealth, self.Health)
    end
    
    -- 사망 체크
    if self.Health <= 0 then
        self:Die(InstigatedBy)
    end
    
    -- 클라이언트에 알림
    self:MulticastOnDamageReceived(ActualDamage, InstigatedBy)
end

-- 리소스 정리 패턴
function M:ReceiveEndPlay(Reason)
    -- 타이머 정리
    self:ClearTimer("CheckStatus")
    self:ClearTimer("RegenerateHealth")
    self:ClearTimer("ResetCombo")
    
    -- 이벤트 언바인딩
    if self.CapsuleComponent then
        self.CapsuleComponent.OnComponentBeginOverlap:RemoveAll(self)
    end
    
    -- 캐시 정리
    self._CachedComponents = nil
    
    self.Super:ReceiveEndPlay(Reason)
    print("[Player] EndPlay completed")
end

return M
```

## 🤖 AI Enemy Pattern

```lua
-- BP_EnemyAI.lua
local M = UnLua.Class()

-- AI 상태 Enum
local EAIState = {
    Idle = 0,
    Patrol = 1,
    Chase = 2,
    Attack = 3,
    Dead = 4
}

function M:Initialize()
    self.CurrentState = EAIState.Idle
    self.TargetPlayer = nil
    self.PatrolPoints = {}
    self.CurrentPatrolIndex = 1
    self.AttackCooldown = 0
end

function M:ReceiveBeginPlay()
    self.Super:ReceiveBeginPlay()
    
    if self:HasAuthority() then
        -- AI는 서버에서만 실행
        self:SetTimer("UpdateAI", 0.2, true)
        self:SetupPatrolRoute()
    end
end

-- FSM (Finite State Machine) 패턴
function M:UpdateAI()
    -- 쿨다운 업데이트
    local DeltaTime = 0.2
    self.AttackCooldown = math.max(0, self.AttackCooldown - DeltaTime)
    
    -- 상태별 처리
    if self.CurrentState == EAIState.Idle then
        self:UpdateIdle()
    elseif self.CurrentState == EAIState.Patrol then
        self:UpdatePatrol()
    elseif self.CurrentState == EAIState.Chase then
        self:UpdateChase()
    elseif self.CurrentState == EAIState.Attack then
        self:UpdateAttack()
    end
end

-- 상태 전환 패턴
function M:ChangeState(NewState)
    if self.CurrentState == NewState then return end
    
    -- Exit current state
    self:ExitState(self.CurrentState)
    
    -- Enter new state
    self.CurrentState = NewState
    self:EnterState(NewState)
    
    -- 상태 변경 알림
    self:OnStateChanged(NewState)
end

-- Perception 패턴
function M:UpdateIdle()
    local DetectedPlayer = self:DetectPlayer()
    if DetectedPlayer then
        self.TargetPlayer = DetectedPlayer
        self:ChangeState(EAIState.Chase)
    else
        -- 일정 시간 후 순찰 시작
        self:ChangeState(EAIState.Patrol)
    end
end

function M:DetectPlayer()
    local World = self:GetWorld()
    local Location = self:GetActorLocation()
    
    -- Sphere overlap으로 감지
    local OverlapActors = UE.TArray(UE.AActor)
    local bFound = UE.UKismetSystemLibrary.SphereOverlapActors(
        World,
        Location,
        self.DetectionRange,
        {UE.EObjectTypeQuery.ObjectTypeQuery3},  -- Pawn
        UE.APawn,
        {self},
        OverlapActors
    )
    
    if bFound and OverlapActors:Length() > 0 then
        -- 시야각 체크
        for i = 1, OverlapActors:Length() do
            local Actor = OverlapActors:Get(i)
            if self:IsInFieldOfView(Actor) then
                return Actor
            end
        end
    end
    
    return nil
end

-- Navigation 패턴
function M:UpdateChase()
    if not UE.UKismetSystemLibrary.IsValid(self.TargetPlayer) then
        self:ChangeState(EAIState.Idle)
        return
    end
    
    local Distance = self:GetDistanceTo(self.TargetPlayer)
    
    if Distance > self.LoseTargetRange then
        -- 목표 잃음
        self.TargetPlayer = nil
        self:ChangeState(EAIState.Patrol)
    elseif Distance <= self.AttackRange then
        -- 공격 범위 진입
        self:ChangeState(EAIState.Attack)
    else
        -- 추적 계속
        self:MoveToTarget(self.TargetPlayer)
    end
end

return M
```

## 🎯 Component Pattern

```lua
-- Comp_HealthComponent.lua
local M = UnLua.Class()

function M:Initialize()
    self.OnHealthChanged = nil  -- Delegate
    self.OnDeath = nil          -- Delegate
    self._IsDead = false
end

function M:ReceiveBeginPlay()
    self.Super:ReceiveBeginPlay()
    
    -- Owner 캐싱
    self._Owner = self:GetOwner()
    
    -- 초기값 설정
    if self._Owner:HasAuthority() then
        self.CurrentHealth = self.MaxHealth
    end
    
    -- Owner의 Damage 이벤트 바인딩
    if self._Owner.OnTakeAnyDamage then
        self._Owner.OnTakeAnyDamage:Add(self, self.HandleDamage)
    end
end

-- 컴포넌트 재사용 패턴
function M:ResetHealth()
    self.CurrentHealth = self.MaxHealth
    self._IsDead = false
    
    if self.OnHealthChanged then
        self.OnHealthChanged:Broadcast(self.CurrentHealth, self.MaxHealth)
    end
end

-- 데미지 처리
function M:HandleDamage(DamagedActor, Damage, DamageType, InstigatedBy, DamageCauser)
    if self._IsDead or not self._Owner:HasAuthority() then
        return
    end
    
    -- 데미지 적용
    local OldHealth = self.CurrentHealth
    self.CurrentHealth = math.max(0, self.CurrentHealth - Damage)
    
    -- 변경 알림
    if self.OnHealthChanged then
        self.OnHealthChanged:Broadcast(self.CurrentHealth, OldHealth)
    end
    
    -- 사망 체크
    if self.CurrentHealth <= 0 and not self._IsDead then
        self._IsDead = true
        if self.OnDeath then
            self.OnDeath:Broadcast(InstigatedBy)
        end
    end
    
    -- Replication
    self:OnRep_CurrentHealth()
end

-- Replication 핸들러
function M:OnRep_CurrentHealth()
    -- 클라이언트 UI 업데이트
    if self.OnHealthChanged then
        self.OnHealthChanged:Broadcast(self.CurrentHealth, self.MaxHealth)
    end
end

return M
```

## 🛠️ Utility Library Pattern

```lua
-- G_GameplayUtils.lua
local M = UnLua.Class()

-- Singleton 패턴
local _Instance = nil

function M:Get()
    if not _Instance then
        _Instance = M()
    end
    return _Instance
end

-- 거리 유틸리티
function M:GetDistance2D(ActorA, ActorB)
    if not UE.UKismetSystemLibrary.IsValid(ActorA) or 
       not UE.UKismetSystemLibrary.IsValid(ActorB) then
        return math.huge
    end
    
    local LocA = ActorA:GetActorLocation()
    local LocB = ActorB:GetActorLocation()
    
    -- Z 축 무시
    LocA.Z = 0
    LocB.Z = 0
    
    return UE.UKismetMathLibrary.Vector_Distance(LocA, LocB)
end

-- 배열 유틸리티
function M:ShuffleArray(Array)
    local n = #Array
    for i = n, 2, -1 do
        local j = math.random(i)
        Array[i], Array[j] = Array[j], Array[i]
    end
    return Array
end

-- 디버그 유틸리티
function M:DrawDebugSphere(World, Location, Radius, Duration, Color)
    if not self:IsDebugEnabled() then return end
    
    UE.UKismetSystemLibrary.DrawDebugSphere(
        World,
        Location,
        Radius,
        12,
        Color or UE.FLinearColor(1, 0, 0, 1),
        Duration or 0.0,
        1.0
    )
end

-- 오브젝트 풀링 패턴
function M:CreateObjectPool(ActorClass, InitialSize, World)
    local Pool = {
        ActorClass = ActorClass,
        Available = {},
        InUse = {},
        World = World
    }
    
    -- 초기 풀 생성
    for i = 1, InitialSize do
        local Actor = self:_SpawnPoolActor(Pool)
        Actor:SetActorHiddenInGame(true)
        Actor:SetActorEnableCollision(false)
        table.insert(Pool.Available, Actor)
    end
    
    return Pool
end

function M:GetFromPool(Pool)
    local Actor = nil
    
    if #Pool.Available > 0 then
        Actor = table.remove(Pool.Available)
    else
        Actor = self:_SpawnPoolActor(Pool)
    end
    
    Actor:SetActorHiddenInGame(false)
    Actor:SetActorEnableCollision(true)
    table.insert(Pool.InUse, Actor)
    
    return Actor
end

function M:ReturnToPool(Pool, Actor)
    -- InUse에서 제거
    for i, InUseActor in ipairs(Pool.InUse) do
        if InUseActor == Actor then
            table.remove(Pool.InUse, i)
            break
        end
    end
    
    -- 리셋 후 Available에 추가
    Actor:SetActorHiddenInGame(true)
    Actor:SetActorEnableCollision(false)
    Actor:SetActorLocation(UE.FVector(0, 0, -10000))
    table.insert(Pool.Available, Actor)
end

return M
```

## 📊 Performance Patterns

```lua
-- 성능 최적화 패턴 모음

-- 1. 캐싱 패턴
local M = UnLua.Class()

function M:Initialize()
    -- 자주 사용하는 참조 캐싱
    self._CachedWorld = nil
    self._CachedGameState = nil
    self._CachedPlayerController = nil
end

function M:GetCachedWorld()
    if not self._CachedWorld then
        self._CachedWorld = self:GetWorld()
    end
    return self._CachedWorld
end

-- 2. Tick 최적화 패턴
function M:ReceiveTick(DeltaTime)
    -- Tick 사용 최소화
    self.TickCounter = (self.TickCounter or 0) + DeltaTime
    
    -- 0.1초마다만 실행
    if self.TickCounter >= 0.1 then
        self:SlowTick(self.TickCounter)
        self.TickCounter = 0
    end
end

-- 3. 이벤트 Throttling 패턴
function M:OnDamageReceived(Damage)
    local CurrentTime = UE.UGameplayStatics.GetTimeSeconds(self)
    
    -- 0.1초 쿨다운
    if CurrentTime - (self._LastDamageTime or 0) < 0.1 then
        return
    end
    
    self._LastDamageTime = CurrentTime
    self:ProcessDamage(Damage)
end

-- 4. Lazy Loading 패턴
function M:GetExpensiveData()
    if not self._ExpensiveData then
        self._ExpensiveData = self:LoadExpensiveData()
    end
    return self._ExpensiveData
end

return M
```

## ⚠️ Common Mistakes to Avoid

```lua
-- ❌ BAD: 매 프레임 Actor 검색
function M:ReceiveTick(DeltaTime)
    local AllEnemies = UE.UGameplayStatics.GetAllActorsOfClass(
        self:GetWorld(), 
        UE.ABP_Enemy
    )
    -- 매 프레임 실행 = 성능 저하
end

-- ✅ GOOD: 캐싱과 타이머 사용
function M:ReceiveBeginPlay()
    self:SetTimer("UpdateEnemyList", 1.0, true)
end

function M:UpdateEnemyList()
    self.CachedEnemies = UE.UGameplayStatics.GetAllActorsOfClass(
        self:GetWorld(), 
        UE.ABP_Enemy
    )
end

-- ❌ BAD: 긴 문자열 연결
local Result = ""
for i = 1, 1000 do
    Result = Result .. "Item" .. i .. ", "
end

-- ✅ GOOD: Table 사용
local Parts = {}
for i = 1, 1000 do
    table.insert(Parts, "Item" .. i)
end
local Result = table.concat(Parts, ", ")
```
