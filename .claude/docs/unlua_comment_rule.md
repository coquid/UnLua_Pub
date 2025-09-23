
## Somneko LuaLS의 Annotation 사용법

아래는 LuaLS의 주요 Annotation별 사용법과 예시를 이해하기 쉬운 형태로 정리한
요약입니다.[github](https://github.com/LuaLS/lua-language-server/wiki/Annotations#as)

---

**@alias**

- 타입에 별명이나 enum을 만들어 재사용할 수 있게 합니다.
- 예시:

  `lua*---@alias Color "red"|"blue"|"green"*`

**@as**

- 어떤 표현식에 타입을 강제로 지정합니다.
- 반드시 `-[[@as 타입]]` 댓글 형태로 사용하며, `--@as`는 사용 불가.
- 예시:

  `lualocal x = y *--[[@as string]]-- 배열 표기 시: --[=[@as string[]]=]*`

**@async**

- 비동기 함수임을 명시, IDE에서 await 등 힌트 제공.
- 예시:

  `lua*---@async*
  function fetchData() ... end`

**@cast**

- 변수에 대해 타입을 추가/제거/변환합니다.
- 예시:

  `lua*---@cast foo +number|string  -- foo에 number, string 타입 추가---@cast foo -string         -- foo에서 string 타입 제거*`

**@class**

- 테이블을 클래스처럼 선언하고 타입으로 사용.
- 상속 지원: `--@class Child:Parent`
- 예시:

  `lua*---@class Person---@field name string---@field age integer*`

**@deprecated**

- 함수, 변수 등이 더 이상 사용되지 않음을 경고.
- 예시:

  `lua*---@deprecated*
  function oldAPI() end`

**@diagnostic**

- 진단 메시지 상태를 한 줄 혹은 파일 단위로 토글.
- 예시:

  `lua*---@diagnostic disable-next-line: undefined-global*`

**@enum**

- 테이블에 런타임 enum 기능을 부여.
- 예시:

  `lua*---@enum Weekday*
  local Weekday = { Sun=1, Mon=2, ... }`

**@field**

- 클래스/테이블의 필드 타입 지정.
- 예시:

  `lua*---@field health number---@field private mana number  -- 접근 제한자 표기 가능*`

**@generic**

- 타입 파라미터(제네릭) 지정, 실험적 기능.
- 예시:

  `lua*---@generic T---@param t T---@return T*`

**@meta**

- 해당 파일이 라이브러리 정의용(메타)임을 명시.
- 예시:

  `lua*---@meta*`

**@module**

- 파일을 require로 불러올 모듈로 선언.
- 예시:

  `lua*---@module 'my_module'*`

**@nodiscard**

- 함수 반환값이 반드시 사용되어야 함을 지시.
- 예시:

  `lua*---@nodiscard*
  function mustUse() return 1 end`

**@operator**

- 메타메서드의 타입 정보를 명시(예: __add, __call).
- 예시:

  `lua*---@operator add(Person): Person*`

**@overload**

- 함수 오버로딩(추가 시그니처) 정의.
- 예시:

  `lua*---@overload fun(a: string): number*`

**@package**

- 함수/변수의 접근범위를 파일 내부로 제한.
- 예시:

  `lua*---@package*
  local function internal() end`

**@param**

- 함수 파라미터의 타입과 설명 문서화. `?`는 optional.
- 예시:

  `lua*---@param x number---@param y? string  -- y는 optional*`

**@private / @protected**

- 클래스 멤버의 접근 제한: private(자기 클래스만), protected(자식 허용).
- 예시:

  `lua*---@private*
  function selfSecret() end`

**@return**

- 함수 반환값 타입 및 설명. 이름 지정과 optional, 다중 반환 가능.
- 예시:

  `lua*---@return string result 설명*`

**@see / @source**

- 참고 주석, 코드 소스 경로 링크(IDE 기능 용도, 효과는 크지 않음).
- 예시:

  `lua*---@see 설명*`

**@type**

- 변수의 타입을 명시. 유니온(`|`), 배열(`[]`) 등 지원.
- 예시:

  `lua*---@type number|string[]*
  local val`

**@vararg**

- 함수의 가변 인자 표기(비추천, @param으로 대체 권장).
- 예시:

  `lua*---@vararg number*`

**@version**

- 지원/요구 Lua 버전을 명시.
- 예시:

  `lua*---@version >5.1, <5.4*`

---

각 Annotation별 파트에서 예시 코드, option, 주요 목적을 중심으로 정리했습니다. Lua 5.4 기반에서도 대부분 활용 가능하며, 특이 사항은 공식 Wiki 최신 버전을 참고하면
됩니다.[github](https://github.com/LuaLS/lua-language-server/wiki/Annotations#as)

Annotations · LuaLS/lua-language-server Wiki ·
GitHub[github](https://github.com/LuaLS/lua-language-server/wiki/Annotations#as)

1. [https://github.com/LuaLS/lua-language-server/wiki/Annotations#as](https://github.com/LuaLS/lua-language-server/wiki/Annotations#as)