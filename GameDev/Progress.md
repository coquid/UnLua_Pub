# 개발 일지

---

## 📅 2025-08-17 (오늘)
### 🔨 오늘 작업한 것
- **UI 시스템 완성**: WBP_GameHUD와 WBP_GameComplete Lua 스크립트 완성
- **큐브 스폰 시스템**: GameManager에서 10개 큐브 자동 배치 시스템 구현
- **맵 경계 시스템**: 플레이어가 맵 밖으로 나가지 않도록 보정 시스템 추가
- **조명 관리**: BP_LevelManager를 통한 기본 조명 및 환경 설정 시스템 구현
- **게임 재시작 기능**: 완료 화면에서 재시작 버튼 연동 완료
- **Blueprint 구현**: 모든 UI 위젯 Blueprint 생성 및 Lua 연동 완료
- **버튼 이벤트 수정**: UnLua에서 올바른 델리게이트 바인딩 방식으로 버튼 클릭 이벤트 수정
- **로그 정리**: 모든 스크립트의 불필요한 디버그 로그 정리 및 최적화
- **전체 테스트**: MVP 게임 전체 플로우 테스트 및 완성 확인

### 📚 배운 것 / 발견한 것
- **Widget-GameManager 연동**: UI 위젯과 게임 매니저 간 상호 참조 설정 방법
- **동적 액터 스폰**: `UGameplayStatics.BeginDeferredActorSpawnFromClass` 사용법
- **FVector 및 FTransform**: 위치 계산 및 스폰 파라미터 설정
- **맵 경계 체크**: Tick 이벤트에서 실시간 위치 보정 구현
- **조명 시스템**: 디렉셔널 라이트, 스카이 라이트 프로그래밍 방식 설정
- **UnLua 델리게이트 바인딩**: `self.ButtonName.OnClicked:Add(self, self.FunctionName)` 방식
- **Blueprint IsVariable 설정**: Lua에서 위젯 접근을 위한 필수 설정
- **레벨 재시작**: `UKismetSystemLibrary.ExecuteConsoleCommand(World, "RestartLevel")` 사용법

### 📋 다음 단계 선택지
- **Phase 2 기능 추가**: 타이머, 사운드, 시각 효과, 난이도 시스템 등
- **게임 폴리싱**: 현재 게임의 품질 향상 및 세부 개선
- **새로운 게임 프로젝트**: 다른 장르나 컨셉의 게임 개발 시작
- **UnLua 고급 기능**: 더 복잡한 UnLua 시스템 및 최적화 학습

### 💭 메모
- **큐브 스폰 위치**: 10개 위치가 고정되어 있음, 랜덤 배치로 변경 가능
- **게임 재시작**: 레벨 재로드 대신 인게임 리셋 방식 사용
- **위젯 연동**: FindGameManager → SetHUDWidget/SetVictoryWidget 패턴으로 상호 참조
- **Blueprint 경로**: `/Game/ClaudeCode/BP_Cube.BP_Cube_C` 형식으로 하드코딩됨

### 🚧 발생한 문제 & 해결책
**문제**: GameManager와 UI Widget 간 참조 설정이 복잡함
**시도한 해결방법**: 
1. World.GameManagerInstance에 전역 참조 저장
2. Widget에서 GameManager 찾아서 자신을 등록하는 방식
**최종 해결책**: 양방향 참조 설정 (GameManager ↔ Widgets)
**참고 자료**: UnLua 공식 튜토리얼의 Widget 바인딩 예제

### ⭐ 주요 성과
- **🎉 MVP 완전 완성**: 모든 기능이 정상 작동하는 완성된 게임
- **체계적인 아키텍처**: GameManager 중심의 깔끔한 시스템 설계
- **재사용 가능한 코드**: 각 스크립트가 독립적이면서도 잘 연동됨
- **확장성 확보**: Phase 2 기능 추가를 위한 기반 구축 완료
- **UnLua 마스터**: 복잡한 UI 이벤트 바인딩 및 델리게이트 시스템 완전 이해
- **깔끔한 코드**: 로그 정리를 통한 운영 환경에 적합한 코드 품질

### 🎯 진행률 체크
- [x] MVP 모든 기능 완성 (Lua 스크립트 + Blueprint)
- [x] 버튼 클릭 이벤트 수정 완료
- [x] 로그 정리 및 코드 품질 개선 완료
- [x] 전체 시스템 테스트 완료
- [x] 발생한 이슈 정리 (Widget 연동, 델리게이트 바인딩)
- [x] 학습 내용 정리 (UnLua UI 시스템, 이벤트 처리)

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