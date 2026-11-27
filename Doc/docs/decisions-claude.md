# Claude 결정 기록

`CLAUDE.md`의 "결정 기록 파일" 규칙에 따라 Claude가 작성한다. `docs/decisions.md`(AGENTS.md 기준, 다른 개발자용)와는 별개다.

- 기획안 v0.3: `Doc/기획/Project202701_기획안_v0.3_프로토타입_개발기준.md`
- 설계서 v1.1: `Doc/설계/Project202701_통합화면설계_및_AI개발지시서_v1.1.md`

---

## D-001 Spring Boot 버전

- 날짜: 2026-11-26
- 상태: 결정
- 충돌 내용: 기획안 v0.3 §3과 설계서 v1.1 §6은 Spring Boot 4.0.x를 기준으로 한다. 기존 `pom.xml`은 4.2.0이었다.
- 대안:
  1. 4.2.0 유지 (문서 기준과 다름, MyBatis Starter 4.0.x 호환 미확인)
  2. 4.0.x 최신 패치로 변경
- 결정: 4.0.10으로 변경 (2026-11-26 기준 4.0.x 최신 GA)
- 영향 범위: `pom.xml` parent. BOM 관리 버전이 Spring Framework 7.0.11, Tomcat 11.0.27, Flyway 11.14.1, PostgreSQL JDBC 42.7.14로 정해진다.
- 결정자: 박소명

## D-002 DB 접근 방식

- 날짜: 2026-11-26
- 상태: 결정
- 충돌 내용: 기획안 v0.3 §3은 MyBatis Starter 4.0.x를 기준으로 한다. 이전 `CLAUDE.md`에는 JdbcTemplate 사용 규칙이 있었으나 커밋 0984167에서 삭제되었다.
- 대안:
  1. `spring-boot-starter-jdbc`(JdbcTemplate) 유지
  2. 문서 기준 MyBatis 사용
- 결정: MyBatis 사용. `mybatis-spring-boot-starter` 4.0.1 추가(Spring Boot 4.0.1 기준 빌드), `spring-boot-starter-jdbc` 직접 의존성 삭제(MyBatis starter에 포함).
- 영향 범위: `pom.xml`. 기존 `testController`(DB 접속 테스트용)가 JdbcTemplate을 사용하며, MyBatis starter에 포함된 `spring-boot-starter-jdbc`로 계속 동작한다. HikariCP는 그대로 사용된다.
- 결정자: 박소명

## D-003 웹 starter 교체

- 날짜: 2026-11-26
- 상태: 결정
- 충돌 내용: 문서 충돌은 아니다. Spring Boot 4.0에서 `spring-boot-starter-web`은 `spring-boot-starter-webmvc`로 대체되어 deprecated 처리되었다.
- 대안:
  1. `spring-boot-starter-web` 유지 (deprecated)
  2. `spring-boot-starter-webmvc`로 교체
- 결정: `spring-boot-starter-webmvc`로 교체
- 영향 범위: `pom.xml`. 포함 기능(Spring MVC, 내장 Tomcat, Jackson)은 동일하다.
- 결정자: 박소명 (pom 문서 기준 정리 지시에 따름)

## D-004 DEV-00 필수 라이브러리 추가 범위

- 날짜: 2026-11-26
- 상태: 결정
- 충돌 내용: `CLAUDE.md` 규칙 1, 2는 pom에 없는 라이브러리 사용 전 확인을 요구한다. 설계서 v1.1 §6의 DEV-00 완료 게이트는 JSP WAR 기동과 PostgreSQL Flyway migration을 요구한다.
- 대안:
  1. 기획안 v0.3 §3의 전체 스택을 한 번에 추가
  2. DEV-00에 꼭 필요한 것만 추가
- 결정: 2안. 추가한 항목은 다음과 같다.
  - `tomcat-embed-jasper`, `jakarta.servlet.jsp.jstl-api`, `org.glassfish.web:jakarta.servlet.jsp.jstl` (JSP/JSTL)
  - `spring-boot-starter-flyway`, `flyway-database-postgresql` (Flyway)
  - `maven-enforcer-plugin` (Java 25, Maven 3.9 이상, 동적 버전 금지)
- 보류한 항목: Spring Security(DEV-02, 추가 시 모든 화면에 인증 적용), Apache POI(DEV-02), Jakarta Validation(DEV-02), Apache MINA SSHD(DEV-04), MetricsHub WinRM Java(DEV-05)
- 영향 범위: `pom.xml`. `mvn -DskipTests package` 통과 확인(JDK 25.0.4, Maven 3.10.1). 테스트는 DB 접속이 필요해 미실행.
- 결정자: 박소명

