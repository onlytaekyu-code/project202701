# Project202701 최종 통합 기획·요구사항 정의서 v0.3

**부제:** 에이전트리스 OS·소프트웨어 인벤토리 및 보안 영향 조사 시스템  
**기준일:** 2026-11-26 | **상태:** 프로토타입 개발 기준안 (운영 승인 전)  
**기준 문서:** Project202701_기획안_v0.2_통합상세설계.md (2026-11-20)  
**대상:** 개발자, AI 코딩 에이전트, 기획·보안·운영 담당자

> 개발 착수에 필요한 추가 기획 결정은 없다. 사용자 확정사항과 위임된 기술 선정안을 기준으로 기능이 실제로 동작하는 프로토타입을 개발한다. 실제 개발 서버 연결은 해당 서버 담당자에게 허가받은 계정·접속 경로·호스트 신원을 검증한 뒤 실행한다. 운영 전환 승인을 의미하지 않는다.

## 0. 문서 사용법 및 변경사항

- [확정] 사용자 지정 기술, 개발 서버 검증, DB 우선, 웹·엑셀 관리, 자동/수동 비교 UI, Linux·Unix·Windows 프로토타입 및 v0.1 불변 원칙.
- [선정] 사용자가 기술 선정 등을 위임한 범위에서 결정한 개발 기준. 성능 1위 또는 모든 환경 검증 완료라는 의미는 아니다.
- [개발 기본값] 개발자가 변경 가능한 초기 설정. 운영 정책 및 성능 SLA가 아니다.
- [유보] 프로토타입 후 결정할 운영 정책. 연결 시점에 필요한 최소 안전 조건은 유보할 수 없다.
- v0.3은 v0.2의 기능 ID를 유지하되 개발 단계와 기술 스택을 재배치한다. v0.2의 운영 목표와 지원 후보는 폐기하지 않고 별도 관리한다. 원본은 변경 이력으로 별도 보존한다.

| 변경 항목 | v0.2 | v0.3 |
|---|---|---|
| 개발 방식 | Linux부터 5단계 확장 | 3개 OS군을 프로토타입에 포함, 지원 깊이는 단계화 |
| 기술 | Python/PostgreSQL 후보 | Java 25 + Spring Boot MVC + JSP/Vanilla JS + PostgreSQL |
| 수집 | 자체 엔진/Ansible 비교 | MINA SSHD 제한 엔진, WinRM Java 별도 어댑터 선정 |
| 수동 수정 | 관리자 취약 판단 위주 | OS·소프트웨어 관측값과 작업자 관리값 별도 보존, 필드별 정합성 관리 |
| 데이터 | DB 중심 | 모든 업무 기록 DB 우선, 엑셀 업·다운로드 표준화 |
| 정책 | 일부 개발 전 승인 | 운영 상세정책은 후속, 프로토타입에는 최소 안전 가드 및 설정 확장 구조 |

## 1. 목표와 범위

### 1.1 사용자 가치

자산을 등록한 뒤 OS, 패키지 및 주요 소프트웨어의 버전과 실행 정보를 수집한다. 신규 보안 이슈가 발생하면 제품·버전·OS·담당자·노출 상태 등을 검색해 영향 후보를 도출한다. 수집 오차는 작업자가 관리값으로 수정하며 원본과 불일치 여부를 쉽게 확인한다. 최종 취약 여부는 관리자가 근거를 기록해 판단한다.

| 목표 ID | 개발 결과 |
|---|---|
| OBJ-01 | 자산 신규 등록, 엑셀 일괄 등록, 즉시/정기 수집 골격 |
| OBJ-02 | 제품·버전별 통합 검색, 확인 필요 분리, 엑셀 출력 |
| OBJ-03 | 원본·수동 수정·판단·조치 이력 및 비교 상태 |
| OBJ-04 | 에이전트리스, 읽기 전용 수집, 자격증명 격리 |
| OBJ-05 | 수십 대 실사용 및 수백 대 확장 검증 가능한 큐/작업자 구조 |

### 1.2 프로토타입 포함 범위

- 개발 서버의 Linux, Unix, Windows를 대상으로 실제 수집. 별도의 모의 수집 어댑터는 자동 테스트·시연에 사용하되 실제 결과와 엄격히 분리한다.
- 자산·OS·소프트웨어·제품 사전·탐지 규칙·이슈·판단의 등록 및 변경, 필터/정렬/페이지 이동, 엑셀 입출력, 변경·감사 기록.
- 제품별 버전 비교와 영향 후보 조사, 필드 단위 관리값 보정, 불일치 확인 및 원복.
- 고정 읽기 동작, 최소한의 검증/시험/활성화/롤백, 큐 처리와 실패 진단.
- 기본 로그인 및 작업자 식별, 권한 경계, 수집기 신원 검증, 자원 제한. 화면 및 데이터 흐름 검증 중심.

### 1.3 비범위 및 확장 범위

자동 패치, 원격 터미널, 임의 명령 실행, 대상 설정 변경, 자동 취약 확정, CVE DB 자체 운영, 네트워크 대역 탐색, 전사 CMDB 대체는 제외. 네트워크 장비, 컨테이너 및 중첩 JAR, npm/pip 전체 탐지, KEV/EPSS 등 외부 자료 자동 연동은 후속 확장 후보. 모든 Unix 제품/버전의 완전 지원은 약속하지 않는다. 외부 노출은 별도 확인 근거 없이는 미확인으로 둔다.

## 2. 최종 결정 등록부

| ID | 결정 | 개발 반영 / 상태 |
|---|---|---|
| DEC-01 | Java 제한형 수집 엔진 | [선정] MINA SSHD + WinRM Java. 실제 동시성·비용 실측 후 최적화 |
| DEC-02 | 기술 스택 | [확정/선정] Java 25, PostgreSQL, JSP, HTML, Vanilla JS; 세부 기술 §3 |
| DEC-03 | 신규 자산 등록 | [확정] 기존 목록 연동 필수 아님. 웹·엑셀 신규 등록 |
| DEC-04 | 네트워크 | [유보] 운영 방화벽/NAT/구역. 실제 테스트 전 허가된 경로·출발지 IP·목적지 검증 |
| DEC-05 | 탐지 및 수정 | [확정] 탐지 후 작업자 수동 수정/등록, 원본 보존. 규칙 시험/활성화/이력 골격 |
| DEC-06 | 허용 경로 | [유보] 운영 목록·승인 체계. 개발 단계는 수집기 고정 허용목록 |
| DEC-07 | 데이터 관리 | [확정] DB 우선, 웹 입력, 엑셀 양식 업·다운로드. 규칙 JSONB는 DB 내부 형식 |
| DEC-08 | 계정 권한 | [유보] 운영 상세 권한. 개발용 승인된 최소 읽기 권한, 기본 sudo 금지 |
| DEC-09 | 수집 주기 | [유보] 운영 일정. 즉시 수집 구현, 정기 수집 골격과 개발 설정값 |
| DEC-10 | Windows 인증 | [유보] 운영 인증 정책. 실제 테스트에 필요한 승인된 인증 및 TLS 검증 필수 |
| DEC-11 | 관리자 권한 | [유보] 상세 RBAC/SSO/MFA 정책. 개발용 기본 인증·권한 및 작업자 기록 |
| DEC-12 | 성능·한도 | [유보] 운영 동시성/SLA. 개발 단계 유한 기본 한도 적용 |
| DEC-13 | 인터넷 노출 | [유보] 운영 확인 방법. 관리자 입력 및 증거·시각 별도 보존 |
| DEC-14 | 보존·복구 | [유보] 운영 보존·RPO/RTO. 개발 DB 백업/복구 및 큐 회복 기능 최소 검증 |
| DEC-15 | 지원 범위 | [확정] Linux/Unix/Windows 기능 구현 중심, 제품별 범위는 테스트 결과로 결정 |
| DEC-16 | 승인·위험 수용 | [유보] 운영 승인 조직/절차/만료 정책. 규칙·판단 이력 및 상태 구조 유지 |
| FINAL-01 | 실제 테스트 | [확정] 승인받은 개발 서버에서 시험. 모의 어댑터는 보조 수단 |
| FINAL-02 | 데이터 정합성 | [확정] 원본 보존, 수동값 우선, 수정·일치·불일치·확인불가를 화면/필터에 표시 |
| FINAL-03 | 세부 기술 | [선정] §3 기준. 사용자가 최적 기술 선정을 위임 |

기존 제안 DEC-17~58은 §3, §5~13의 개발 기본값 및 §15 운영 유보 항목으로 통합한다. 개별 사전 승인 회의는 요구하지 않는다. 원안 불변 원칙 변경, 신규 원격 프로토콜, 운영 적용, 외부 시스템 연동은 변경 승인 필요.

## 3. 기술 스택 및 선정 근거

