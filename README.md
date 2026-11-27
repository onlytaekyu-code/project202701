# Project202701

에이전트리스 OS·소프트웨어 인벤토리 및 취약점 영향 조사 시스템 (프로토타입, 운영 승인 전).

등록된 서버에서 별도 수집기가 SSH 및 WinRM으로 OS·소프트웨어 정보를 읽기 전용으로 수집한다. 관리자는 웹에서 자동 관측값과 관리값을 기준으로 영향 후보를 검색하고, 취약 여부와 조치 결과를 근거와 함께 기록한다.

- 현재 단계: DEV-00 (프로젝트 골격). 업무 기능은 DEV-01 이후 구현한다.
- 빌드·기동·DB migration 검증 상태: NOT_RUN (개발자 수행 예정)

## 구조

```text
project202701/                  루트 집계/부모 POM (com.security:project202701, packaging=pom)
  common/                       공용 enum, DTO, 버전 비교기, 검증 정책 (jar)
  persistence/                  MyBatis Mapper, SQL, DB 계약 (jar)
  db-migration/                 Flyway DDL 전용 실행 단위 (jar, Boot 실행)
    src/main/resources/db/migration/
  web/                          관리·조회·작업 등록 웹 (war, Boot 실행)
    src/main/webapp/WEB-INF/jsp/
  collector/                    원격 수집기 (jar, Boot 실행, 웹 의존성 없음)
  Doc/                          기획·설계 문서, Claude 결정 기록
```

| 모듈 | 의존 | 비고 |
|---|---|---|
| common | 없음 | 비밀·SSH/WinRM 코드 금지 |
| persistence | common, MyBatis, PostgreSQL JDBC | `#{...}` 바인딩만 사용 |
| db-migration | Flyway, PostgreSQL JDBC | migration 계정으로 실행 후 종료 |
| web | common, persistence, Spring MVC, JSP/JSTL | Flyway·원격 접속 라이브러리 없음 |
| collector | common, persistence | MINA SSHD/WinRM은 DEV-04/05 승인 후 추가 |

### 불변 경계

- 웹과 수집기는 직접 통신하지 않는다. DB 작업 테이블로만 연계한다.
- 원격 대상에 접속하는 것은 수집기뿐이다. SSH 개인키·WinRM 비밀은 수집기 로컬에만 둔다.
- 스키마 변경은 `db-migration`만 수행한다. web/collector는 자동 migration을 하지 않는다.
- 실제 원격 연결은 기본 OFF이며, 모의 데이터와 실제 데이터를 분리한다.

자세한 원칙은 `CLAUDE.md`, `AGENTS.md` 및 기획안 v0.3 §4를 따른다.

## 요구 환경

| 항목 | 기준 |
|---|---|
| JDK | Java 25 (Enforcer `[25,26)`) |
| Maven | Maven Wrapper, Maven 3.9.16 (Enforcer `[3.9,)`) |
| DB | PostgreSQL 18 목표 |
| IDE | Eclipse IDE for Enterprise Java (m2e 내장 Maven 3.9.16) |

의존성 버전과 라이선스는 [`Doc/docs/dependency-lock.md`](Doc/docs/dependency-lock.md)에 기록한다.

## 환경 설정

접속 정보와 비밀은 Git에 커밋하지 않는다. 실행 단위별로 계정을 분리한다(결정 기록 D-008 미결정).

| 실행 단위 | 환경변수 | 용도 |
|---|---|---|
| db-migration | `MIGRATION_DB_URL`, `MIGRATION_DB_USERNAME`, `MIGRATION_DB_PASSWORD` | DDL 전용 계정 |
| collector | `COLLECTOR_DB_URL`, `COLLECTOR_DB_USERNAME`, `COLLECTOR_DB_PASSWORD` | 작업 claim·결과 저장 최소 권한 계정 |
| web | `web/src/main/resources/application.properties` | 현재 구 테스트 DB 설정 유지 중. DB 교체 시 환경변수 방식으로 정리 예정 |

- 기본값이 없는 환경변수가 비어 있으면 해당 실행 단위는 기동에 실패한다.
- web 기본 포트: 8808

## 빌드 및 실행 (개발자 수행)

아래 명령은 개발자 참고용이다. AI 도구는 지침(`CLAUDE.md` §0, §10)에 따라 빌드·기동·migration을 자동 실행하지 않는다.

```bash
# 도구 확인
java -version
./mvnw -v                     # Windows: mvnw.cmd -v

# 빌드 및 의존성 확인
./mvnw validate
./mvnw help:effective-pom
./mvnw dependency:tree
./mvnw package                # 테스트 포함

# 1) DB migration (빈 DB에 순차 적용 후 종료)
java -jar db-migration/target/project202701-db-migration-0.0.1-SNAPSHOT.jar

# 2) 웹 기동 후 http://localhost:8808/ 에서 JSP 렌더링 확인
java -jar web/target/project202701-web-0.0.1-SNAPSHOT.war

# 3) 수집기 (DEV-03 이전에는 실행 골격만 존재)
java -jar collector/target/project202701-collector-0.0.1-SNAPSHOT.jar
```

- JSP는 war 패키징에서만 동작한다. executable jar로 바꾸지 않는다.
- IDE에서 `WebApplication`을 실행할 때 작업 디렉터리는 `web` 모듈이어야 `src/main/webapp`의 JSP를 찾는다.
- 적용된 Flyway migration 파일은 수정·삭제하지 않는다. `clean`은 비활성화되어 있다.

## Eclipse 가져오기

1. File > Import > Maven > Existing Maven Projects에서 저장소 루트를 선택하고 루트와 하위 모듈 5개를 모두 가져온다.
2. 전체 선택 후 Maven > Update Project (Alt+F5).
3. `web` 모듈은 Dynamic Web 프로젝트로 구성된다. 루트는 pom 프로젝트다.

## 문서

| 문서 | 경로 |
|---|---|
| AI 공통 지침 | `AGENTS.md`, `CLAUDE.md` |
| 기획안 v0.3 | `Doc/기획/Project202701_기획안_v0.3_프로토타입_개발기준.md` |
| 통합 화면설계·AI 개발지시서 v1.1 | `Doc/설계/Project202701_통합화면설계_및_AI개발지시서_v1.1.md` |
| 화면설계·AI 개발작업지시서 v1.3 (WP 분해) | `Doc/설계/Project202701_화면설계_및_AI개발작업지시서_통합_v1.3.pptx` |
| 최종 화면설계서 v1.1 | `Doc/설계/Project202701_최종화면설계서_v1.1.pptx` |
| Claude 결정 기록 | `Doc/docs/decisions-claude.md` |
| 의존성 기록 | `Doc/docs/dependency-lock.md` |

## 개발 단계

DEV-00 골격 → DEV-01 DB·권한·감사 → DEV-02 공통 UI·인증·자산/제품·엑셀 → DEV-03 DB 큐·모의 수집 → DEV-04 Linux 수집 → DEV-05 Unix·Windows 수집 → DEV-06 정합성 → DEV-07 검색·이슈·판단 → DEV-08 규칙·운영 → DEV-09 통합 수용.

상태는 `IMPLEMENTED`(AI 구현·소스 검토) / `VERIFIED`(개발자 기술 검증) / `DONE`(개발자 인수)로 구분한다.
