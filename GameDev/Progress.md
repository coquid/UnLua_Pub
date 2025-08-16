# 개발 일지

---

## 📅 2024-XX-XX (오늘)
### 🔨 오늘 작업한 것
- GameDev 문서 구조 생성 및 템플릿 작성
- Design.md, Tasks.md, Progress.md 파일 생성
- CLAUDE.md 파일 게임 개발용으로 개선

### 📚 배운 것 / 발견한 것
- UnLua 프로젝트의 문서 구조와 관리 방법
- Blueprint와 Lua 스크립트 연동을 위한 파일 네이밍 규칙
- Enhanced Input 시스템 사용법과 Lua 바인딩 방법

### 📋 내일 할 일
- 실제 게임 기획서 작성 (Design.md에 구체적인 게임 아이디어 입력)
- BP_PlayerCharacter 블루프린트 생성
- UnLua 바인딩 테스트

### 💭 메모
- UnLua 바인딩할 때 GetModuleName에서 반환하는 경로는 `Content/Script/` 기준 상대경로
- Enhanced Input 사용시 `Content/Script/UnLua/EnhancedInput.lua` 참조 필요
- Blueprint 이름이 `BP_Something`이면 Lua 파일은 `BP_Something_C.lua`로 생성

### 🚧 발생한 문제 & 해결책
**문제**: 없음 (아직 실제 구현 시작 전)
**해결**: 해당없음

---

## 📅 템플릿 (복사해서 사용)

### 🔨 오늘 작업한 것
- 
- 
- 

### 📚 배운 것 / 발견한 것
- **UnLua 관련**: 
- **Blueprint 관련**: 
- **UE 일반**: 
- **게임 개발**: 

### 📋 내일 할 일
- 
- 
- 

### 💭 메모
- 
- 

### 🚧 발생한 문제 & 해결책
**문제**: 
**시도한 해결방법**: 
1. 
2. 
**최종 해결책**: 
**참고 자료**: 

### ⭐ 주요 성과
- 
- 

### 🎯 진행률 체크
- [ ] 오늘 계획한 작업 완료
- [ ] 내일 작업 계획 수립
- [ ] 발생한 이슈 정리
- [ ] 학습 내용 정리

---

## 📝 자주 참조하는 정보

### UnLua 관련
- **바인딩 방법**: Blueprint에서 UnLuaInterface 구현 → GetModuleName에서 Lua 파일 경로 반환
- **파일 경로**: `Content/Script/` 기준 상대경로 (예: `Player/BP_PlayerCharacter`)
- **Enhanced Input**: `Content/Script/UnLua/EnhancedInput.lua` 참조
- **디버깅**: 콘솔에서 `lua.do print("Hello")` 로 Lua 코드 테스트

### Blueprint 네이밍 규칙
- **액터**: `BP_` 접두사 (예: `BP_PlayerCharacter`)
- **위젯**: `WBP_` 접두사 (예: `WBP_MainMenu`)
- **게임모드**: `BP_GameMode`, `BP_GameState` 등
- **컴포넌트**: `BC_` 접두사 (예: `BC_Health`)

### Lua 스크립트 구조
```lua
-- BP_PlayerCharacter_C.lua
local BP_PlayerCharacter_C = {}

function BP_PlayerCharacter_C:ReceiveBeginPlay()
    print("Player Character Begin Play")
end

function BP_PlayerCharacter_C:ReceiveTick(DeltaSeconds)
    -- 매 프레임 실행
end

return BP_PlayerCharacter_C
```

### 유용한 콘솔 명령어
- `lua.do <code>`: Lua 코드 실행
- `lua.dofile <path>`: Lua 파일 실행
- `lua.gc`: 가비지 컬렉션 강제 실행
- `lua.mem`: 메모리 사용량 확인

### 자주 사용하는 UE 함수 (Lua에서)
- `UE.UKismetMathLibrary`: 수학 계산
- `UE.UKismetSystemLibrary`: 시스템 함수
- `UE.UGameplayStatics`: 게임플레이 유틸리티
- `self:GetWorld()`: 현재 월드 가져오기
- `self:K2_GetActorLocation()`: 액터 위치 가져오기

---

## 📊 주간 리뷰 템플릿

### 이번 주 요약 (2024-xx-xx ~ 2024-xx-xx)
**주요 성과**:
- 
- 

**완료한 작업**:
- [x] 
- [x] 

**미완료 작업 (다음 주로 이월)**:
- [ ] 
- [ ] 

**배운 것**:
- 
- 

**어려웠던 점**:
- 
- 

**다음 주 계획**:
- 
- 

**개선할 점**:
- 
- 

---

## 🎯 마일스톤 체크

### 프로토타입 단계 (목표: 2024-xx-xx)
- [ ] 플레이어 이동 구현
- [ ] 기본 UI 구현
- [ ] 핵심 게임플레이 1개 구현
- [ ] 간단한 레벨 1개 완성

### 알파 단계 (목표: 2024-xx-xx)
- [ ] 모든 핵심 기능 구현
- [ ] 사운드 시스템 추가
- [ ] 3개 레벨 완성
- [ ] 게임 시작부터 끝까지 플레이 가능

### 베타 단계 (목표: 2024-xx-xx)
- [ ] 모든 기능 구현 완료
- [ ] 밸런싱 완료
- [ ] 버그 수정 완료
- [ ] UI/UX 최종 조정

### 출시 준비 (목표: 2024-xx-xx)
- [ ] 최종 테스트 완료
- [ ] 성능 최적화 완료
- [ ] 문서화 완료
- [ ] 배포 준비 완료