| 계층 | 개발 기준 | 선정 근거 / 검증 |
|---|---|---|
| JDK | Eclipse Temurin Java 25 LTS | 기존 개발 환경과 단일 Java 생태계. 보안 패치 반영 |
| 웹 | Spring Boot 4.0.x, Spring MVC, Tomcat 11.0.x | Java 25·Servlet 6.1 호환 [R01] |
| UI | JSP/Jakarta JSTL, HTML5/CSS3, Vanilla JS ES modules | 화면 서버 렌더링+fetch, 별도 Node 빌드 불필요. JSP는 WAR [R02] |
| DB | PostgreSQL 18.x | 지원되는 안정 메이저, JSONB·트랜잭션·SKIP LOCKED [R03/R04] |
| DB 접근 | MyBatis Starter 4.0.x, HikariCP, PostgreSQL JDBC | 명시적 SQL/복잡 검색·큐 제어, Boot 4.0 계열 호환 [R05] |
| 마이그레이션 | Flyway Community + PostgreSQL DB 모듈 | SQL 버전 관리, DDL 전용 계정, 적용 후 이력 변경 금지 [R06] |
| SSH | Apache MINA SSHD 2.x 안정판 | Apache 2.0, 순수 Java, 클라이언트 재사용 및 다중 세션 [R07] |
| WinRM | MetricsHub WinRM Java 안정판 (2.x 이상 API 기준으로 검토) | Apache 2.0, HTTPS·인증·WQL/고정 조회 지원. 실제 테스트 전 버전/동작 고정 [R08/R09] |
| 병렬 | Java Virtual Thread + Semaphore + 제한된 큐 | 블로킹 I/O 코드 단순화; 무제한 병렬 금지. 라이브러리 자체 I/O 스레드와 별도 실측 |
| 엑셀 | Apache POI XSSF/SXSSF | xlsx 검증·템플릿·출력 스트리밍 [R10] |
| 검증 | Jakarta Validation, Jackson (Boot 관리), 안전한 정규식 RE2/J 후보 | DTO 검증, 스키마 버전, 복잡도 제한. 정규식 호환/안전성 시험 |
| 인증 | Spring Security, 세션 + CSRF | 개발용 개별 계정, BCrypt/Argon2 계열 검증 후 선택, 최소 역할 분리 |
| 로깅 | SLF4J + Logback, Actuator 내부용 | 구조화 로그, 비밀 마스킹, 공개 관리 포트 없음 |
| 빌드 | Maven Wrapper 3.9.x + Boot BOM + Enforcer | 재현 가능 빌드, Java 25 release, 의존성 고정 |
| 테스트 | Boot 테스트, JUnit Jupiter, Mockito, PostgreSQL 통합 테스트 | 실제 PostgreSQL 사용, H2로 큐·버전 비교 검증 대체 금지 |
| 배포 | web.war / collector.jar / db-migrate 실행 단위 | JSP 호환 및 웹-수집기 네트워크 경계 |

**버전 관리:** 위 계열은 선정 기준이다. 최초 빌드에서 최신 보안 수정이 적용된 호환 GA 패치 버전을 확인하고 부모 POM/BOM 및 명시적 관리 목록에 정확히 고정한다. `LATEST`, 동적 범위, SNAPSHOT, 서로 다른 Boot 스타터 계열 혼용 금지. Maven dependency:tree, SBOM, 라이선스 및 알려진 취약점 점검 결과를 `docs/dependency-lock.md`에 기록. 상용 라이선스 기능을 전제로 하지 않는다. PostgreSQL 18 및 Flyway의 실제 버전 조합은 빈 DB 마이그레이션 테스트 필수.

### 3.1 엔진 비교와 성능 검증

| 대안 | 장점 | 이번 선택 |
|---|---|---|
| MINA SSHD | Java 내 제어, 다중 세션, SSH 검증 정책 | Linux/Unix 채택 |
| SSHJ | 간결한 Java SSH 클라이언트 | 비교 후보, 교체 가능한 인터페이스 |
| OpenSSH | 검증된 외부 실행 도구 | 별도 프로세스·출력 관리 부담, 기본 엔진 미채택 |
| Ansible Core | 자동화 플레이북·모듈 | 별도 런타임 및 원격 실행 모델이 프로젝트 구조와 다름. 참고/PoC 비교 후보 |
| MetricsHub WinRM Java | Java 기반 WinRM | Windows 채택 |

MINA SSHD는 완성형 인벤토리 엔진이 아니다. 직접 구현할 것은 작업/대상 정책, 명령 카탈로그, OS별 파서, 증거/정규화, 버전 비교 및 DB 저장이다. 동일 개발 서버에서 접속 시간, 인증 시간, 전체 수집 시간, 처리량, CPU/메모리, 실패율, 정확도와 대상 부하를 측정한다. 공개된 동등 조건 비교 결과가 없어 절대 성능 1위로 주장하지 않는다.

## 4. 아키텍처와 불변 보안 원칙

```mermaid
flowchart LR
  U[내부망 브라우저] --> W[Web WAR / Spring MVC]
  W -->|업무 CRUD · 작업 요청| D[(PostgreSQL)]
  C[Collector JAR / 제한 엔진] -->|작업 claim · 결과 기록| D
  C -->|SSH 읽기| L[Linux / Unix 개발 서버]
  C -->|WinRM HTTPS 읽기| X[Windows 개발 서버]
  K[수집기 로컬 자격증명] --> C
  M[DB migration 전용] --> D
```

| ID | 불변 원칙 |
|---|---|
| BL-01 | 상주 에이전트 없음. Linux/Unix SSH, Windows WinRM. 대상 파일 배포/설정 변경 금지 |
| BL-02 | SSH 개인키는 수집기에만 파일로 보관. WinRM 비밀도 수집기 로컬 보안 저장소에만. 웹/DB/로그/엑셀/Git 금지 |
| BL-03 | 수집 전용 계정, 출발지 IP 제한, 포워딩/PTY 제한 및 최소 권한 |
| BL-04 | 웹과 수집기는 별도 서버/독립 프로세스, 직접 통신 금지. 단일 장비 로컬 모의 테스트만 논리 격리 허용; 실제 수집 시험은 분리된 환경에서 수행 |
| BL-05 | DB 작업 테이블로만 요청 전달. 작업 유형 및 승인된 규칙 참조만 등록 |
| BL-06 | 웹 규칙은 데이터, 고정 엔진이 허용 동작을 해석. 임의 명령·파일 업로드·스크립트 실행 금지 |
| BL-07 | 검색 결과는 영향 후보이며 관리자 최종 판단 |

웹은 원격 대상과 통신하지 않는다. 수집기는 HTTP 업무 API를 제공하지 않는다. DB는 자산·업무 기록·작업·관측·정합성 상태의 단일 기준 저장소다. 예외: 코드/DB 스키마/허용 카탈로그/서버 설정은 버전 관리, 비밀은 로컬 보안 저장소, 실행 로그는 운영 설정에 따라 보관. 업무 데이터의 엑셀 파일은 교환 수단으로만 사용한다.

**실제 연결 전 최소 게이트:** 대상별 허가/테스트 시간대, 계정, 수집기 출발 IP, 호스트 키 지문(독립된 경로로 확인), WinRM 신뢰된 인증서·호스트명과 허용 인증, 읽기 범위, 유한 자원 한도, 실제 접속 허용목록이 있어야 한다. 미구성 시 `CONFIG_REQUIRED`로 실패하며 모의 성공으로 대체하지 않는다. MINA의 기본 verifier에 의존하지 말고 명시적인 fail-closed 검증을 적용한다. WinRM에서 TLS 검증 무력화·평문 Basic·무단 권한 상승 금지. Windows의 WinRM 설정은 담당자 사전 작업이며 수집기가 변경하지 않는다.

## 5. 기능 요구사항 및 범위 추적

우선순위 P0=프로토타입 핵심, P1=프로토타입 내 최소 구현/시간 여유에 따른 단계화, P2=후속. 기존 FR 번호는 의미를 유지한다.

| ID | 요구사항 | 단계 |
|---|---|---|
| FR-001 | 자산 CRUD, 불변 ID, IP 변경 이력, 비활성화 | P0 |
| FR-002 | xlsx 양식/미리보기/중복/오류 행/확정 저장 | P0 |
| FR-003 | SSH 호스트 키 검증, 변경/미확인 중단 | P0 |
| FR-004 | 즉시 수집, 일정 설정 골격, 작업 상태 | P0 |
| FR-005 | OS·커널·패키지·기본 도구 버전/실패 사유 | P0 |
| FR-006 | 제품·버전·OS·담당자·중요도·실행·정합성 필터, 다운로드 | P0 |
| FR-007 | 복수 경로/버전 인스턴스 | P0 |
| FR-008 | 확인됨/추정됨/미발견/확인 불가/실패 구분 | P0 |
| FR-009 | 신규·삭제 후보·변경 이벤트 | P0 |
| FR-010 | 마지막 성공/시도·신선도·증거 | P0 |
| FR-011 | 실패 사유 분류 및 상세 | P0 |
| FR-012 | 미등록 자산 발견 | P2, 별도 승인 |
| FR-013 | 패키지→프로세스→제한 경로 탐지 | P0 핵심, 제품별 깊이 P1 |
| FR-014 | 원문/비교 체계/Epoch/릴리스 보존 | P0 |
| FR-015 | 비교불가·백포트 시 확인 필요 | P0 |
| FR-016 | 실행 정보·포트 및 최소 식별 정보, 민감정보 제거 | P1 |
| FR-017 | 설치·실행·내부 접근·외부 노출 별도 | P0 데이터 구조, P1 일부 관측 |
| FR-018 | 관측 증거·규칙/엔진 버전·신뢰 | P0 |
| FR-019 | 설치 인스턴스별 안전한 병합 | P0 |
| FR-020 | 중첩 라이브러리/가상환경/컨테이너 | P2 |
| FR-021 | 컨테이너 Digest | P2 |
| FR-022 | 웹/엑셀 규칙 입력, 버전별 JSONB | P0 |
| FR-023 | 규칙 스키마·안전 검증·예산 | P0 |
| FR-024 | 지정 개발 서버 시험·활성화 | P0 최소, 운영 승인 후속 |
| FR-025 | 규칙 버전/변경/활성화/중지/롤백 이력 | P0 |
| FR-026 | 이슈 등록·조건·출처·영향 후보 | P0 |
| FR-027 | 판단 상태와 조치 상태 분리 | P0 |
| FR-028 | 근거·담당·기한·재검증 기록 | P0 기본, 위험수용 승인 운영 후속 |
| FR-029 | 자산·인벤토리·규칙·이슈·수집·이력 UI | P0 |
| FR-030 | 권한 범위·최대 건수·마스킹·감사 내보내기 | P0 |
| FR-031 | 외부 위협 자료 선택 반입 | P2 |
| FR-032 | 자동 관측 보존·필드별 수동 보정/수동 등록·원복 | P0 신규 |
| FR-033 | 일치/불일치/확인불가/미수정, 변경 플래그 필터·집계 | P0 신규 |
| FR-034 | 불일치 검토, 수동 유지/수집값 적용/보정 재수정, 검토 이력 | P0 신규 |
| FR-035 | 엑셀 일괄 보정 및 충돌 검증, 수정원 구분 | P0 신규 |
| FR-036 | Linux/Unix/Windows 별 지원 프로필 및 모의/실제 분리 | P0 신규 |

