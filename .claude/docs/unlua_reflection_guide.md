# 🔍 Reflection Guide

## 📌 Core Rule: UnLua는 리플렉션된 요소만 접근 가능

### 리플렉션이란?
Unreal Engine의 리플렉션 시스템은 C++ 코드를 런타임에서 접근 가능하게 만드는 메타데이터 시스템입니다.
UnLua는 이 리플렉션 시스템을 통해서만 C++ 코드에 접근할 수 있습니다.

## ✅ 접근 가능 (Reflected)

### 1. UFUNCTION 매크로
```cpp
// C++ 헤더
UCLASS()
class AMyActor : public AActor
{
    // ✅ 접근 가능: BlueprintCallable
    UFUNCTION(BlueprintCallable, Category = "Combat")
    void TakeDamage(float Damage);
    
    // ✅ 접근 가능: BlueprintPure (const 함수)
    UFUNCTION(BlueprintPure, Category = "Stats")
    float GetHealth() const;
    
    // ✅ 접근 가능: BlueprintImplementableEvent
    UFUNCTION(BlueprintImplementableEvent)
    void OnDeath();
    
    // ✅ 접근 가능: BlueprintNativeEvent
    UFUNCTION(BlueprintNativeEvent)
    void OnHit();
    virtual void OnHit_Implementation();
};
```

```lua
-- Lua에서 사용
function M:UseFunctions()
    -- 모두 접근 가능
    self:TakeDamage(10.0)
    local Health = self:GetHealth()
    self:OnDeath()
    self:OnHit()
end
```

### 2. UPROPERTY 매크로
```cpp
// C++ 헤더
UCLASS()
class AMyCharacter : public ACharacter
{
    // ✅ 접근 가능: BlueprintReadWrite
    UPROPERTY(BlueprintReadWrite, Category = "Stats")
    float MaxHealth;
    
    // ✅ 접근 가능: BlueprintReadOnly
    UPROPERTY(BlueprintReadOnly, Category = "Stats")
    float CurrentHealth;
    
    // ✅ 접근 가능: EditAnywhere (에디터에서 설정, 런타임 읽기)
    UPROPERTY(EditAnywhere, BlueprintReadOnly)
    int32 TeamID;
    
    // ✅ 접근 가능: Replicated
    UPROPERTY(Replicated, BlueprintReadWrite)
    bool bIsAlive;
};
```

```lua
-- Lua에서 사용
function M:UseProperties()
    -- 읽기/쓰기 가능
    self.MaxHealth = 100
    local Max = self.MaxHealth
    
    -- 읽기만 가능
    local Current = self.CurrentHealth
    -- self.CurrentHealth = 50  -- 에러! ReadOnly
    
    -- Replicated 속성도 접근 가능
    if self.bIsAlive then
        -- 살아있음
    end
end
```

### 3. UCLASS와 USTRUCT
```cpp
// ✅ 접근 가능: UCLASS
UCLASS(Blueprintable)
class AMyGameMode : public AGameModeBase
{
    GENERATED_BODY()
};

// ✅ 접근 가능: USTRUCT
USTRUCT(BlueprintType)
struct FItemData
{
    GENERATED_BODY()
    
    UPROPERTY(BlueprintReadWrite)
    FString ItemName;
    
    UPROPERTY(BlueprintReadWrite)
    int32 ItemCount;
};
```

```lua
-- Lua에서 사용
function M:UseStructs()
    -- 구조체 생성 및 사용
    local ItemData = UE.FItemData()
    ItemData.ItemName = "Sword"
    ItemData.ItemCount = 1
    
    -- 함수에 전달
    self:AddItemToInventory(ItemData)
end
```

### 4. UENUM
```cpp
// ✅ 접근 가능: UENUM
UENUM(BlueprintType)
enum class EWeaponType : uint8
{
    None        UMETA(DisplayName = "None"),
    Sword       UMETA(DisplayName = "Sword"),
    Bow         UMETA(DisplayName = "Bow"),
    Magic       UMETA(DisplayName = "Magic")
};
```