## D-005 Flyway 실행 위치

- 날짜: 2026-11-26 (결정 2026-11-27)
- 상태: 결정
- 관련: DEV-00 WP-00-01/02, 기획안 v0.3 §3·§7·§12.2, T-32
- 충돌 내용: 기획안 v0.3 §12.2는 독립 실행 단위(`db-migration`)가 migration을 적용하고 web/collector의 자동 migration을 금지한다. 기존 단일 모듈에서는 Flyway starter가 web 기동 시 자동 실행되었다.
- 대안:
  1. 멀티모듈 전환 시 `db-migration` 모듈로 분리
  2. 단일 모듈 유지 시 web에서 `spring.flyway.enabled=false`로 두고 별도 실행 방법 마련
- 결정: 1안. Flyway 의존성(`spring-boot-starter-flyway`, `flyway-database-postgresql`)은 `db-migration` 모듈에만 둔다. web/collector/persistence에는 Flyway 의존성을 두지 않아 자동 migration이 발생하지 않는다. `db-migration`은 웹 서버 없는 Boot 애플리케이션으로 migration 적용 후 종료하며 `clean-disabled=true`, `validate-on-migrate=true`를 명시한다.
- 영향 범위: 루트/모듈 POM, `db-migration/src/main/resources/application.properties`, `db/migration` 경로
- 검증: 2026-11-27 개발자 보고로 확인. 빈 DB에서 `db-migration` 실행 성공(`app.flyway_schema_history` 생성), web 기동 성공. web·collector·persistence 의존성 트리에 Flyway 없음(`dependency-lock.md` 4·5절). migration 파일 순차 적용·재실행(T-32)은 DEV-01 이후
- 롤백: 이 커밋 이전 단일 모듈 POM으로 복원
- 결정자: 박소명

## D-006 모듈 구조

- 날짜: 2026-11-26 (결정 2026-11-27)
- 상태: 결정
- 관련: DEV-00 WP-00-01, 기획안 v0.3 §12.2, 설계서 v1.1 §6, FR-029, FR-036
- 충돌 내용: 기획안 v0.3 §12.2는 Maven 멀티모듈(common, persistence, db-migration, web, collector, integration-tests)을 요구한다. 기존은 단일 모듈 `demo`였다. 한 차례 다른 브랜치에서 전환 후 원복했으며, 원복 사유는 지침(AGENTS.md/CLAUDE.md)과 설계 문서(v1.3) 개정이다.
- 대안:
  1. DEV-00에서 멀티모듈로 전환
  2. 단일 모듈로 시작 후 수집기 개발 전에 분리
- 결정: 1안. 루트 `com.security:demo`는 `packaging=pom` 집계/부모 POM이며 Boot parent 4.0.10, `java.version=25`, Enforcer 규칙, MyBatis 버전 관리를 상속한다. 하위 모듈:
  - `project202701-common` (jar): 공용 enum/DTO. 외부 의존성 없음
  - `project202701-persistence` (jar): common, MyBatis starter, PostgreSQL(runtime)
  - `project202701-db-migration` (jar, Boot 실행): Flyway, PostgreSQL(runtime)
  - `project202701-web` (war, Boot 실행): common, persistence, webmvc, jasper, JSTL, starter-test(test). 기존 `DemoApplication`/`ServletInitializer`를 `com.security.web.WebApplication`/`WebServletInitializer`로 이동
  - `project202701-collector` (jar, Boot 실행): common, persistence. 웹 의존성 없음. SSH/WinRM 라이브러리는 DEV-04/05 승인 후
- 제외: `integration-tests` 모듈은 테스트 전용 모듈이므로 `CLAUDE.md` §0에 따라 AI가 생성하지 않는다. 개발자가 생성하거나 별도 지시 시 진행한다.
- 함께 처리: 사용자 지시에 따라 테스트 목적의 기존 소스 `testController`(구 테스트 DB `app.sample` 조회)와 `DemoApplicationTests`를 삭제했다. web의 DB 접속 설정(`web/src/main/resources/application.properties`)은 DB 교체 예정이라 내용 변경 없이 이동만 했다.
- 신규 의존성: 없음. 기존 POM 직접 의존성을 모듈별로 재배치만 했다. 버전·scope 변경 없음.
- 영향 범위: 전체 프로젝트 구조, Eclipse 프로젝트 구성(하위 모듈별 프로젝트), D-005
- 검증: 2026-11-27 개발자 보고로 확인. Eclipse m2e에서 루트 `clean package` 통과(WAR/JAR 생성), `help:effective-pom` 및 전 모듈 `dependency:tree` 확인(`dependency-lock.md` 5절)
- 롤백: 이 커밋 이전 단일 모듈 구조로 복원
- 결정자: 박소명