### 5.1 자산 정보

필수: 자산명, 주소(IP/FQDN), OS군, 환경, 수집 방식, 활성 여부. 실제 수집 시 endpoint/port, 수집기 프로필 참조, 검증된 신원, 담당자 및 허가 기록 필수. 선택: 업무/조직, 담당자, 중요도, 설명, 관리용 OS명/버전, 관리자 외부 노출 주장·출처·확인일. OS군/프로토콜은 수정 시 기존 작업 취소·새 endpoint 검증을 요구한다. 중복은 환경/네트워크 구역/정규화 주소·포트 조합으로 확인하고 IP 하나만으로 병합하지 않는다. 업무에서 삭제는 비활성화가 기본이며 관측 및 이력은 유지한다. 테스트 DB의 완전 삭제는 관리자용 별도 초기화 스크립트로만.

### 5.2 수집 지원 매트릭스 (개발 목표, 실측 전)

| OS | 기본 정보 | 설치 패키지/주요 제품 | 제한 |
|---|---|---|---|
| RHEL 계열 | OS 릴리스, 커널, 아키텍처, 호스트명 | RPM, OpenSSL/OpenSSH, Java, Tomcat, nginx | 권한/백포트, 버전별 출력 차이 |
| Debian/Ubuntu | OS 릴리스, 커널, 아키텍처 | dpkg, 주요 도구·런타임 | epoch/revision 보존 |
| AIX | uname/oslevel 계열, 아키텍처 | lslpp 기반 패키지, 제한된 주요 제품 | 실제 OS 버전/출력 및 허가 범위별 지원 |
| Solaris | uname/릴리스 | pkg 또는 pkginfo 기반 | Solaris 버전별 별도 파서 |
| HP-UX | uname/릴리스 | swlist 기반 | 개발 서버 확보 시 실제 검증, 없으면 제한 지원 |
| Windows Server | OS 버전/빌드/아키텍처 | 32/64비트 Uninstall 레지스트리, 접근 가능한 핫픽스, Java/IIS 등 | 사용자별 설치 범위와 핫픽스 조회 한계 표시 |

최소 Linux 한 계열, Unix 한 계열, Windows 한 환경의 실제 결과 확보를 완료 게이트로 한다. 그 외 환경은 fixture·단위테스트 검증과 실제 검증 여부를 별도로 표시한다. 서버 미확보 시 해당 실제 검증은 미완료이며 완료로 주장하지 않는다. Windows `Win32_Product` 방식은 설치 프로그램 재구성 부작용 우려로 채택하지 않는다. WQL 및 고정된 조회 프로브, Uninstall 레지스트리 읽기만 사용한다.

주요 SW 첫 대상: OS 기본 보안 도구, Java/JDK, Tomcat, Node.js, Python, Apache httpd/nginx. v0.2의 WebtoB/JEUS, WildFly/JBoss/WebLogic, DB(MySQL/MariaDB/PostgreSQL/Oracle/MSSQL/Tibero/MongoDB/Redis), Kafka/RabbitMQ/ZooKeeper/Elasticsearch, 백신/EDR/백업/모니터링, IIS/.NET 등은 제품 규칙 단위로 확장한다. 메뉴에 제품이 보이는 것과 실제 탐지 지원은 구분한다.

### 5.3 설치·실행·노출·증거

설치 위치별 인스턴스 ID를 유지한다. 제품명만 같은 두 설치를 병합하지 않는다. 패키지 ID 및 설치 위치를 안정적 locator로 사용하고 버전은 locator의 일부로 사용하지 않는다(버전 변경은 기존 인스턴스 변경). 서로 다른 출처가 같은 설치라는 근거가 있을 때만 연결한다. 실행과 리스닝 포트는 설치와 별도이며 내부 접근/인터넷 노출은 증거 및 관측 시각이 있어야 한다. 마지막 성공과 마지막 시도를 구분하고 실패/부분 성공으로 정상 데이터를 지우지 않는다. 미발견은 탐색 범위 내의 결과이지 미설치 확정이 아니다.

## 6. 핵심: 자동 수집과 수동 수정의 정합성

### 6.1 데이터 계약

- 자동 관측(A): 수집 결과로 생성되는 읽기 전용 기록. 원본 버전, 비교 체계, 증거, 범위, scan_run_id, 관측시각을 보존한다. 저장되는 원본은 비밀을 제거한 업무 관측값이며 무제한 stdout 원본이 아니다.
- 수동 보정(M): 작업자가 필드 단위로 관리값을 입력하는 별도 레코드. 수정자/사유/출처/시각/기준 관측 ID/활성 여부/revision 필수. 웹 및 엑셀 모두 동일 서비스 경유.
- 유효 관리값(E): 활성 보정이 있으면 M, 없으면 마지막 유효 A. 관리용 값이 없으면 미확인. 실제 탐지 사실과 관리용 판단을 혼동하지 않도록 출처를 항상 표시한다.
- 비교는 같은 자산·인스턴스·필드 및 비교 체계의 최신 유효 관측에 한정한다. 누락·오래된 결과·비교불가·실패는 별도 상태; 기존 값은 보존하되 현재 검증되지 않았음을 표시한다.
- 수동 등록 인스턴스는 수집 관측이 없을 수 있다. 새 수집이 발견한 설치와 자동 병합하지 않고 검토 후 연결한다. 연결 변경 및 원복 기록을 남긴다.

### 6.2 상태 모델

| 상태 코드 | 표시 | 조건 | 관리값 |
|---|---|---|---|
| AUTO_ONLY | 자동 수집 | 수동 보정 없음, 자동값 유효 | A |
| MATCH | 일치 | 활성 M과 유효 A가 같은 의미 | M |
| MISMATCH | 불일치 | 활성 M과 유효 A가 다름 | M |
| MANUAL_ONLY | 수동 등록 | M 존재, 아직 수집으로 확인되지 않음 | M |
| UNVERIFIABLE | 확인 불가 | A가 실패/범위 부족/오래됨/비교 불가, 또는 값 없음 | 마지막 유효값 또는 M, 경고 표시 |

`has_manual_override`, `ever_manually_edited`, `review_state`(PENDING/ACKNOWLEDGED/NONE), `freshness_state`, `detection_state`는 별도 필드. 일치한 경우에도 수동 보정 사실이 남는다. 불일치가 확인되더라도 작업자가 수동 유지하면 비교 상태는 MISMATCH 그대로이며 검토 상태만 ACKNOWLEDGED. 새로운 관측이 기존 검토 기준과 달라지면 PENDING으로 전환한다. 비교 기준 관측 및 보정 revision을 보존하고 같은 값/상태의 반복 수집은 불필요한 신규 경보를 생성하지 않는다.

필드 상태 우선순위는 실제 실패/권한 부족/오래된 관측 등 검증 불능이면 UNVERIFIABLE, 아직 수집 관측 없이 수동 등록한 경우에는 MANUAL_ONLY, 유효 관측이 있을 때 활성 보정 여부에 따라 AUTO_ONLY/MATCH/MISMATCH로 분류한다. 자동 관측과 보정이 모두 없는 지원 필드는 확인 불가로 표시한다.

행 집계는 현재 필드 중 불일치가 있으면 불일치, 없고 확인 불가가 있으면 확인 불가, 수동 전용이면 수동 등록, 보정 필드가 모두 일치하면 일치, 나머지는 자동 수집. 집계 외에도 필드별 상태는 보존하여 `불일치 필드 있음`/`확인 불가 필드 있음` 다중 필터를 지원한다. 신선도 및 관측 상태는 독립 표기하고 행 집계로 가리지 않는다.

### 6.3 화면 예시 (가상 데이터)

| 자산 | 제품 | 자동 수집값 | 수동 수정값 | 관리값 | 비교 상태 | 검토 |
|---|---|---|---|---|---|---|
| DEV-LNX-01 | Tomcat | 9.0.85 | — | 9.0.85 | 자동 수집 | — |
| DEV-LNX-02 | Tomcat | 9.0.85 | 9.0.86 | 9.0.86 | 불일치 | 검토 필요 |
| DEV-UNX-01 | Java | 17.0.12 | 17.0.12 | 17.0.12 | 일치 | — |
| DEV-WIN-01 | Java | 미발견 | 21.0.5 | 21.0.5 | 수동 등록 | 확인 필요 |
| DEV-WIN-02 | IIS | 마지막 관측 10.0 | — | 10.0 | 확인 불가 | 최근 수집 실패 |

비교 필터: 전체 / 자동 수집 / 수동 수정 있음 / 일치 / 불일치 / 수동 등록 / 확인 불가 / 미검토 / 검토 완료. 자산명, OS군, 제품, 버전(자동/관리/양쪽), 담당자, 변경기간, 수정자, 수정경로(웹/엑셀), 신선도 및 수집 상태 조합. 건수 기준은 설치 인스턴스 또는 OS 레코드이며 서로 다른 단위를 혼합하지 않는다.

### 6.4 작업자 행동 및 동시성

1. 상세 화면에서 자동 관측/관리값/증거/이력을 조회한다. `수정`을 선택하고 필드/새값/사유를 입력한다.
2. 서버가 허용 필드, 타입, 버전 체계, 대상 권한, `expectedRevision` 및 관측 기준을 검증한다. 변경 미리보기 후 저장하면 원본에는 변화가 없다.
3. 재수집 결과가 다르면 불일치 큐에 노출한다. 필드별 `수동값 유지`(검토 완료), `자동값 적용`(보정 해제), `수동값 재수정`, `재수집 요청`을 제공한다.
4. 수동값 해제는 이력을 삭제하지 않고 활성 플래그를 변경한다. 자동값 미확인 상태의 해제는 확인 경고 후 진행하며 존재하지 않는 값을 생성하지 않는다.
5. 동시 수정이나 재수집으로 미리보기 기준이 달라지면 409 충돌, 최신 값 재조회·확인. 전체 저장과 이력 기록은 같은 트랜잭션. 재요청 키로 중복 변경 방지.
6. 취약점 후보 검색의 기본은 양쪽 값 검토: 자동/관리 중 하나라도 조건 충족 시 후보, 한쪽 불명확 또는 상충은 확인 필요. 화면의 관리값 우선 표시 정책으로 인해 원본 조건 충족이 누락되어서는 안 된다. 출처 선택 및 후보/확인 필요 탭 제공. 수동 입력은 취약 판단의 대체가 아니다.

