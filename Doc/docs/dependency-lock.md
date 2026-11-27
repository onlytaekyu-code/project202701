# Project202701 의존성 기록

- 기준일: 2026-11-27
- 기준: 기획안 v0.3 §3 "버전 관리", 설계서 v1.3 WP-00-01, `CLAUDE.md` §3
- 작성: Claude Code (DEV-00 WP-00-01)
- 상태: DONE (2026-11-27 개발자 확인). Java·Maven·PostgreSQL 버전, `validate`, `clean package`, `help:effective-pom`, 전 모듈 `dependency:tree` 결과 반영(5절). SBOM과 취약점 점검은 DEV-00 범위에서 제외

## 0. 이 문서의 근거와 한계

- 버전은 각 POM의 직접 선언과 로컬 Maven 저장소(`~/.m2`)에 있는 `spring-boot-dependencies:4.0.10` BOM의 관리 버전에서 읽었다.
- 라이선스는 로컬 저장소에 있는 각 아티팩트 POM(또는 부모 POM)의 `<licenses>` 값을 옮겼다.
- AI는 `dependency:tree`, `help:effective-pom`, SBOM 생성, 취약점 점검을 실행하지 않았다. 4절의 전이 의존성은 개발자가 제공한 `dependency:tree` 출력(2026-11-27)으로 대조했고, 실행 결과는 5절에 기록한다. SBOM과 취약점 점검은 DEV-00 범위에서 제외되어 수행하지 않았다.
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

개발자가 제공한 전 모듈 `dependency:tree` 출력(2026-11-27, Eclipse m2e, maven-dependency-plugin 3.9.0)으로 확인한 해석 결과다. "모듈" 열은 해당 아티팩트가 포함되는 실행 단위다. 라이선스 중 "(확인 필요)"는 아티팩트 POM 대조 전의 공개 정보 기준 값이다.

### 4.1 공통 (common·persistence 경유 또는 Boot starter 공통)

| 아티팩트 | 버전 | 경유 | 모듈 | 라이선스 |
|---|---|---|---|---|
| Spring Framework (`spring-core`, `-context`, `-beans`, `-aop`, `-expression`, `-tx`, `-jdbc`) | 7.0.11 | Boot starter | 전체 | Apache-2.0 |
| Spring Boot (`spring-boot`, `-autoconfigure`, `-jdbc`, `-sql`, `-transaction`, `-persistence`) | 4.0.10 | Boot starter | 전체 | Apache-2.0 |
| `com.zaxxer:HikariCP` | 7.0.2 | `spring-boot-starter-jdbc` | 전체 | Apache-2.0 |
| `org.mybatis:mybatis` | 3.5.19 | MyBatis starter (`mybatis.version`) | persistence, web, collector | Apache-2.0 (mybatis-parent) |
| `org.mybatis:mybatis-spring` | 4.0.0 | MyBatis starter (`mybatis-spring.version`) | persistence, web, collector | Apache-2.0 (mybatis-parent) |
| `org.mybatis.spring.boot:mybatis-spring-boot-autoconfigure` | 4.0.1 | MyBatis starter | persistence, web, collector | Apache-2.0 |
| `org.postgresql:postgresql` | 42.7.14 (runtime) | 직접 선언 | 전체 | BSD-2-Clause |
| `org.checkerframework:checker-qual` | 3.55.1 (runtime) | `postgresql` | 전체 | MIT (확인 필요) |
| SLF4J (`slf4j-api`, `jul-to-slf4j`) / Logback (`logback-classic`, `-core`) | 2.0.20 / 1.5.38 | `spring-boot-starter-logging` | 전체 | MIT / EPL-1.0 · LGPL-2.1 (확인 필요) |
| `org.apache.logging.log4j:log4j-to-slf4j` / `log4j-api` | 2.25.5 | `spring-boot-starter-logging` | 전체 | Apache-2.0 (확인 필요) |
| `io.micrometer:micrometer-observation` / `micrometer-commons` | 1.16.9 | `spring-context` | 전체 | Apache-2.0 (확인 필요) |
| `commons-logging:commons-logging` | 1.3.6 | `spring-core` | 전체 | Apache-2.0 (확인 필요) |
| `org.jspecify:jspecify` | 1.0.1 | `spring-core` | 전체 | Apache-2.0 (확인 필요) |
| `jakarta.annotation:jakarta.annotation-api` | 3.0.0 | `spring-boot-starter` | 전체 | EPL-2.0 / GPL-2.0 with CPE (확인 필요) |
| `org.yaml:snakeyaml` | 2.5 | `spring-boot-starter` | 전체 | Apache-2.0 (확인 필요) |

