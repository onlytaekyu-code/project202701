# Project202701 의존성 기록

- 기준일: 2026-11-27
- 기준: 기획안 v0.3 §3 "버전 관리", 설계서 v1.3 WP-00-01, `CLAUDE.md` §3
- 작성: Claude Code (DEV-00 WP-00-01)
- 상태: IMPLEMENTED. 의존성 해석 검증은 NOT_RUN (개발자 수행 예정)

## 0. 이 문서의 근거와 한계

- 버전은 각 POM의 직접 선언과 로컬 Maven 저장소(`~/.m2`)에 있는 `spring-boot-dependencies:4.0.10` BOM의 관리 버전에서 읽었다.
- 라이선스는 로컬 저장소에 있는 각 아티팩트 POM(또는 부모 POM)의 `<licenses>` 값을 옮겼다.
- `dependency:tree`, `help:effective-pom`, SBOM 생성, 취약점 점검은 실행하지 않았다. 전이 의존성 전체 목록과 실제 해석 결과는 개발자가 확인하여 이 문서의 5절에 추가한다.
- 선언된 버전이 실제 다운로드·해석·실행 성공을 보장하지 않는다.

## 1. 빌드 기준

| 항목 | 값 | 선언 위치 |
|---|---|---|
| 프로젝트 좌표 | `com.security:project202701:0.0.1-SNAPSHOT` (packaging=pom) | 루트 `pom.xml` |
| Spring Boot Parent | `org.springframework.boot:spring-boot-starter-parent:4.0.10` | 루트 `pom.xml` |
| Java | `java.version=25`, Enforcer `[25,26)` | 루트 `pom.xml` |
| Maven | Wrapper 배포판 3.9.16, Enforcer `[3.9,)` | `.mvn/wrapper/maven-wrapper.properties`, 루트 `pom.xml` |
| Maven Wrapper | `wrapperVersion=3.3.4`, `distributionType=only-script` | `.mvn/wrapper/maven-wrapper.properties` |
| Enforcer 규칙 | `requireJavaVersion`, `requireMavenVersion`, `banDynamicVersions`(내부 모듈 `com.security:project202701-*`만 제외, D-010) | 루트 `pom.xml` (전 모듈 상속) |
| maven-enforcer-plugin | 3.6.3 (Boot 부모 관리) | Boot BOM |

## 2. 모듈 좌표

| 모듈 | 좌표 | 패키징 |
|---|---|---|
| common | `com.security:project202701-common:0.0.1-SNAPSHOT` | jar |
| persistence | `com.security:project202701-persistence:0.0.1-SNAPSHOT` | jar |
| db-migration | `com.security:project202701-db-migration:0.0.1-SNAPSHOT` | jar (Boot 실행) |
| web | `com.security:project202701-web:0.0.1-SNAPSHOT` | war (Boot 실행) |
| collector | `com.security:project202701-collector:0.0.1-SNAPSHOT` | jar (Boot 실행) |

프로젝트 자체 `0.0.1-SNAPSHOT`은 의존성 버전이 아니며, 내부 모듈 간 참조는 루트 `dependencyManagement`의 `${project.version}`으로 고정한다.

## 3. 직접 선언 의존성

| groupId:artifactId | 버전 | 버전 출처 | scope | 사용 모듈 | 라이선스 |
|---|---|---|---|---|---|
| `org.springframework.boot:spring-boot-starter-webmvc` | 4.0.10 | Boot BOM | compile | web | Apache-2.0 |
| `org.apache.tomcat.embed:tomcat-embed-jasper` | 11.0.27 | Boot BOM (`tomcat.version`) | compile | web | Apache-2.0 |
| `jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api` | 3.0.2 | Boot BOM | compile | web | EPL-2.0 / GPL-2.0 with Classpath Exception |
| `org.glassfish.web:jakarta.servlet.jsp.jstl` | 3.0.1 | Boot BOM (`glassfish-jstl.version`) | compile | web | EPL-2.0 / GPL-2.0 with Classpath Exception |
| `org.mybatis.spring.boot:mybatis-spring-boot-starter` | 4.0.1 | 루트 `mybatis-spring-boot.version` | compile | persistence (→ web, collector 전이) | Apache-2.0 (부모 POM 기준, 개발자 확인 필요) |
| `org.springframework.boot:spring-boot-starter-flyway` | 4.0.10 | Boot BOM | compile | db-migration | Apache-2.0 |
| `org.flywaydb:flyway-database-postgresql` | 11.14.1 | Boot BOM (`flyway.version`) | compile | db-migration | Apache-2.0 (flyway-parent) |
| `org.postgresql:postgresql` | 42.7.14 | Boot BOM | runtime | persistence, db-migration | BSD-2-Clause |
| `org.springframework.boot:spring-boot-starter-test` | 4.0.10 | Boot BOM | test | web | Apache-2.0 |