## 7. DB 논리 설계

기본 키 UUID, 시각 `timestamptz`(저장 UTC, 화면 Asia/Seoul), UTF-8, 삭제 대신 상태, 업무 상태는 체크 제약/참조 코드. FK 및 UNIQUE로 중복 방지. 현재 조회 성능을 위해 최신 상태 projection을 두되 이력을 기준으로 재구축 가능하게 설계한다.

| 테이블 | 핵심 필드 / 용도 |
|---|---|
| assets | id, name, address, os_family, env, owner_id, criticality, active, revision |
| asset_endpoints | id, asset_id, protocol, port, network_zone, credential_ref, identity_fingerprint, verified_at, enabled |
| software_products | id, vendor, canonical_name, category, version_scheme, support_level |
| product_aliases | product_id, alias, scheme, mapping_revision, approved_flag |
| installations | id, asset_id, product_id, locator_key, package_id, path, lifecycle, revision; UNIQUE(asset_id, product_id, locator_key) |
| scan_jobs | id, asset_id, endpoint_id, job_type, ruleset_id, mode, priority, request_key, status, cancel_requested, worker_id, lease_until, lease_token, heartbeat_at, attempt, next_retry_at, error_code |
| scan_runs | id, job_id, attempt_no, lease_token, mode, started_at, finished_at, outcome, engine_version, policy_version, coverage_summary; UNIQUE(job_id, attempt_no) |
| scan_coverage | run_id, probe_id, scope, outcome, reason_code, observed_at |
| os_observations | id, run_id, asset_id, raw_os, raw_version, kernel, arch, observed_at, source, confidence |
| observations | id, run_id, installation_id, raw_version, normalized_version, scheme, epoch, release, running_state, evidence_ref, observed_at, confidence |
| evidence | id, run_id, probe_id, rule_version_id, scope, sanitized_metadata JSONB, hash, observed_at |
| latest_os / latest_installation | subject_id, observation_id, last_success_at, last_attempt_at, detection_state, freshness; collector 전용 관측 projection |
| os_overrides / installation_overrides | id, subject FK, field_code, manual_value JSONB, base_observation_id, active, revision, author, reason, source, created_at; 필드당 활성 보정 하나 |
| override_events | id, subject_type/id, field_code, previous/next JSONB, actor, source, reason, request_key, at |
| reconciliation | subject_type/id, field_code, comparison_state, review_state, observation_id, override_revision, checked_at; 상태 변경 시 upsert |
| reconciliation_events | 상태 전이, 검토 처리, actor, basis, at |
| detection_rules / detection_rule_versions | rule_id, version, product_id, OS, JSONB schema, state, author, validated_at, tested_run_id, limits_profile, activated_at |
| rule_sets / rule_set_members | immutable ruleset ID, member version IDs, state |
| collection_schedules | asset/group, cadence, enabled, next_run_at, revision |
| workers | id, last_heartbeat_at, engine_version, active_jobs, health, capabilities |
| change_events | asset/installation, event_type, old/new observation, coverage, at |
| exposure_evidence | asset_id, type, claim, source, checked_at, confidence |
| security_issues / issue_conditions | id, external_id, title, product/scheme/interval, source_url, state, created_at |
| issue_search_runs / issue_candidates | issue_id, condition_revision, query_at, basis observations/overrides, match_state, reasons |
| assessments / assessment_events | issue, asset, installation, impact_state, action_state, reason, due_at, owner, evidence, revision; 판단/조치/재검증 이력 |
| import_batches / import_rows | template_version, operation, owner, row_no, status, validated_payload, errors, expected_revision, expires_at |
| users / roles / user_roles | 개발용 계정, password_hash, enabled, 역할 및 변경 기록 |
| audit_logs | actor, action, object_type/id, at, source_ip, outcome, correlation_id; append-only |
| saved_filters / app_settings | 사용자 검색 조건, 민감정보 없는 업무 설정 및 버전 |

웹용 DB 역할은 업무 CRUD/보정/요청/허용된 상태 조회, 수집기 역할은 제한된 asset/rule 참조 조회·claim/결과·관측 projection 갱신, migration 역할은 DDL 전용. 웹에서 관측 원본/작업 완료 상태를 UPDATE/DELETE할 수 없도록 DB 권한으로 제한한다. 정합성 projection은 웹과 수집기의 변경 트리거 또는 전용 함수/서비스를 통해 같은 계산 규칙으로 갱신하고 테스트한다. 역할별 컬럼/뷰 및 함수 권한을 분리한다. 원격 자격증명·개인키는 저장하지 않는다.

권장 인덱스: 작업 status/next_retry_at/priority, 자산/시간별 scan_runs, installation asset/product, observation installation/observed_at, 활성 override 유일 인덱스, reconciliation 상태/검토, assessment issue/state, audit at. 필요한 검색 SQL의 EXPLAIN ANALYZE로 추가한다. JSONB는 가변 데이터용, 자주 필터하는 컬럼은 정규 컬럼. DB migration은 V001~ 순서로 관리하며 적용된 SQL 수정 및 Flyway clean 운영 실행 금지.

## 8. 수집기 및 작업 처리

### 8.1 어댑터

`CollectorAdapter` 계약: supports(profile), verifyIdentity(endpoint), collect(context, ruleSet, deadline) → `CollectionResult` (scope outcomes + observations + error codes). `LinuxSshAdapter`, `UnixSshAdapter`(AIX/Solaris/HP-UX별 parser), `WindowsWinrmAdapter`, `MockAdapter`. 연결·명령/쿼리·파서·정규화·저장은 각각 독립 단위 테스트. 웹의 job 요청에는 command, script, URL, arbitrary path, password 필드가 존재하지 않는다.

수집기 프로브 카탈로그는 코드로 정의하고 고정 읽기 조회만 허용한다. 웹 규칙은 카탈로그 ID, 제품, 허용 경로 프로필 ID, 안전한 패턴/추출 방식만 조합한다. 패키지 관리자 우선, 프로세스의 안전한 식별자, 제한 파일 탐지 순서. 실행 중 제품 바이너리의 임의 호출 금지. 제품 버전 명령은 코드 리뷰로 등록된 읽기 전용 고정 명령만 허용한다. 원격 환경변수/전체 명령행·개인키/비밀번호 파일 수집 금지. 파서 오류는 정상 빈 목록과 구별한다.

### 8.2 작업 상태

`PENDING → RUNNING → SUCCESS / FAILED / TIMEOUT / CANCELLED`; 일시 오류는 `RETRY_PENDING → PENDING`; 일부 항목만 성공은 `scan_runs.outcome=PARTIAL_SUCCESS`로, 작업 종료 상태는 SUCCESS(부분 성공 표기)로 표현한다. 수집 취소 요청은 별도 플래그, 워커 확인 후 종료. 원격 작업이 실제 종료됐는지 확인할 수 없는 경우 경고 및 재실행 차단/검토 필요.

- 동일 자산은 기본 한 번에 하나만 실행. 중복 활성 작업 DB 제약 또는 자산별 lease로 방지. idempotency key로 버튼 반복 요청 방지.
- DB 시간 기준 `FOR UPDATE SKIP LOCKED`로 짧은 트랜잭션에서 claim, token/lease/attempt 갱신 후 잠금 해제. 원격 작업 중 DB 트랜잭션을 유지하지 않는다.
- lease 만료는 재할당 전 이전 작업 종료 불확실성을 고려해 제한. heartbeat와 lease_token으로 오래된 워커의 결과 쓰기를 fencing. 완료 시 현재 token 재확인 후 관측 저장/최신 projection/작업 종료를 원자적으로 처리한다.
- 네트워크 일시 실패만 제한 재시도. 인증, 호스트 키, TLS, 허용목록, 권한, 파서 및 정책 실패는 사유 표시 및 수동 조치. 이전 정상 관측 보존.
- 정기 작업은 DB 일정 참조 및 중복 키를 사용. 기본 즉시 수집부터 검증; 스케줄러 기본 비활성, 운영 주기 미확정. 심화/긴급은 작업 종류·우선순위 구조 유지, 심화 실제 기능은 후속.

| 오류 코드 | 표시/처리 |
|---|---|
| CONFIG_REQUIRED / POLICY_DENIED | 미설정/정책 차단. 자동 재시도 금지 |
| HOST_KEY_MISMATCH / TLS_ERROR | 신원 확인 필요. 중지 |
| AUTH_FAILED / PERMISSION_DENIED | 인증/권한 확인. 해당 범위 미확인 |
| CONNECTION_TIMEOUT / NETWORK_ERROR | 유한 재시도 대상 |
| PROBE_TIMEOUT / LIMIT_EXCEEDED | 제한 초과, 부분 관측 및 범위 기록 |
| PARSE_ERROR / UNSUPPORTED | 지원·파서 확인, 미발견으로 변환 금지 |
| DB_ERROR / LEASE_LOST / CANCELLED | 실패·중단 원인, 중복 최종 결과 차단 |

### 8.3 초기 설정값 (개발용 제안, 운영 미확정)