## D-009 루트 프로젝트 이름

- 날짜: 2026-11-27
- 상태: 결정
- 관련: DEV-00 WP-00-01, D-006
- 충돌 내용: 루트 Maven 좌표가 초기 생성 시의 `com.security:demo`였고, 저장소 폴더명·하위 모듈 이름(`project202701-*`)과 맞지 않았다. `CLAUDE.md`/`AGENTS.md` §3.1 스냅샷은 `com.security:demo:0.0.1-SNAPSHOT`으로 기록되어 있다.
- 결정: 루트 artifactId를 `project202701`로 변경(`com.security:project202701:0.0.1-SNAPSHOT`). 하위 모듈의 parent 참조를 같이 변경했다. web `spring.application.name`도 `project202701-web`으로 변경했다.
- 영향 범위: 루트 및 모든 모듈 POM, web `application.properties`(DB 설정 제외), Eclipse 루트 프로젝트 이름. `CLAUDE.md`/`AGENTS.md` §3.1 스냅샷과 달라지며, 지침상 실제 POM이 우선한다. 지침 문서 갱신 여부는 별도 확인.
- 검증: 2026-11-27 개발자 보고로 확인. 루트 `validate`/`clean package` 통과로 모듈 parent 해석 확인. `CLAUDE.md`/`AGENTS.md` §3.1 스냅샷은 `com.security:project202701`로 갱신됨
- 롤백: artifactId를 `demo`로 복원
- 결정자: 박소명

## D-007 Maven 버전

- 날짜: 2026-11-26 (결정 2026-11-27)
- 상태: 결정
- 관련: DEV-00 WP-00-01, 기획안 v0.3 §3
- 충돌 내용: 기획안 v0.3 §3은 Maven Wrapper 3.9.x를 기준으로 한다. 기존 `.mvn/wrapper/maven-wrapper.properties`는 Maven 3.10.1이었다.
- 대안:
  1. 3.10.1 유지
  2. 3.9.x 최신 패치로 변경
- 결정: 2안. Wrapper 배포판을 Maven 3.9.16으로 변경. 2026-11-27 기준 Maven Central `apache-maven` 메타데이터의 3.9 계열 최고 GA이며(`apache-maven-3.9.16-bin.zip` 존재 확인), Eclipse 2026-09 m2e 내장 런타임(`org.eclipse.m2e.maven.runtime_3.9.1601`)과 같은 계열이다. Enforcer `requireMavenVersion [3.9,)`는 변경하지 않았다.
- 영향 범위: `.mvn/wrapper/maven-wrapper.properties`. 로컬에 받아 둔 3.10.1 배포판은 더 이상 쓰이지 않는다.
- 제한: Wrapper `distributionSha256Sum` 검증값은 설정하지 않았다(필요 시 공식 checksum 확인 후 추가). 기존 TLS 오류(SEC_E_UNTRUSTED_ROOT)로 Wrapper 다운로드가 실패할 수 있다.
- 검증: 2026-11-27 개발자 보고로 확인. Maven 3.9.16, Java 25로 설계 기준과 일치
- 롤백: distributionUrl을 3.10.1로 복원
- 결정자: 박소명

## D-010 banDynamicVersions 내부 모듈 제외

- 날짜: 2026-11-27
- 상태: 결정
- 관련: DEV-00 WP-00-01, D-006, CLAUDE.md §3.3
- 충돌 내용: 멀티모듈 전환 후 web·collector·persistence가 내부 모듈(`project202701-common`, `project202701-persistence`)을 `${project.version}`(`0.0.1-SNAPSHOT`)으로 참조한다. `banDynamicVersions`는 기본값(`allowSnapshots=false`)에서 `-SNAPSHOT` 의존성을 금지하므로 빌드가 실패했다(개발자 보고). 단일 모듈일 때는 SNAPSHOT 의존성이 없어 통과했다.
- 대안:
  1. `ignores`로 내부 모듈 좌표만 제외
  2. `allowSnapshots=true`로 SNAPSHOT 전체 허용
  3. 규칙 제거
