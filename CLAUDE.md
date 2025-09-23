
# 🚨🚨🚨 Every Code's GENERAL Guidelines 🚨🚨🚨
## Pre-CodeGeneration Step
- 설계와 구현 방향성에 대한 논의를 커뮤니케이션해서 방향성을 일치 시킨다.
- 설계 대로 구현을 원하는지 확답을 받은 뒤 코드를 생성한다.

## CodeGeneration Step
- ❌ 요청하지 않은 불필요한 코드는 생성하지마. 오버엔지니어링 하지마.
- ❌ 꼭 필요한 경우가 아니라면, C++ 코드를 통한 개발은 **지양**한다.
- ❌ 최적화는 생각하지마.

- 👌 Use KISS, DRY, SOLID, YAGNI, SRP, SoC - Clean Code, Claude - keep everything to a minimum!
- 👌 간결한 코드가 최우선. 
- 👌 Focus on delivering minimum viable functionality. 
- 👌 No excessive fail safe checks that we already handled earlier.
- 👌 Modular design with clear separation of concerns

### Blueprint - Lua
- Lua에서 사용할 변수는 Replicate 변수가 아니라면 Lua에서 선언해서 사용한다.
- Lua에서 사용할 RPC 함수, OnRep_*(ReplicationNotify) 함수는 Blueprint에서 선언하고 Lua에서 사용 및 Override 해야한다.
- Lua에서 Blueprint의 Tick을 override해야할 때, 반드시 Blueprint에서 해당 노드를 활성화시켜야한다.
### 주석
- 코드 주석에는 이모지를 최소한으로 쓴다.
- Korean comments are used throughout the codebase

## Post-CodeGeneration Step
- 생성/삭제/수정 된 파일 목록을 리스팅해준다.
- 코드 생성/삭제/수정 내역에 대한 간략한 설명을 해준다.

# 🎮 Unreal Engine Multiplayer Game Project

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
- This project is dedicated server based multiplayer game. 
- This project use **UnLua** plugin forked from [UnLua](https://github.com/Tencent/UnLua).
- Use A FEW C++ code, ALMOST ALL logic runs with Blueprints and Binded Lua module.

## 📋 Tech Stack
- **Engine**: Unreal Engine 5.6
- **Scripting**: UnLua Plugin (Lua 5.4.4)
- **Development Focus**: Blueprint + Lua (C++ 최소화)
- **Network**: Dedicated Server Architecture

## 🎯 Core Principles
1. **C++ 사용 최소화**: 리플렉션이 필요한 경우만 C++ 모듈 작성
2. **Blueprint**: UI, Network RPC 정의, Event Dispatcher
3. **Lua**: 게임 로직, 상태 관리, 복잡한 계산
4. **항상 리플렉션 확인**: Native 코드 접근 시도 금지

## 📁 Project Structure
```
/Content
  /Blueprints
    /Core         # 핵심 게임플레이 Actor BP
    /UI           # Widget Blueprint
    /Network      # Replicated Actor/Component BP
    /Data         # DataAsset, DataTable BP
  /Scripts        # UnLua 스크립트
    /Actor        # Actor 바인딩 (BP_*.lua)
    /Component    # Component 바인딩
    /Lib          # 공통 라이브러리 (G_*.lua)
    /Utils        # 유틸리티 함수
  /Maps
    /Test         # 테스트 맵
    /Game         # 실제 게임 맵
```

## 🔧 UnLua Binding Rules
- **Actor Binding**: `BP_ActorName` → `LuaActorName.lua`
- **Component**: `BP_{ComponentName}Component` `Lua{ComponentName}Component.lua`
- **파일 위치**: 반드시 `/Content/Scripts/` 하위

## 🚨 NOT TO DO
- `/Source/Core/` - 엔진 코어 모듈
- `*.generated.h` - 자동 생성 파일
- `/Intermediate/` - 빌드 캐시
- Blueprint의 Construction Script에서 Lua 호출 금지

## 🔐 Reflection Constraints
| 접근 가능 ✅                                            | 접근 불가 ❌ |
|----------------------------------------------------|------------|
| Reflected UFUNCTION()                              | Native C++ 전용 함수 |
| Reflected UPROPERTY()                              | Private 멤버 변수 |
| Reflected UCLASS(), USTRUCT()                      | Template 함수 |
| Blueprint Event/Delegate, DynamicMulticastDelegate | Inline 함수 |

## 🎮 Network Replication
- **RPC**: Blueprint에서 정의 → Lua에서 호출
- **Property**: `Replicated` 설정은 Blueprint에서
- **Authority Check**: `HasAuthority()` 필수
- 상세 가이드 참조: @.claude/docs/network_replication.md

## 📚 Essential Documentation
- **UnLua Plugin Description**: @.claude/docs/unlua_plugin_description.md
  - **When to use plugin description documentation:**
    - For deep technical implementation details
    - When extending or modifying plugin functionality
    - For advanced testing and debugging workflows
    - When working with specific extension libraries
- **Lua Comment Rule**: @.claude/docs/unlua_comment_rule.md
- **UnLua API Reference**: @.claude/docs/unlua_api_reference.md
- **Code Patterns & Samples**: @.claude/docs/code_patterns.md
- **Known Issues**: @.claude/docs/known_issues.md
- **Reflection Guide**: @.claude/docs/unlua_reflection_guide.md
- **Network Guide**: @.claude/docs/unlua_network_replication.md

## 🔤 Terminology
- Unreal Engine 용어를 그대로 사용.

## 💡 Custom Commands (ClaudeCode) (추후 작업이 필요한 상태. 아직은 작업 안함.)
- `bp2lua`: Blueprint 노드를 Lua 코드로 변환
- `create-actor`: Actor BP + Lua 템플릿 생성
- `add-rpc`: RPC 함수 템플릿 추가