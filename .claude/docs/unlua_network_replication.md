# 🌐 Network Replication Guide

## 📡 Core Concepts

### Network Roles
```lua
-- Role 확인
local Role = self:GetLocalRole()
local RemoteRole = self:GetRemoteRole()

-- Role 종류
-- ROLE_None: 네트워크 없음
-- ROLE_SimulatedProxy: 시뮬레이션 클라이언트
-- ROLE_AutonomousProxy: 소유 클라이언트
-- ROLE_Authority: 서버 권한

-- 간단한 체크
if self:HasAuthority() then
    -- 서버 코드
else
    -- 클라이언트 코드
end
```

### Ownership
```lua
-- 소유자 확인
function M:IsLocallyControlled()
    local PC = self:GetController()
    if not PC then return false end
    
    return PC:IsLocalController()
end

-- 소유권 설정 (서버에서만)
function M:AssignOwnership(PlayerController)
    if not self:HasAuthority() then return end
    
    self:SetOwner(PlayerController)
end
```

## 🔄 Property Replication

### Blueprint 설정
1. Actor의 `Replicates` 체크
2. Property의 `Replicated` 또는 `RepNotify` 설정
3. Component의 `Component Replicates` 체크

### 변수 리플리케이션을 사용할 때는 PushModelBase인지 체크.
- 일반적인 상황에서는 자동으로 OnRep_XXX 함수가 호출된다. 그리고 해당 함수를 Override 할 수 있다.
- `net.IsPushModelEnabled=1` 이게 켜져 있는 경우에는 변수를 변경한 후 UNetPushModelHelpers의 함수를 통해 다음과 같이 처리를 해줘야 정상적으로 리플리케이션.
```lua
self.Var = 9999
UE.UNetPushModelHelpers.MarkPropertyDirty(self, "Var")
```

### Lua에서 RepNotify 처리
```lua
-- Blueprint에서 RepNotify로 설정된 프로퍼티
-- OnRep_PropertyName 함수가 자동 호출됨

function M:OnRep_Health()
    -- 클라이언트에서 체력 변경 시 UI 업데이트
    self:UpdateHealthBar(self.Health)
    
    -- 이펙트 재생
    if self.Health < self.LastHealth then
        self:PlayDamageEffect()
    end
    self.LastHealth = self.Health
end

function M:OnRep_TeamColor()
    -- 팀 색상 변경
    self:UpdateMaterialColor(self.TeamColor)
end
```

### Replication Conditions
```lua
-- 조건부 리플리케이션 (Blueprint에서 설정)
-- COND_None: 항상
-- COND_InitialOnly: 최초 한 번만
-- COND_OwnerOnly: 소유자에게만
-- COND_SkipOwner: 소유자 제외
-- COND_SimulatedOnly: 시뮬레이션 프록시만
-- COND_AutonomousOnly: 자율 프록시만

-- Lua에서 활용
function M:SetPlayerScore(Score)
    if not self:HasAuthority() then return end
    
    -- RepNotify 프로퍼티 설정
    self.PlayerScore = Score  -- 자동으로 클라이언트에 전파
end
```

## 📨 Remote Procedure Calls (RPC)
### 1. **RPC 함수명 규칙**
```lua
-- Blueprint: MyFunction (Run on Server/Client/Multicast 설정)
-- Lua 구현: 함수명_RPC 접미사 필수!
function M:MyFunction_Server_RPC()  -- 구현
    -- 로직
end

-- 호출할 때는 _RPC 없이
self:MyFunction_Server()  -- 호출

```

### 2. **RPC에서 Overridden 미지원**
```lua
-- ❌ RPC는 self.Overridden 지원 안 함
function M:Fire_Server_RPC()
    self.Overridden.Fire_Server_RPC(self)  -- 작동 안 함!
end

-- ✅ 해결책 1: BP에서 로직 분리
-- BP: Fire_Server (RPC) → Fire_Implementation (일반 함수)
function M:Fire_Server_RPC()
    self:Fire_Implementation()  -- BP의 일반 함수 호출
end

-- ✅ 해결책 2: Super 사용 (Lua 상속 시)
local M = UnLua.Class("BP_CharacterBase_C")
function M:Fire_Server_RPC()
    self.Super.Fire_Server_RPC(self)  -- 부모 Lua 호출
end
```

## 🐛 Common Network Bugs

### 1. Race Condition
```lua
-- ❌ 문제: BeginPlay 순서 의존
function M:ReceiveBeginPlay()
    -- GameState가 아직 준비되지 않았을 수 있음
    local GameState = self:GetWorld():GetGameState()
    self.TeamScore = GameState.TeamScores[self.TeamID]  -- nil 에러 가능
end

-- ✅ 해결: 지연 초기화
function M:ReceiveBeginPlay()
    self:SetTimer("InitializeTeamData", 0.1, false)
end

function M:InitializeTeamData()
    local GameState = self:GetWorld():GetGameState()
    if GameState and GameState.TeamScores then
        self.TeamScore = GameState.TeamScores[self.TeamID]
    else
        -- 재시도
        self:SetTimer("InitializeTeamData", 0.1, false)
    end
end
```

### 2. 권한 체크 누락
```lua
-- ❌ 문제: 클라이언트에서도 스폰
function M:SpawnPickup()
    local Pickup = self:GetWorld():SpawnActor(...)
end

-- ✅ 해결: 서버에서만 스폰
function M:SpawnPickup()
    if not self:HasAuthority() then return end
    local Pickup = self:GetWorld():SpawnActor(...)
end
```