### 4.2 web 전용

| 아티팩트 | 버전 | 경유 | 라이선스 |
|---|---|---|---|
| Tomcat (`tomcat-embed-core`, `-el`, `-websocket`, `tomcat-annotations-api`) | 11.0.27 | jasper, `spring-boot-starter-tomcat` | Apache-2.0 |
| `org.eclipse.jdt:ecj` | 3.46.100 | `tomcat-embed-jasper` (JSP 컴파일러) | EPL-2.0 (확인 필요) |
| `jakarta.servlet:jakarta.servlet-api` | 6.1.0 | `jakarta.servlet.jsp.jstl-api` | EPL-2.0 / GPL-2.0 with CPE |
| `jakarta.el:jakarta.el-api` | 5.0.0 | `jakarta.servlet.jsp.jstl-api` | EPL-2.0 / GPL-2.0 with CPE (확인 필요) |
| Jackson 3 (`tools.jackson.core:jackson-databind`, `jackson-core`) | 3.1.8 | `spring-boot-starter-jackson` | Apache-2.0 |
| `com.fasterxml.jackson.core:jackson-annotations` | 2.21 | Jackson 3 (애너테이션은 2.x 좌표 공유) | Apache-2.0 |
| Spring Web (`spring-web`, `spring-webmvc`), Boot web (`-web-server`, `-tomcat`, `-servlet`, `-webmvc`, `-http-converter`, `-jackson`) | 7.0.11 / 4.0.10 | `spring-boot-starter-webmvc` | Apache-2.0 |

### 4.3 db-migration 전용

| 아티팩트 | 버전 | 경유 | 라이선스 |
|---|---|---|---|
| `org.flywaydb:flyway-core` | 11.14.1 | `flyway-database-postgresql` | Apache-2.0 |
| `org.springframework.boot:spring-boot-flyway` | 4.0.10 | `spring-boot-starter-flyway` | Apache-2.0 |
| Jackson 2 (`com.fasterxml.jackson.core:jackson-databind`, `jackson-core`) / `jackson-annotations` | 2.21.8 / 2.21 | `flyway-core` | Apache-2.0 |

### 4.4 test scope (web, 실행 산출물 미포함)

| 아티팩트 | 버전 | 라이선스 |
|---|---|---|
| JUnit Jupiter / Platform | 6.0.3 | EPL-2.0 (확인 필요) |
| Mockito (`mockito-core`, `mockito-junit-jupiter`) / Byte Buddy / Objenesis | 5.20.0 / 1.17.8 / 3.3 | MIT / Apache-2.0 / Apache-2.0 (확인 필요) |
| AssertJ / Hamcrest / Awaitility | 3.27.7 / 3.0 / 4.3.0 | Apache-2.0 / BSD-3-Clause / Apache-2.0 (확인 필요) |
| JsonPath / json-smart / JSONassert / XMLUnit | 2.10.0 / 2.6.1 / 1.5.3 / 2.10.4 | Apache-2.0 / Apache-2.0 / Apache-2.0 / Apache-2.0 (확인 필요) |
| `spring-test`, `spring-boot-test`, `spring-boot-test-autoconfigure` | 7.0.11 / 4.0.10 | Apache-2.0 |
| 기타 (`jakarta.xml.bind-api` 4.0.5, `jakarta.activation-api` 2.1.4, `asm` 9.11.1, `opentest4j` 1.3.0, `apiguardian-api` 1.1.2, `android-json` 0.0.20131108.vaadin1) | - | 확인 필요 |