- 결정: 1안. 루트 `pom.xml`의 `banDynamicVersions`에 `<ignore>com.security:project202701-*</ignore>`를 추가했다. 외부 의존성의 SNAPSHOT·범위·`LATEST`·`RELEASE` 금지는 유지된다. 2·3안은 외부 SNAPSHOT까지 허용하므로 채택하지 않았다.
- 근거: Maven Enforcer 공식 문서(banDynamicVersions, 3.7.0 문서) `ignores` 형식 `groupId[:artifactId[:version...]]`, 와일드카드 지원. 현재 Boot 부모 관리 enforcer 버전은 3.6.3이며 해당 버전의 `ignores` 지원은 개발자 빌드로 확인한다.
- 영향 범위: 루트 `pom.xml`(전 모듈 상속), `Doc/docs/dependency-lock.md`
- 검증: 2026-11-27 개발자 보고로 확인. Eclipse m2e(Enforcer 3.6.3)에서 `validate`와 `clean package` 통과. `ignores`가 3.6.3에서 동작함을 확인
- 롤백: `banDynamicVersions`의 `ignores` 제거
- 결정자: 박소명

## D-008 DB 계정 분리 및 접속 설정

- 날짜: 2026-11-27 (결정 2026-11-27)
- 상태: 결정
- 관련: DEV-00 WP-00-02, 기획안 v0.3 §7(데이터 원칙, DB 역할)·§12.2, CLAUDE.md §4·§8.2, T-28, T-32
- 충돌 내용: 기획안은 migration(DDL) 계정과 web/collector 런타임 계정을 분리하도록 요구한다. web `application.properties`에는 구 테스트 DB(192.168.56.101, `testuser`) 주소와 기본 비밀번호가 남아 있었고, 주석("환경변수 권장")과 실제 설정(기본 비밀번호 사용)이 맞지 않았다.
- 대안:
  1. web도 환경변수 전용(`WEB_DB_*`)으로 전환, 비밀 없는 설정만 커밋
  2. Git 제외 로컬 프로필 파일 사용
- 결정: 1안. 새 개발 DB `192.168.56.1:5432`를 기준으로 다음과 같이 정한다.
  - 데이터베이스 `project202701`(UTF-8, 소유자 `p27_migration`, DB 기본 timezone UTC), 업무 스키마 `app`(소유자 `p27_migration`). `public` 스키마는 PUBLIC 권한 회수.
  - 계정: `p27_migration`(DDL 전용, db-migration만 사용), `p27_web`(웹 런타임), `p27_collector`(수집기 런타임). 런타임 계정은 현 단계에서 CONNECT와 `app` USAGE만 가진다. 테이블·컬럼·함수 권한은 DEV-01 migration에서 최소 권한으로 부여한다(관측 원본·작업 완료 상태에 대한 web UPDATE/DELETE 금지, T-28).
  - 세 계정 모두 `project202701`에서 `search_path=app`.
  - 접속 정보: web `WEB_DB_URL/USERNAME/PASSWORD`, collector `COLLECTOR_DB_*`, db-migration `MIGRATION_DB_*`. 모두 환경변수 전용이며 기본값이 없어 미설정 시 기동 실패한다.
  - db-migration은 `spring.flyway.schemas=app`, `spring.flyway.create-schemas=false`로 이력 테이블을 `app`에 두고, 스키마는 초기 구성 스크립트로만 만든다(누락 시 migration 실패).
- 초기 구성: DB·계정·스키마 생성은 개발자가 관리자 계정으로 1회 수행한다. 스크립트와 명세: `Doc/DB/sql/00_bootstrap.sql`, `Doc/DB/Project202701_DB_환경_및_계정_명세.md`. 비밀번호는 스크립트에 쓰지 않고 psql `\password`로 입력한다.
- 제한: 구 테스트 DB 비밀번호가 이전 커밋(`6e99a67`, `5e441d4` 등)의 `application.properties`에 남아 있다. 이력 재작성은 하지 않았다. 해당 계정이 다른 곳에서 쓰이면 비밀번호를 바꾸거나 폐기한다.
- 영향 범위: web/db-migration `application.properties`, README 환경 설정, `Doc/DB/`. DEV-01 DB 역할·권한 migration의 전제.
- 검증: 2026-11-27 개발자 보고로 확인. 초기 구성 스크립트 실행, `p27_migration`으로 db-migration 실행(`app.flyway_schema_history` 생성), `WEB_DB_*` 설정 후 web 기동·JSP 렌더링 성공. 런타임 계정 최소 권한(T-28)은 DEV-01 이후 확인
- 롤백: web `application.properties`를 이전 버전으로 복원, db-migration의 `spring.flyway.schemas`/`create-schemas` 제거. DB 객체는 명세서의 정리 절차(관리자 수행)로 제거
- 결정자: 박소명

---

## 미결정 항목

(현재 없음)
