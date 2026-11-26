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

---

## 미결정 항목

## D-005 Flyway 실행 위치

- 날짜: 2026-11-26
- 상태: 미결정
- 충돌 내용: 기획안 v0.3 §12.2는 독립 실행 단위(`db-migration`)가 migration을 적용하고 web/collector의 자동 migration을 금지한다. 현재는 단일 모듈이라 Flyway starter가 web 기동 시 자동 실행된다.
- 대안:
  1. 멀티모듈 전환 시 `db-migration` 모듈로 분리
  2. 단일 모듈 유지 시 web에서 `spring.flyway.enabled=false`로 두고 별도 실행 방법 마련
- 결정: 없음
- 영향 범위: `pom.xml`, `application.properties`, 모듈 구조
- 결정자: 미정

## D-006 모듈 구조

- 날짜: 2026-11-26
- 상태: 미결정
- 충돌 내용: 기획안 v0.3 §12.2는 Maven 멀티모듈(common, persistence, db-migration, web, collector, integration-tests)을 요구한다. 현재는 단일 모듈 `demo`다.
- 대안:
  1. DEV-00에서 멀티모듈로 전환
  2. 단일 모듈로 시작 후 수집기 개발 전에 분리
- 결정: 없음
- 영향 범위: 전체 프로젝트 구조, D-005
- 결정자: 미정

## D-007 Maven 버전

- 날짜: 2026-11-26
- 상태: 미결정
- 충돌 내용: 기획안 v0.3 §3은 Maven Wrapper 3.9.x를 기준으로 한다. 현재 `.mvn/wrapper/maven-wrapper.properties`는 Maven 3.10.1이다. Enforcer 규칙은 3.9 이상으로 두어 양쪽 모두 허용한다.
- 대안:
  1. 3.10.1 유지
  2. 3.9.x 최신 패치로 변경
- 결정: 없음
- 영향 범위: `.mvn/wrapper/maven-wrapper.properties`
- 결정자: 미정