### 4.5 대조 결과 (2026-11-27)

- 전 모듈 해석 성공(Reactor 6개 SUCCESS). 이 문서에 미리 기록한 BOM 관리 버전과 실제 해석 버전이 모두 일치한다.
- 외부 의존성에 SNAPSHOT·범위·`LATEST`·`RELEASE` 버전이 없다. SNAPSHOT은 내부 모듈뿐이다(D-010).
- 모듈 경계: collector와 persistence에는 웹·Tomcat·JSP·Flyway가 없고, web에는 Flyway가 없다. Flyway는 db-migration에만 있다(D-005, D-006).
- PostgreSQL JDBC는 전 모듈 `runtime`, 테스트 라이브러리는 web `test` scope에만 있다.
- Jackson이 두 계열로 존재한다. web은 Boot 4 기본인 Jackson 3(`tools.jackson`), db-migration은 Flyway가 쓰는 Jackson 2(`com.fasterxml`)다. 서로 다른 실행 단위라 같은 classpath에 섞이지 않는다.
- 외부 Tomcat 배포 시 확인 사항: web WAR에는 내장 Tomcat(`tomcat-embed-*`)과 `jakarta.servlet-api`가 `compile` scope로 들어간다. 내장 Tomcat 실행(`java -jar`)에는 문제가 없다. 외부 Tomcat 배포가 필요해지면 scope 조정(`provided`)을 별도 변경 요청으로 검토한다(CLAUDE.md §3.2).
- 루트 POM의 `<name/>`이 비어 있어 Reactor Summary에 루트 이름이 공란으로 표시된다. 빌드에는 영향이 없다.

## 5. 개발자 확인 결과

| 항목 | 상태 |
|---|---|
| `mvnw -v`, `java -version` | 확인 (2026-11-27 개발자 보고). Java 25, Maven 3.9.16(Wrapper, D-007). 설계 기준(기획안 v0.3 §3)과 일치 |
| `validate` (Enforcer, D-010 적용 후) | 통과 (2026-11-27 개발자 보고, Eclipse m2e) |
| `clean package` (전 모듈) | 통과 (2026-11-27 개발자 보고, Eclipse m2e). 테스트 소스 없음 |
| DB 초기 구성 `Doc/DB/sql/00_bootstrap.sql` | 실행 완료 (2026-11-27 개발자 보고) |
| WAR 기동·JSP 렌더링 (`WEB_DB_*`, `p27_web`) | 성공 (2026-11-27 개발자 보고) |
| `help:effective-pom` | 성공 (2026-11-27 개발자 보고, Eclipse m2e) |
| `dependency:tree` (전 모듈) | 성공 (2026-11-27 개발자 제공 출력). 전 모듈을 4절과 대조, 차이 없음 (4.5절) |
| DB 서버 버전 | 확인 (2026-11-27 개발자 보고). PostgreSQL 18, 설계 기준과 일치 |
| SBOM 생성 | DEV-00 범위 제외 |
| 알려진 취약점 점검 | DEV-00 범위 제외 |
| 빈 DB에서 db-migration 실행 (`p27_migration`, `app.flyway_schema_history`) | 성공 (2026-11-27 개발자 보고). migration 파일 없는 상태의 연결·이력 테이블 확인. DB 서버 PostgreSQL 18. T-32의 순차 적용·재실행·백업/복구는 DEV-01 이후 |

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
| 2026-11-27 | Enforcer `banDynamicVersions` 내부 모듈 제외. 개발자 확인 결과(5절) 반영, 전 모듈 `dependency:tree` 대조로 4절 재작성 | D-010, D-008 |