```lua
-- Lua에서 사용
function M:UseEnums()
    local WeaponType = UE.EWeaponType.Sword
    
    if self.CurrentWeapon == UE.EWeaponType.Bow then
        -- 활 사용 중
    end
end
```

## ❌ 접근 불가 (Not Reflected)

### 1. 리플렉션 매크로 없는 함수
```cpp
class AMyActor : public AActor
{
public:
    // ❌ 접근 불가: 매크로 없음
    void InternalFunction();
    
    // ❌ 접근 불가: private 함수
private:
    void PrivateHelper();
    
    // ❌ 접근 불가: protected이며 매크로 없음
protected:
    void ProtectedMethod();
    
    // ❌ 접근 불가: inline 함수
    inline void FastFunction() { }
    
    // ❌ 접근 불가: template 함수
    template<typename T>
    void TemplateFunction(T Value);
};
```

### 2. 리플렉션 매크로 없는 변수
```cpp
class AMyActor : public AActor
{
public:
    // ❌ 접근 불가: 매크로 없음
    float InternalHealth;
    
    // ❌ 접근 불가: static 변수
    static int32 StaticCounter;
    
    // ❌ 접근 불가: private 멤버
private:
    FVector SecretLocation;
    
    // ❌ 접근 불가: 포인터 (BlueprintReadWrite 없이)
    UObject* RawPointer;
};
```

### 3. Native 전용 타입
```cpp
// ❌ 접근 불가: std 라이브러리
std::vector<int> Numbers;
std::string Name;

// ❌ 접근 불가: Native 구조체 (USTRUCT 없음)
struct NativeData
{
    int Value;
    float Speed;
};

// ❌ 접근 불가: typedef/using
typedef int32 MyInt;
using MyFloat = float;
```

## 📝 Quick Reference

### 접근 가능 체크리스트

| 요소       | 필요 조건                         | Lua 사용 예시                    |
|----------|-------------------------------|------------------------------|
| 함수       | UFUNCTION(BlueprintCallable)  | `Actor:MyFunction()`         |
| 변수       | UPROPERTY(BlueprintReadWrite) | `Actor.MyVariable`           |
| 읽기 전용    | UPROPERTY(BlueprintReadOnly)  | `local Val = Actor.ReadOnly` |
| 클래스      | UCLASS(Blueprintable)         | `UE.AMyClass`                |
| 구조체      | USTRUCT(BlueprintType)        | `UE.FMyStruct()`             |
| Enum     | UENUM(BlueprintType)          | `UE.EMyEnum.Value`           |
| 이벤트      | BlueprintImplementableEvent   | Override 가능                  |
| Delegate | DECLARE_DYNAMIC_MULTICAST     | `:Add()`, `:Remove()`        |

### 일반적인 실수
```lua
-- ❌ Native 함수 직접 호출 시도
Actor:GetPrivateData()  -- nil

-- ❌ 매크로 없는 변수 접근
local Value = Actor.InternalCounter  -- nil

-- ❌ C++ 전용 타입 사용
local Vector = std.vector()  -- 에러

-- ✅ 올바른 접근
Actor:GetPublicData()  -- UFUNCTION(BlueprintCallable)
local Value = Actor.PublicCounter  -- UPROPERTY(BlueprintReadWrite)
local Array = UE.TArray(UE.int32)  -- Unreal 타입 사용
```

### 🔄 함수 상속 시 Overridden vs Super 차이점

| 구분         | `self.Overridden` | `self.Super` |
|------------| --- | --- |
| **용도**     | 같은 BP의 Blueprint 구현 호출 | Lua 상속 체인의 부모 호출 |
| **RPC 지원** | ❌ | ✅ |
| **사용 조건**  | 항상 가능 | `UnLua.Class("부모")` 필요 |
|  **호출 대상** | Blueprint Graph | 부모 Lua 코드 |