| 설정 | 초기값 |
|---|---|
| 전역/호스트 동시 수집 | 4 / 1 |
| 접속/단일 조회/호스트 시간 | 10초 / 30초 / 180초 |
| lease/heartbeat | 90초 / 15초, 작업 중 갱신 |
| 네트워크 재시도 | 최대 2회, 지수 백오프 |
| 프로브 결과/전체 | 2 MiB / 16 MiB (초과 시 명시적 부분 실패) |
| 파일 탐지 | 기본 비활성; 승인 프로필에서만 깊이 4, 1,000개, 읽기 총량 8 MiB |
| 정기 수집 / 신선도 | 스케줄 기본 OFF; 시험 일정 하루 1회 후보 / 48시간 기준 후보 |
| 대상 | 승인된 개발 서버 allowlist; 기본 실제 수집 OFF |

개발 서버 부하·실측에 따라 조정한다. 결과 초과·타임아웃은 잘린 결과를 완전 성공으로 반영하지 않는다. Virtual Thread가 작업 수 제한을 대체하지 않는다.

## 9. 탐지 규칙, 제품 버전 비교, 보안 조사

규칙 구조 예시(실행 문자열 없음, JSONB로 DB에 저장):

```json
{
  "schemaVersion": 1,
  "productId": "PRODUCT-TOMCAT",
  "osFamily": "LINUX",
  "probeId": "FILE_METADATA",
  "pathProfileId": "DEV_APP_APPROVED",
  "filePattern": "catalina.jar",
  "extractorId": "JAR_MANIFEST_VERSION",
  "versionScheme": "NUMERIC",
  "limitsProfileId": "DEV_STANDARD"
}
```

실제 JAR 메타데이터 프로브는 지원 구현 및 검증이 완료된 이후만 활성 가능. 미지원 프로브 선택은 서버에서 거부한다. 규칙 상태 DRAFT→VALIDATED→TESTED→ACTIVE→DISABLED/RETIRED. 수정은 새 버전, 활성화는 지정 개발 서버 시험 결과 및 작업자 기록 필수. 상세 운영 승인권자는 유보하며 프로토타입에서는 기본 관리자만 활성화. 롤백은 과거 불변 버전 참조를 새 활성 ruleset으로 변경한다. 진행 중 작업은 고정 버전 사용; 비상 비활성은 수집기 정책이 우선한다.

허용 경로는 수집기 정책에 정의된 프로필 ID만 참조. 경로 정규화 및 심볼릭 링크 탈출 금지, shell metacharacter/명령 삽입 금지. 패턴 길이·복잡도·읽기 범위·시간 제한, 안전한 정규식 사용. 승인 여부와 무관하게 엔진의 독립 검증이 필수. 규칙 엑셀에서 명령, 파일 쓰기, 임의 경로 필드 입력 불가.

버전 비교기는 `RPM`, `DEBIAN`, `SEMVER`, `NUMERIC`, `WINDOWS_BUILD`, `VENDOR_SPECIFIC`, `UNKNOWN`을 명시. RPM/Debian은 epoch/release 및 공식 비교 규칙에 맞춘 Java 구현을 공식 도구 결과 fixture로 교차검증한다. SemVer는 정식 규격에 맞지 않는 제품 버전과 혼용 금지. `9.0.9`와 `9.0.85` 사전순 비교 금지, 공급사 백포트는 업스트림 버전만으로 판단하지 않는다. 미지원 scheme/파싱 실패/서로 다른 scheme은 INCOMPARABLE. 버전 조건은 연산자 allowlist 및 두 경계/포함 여부로 표현한다.

보안 이슈: ID, 제목, 공지/근거 URL, 영향 제품·버전 범위, 대상 OS/환경, 조사 상태, 작성자, 등록일. 검색은 관측/관리값과 비교 근거를 스냅샷으로 남긴다. `MATCH_CANDIDATE`, `NEEDS_REVIEW`, `NOT_MATCHED`는 조건 검색 결과이지 취약점 판정이 아니다. 판단 `영향 가능/영향 없음/확인 필요`, 조치 `미조치/진행 중/완료/위험 수용`을 분리. 조치 완료에는 재검증 증거 및 사용자 판단 필수, 운영 위험 수용은 승인자·만료 정책 확정 후 활성화. 실제 보안 공지 예시가 필요한 경우 출처/범위를 명확히 표시.

## 10. 화면 설계 및 공통 UX

### 10.1 디자인 기준

하나금융그룹 CI 페이지 참고 [R11]. 프로토타입은 흰색·중립 배경 기반의 고밀도 내부 업무 화면으로 구성한다. 브랜드 참고 토큰 `#009178`, 접근성을 고려한 주요 버튼 `#007A68`, 선택 `#E6F5F1`, 배경 `#F5F7F9`, 본문 `#172B29`, 경고 `#A65D00`, 오류 `#C62828`, 정보 `#175CD3`. 이 값들은 승인된 그룹 공식 CI 색상표가 아닌 제안 UI 값이다. 실제 로고 원본·최신 CI/하나서체 사용권은 운영 적용 전에 확인한다. 서체는 승인된 하나서체, 없으면 사내 승인 한글 산세리프/Noto Sans KR. 1440×900 기준, 1280px 업무 화면 검증. 좌측 메뉴 224px, 상단 56px, 여백 24px, 8px 간격 체계, 기본 글자 14px, 표 행 44px 권장. 주요 표는 가로 스크롤 및 헤더 고정; 키보드 탭/초점, 라벨, 대비, 색상+문자 상태 표시. 모바일은 조회 중심 후속, 다크모드는 제외.

### 10.2 메뉴 및 화면 계약

| 화면 ID / 경로 | 화면 | 상세 기능 및 수용 기준 |
|---|---|---|
| UI-00 /login | 로그인 | 개별 계정, 오류는 일반화, 로그인 실패 감사. 테스트 계정 외 기본 비밀번호 금지 |
| UI-01 /dashboard | 대시보드 | 등록/활성 자산, OS별 수집 현황, 수집 실패, 불일치 인스턴스, 미검토/확인 필요, 이슈 조사 현황. 카드 클릭 시 동일 기준 필터 조회 |
| UI-02 /assets | 자산 목록 | 자산명/IP/OS/환경/담당자/마지막 성공·시도/수집상태; 필터·정렬·일괄 요청·등록·엑셀·비활성화 |
| UI-03 /assets/new, /assets/{id} | 자산 등록·상세 | 기본정보, 연결 프로필 참조, 공개 호스트 지문/검증 기록, 연결 시험, OS/설치/수집/변경 탭. 비밀 입력 금지 |
| UI-04 /inventory/os | OS 인벤토리 | 원본/관리 OS·버전·커널 비교, 필터, 수동 보정, 엑셀 |
| UI-05 /inventory/software | SW 인벤토리 | 제품·원본/관리 버전·경로·실행·증거·수집시각·비교/검토상태, 중복 설치별 조회 |
| UI-06 /inventory/installations/{id} | 설치 상세 | 원본/수동/관리값 필드 비교, 증거, 설치·실행·노출 분리, 변경·보정 이력, 수동 수정/해제 |
| UI-07 /reconciliation | 데이터 정합성 | 일치/불일치/수동 등록/확인 불가 탭, 미검토 배지, 필터, 작업자 액션, 다건 조회/엑셀 |
| UI-08 /search | 통합 검색 | 제품/OS/버전 체계와 구간/자동·관리·양쪽/담당/노출/신선도/정합성. 검색조건 저장, 후보/확인 필요 분리 |
| UI-09 /issues | 보안 이슈 목록·등록 | ID·제품·조건·출처·조사상태, 대상/담당자 필터, 엑셀 |
| UI-10 /issues/{id} | 영향 조사 | 후보·확인 필요·조건 불일치 목록, 근거, 판단·조치 독립 입력, 재수집·재검증 |
| UI-11 /collection/jobs | 수집 작업 | 즉시/시험/정기, 상태·원인·기간·OS·자산 필터, 재요청/취소, 대기·시도 횟수 |
| UI-12 /collection/jobs/{id} | 작업 상세 | 진행 단계, worker, scope별 결과, 오류·시간, 재시도 이력. 민감한 stdout/비밀 없음 |
| UI-13 /collection/schedules | 일정 | 대상·주기·활성·다음 실행, 개발 초기 OFF, 승인된 대상만 활성 |
| UI-14 /rules | 규칙 목록 | 제품/OS/프로브/버전/상태 필터, 신규·복제·엑셀·중지 |
| UI-15 /rules/{id} | 규칙 작성·시험 | 안전 폼, 검증 결과, 개발 서버 지정 시험, 활성화/과거 버전 롤백, 변경 이력 |
| UI-16 /products | 제품 사전 | 정규 제품명/별칭/분류/비교 체계/지원 상태, 등록 및 일괄 관리 |
| UI-17 /history | 변경 이력 | 자동 탐지 변경/작업자 수정/정합성 이벤트 구분, 기간·자산·제품·작업자 필터 |
| UI-18 /reports | 보고서 | 자산/제품/수집 실패/정합성/영향 후보/판단 현황 엑셀, 집계 기준·조회시각 포함 |
| UI-19 /admin/audit | 감사 | 행위자·행위·객체·시각·성공/실패·correlation ID. 일반 사용자가 수정 불가 |
| UI-20 /admin/settings | 시스템 설정 | 비민감 개발 설정, 사용자 및 기본 권한. 네트워크/비밀/카탈로그 직접 변경 금지 |
| UI-21 /imports/{id} | 엑셀 처리 공통 | 양식 내려받기, 업로드, 검증, 오류 행, 확정, 처리 결과; 브라우저 이탈 후 DB 기반 재조회 |

### 10.3 핵심 화면 레이아웃 — 정합성 관리 UI-07

