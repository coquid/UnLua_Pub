---@class BP_SampleCharacter_C : ACharacter
---@field public lua_Num number 단순히 lua에서 사용할 num.
---@field IsDead boolean 죽었는가?
---@field BodyDuration number 몸의 지속시간
---@field BoneName string bone 이름
---@field Health number 현재 체력
---@field MaxHealth number 최대 체력
local LuaSampleCharacter = UnLua.Class() ---@type BP_SampleCharacter_C 

function LuaSampleCharacter:Initialize(Initializer)
    self.IsDead = false
    self.BodyDuration = 3.0
    self.BoneName = nil
    local Health = 100
    self.Health = Health
    self.MaxHealth = Health
    
    self.bReplicates = true;
end

function LuaSampleCharacter:UserConstructionScript()
end

function LuaSampleCharacter:ReceiveBeginPlay()
    local Weapon = self:SpawnWeapon()
    if Weapon then
        Weapon:K2_AttachToComponent(self.WeaponPoint, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget)
        self.Weapon = Weapon
    end

    self.Overriden.ReceiveBeginPlay()
end

function LuaSampleCharacter:StartFire_Server_RPC()
    self:StartFire_Multicast()
end

function LuaSampleCharacter:StartFire_Multicast_RPC()
end

function LuaSampleCharacter:StopFire_Server_RPC()
end

function LuaSampleCharacter:StopFire_Multicast_RPC()
end

function LuaSampleCharacter:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
end

function LuaSampleCharacter:Died_Multicast_RPC(DamageType)
end

function LuaSampleCharacter:Destroy(Duration)
    self:K2_DestroyActor()
end

return LuaSampleCharacter

