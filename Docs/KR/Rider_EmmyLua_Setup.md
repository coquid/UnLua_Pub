# Rider와 EmmyLua 를 사용하고 싶은데, intelliSense 설정방법을 단계별로 알려줘

JetBrains Rider에서 EmmyLua를 사용하여 UnLua Lua 스크립트의 IntelliSense(코드 자동완성 및 문법 검사)를 설정하는 단계별 방법을 안내해 드리겠습니다.

***

## Rider + EmmyLua IntelliSense 설정 단계

### 1. Rider에서 EmmyLua 플러그인 설치

- Rider를 실행하고, `File > Settings` (또는 `Ctrl+Alt+S`)로 이동합니다.
- 좌측 메뉴에서 `Plugins` 선택 후, `Marketplace`에서 "EmmyLua"를 검색합니다.
- EmmyLua 플러그인을 설치하고 Rider를 재시작합니다.


### 2. UnLua 프로젝트에서 IntelliSense 파일 생성

- Unreal Engine 에디터 내에서 UnLua 플러그인의 툴바 아이콘을 찾습니다.
- 아이콘 클릭 후 드롭다운 메뉴에서 **"Generate IntelliSense"** (또는 유사 명칭) 항목을 선택해 Lua용 코드 자동완성 파일을 생성합니다.
- 첫 생성 시 전체 스캔이므로 시간이 걸릴 수 있으며, 이후에는 Unreal Engine이나 블루프린트 변경 시 자동 업데이트됩니다.


### 3. Rider에서 IntelliSense용 디렉터리 솔루션에 추가

- Rider에서 프로젝트 솔루션 열기 (예: `.sln` 파일).
- 솔루션 탐색기에서 우측 상단의 **"Show All Files"** 버튼을 눌러 숨겨진 파일 및 폴더를 표시합니다.
- 다음 두 폴더를 찾아서 각각 오른쪽 클릭 후 `Tools > Attach to Solution` 선택:
    - `Content/Scripts` (Lua 스크립트 실제 파일들이 위치)
    - `Plugins/UnLua/Intermediate/IntelliSense` (자동 생성된 IntelliSense용 Lua 파일들)
- 이후에는 `Show All Files`를 다시 눌러 불필요한 폴더는 숨기고, Lua 코드 폴더는 그대로 유지할 수 있습니다.


### 4. EmmyLua 태그 주석 활용으로 정확도 향상

- Lua 코드 내에 EmmyLua 문법(`---@class`, `---@param` 등)을 활용해 타입 정보를 주석으로 명시하면 IntelliSense가 더 정확해집니다.
- 예:

```lua
---@class MyClass
local obj = {}

---@param param1 string
function obj:MyFunction(param1)
    -- function body
end
```

- 이런 주석은 함수 시그니처, 자동완성, 매개변수 힌트 등에 도움이 됩니다.


### 5. Rider에서 인덱싱 및 캐시 관리

- 처음 추가 후 인덱싱이 완료될 때까지 기다립니다.
- 인텔리센스 동작이 이상할 경우, Rider의 `File > Invalidate Caches / Restart` 기능을 사용해 캐시를 초기화할 수 있습니다.
- 필요 시 Unreal Engine 프로젝트 파일을 새로 생성하거나 업데이트해 Rider가 최신 프로젝트 구조를 파악하도록 합니다.

***

## IntelliSense 수준 및 활용 팁

- Unreal Engine의 UCLASS, UPROPERTY, UFUNCTION 등 핵심 메타데이터를 기반으로 Lua 코드 자동완성을 지원합니다.
- 블루프린트 이벤트 오버라이드, 기본 구조체, 열거형 등에 대한 함수 및 속성 완성도 가능합니다.
- 다만, Lua의 동적 특성으로 인해 완벽한 타입 추론은 한계가 있으며, 복잡한 동적 코드나 커스텀 타입은 수동 주석이 필요합니다.
- Rider와 EmmyLua 조합은 VSCode 대비 더욱 안정적이고 강력한 C++/Lua 혼합 코드 편집 환경을 제공합니다.
- 향후 Lua용 디버거 연동도 가능하지만, 별도 환경 구성이 필요할 수 있습니다.

***

필요하다면 자세한 EmmyLua 주석 문법이나 추가 설정, Lua 디버깅 환경 구성법까지도 안내해 드릴 수 있습니다.
Rider에서 UnLua 개발 효율을 대폭 올릴 수 있는 좋은 선택입니다.

궁금한 점 있으면 언제든 문의해 주세요.

<div style="text-align: center">⁂</div>