```text
┌────────────────────────────────────────────────────────────────────────────┐
│ Project202701                         개발환경     사용자 ▾                │
├─────────────┬──────────────────────────────────────────────────────────────┤
│ 대시보드    │ 데이터 정합성                         [엑셀 양식] [내보내기] │
│ 자산 관리   │ 원본과 관리값의 차이를 확인하고 수정합니다.                   │
│ 인벤토리    │ [전체 128] [일치 24] [불일치 8] [확인 불가 5] [수동 등록 3]  │
│ 정합성 관리 │ 자산명 [    ] 제품 [    ] OS [전체] 비교상태 [불일치]        │
│ 통합 검색   │ 수정여부 [전체] 검토 [미검토] 수정자 [ ] 기간 [   ] [검색]   │
│ 이슈 조사   │ ☐ 자산     제품     자동값      수동값      관리값   상태    │
│ 수집 관리   │ ☐ DEV-01   Tomcat   9.0.85      9.0.86      9.0.86   불일치  │
│ 탐지 규칙   │ ☐ DEV-02   Java     17.0.12     17.0.12     17.0.12  일치    │
│ 변경 이력   │                 [선택 재수집]  [상세 비교]                   │
│ 보고서      │ 총 N건                           50건/페이지  이전 1 다음  │
└─────────────┴──────────────────────────────────────────────────────────────┘
```

표의 데이터는 설명용 가상 데이터. KPI 집계 단위는 선택된 OS/설치 탭과 일치하며, 같은 행을 클릭할 때 필터와 페이지 상태를 URL로 보존한다. 탭 카드 수치는 현재 다른 검색 조건을 반영하며 전체 범위 표시. 상세 비교는 우측 drawer 또는 상세 페이지로 제공. 필드별 값·시각·관측 기준·사유·작업자를 나란히 표시. 수동값 유지/자동값 적용/재수정은 확인 대화상자와 사유 입력 후 실행. 불일치 색상만으로 의미 전달 금지. 고위험 일괄 값 변경은 반드시 미리보기와 행별 충돌 검증.

### 10.4 공통 상호작용

- 모든 테이블: 서버 측 pagination 기본 50/선택 20·50·100, 최대 100(개발 기본값), 정렬 allowlist, 다중필터, 초기화, 적용된 필터 표시, 검색 결과·전체 구분, 다운로드 조건 표시.
- 목록과 상세는 URL 및 뒤로가기 유지. 모달 취소 시 값 변경 없음. 제출 중 중복 방지, 저장 성공/실패 메시지, 409 충돌 시 최신 내용 비교.
- 화면 공통 상태: loading, empty(초기/필터 결과 없음 구분), error(재시도), forbidden, stale, partial, disabled, unsupported. 표의 숫자 0과 데이터 없음은 별도 표현.
- 데이터 출력은 JSP escape, JSTL, JS `textContent`; 문자열로 HTML 조립하지 않는다. AJAX는 same-origin `fetch`, CSRF 토큰, 취소 가능한 검색 요청. CDN/외부 API 없이 내부망 로컬 정적 리소스 제공.
- 상태 표시는 한국어, DB/API enum은 영문. 실제/모의 환경을 헤더와 결과 화면 모두에서 표시. 모의 데이터를 실제 통계·보안 조사로 혼합하지 않는다. 개발 모의 DB를 실제 연결 시험 DB와 분리하는 것을 기본으로 하고, 모드 컬럼도 유지해 오사용을 방지한다.

### 10.5 벤치마킹 채택

v0.2 참고 자료의 Lansweeper(인증 기반 인벤토리/검색), GLPI(자산·담당자 관리), Open-AudIT(변경 이력), Defender VM(제품 중심 조사), Tenable(수집 성공과 인증 성공 구분), Trivy(증거 기반 심화 탐지), Ansible(수집 비교) 패턴을 활용한다. 프로젝트에 맞게 데이터 정합성 중심의 UI를 추가하고, 해당 제품의 자동 취약점 판정·자동 조치·에이전트 설치 방식은 채택하지 않는다. 이 항목은 기능 설계 참고이며 실제 제품 성능/사용성 비교시험 결과가 아니다. 기존 참고자료 목록은 v0.2 §20에 보존한다.

## 11. 엑셀 표준 및 보고서

업무 데이터는 DB가 단일 기준이다. 엑셀은 xlsx 교환 인터페이스이며 장기간 파일 자체를 마스터로 보존하지 않는다. 파일 업로드 후 검증 행/오류 및 처리 이력 DB 저장; 원본 파일 보존 필요 여부는 운영 정책에서 결정. 임시 파일은 접근 권한 및 정리 시간 제한.

| 양식 ID | 내용 / 주요 컬럼 |
|---|---|
| XLS-01 | 자산: assetId(수정), expectedRevision, 자산명, IP/FQDN, 환경, OS군, 담당, 중요도, 노출 주장·출처, active |
| XLS-02 | OS 보정: assetId, fieldCode, baseObservationId, expectedRevision, manualValue, reason, operation |
| XLS-03 | SW 등록/보정: installationId(수정), assetId, productId, locator, fieldCode, baseObservationId, expectedRevision, manualValue, reason, operation |
| XLS-04 | 규칙: ruleId, baseVersion, productId, osFamily, probeId, pathProfileId, pattern, extractorId, scheme, limitsProfileId, reason |
| XLS-05 | 제품: productId, canonicalName, vendor, category, aliases, scheme, supportLevel, expectedRevision |
| XLS-06 | 보안 이슈: issueId, externalId, title, productId, scheme, lower/upper, inclusive, sourceUrl, expectedRevision |
| XLS-07 | 후보 판단: issueId, installationId, impactState, actionState, owner, dueAt, reason, expectedRevision; 위험 수용 운영 승인 우회 불가 |
| XLS-08 | 읽기 전용 조회: 화면 필터·기준 시각·자산/OS/제품·원본·관리값·수동값·정합성·증거/출처·수정자·검토 상태 |

각 양식은 안내(버전/필수/예시/코드), 데이터, 코드표 시트로 구성한다. 신규 행의 ID는 비어 있음, 수정·해제는 ID 및 revision 필수. 버전·IP·제품 코드는 텍스트 타입으로 강제해 엑셀 자동 날짜 변환을 예방한다. 빈 셀은 변경 없음과 명시적 삭제/보정 해제를 혼동하지 않도록 operation/fieldCode로 표현한다.

업로드 → 파일 형식/용량/행 수 검증 → 필수/중복/코드/FK/권한/수정 충돌 검증 → 미리보기 및 오류 행 xlsx → 사용자가 확정 → DB 트랜잭션 재검증 및 감사 → 성공/실패 결과. 개발 기본값: 10 MiB, 5,000행, 오류 시 전체 확정 중단(일괄 원자성), 만료 24시간 후보. 전체 파일을 신뢰하지 않고 ZIP 팽창 한도, 수식 셀·매크로·외부 링크·숨은 입력 필드 차단, 셀 길이 제한, 문자열로 내보내기. POI 스트리밍 출력, 임시 파일 정리. 행수 한도 초과는 화면 메시지로 안내; 무제한 export 금지. 다운로드 조회 기준과 검색 필터가 동일해야 하며 권한·마스킹·감사 적용.

## 12. API 및 모듈 구조

### 12.1 대표 API 계약 (기획 기준, OpenAPI YAML로 상세화)

JSP 페이지와 JSON API를 분리한다. 컨트롤러는 DTO→검증→서비스→Mapper 구조. JSP에서 SQL/비즈니스 로직 실행 금지. `/api/v1` 동일 출처 및 인증/CSRF 적용. 목록 응답 `items,total,page,size`; 오류는 `code,message,fieldErrors,traceId` (민감정보 제외). GET은 조회만, POST/PATCH는 변경. 모든 수정에 expectedRevision 또는 If-Match. 응답은 200/201, 수집 접수 202, 400 검증, 401 미인증, 403 권한, 404 미존재, 409 충돌, 429 제한, 500 일반화 오류.

| API | 용도 |
|---|---|
| GET/POST /api/v1/assets | 자산 조회/생성 |
| GET/PATCH /api/v1/assets/{id} | 상세·수정/비활성화 |
| GET /api/v1/inventory/os ; /software | 목록/필터, 자동·관리·양쪽 조회 |
| GET /api/v1/installations/{id} | 상세·관측·보정 상태 |
| POST /api/v1/overrides | 필드 보정/수동 등록(등록은 전용 유형 검증) |
| POST /api/v1/overrides/{id}/resolve | KEEP_MANUAL/ACCEPT_AUTO/REEDIT, reason, revision, observationId |
| GET /api/v1/reconciliation | 비교·검토 상태 필터/집계 |
| POST /api/v1/search | 조건/출처 기준/버전 비교, 후보·확인필요 분리 |
| GET/POST /api/v1/jobs | 목록/작업 생성; 접수 ID, 중복 키 |
| POST /api/v1/jobs/{id}/cancel ; /retry | 취소/재수집 요청(재수집은 새 job) |
| GET/POST /api/v1/schedules | 일정 조회/등록; 수정 별도 PATCH |
| GET/POST /api/v1/rules | 규칙 목록/초안, 기존 규칙 수정은 버전 생성 |
| POST /api/v1/rules/{id}/validate ; /test ; /activate ; /rollback | 단계 전이, 고정 ruleset |
| GET/POST /api/v1/products | 제품 사전 |
| GET/POST /api/v1/issues | 이슈 목록/등록 |
| POST /api/v1/issues/{id}/evaluate | 조건 검색 스냅샷 생성 |
| POST/PATCH /api/v1/assessments | 판단·조치 기록 |
| GET /api/v1/history ; /audit | 이력 조회, 감사 권한 분리 |
| GET /api/v1/imports/templates/{type} | 양식 다운로드 |
| POST /api/v1/imports | 업로드·검증 결과 및 batch ID |
| GET /api/v1/imports/{id} | 검증 결과·오류 행 조회 |
| POST /api/v1/imports/{id}/commit | 재검증 후 확정, idempotency key |
| GET /api/v1/exports/{type} | 허용 필터 기반 xlsx (큰 작업은 별도 내보내기 job 검토) |

작업 생성 예시: `assetId`, `jobType=BASIC`, `ruleSetVersionId`, `requestKey`. 서버가 저장된 endpoint 및 권한, 모드, 우선순위를 결정하고 검증한다. 클라이언트가 임의 명령·비밀·호스트 주소·path payload를 추가하면 400. 수집기 접근 API는 존재하지 않는다. 후보 조사 요청에는 condition revision, productId, scheme, 양끝/포함 여부, sourceMode를 포함; SQL 비교는 scheme별 검증된 비교기 결과만 사용.