## 4. 주요 전이 의존성 (BOM 관리 버전)

스타터 POM에서 확인한 포함 관계와 BOM 관리 버전이다. 실제 해석 여부는 `dependency:tree`로 확인한다.

| 아티팩트 | 버전 | 경유 | 라이선스 |
|---|---|---|---|
| Spring Framework | 7.0.11 | 모든 Boot starter | Apache-2.0 |
| Apache Tomcat (embed) | 11.0.27 | `spring-boot-starter-tomcat` (webmvc) | Apache-2.0 |
| Jakarta Servlet API | 6.1.0 | Tomcat 11 | EPL-2.0 / GPL-2.0 with CPE |
| `spring-boot-starter-jdbc` / HikariCP | 4.0.10 / 7.0.2 | MyBatis starter, Flyway starter | Apache-2.0 |
| `org.mybatis:mybatis` | 3.5.19 | MyBatis starter (`mybatis.version`) | Apache-2.0 (mybatis-parent) |
| `org.mybatis:mybatis-spring` | 4.0.0 | MyBatis starter (`mybatis-spring.version`) | Apache-2.0 (mybatis-parent) |
| `org.flywaydb:flyway-core` | 11.14.1 | Flyway starter | Apache-2.0 |
| Jackson | 3.1.8 (BOM) | `spring-boot-starter-jackson` (webmvc) | Apache-2.0 |
| SLF4J / Logback | 2.0.20 / 1.5.38 | `spring-boot-starter-logging` | MIT / EPL-1.0 · LGPL-2.1 (개발자 확인 필요) |
| JUnit Jupiter / Mockito / AssertJ | 6.0.3 / 5.20.0 / 3.27.7 | `spring-boot-starter-test` (test) | EPL-2.0 / MIT / Apache-2.0 (개발자 확인 필요) |

## 5. 개발자 확인 결과 (미제공)

| 항목 | 상태 |
|---|---|
| `mvnw -v`, `java -version` | NOT_RUN (개발자 수행 예정) |
| `mvnw validate` (Enforcer) | NOT_RUN (개발자 수행 예정) |
| `mvnw help:effective-pom` | NOT_RUN (개발자 수행 예정) |
| `mvnw dependency:tree` (전 모듈) | NOT_RUN (개발자 수행 예정) |
| SBOM 생성 | NOT_RUN. 도구(플러그인) 미등록, 도입 시 승인 필요 |
| 알려진 취약점 점검 | NOT_RUN. 점검 도구·결과 개발자 제공 필요 |
| 빈 PostgreSQL 18 DB에서 Flyway 11.14.1 migration | NOT_RUN (개발자 수행 예정, T-32) |

## 6. 승인 대기 라이브러리 (현재 미등록)

`CLAUDE.md` §3.3에 따라 아래는 POM에 없으며 승인 전 사용하지 않는다.

| 라이브러리 | 목적 | 필요 시점 |
|---|---|---|
| Spring Security | 인증·권한·CSRF | DEV-02 |
| Apache POI | xlsx 읽기·쓰기 | DEV-02 / DEV-06 |
| Jakarta Validation (`spring-boot-starter-validation`) | DTO 입력 검증 | DEV-02 (기획안 §3 후보) |
| Apache MINA SSHD | Linux/Unix SSH 수집 | DEV-04 / DEV-05 |
| MetricsHub WinRM Java | Windows 수집 | DEV-05 |
| RE2/J | 안전한 정규식 | DEV-08 (기획안 §3 후보) |

## 7. 변경 이력

| 날짜 | 변경 | 근거 |
|---|---|---|
| 2026-11-27 | 최초 작성. 멀티모듈 전환 후 직접 의존성 재배치, 루트 좌표 `project202701`, Maven Wrapper 3.9.16 | D-006, D-009, D-007 |