### 12.2 프로젝트 디렉터리 (Maven 멀티모듈)

```text
project202701/
  pom.xml                          # Java 25, BOM, Enforcer, 공통 테스트
  mvnw / mvnw.cmd / .mvn/
  AGENTS.md                        # AI 개발 지침
  README.md                        # 빌드/실행/환경 설정/검증
  docs/
    planning-v0.3.md
    ui-spec.md
    openapi.yaml
    data-dictionary.md
    dependency-lock.md
    support-matrix.md
    test-plan.md
    decisions.md
  common/                          # enum, DTO, 비교기, 검증 정책; 비밀/SSH 없음
  persistence/                     # MyBatis mapper, SQL, DB 계약
  db-migration/                    # Flyway, DDL 전용 실행 단위
    src/main/resources/db/migration/
  web/                             # WAR
    src/main/java/.../web/         # controller, service, security, excel
    src/main/webapp/WEB-INF/jsp/   # layout, fragments, feature pages
    src/main/resources/static/     # css, js, local assets
  collector/                       # 독립 실행 JAR, 웹 의존성 금지
    src/main/java/.../collector/   # queue, worker, adapters, probe, parser, policy
    src/test/resources/fixtures/   # OS별 비식별 예제 및 예상 결과
  integration-tests/               # DB/queue/실패 시나리오/실제 연결 별도 프로필
  config/                          # 비밀 없는 설정 예제만
  scripts/                         # 개발 DB migration/실행/백업·복구 설명
```

DB 마이그레이션은 독립 실행 단위가 먼저 적용하고 web/collector 시작 시 스키마 호환 확인. migration 계정과 런타임 계정 분리; collector/web 중복 자동 migration 금지. 실제 개발 서버별 설정은 Git 외부 파일/환경으로 관리한다. 테스트 데이터는 가상 호스트와 비식별 정보만 커밋. 서버별 OS/네트워크 사양은 개발 서버 확보 후 문서화한다. GitHub는 사내 승인된 비공개 저장소 또는 내부 Git 사용. 외부 공개 저장소에 기획·실데이터·비밀 업로드 금지. 브랜치 main + feature, PR 단위 테스트, main 보호는 저장소 생성/권한 확정 후 적용.

## 13. 바이브 코딩 개발 작업 지시서

AI에게 한 번에 전체 코드를 생성하도록 지시하지 않는다. 아래 작업 패키지 순서를 따르고 각 단계의 테스트 결과와 변경 파일을 제출하도록 한다. 다음 작업의 진입 조건은 이전 핵심 테스트 통과. 정확한 라이브러리 API는 Context7 및 공식 릴리스 문서로 확인하고 가짜 API 사용 금지.

| 순서 | 작업 ID | 구현 산출물 | 완료 기준 |
|---|---|---|---|
| 0 | DEV-00 | Maven 구조, JDK/BOM 고정, CI, README, 환경 예제, 라이선스 목록 | Java 25로 clean verify, JSP WAR 시동, 실제 PostgreSQL migration 성공 |
| 1 | DEV-01 | DB 초기 schema, 역할/뷰, audit, seed(가상), API 공통 오류 | 웹 계정 원본/작업 완료 수정 거부, FK/중복 제약 테스트 |
| 2 | DEV-02 | UI shell, 로그인, 공통 table/filter/form/modal, 자산·제품 CRUD, 엑셀 | 브라우저에서 등록/검색/수정/엑셀 왕복 실제 DB 확인 |
| 3 | DEV-03 | DB 큐, mock collector, lease/fencing, 관측·projection | 작업 처리/재시도/부분 실패/중복 방지/워커 종료 시험 |
| 4 | DEV-04 | MINA SSHD 어댑터 및 Linux parser, 테스트 서버 실제 수집 | 호스트 키 확인/거부, 패키지·OS 관측 DB 저장, 제한 시간 검증 |
| 5 | DEV-05 | Unix 어댑터별 parser, WinRM HTTPS 어댑터 | 승인된 Unix/Windows 개발 서버 결과 확인, 미지원/권한 부족 분리 |
| 6 | DEV-06 | OS/SW 상세, 수동 보정, 정합성 projection, 불일치 필터, 엑셀 수정 | 자동/수동값 분리, 일치/불일치 전이/원복/재수집/409 통과 |
| 7 | DEV-07 | 제품별 버전 비교기, 통합 검색, 영향 이슈/판단·조치 | 복수 설치/백포트/비교불가/자동값 누락 방지 테스트 |
| 8 | DEV-08 | 탐지 규칙, 검증·시험·활성/롤백, 일정, 실패·이력·보고서 | 승인되지 않은 probe 거부, 버전 고정, dashboard와 결과 집계 일치 |
| 9 | DEV-09 | 전체 통합/UAT, DB 복구/부하 측정, 문서 | 실제 3개 OS군 결과, P0 테스트 통과, 미완료와 운영 유보 목록 |

**각 개발 요청의 최소 형식**

```text
작업: DEV-06 (예: 데이터 정합성)
근거: 기획안 v0.3 §6, FR-032~035, UI-07, T-19~26
선행: DB 마이그레이션/관측/큐 기능 테스트 통과
요구: 필드별 보정, 원본 보존, 비교 상태/검토 상태, 재수집, 엑셀
금지: 관측 원본 변경, 자동 보정 삭제, 실서버 연결 임의 수행
출력: 변경 파일, migration, API/JSP/JS, 단위·통합 테스트, 실행 명령,
      테스트 결과/실패/미구현 사항, 관련 문서 업데이트
완료 조건: 요구사항 테스트 실제 통과; 실행하지 않은 테스트는 미실행 표시
```

AI가 구현 중 미결정 운영 정책을 임의 확정하거나 기술 스택을 변경하면 안 된다. 변경이 필요한 경우 `docs/decisions.md`에 근거·대안·영향을 기록하고 요청자 검토 후 반영. 개발 설정값은 조정 가능하나 안전 한도 제거 금지. 생성한 SQL은 파라미터 바인딩 사용, MyBatis `${}` 직접 입력 치환 금지(정렬 allowlist를 서버에서 고정 매핑). JSP/JS 보안 및 엑셀 검증은 모든 작업 단위에서 포함. test fixture는 실제 운영 정보 대신 가상 자료. 로컬 테스트, PostgreSQL 통합 테스트, 승인된 실제 연결 시험은 명시적으로 분리한다.

## 14. 테스트·수용 기준

| ID | 시나리오 | 통과 조건 |
|---|---|---|
| T-01 | 동일 서버 Tomcat 두 경로/버전 | 서로 다른 설치 ID, 버전/경로 유지 |
| T-02 | 9.0.9 vs 9.0.85 | 숫자 비교, 사전순 오판 없음 |
| T-03 | RPM 백포트 | 자동 취약 확정 금지, 근거와 확인 필요 |
| T-04 | 패키지 성공·경로 권한 부족 | 부분 성공, 해당 범위 확인 불가 |
| T-05 | 이전 발견 파일 범위 제외 | 자동 삭제 확정 금지 |
| T-06 | 리스닝 포트만 있음 | 인터넷 노출 자동 확정 금지 |
| T-07 | 호스트 키 변경/미등록 | 중단, 감사, 승인 전 연결 불가 |
| T-08 | 출발지 IP 제한 | 허가된 개발 경로에서만 접근, 다른 경로 거부 검증(담당자 승인 하에) |
| T-09 | 금지 경로·symlink·악성 regex·명령 입력 | 웹/수집기 각각 거부 또는 안전 중단 |
| T-10 | 큰 결과/시간 초과 | 유한 한도, 부분 실패, 정상 결과 보존 |
| T-11 | 워커 강제 종료 및 오래된 결과 | 재할당 안전 처리, fencing, 중복 완료 없음 |
| T-12 | 인증 실패 vs 네트워크 일시 오류 | 인증 자동 반복 금지, 네트워크 제한 재시도 |
| T-13 | 미시험 규칙 활성화 | 거부·감사. 시험/관리자 활성화 후만 허용 |
| T-14 | 민감 토큰 포함 출력 | 원본 업무관측/로그/엑셀 마스킹 |
| T-15 | 500대 가상 부하 및 긴급 요청 | 후속 운영 검증. 프로토타입에서는 동시성·대기·우선순위 및 측정 방법 검증 |
| T-16 | 조치 완료 시 재수집 실패 | 완료 근거 부족 경고, 이력 보존, 자동 완료 금지 |
| T-17 | JAR 파일명 위장/중첩 | 후속 심화 기능에서 metadata 기반 검증 |
| T-18 | WinRM 인증서/인증 실패, Unix 출력 차이 | 명확한 오류 분류 및 안전한 실패; 네트워크 장비 후속 |
| T-19 | 수동 보정 9.0.86, 자동 9.0.85 | 원본 유지, 관리 9.0.86, 불일치/미검토 |
| T-20 | 재수집으로 자동 9.0.86 | 일치로 갱신, 수동 수정 표시 및 이력 유지 |
| T-21 | 불일치 검토 후 수동 유지 | 불일치 유지, 검토만 완료; 새로운 차이는 재검토 |
| T-22 | 자동값 적용(보정 해제) | 원본/수동 이력 보존, 관리값 자동으로 전환 |
| T-23 | 재수집 실패/오래된 관측 | 일치로 오인하지 않고 확인 불가/경고, 마지막 값 보존 |
| T-24 | 수동 등록과 신규 자동 설치 | 무조건 병합 금지, 검토 후 연결, 중복 이력 보존 |
| T-25 | 엑셀 보정·수정 충돌 | 같은 검증 서비스, 전체 중단/오류행/409, revision 재조회 |
| T-26 | 관리값 조건 불일치, 원본 조건 충족 | 양쪽 검색에서 후보 누락 없음, 불일치 근거 표시 |
| T-27 | 대시보드 카드·목록·엑셀 비교 | 같은 필터/기준 데이터, 건수 일치 |
| T-28 | 웹 DB 계정으로 관측 변경 | DB 권한 거부, 수집기 비밀 접근 금지 |
| T-29 | 모의 수집 및 실제 수집 혼합 | 데이터 출처·환경 구분, 실제 보고서에서 모의 제외 |
| T-30 | Linux/Unix/Windows 실제 개발 서버 | 각각 OS 및 접근 가능한 소프트웨어 관측 저장·화면·검색 검증 |
| T-31 | xlsx 수식/ZIP 팽창/잘못된 유형 | 거부·오류 안내, DB 변경 없음 |
| T-32 | 빈 DB migration/백업·복구 | 순차 실행 성공, 재실행 안전, 복구 후 원본/보정/작업 정합성 |
| T-33 | JSP WAR 실행, 기본 인증 및 권한 | 로그인, CSRF/XSS 방어, 수정/조회 권한 분리 |
| T-34 | 이중 클릭/같은 요청 키/다른 사용자 동시 저장 | 멱등성 및 충돌 거부, 감사 일관 |

프로토타입 완료: DEV-00~09 P0 기능 구현, P0 관련 T 시험 실제 통과, 3개 OS군 최소 실제 개발 서버 증거, 엑셀 왕복, 자동/수동 정합성 핵심 시나리오 통과. 지원이 안 되는 OS/제품은 `제한 지원/미지원` 및 이유, 테스트 미실행 항목 명시. UI만 동작하고 실제 DB/수집이 없는 상태를 완료라 주장하지 않는다. 후속 성능 SLA(T-15)와 심화(T-17)는 프로토타입 필수 합격 범위가 아니다.

## 15. 프로토타입 이후·운영 전 확정 사항 및 성능 목표

| 분야 | 프로토타입 적용 | 운영 전 필수 확정 |
|---|---|---|
| 네트워크 | 개발 서버 허가 경로 | 망 구간/방화벽/NAT, 운영 수집기 출발 IP, 별도 서버/구역별 키 |
| 수집 권한 | 승인된 최소 읽기, sudo 기본 금지 | 계정 권한 및 예외 sudo, 정밀 경로 승인, 키 회전/폐기 |
| Windows | 승인된 인증·신뢰 TLS 검증 | Kerberos/NTLM 등 도메인 인증 정책, 인증서 운영, 계정 권한 |
| 일정/성능 | 즉시 수집, 일정 OFF, 제한된 실행 | 기본/심화 주기, 병렬도, 타임아웃, SLA, 500대 규모 실측 |
| 권한/승인 | 개발용 개별 계정·기본 권한 | SSO/AD/LDAP, MFA, 세션, 자산별 RBAC, 작성/승인 분리 |
| 외부 노출 | 관리자 주장/증거 분리 | 방화벽/NAT/LB·외부 관측 근거, 재확인 주기 |
| 보존/복구 | 이력 보존·개발 백업 | 보존 기간, RPO/RTO, 아카이브, DR/수집기 이중화 |
| 규칙·조치 | 시험/활성/롤백 및 기록 | 승인 책임자/위험 수용/만료/재검증 조직 정책 |
| 배포 | 독립 WAR/JAR, 비밀 없는 설정 | 운영 OS·사양, 오프라인 반입/사내 Maven, 배포/모니터링/알림 |
| 디자인 | 하나그린 참고 토큰, 한국어 화면 | 공식 CI/로고/서체 권한, 브라우저·접근성 기준 |
| 확장 | 기본 3개 OS군 | 제품 지원 매트릭스, 컨테이너/라이브러리/네트워크 장비/외부 자료 |

v0.2 NFR 목표는 운영 PoC 후보로 유지한다: 수십~100대 기반, 500대 기본 배치 2시간 이내, 정상 연결·지원 범위 내 성공률 99%, 대표 OS/패키지 정확 식별 98%, 선정 런타임 탐지율 95%, 대표 검색 P95 2초 이내. 모두 실측 전 목표이며 SLA 아님. NFR-06 확인 불가/미발견 구분, NFR-08 작업 유실·중복 방지, NFR-10 보존/복구 구조는 프로토타입부터 검증. 나머지는 지표 산출 기반을 확보하고 운영 전 실제 규모·데이터량·네트워크·실패 분포와 함께 재측정한다.

대시보드 지표: 등록/활성 자산, 최근 24시간/7일 수집 정상률(완전/부분 분리), 마지막 성공 경과, 실패 유형, 확인 불가·정합성·미검토 건수, 변경 이벤트, 큐 대기/수집 P50/P95, 규칙 오류율, 조사 미완료/기한초과. 대상 부하 지표는 허가 범위 내 측정 가능한 환경에서만 표시. 집계 분모·기준시간·모의 데이터 제외 조건을 표기한다.

## 16. 개발 위험 및 대응

| 위험 | 대응 |
|---|---|
| Java 25 + JSP 신규 스택의 의존성 불일치 | 첫 단계 WAR/DB/통합 빌드, 정확한 BOM·패치 버전 고정 |
| WinRM/Unix 실제 서버 미확보 또는 인증 실패 | 실제 검증 미완료 명시, fixture로 대체 시험하되 완료 조건 대체 불가 |
| 수동 수정값에 의한 보안 조사 누락 | 양쪽 값 검색, 충돌·확인 필요 우선 표시 |
| 탐지 실패를 삭제·미설치로 처리 | 범위/증거/실패 사유, 마지막 정상 관측 보존 |
| 규칙의 임의 명령 또는 비밀 유출 | 독립 엔진 allowlist, 검증·자원 한도, 비밀 격리·마스킹 |
| 오래된 워커의 결과 쓰기 | lease token fencing, 트랜잭션 및 중복 제약 |
| 다중 설치 자동 병합 오류 | 안정적 locator, 근거 없는 병합 금지 |
| AI 코드 환각/무단 범위 확대 | 모듈별 지시서, 공식 문서 검증, 실행 테스트, 리뷰 |
| 운영 정책 미확정 상태로 운영 적용 | DEV_ONLY 환경 표시 및 배포 게이트, 운영 전 승인 필수 |

## 17. 최종 산출물 및 인수인계

- 기획안 v0.3, 화면 상세설계(UI ID·필드/동작/검증), API OpenAPI, DB ERD 및 컬럼 명세, 엑셀 실제 템플릿, 소스코드, AGENTS.md, 빌드/설치/수집 환경 설정 안내, 지원 매트릭스, 테스트 결과, 운영 유보·변경 목록.
- 개발 종료 시 결과 상태는 구현 완료/실제 검증 완료/모의 검증/미검증/제한 지원으로 구분. 소스 및 migration의 버전, 라이브러리 목록, 테스트 서버별 비식별 관측 증거, 미결함 목록과 재현 절차 기록.
- 이 문서는 개발 기준이다. 이 문서 작성만으로 화면/Figma, 실행 코드, 데이터베이스, 실제 수집 테스트 또는 운영 승인이 완료된 것이 아니다.

## 18. 검증 자료 및 참고 링크 (2026-11-26)

기존 v0.2 §20의 S-01~19 참조는 유지하며, 이번 기술 선정에 활용한 공식 문서를 추가한다.

- R01 Spring Boot 4.0 시스템 요구사항: https://docs.spring.io/spring-boot/4.0/system-requirements.html ; Java 25 지원 발표: https://spring.io/blog/2025/11/20/spring-boot-4-0-0-available-now/
- R02 JSP/WAR: https://docs.spring.io/spring-boot/4.0/reference/web/servlet.html ; https://docs.spring.io/spring-boot/4.0/how-to/deployment/traditional-deployment.html
- R03 PostgreSQL 18 지원: https://www.postgresql.org/support/versioning/
- R04 PostgreSQL 큐/JSONB: https://www.postgresql.org/docs/18/sql-select.html ; https://www.postgresql.org/docs/18/datatype-json.html
- R05 MyBatis 호환표: https://mybatis.org/spring-boot-starter/mybatis-spring-boot-autoconfigure/ ; https://github.com/mybatis/spring-boot-starter
- R06 Flyway/PostgreSQL: https://docs.spring.io/spring-boot/4.0/how-to/data-initialization.html ; https://documentation.red-gate.com/flyway/reference/database-driver-reference/postgresql-database
- R07 MINA SSHD: https://github.com/apache/mina-sshd ; https://github.com/apache/mina-sshd/blob/master/docs/client-setup.md ; https://mina.apache.org/sshd-project/downloads.html
- R08 WinRM Java: https://github.com/MetricsHub/winrm-java ; https://github.com/MetricsHub/winrm-java/releases
- R09 Microsoft WinRM: https://learn.microsoft.com/ko-kr/powershell/scripting/security/remoting/winrm-security ; https://learn.microsoft.com/en-us/troubleshoot/windows-client/system-management-components/configure-winrm-for-https
- R10 POI: https://poi.apache.org/components/spreadsheet/ ; https://poi.apache.org/security.html
- R11 하나금융그룹 CI: https://www.hanafn.com/hfm/mnu/aboutus/hanaFnCi.do (이전 CI 참고 조사, 세부 원본 매뉴얼 및 서체 권한은 미검증)

**검증 이력:** 기본 웹 및 Firecrawl 검색 성공(일부 동일 공식 원문을 반환하므로 독립 성능 비교 근거는 아님). Context7 선택 ID: `/websites/spring_io_spring-boot/4.0` (공식 Boot 4.0 문서), `/mybatis/spring-boot-starter` (호환 및 설정), `/apache/mina-sshd` (호스트 키 검증 및 클라이언트). GitHub에서 공개 MINA 및 WinRM 저장소 메타데이터/WinRM README 확인; 연결된 Project202701 저장소 검색 결과 없음, 저장소 생성·커밋·문서 업로드 없음. 실제 Maven 빌드·개발 서버 접속·성능 실측은 미실행이며 DEV 작업의 수용 조건이다. 기술 계열 선정 및 개발 기본값, UI 토큰/메뉴/API는 위임 범위 내 설계 선택이다.
