# Project202701 DB 환경 및 계정 명세

- 작성일: 2026-11-27
- 관련: DEV-00 WP-00-02, 결정 D-008(`Doc/docs/decisions-claude.md`), 기획안 v0.3 §7·§12.2, T-28, T-32
- 범위: 개발 DB의 데이터베이스·스키마·계정 초기 구성과 각 실행 단위의 접속 방법. 테이블 설계와 테이블별 권한은 DEV-01에서 정한다.
- 상태: DEV-00 범위 DONE (2026-11-27 개발자 확인). PostgreSQL 18. 초기 구성 스크립트 실행, `p27_migration`으로 db-migration 실행, `p27_web`으로 web 기동. 런타임 계정 최소 권한(T-28)은 DEV-01 이후 확인

## 1. 구성 요약

| 항목 | 값 | 근거 |
|---|---|---|
| DB 서버 | `192.168.56.1:5432` (PostgreSQL, 18 목표) | 개발자 제공 (2026-11-27) |
| 데이터베이스 | `project202701` | D-008 |
| 인코딩 | UTF-8 (`TEMPLATE template0`) | 기획안 v0.3 §7 |
| 업무 스키마 | `app` (소유자 `p27_migration`) | D-008 |
| `public` 스키마 | 사용하지 않음 (PUBLIC 권한 회수) | D-008 |
| DB 기본 시간대 | `UTC` | 기획안 v0.3 §7 (저장 UTC, 화면 Asia/Seoul) |
| Flyway 이력 테이블 | `app.flyway_schema_history` | D-008 (`spring.flyway.schemas=app`) |

시각 컬럼은 `timestamptz`로 저장하므로 저장값은 시간대와 무관한 절대 시각이다. DB 기본 시간대 `UTC`는 psql 등에서 시간대를 지정하지 않았을 때의 표시 기준이다. PostgreSQL JDBC 드라이버는 접속 시 JVM 기본 시간대를 세션 시간대로 전달한다.

## 2. 계정 명세

| 계정 | 용도 | 사용 실행 단위 | 환경변수 | 현재 권한 (초기 구성) | DEV-01에서 부여할 권한 (기획안 v0.3 §7) |
|---|---|---|---|---|---|
| `p27_migration` | DDL 전용 | db-migration | `MIGRATION_DB_*` | DB 소유자, `app` 스키마 소유자 | 변경 없음. web·collector에서 사용 금지 |
| `p27_web` | 웹 런타임 | web | `WEB_DB_*` | `CONNECT`, `app` `USAGE` | 업무 CRUD, 보정, 작업 요청, 허용된 상태 조회. 관측 원본과 작업 완료 상태의 UPDATE/DELETE 금지 (T-28) |
| `p27_collector` | 수집기 런타임 | collector | `COLLECTOR_DB_*` | `CONNECT`, `app` `USAGE` | 제한된 자산·규칙 참조 조회, 작업 claim, 결과·관측 저장, projection 갱신 |

- 세 계정 모두 `NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`다.
- 세 계정 모두 `project202701`에서 `search_path = app`이다.
- 런타임 계정은 `app` 스키마에 객체를 만들 수 없다(`CREATE` 권한 없음).
- 원격 자격증명과 SSH 개인키는 DB에 저장하지 않는다 (CLAUDE.md §4-3).

## 3. 환경변수

접속 정보와 비밀번호는 Git에 커밋하지 않는다. 모든 실행 단위는 기본값이 없으므로 환경변수가 없으면 기동에 실패한다.

| 실행 단위 | URL | 사용자 | 비밀번호 |
|---|---|---|---|
| db-migration | `MIGRATION_DB_URL` | `MIGRATION_DB_USERNAME` | `MIGRATION_DB_PASSWORD` |
| web | `WEB_DB_URL` | `WEB_DB_USERNAME` | `WEB_DB_PASSWORD` |
| collector | `COLLECTOR_DB_URL` | `COLLECTOR_DB_USERNAME` | `COLLECTOR_DB_PASSWORD` |

URL은 세 실행 단위 모두 `jdbc:postgresql://192.168.56.1:5432/project202701`이다.

## 4. 초기 구성 절차 (개발자 수행, 1회)

### 4.1 사전 확인

1. PostgreSQL 서버에 관리자 계정(예: `postgres`)으로 접속할 수 있어야 한다.
2. 이 PC에 `psql`이 있어야 한다. PostgreSQL 설치 경로의 `bin` 폴더(예: `C:\Program Files\PostgreSQL\18\bin`)에 있다.
3. 스크립트는 `\password`, `\c` 같은 psql 명령을 쓰므로 pgAdmin Query Tool에서는 실행할 수 없다.

### 4.2 스크립트 실행

저장소 루트에서 PowerShell로 실행한다.

```powershell
psql -h 192.168.56.1 -p 5432 -U postgres -d postgres -f Doc/DB/sql/00_bootstrap.sql
```

- 처음에 `postgres` 비밀번호를 묻고, 이어서 세 계정의 비밀번호를 각각 두 번씩 묻는다.
- 비밀번호는 화면과 명령 이력에 남지 않는다. 입력한 비밀번호는 개인 보안 저장소에 따로 보관한다.
- 오류가 나면 그 자리에서 중단된다(`ON_ERROR_STOP`). 이미 일부 객체가 만들어졌으면 6절의 정리 절차를 수행한 뒤 다시 실행한다.

### 4.3 구성 확인 (조회만 수행)

```powershell
psql -h 192.168.56.1 -p 5432 -U postgres -d project202701
```

```sql
-- 계정 속성
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles WHERE rolname IN ('p27_migration', 'p27_web', 'p27_collector');

-- DB 소유자, 인코딩, 접근 권한
\l project202701

-- 스키마 소유자와 권한
\dn+

-- 계정별 search_path, DB 기본 시간대
SELECT COALESCE(r.rolname, '(DB 전체)') AS role_name, s.setconfig
FROM pg_db_role_setting s
LEFT JOIN pg_roles r ON r.oid = s.setrole
WHERE s.setdatabase = (SELECT oid FROM pg_database WHERE datname = 'project202701');
```

기대 결과:
- 세 계정 모두 `rolsuper`, `rolcreatedb`, `rolcreaterole`이 `f`이고 `rolcanlogin`이 `t`다.
- `project202701`의 소유자는 `p27_migration`이고 인코딩은 `UTF8`이다.
- `app` 스키마의 소유자는 `p27_migration`이고, `p27_web`과 `p27_collector`에 `U`(USAGE) 권한이 있다.
- 세 계정의 `search_path=app`과 DB 전체 `TimeZone=UTC`가 보인다.

## 5. 실행 단위별 접속

### 5.1 db-migration (DEV-00 smoke test, T-32 일부)

```powershell
$env:MIGRATION_DB_URL = 'jdbc:postgresql://192.168.56.1:5432/project202701'
$env:MIGRATION_DB_USERNAME = 'p27_migration'
$env:MIGRATION_DB_PASSWORD = Read-Host 'p27_migration 비밀번호'
java -jar db-migration\target\project202701-db-migration-0.0.1-SNAPSHOT.jar
```

- `Read-Host`로 입력하면 비밀번호가 PowerShell 명령 이력에 남지 않는다. `$env:` 변수는 해당 PowerShell 창에서만 유효하다.
- 현재 migration 파일이 없으므로 기대 결과는 `app.flyway_schema_history` 생성 후 정상 종료다. "No migrations found" 류의 안내는 정상이다.
- `app` 스키마가 없으면 실패한다(`spring.flyway.create-schemas=false`). 4절을 먼저 수행한다.
- 확인: `SELECT installed_rank, version, description, success FROM app.flyway_schema_history;`

### 5.2 web

```powershell
$env:WEB_DB_URL = 'jdbc:postgresql://192.168.56.1:5432/project202701'
$env:WEB_DB_USERNAME = 'p27_web'
$env:WEB_DB_PASSWORD = Read-Host 'p27_web 비밀번호'
java -jar web\target\project202701-web-0.0.1-SNAPSHOT.war
```

브라우저에서 `http://localhost:8808/`을 연다.

### 5.3 collector

```powershell
$env:COLLECTOR_DB_URL = 'jdbc:postgresql://192.168.56.1:5432/project202701'
$env:COLLECTOR_DB_USERNAME = 'p27_collector'
$env:COLLECTOR_DB_PASSWORD = Read-Host 'p27_collector 비밀번호'
java -jar collector\target\project202701-collector-0.0.1-SNAPSHOT.jar
```

DEV-03 이전에는 실행 골격만 있다.

### 5.4 Eclipse에서 실행할 때

Run > Run Configurations > 해당 Java Application(`WebApplication`, `MigrationApplication`, `CollectorApplication`) > Environment 탭에서 3절의 환경변수를 추가한다.

- Run Configuration은 워크스페이스 메타데이터(`.metadata`)에 저장되며 기본적으로 Git에 포함되지 않는다.
- Run Configuration을 "Shared file"로 저장하지 않는다. 저장소에 비밀번호가 들어간다.

## 6. 정리 절차 (개발자 수행, 승인 후)

초기 구성을 다시 하거나 개발 DB를 폐기할 때만 사용한다. 데이터가 모두 삭제되며 되돌릴 수 없다. 운영 DB에서는 실행하지 않는다(CLAUDE.md §8.2).

```sql
-- postgres DB에 관리자로 접속하여 실행
DROP DATABASE IF EXISTS project202701;
DROP ROLE IF EXISTS p27_web;
DROP ROLE IF EXISTS p27_collector;
DROP ROLE IF EXISTS p27_migration;
```

다른 DB에 같은 계정이 소유하거나 권한을 받은 객체가 있으면 `DROP ROLE`이 실패한다. 이 경우 해당 객체를 먼저 확인한다.

## 7. 문제 해결

| 증상 | 확인할 것 |
|---|---|
| `Connection refused`, 시간 초과 | 서버 `postgresql.conf`의 `listen_addresses`가 `192.168.56.1`(또는 `*`)을 포함하는지, 방화벽에서 5432가 열려 있는지 |
| `no pg_hba.conf entry for host ...` | 서버 `pg_hba.conf`에 접속하는 PC 주소 대역(예: `192.168.56.0/24`)과 `scram-sha-256` 인증 항목이 있는지. 수정 후 서버 설정 재적재 필요 |
| `password authentication failed` | 계정 이름과 `\password`로 입력한 비밀번호, 환경변수 값 |
| `permission denied for database project202701` | 런타임 계정의 `CONNECT` 권한 (4.3절 `\l` 결과) |
| `schema "app" does not exist` (db-migration) | 4절 초기 구성 수행 여부. Flyway는 스키마를 자동 생성하지 않도록 설정되어 있다 |
| `permission denied for schema app` (web, collector) | 현재 정상일 수 있다. 테이블 권한은 DEV-01에서 부여한다 |
| psql 한글 메시지가 깨짐 | 스크립트는 `\encoding UTF8`로 실행된다. 콘솔 출력만 깨지는 경우 `chcp 65001` 후 실행 |

## 8. 보안 주의

- 비밀번호와 접속 정보를 `application.properties`, 스크립트, 문서, Git, 로그에 넣지 않는다.
- 구 테스트 DB(`192.168.56.101`, `testuser`)의 기본 비밀번호가 과거 커밋에 남아 있다. 해당 계정이 다른 곳에서 쓰이면 비밀번호를 바꾸거나 폐기한다.
- 런타임 계정에 DDL 권한, `SUPERUSER`, `BYPASSRLS`를 주지 않는다.
- 웹 계정으로 관측 원본을 변경할 수 없는지는 DEV-01 이후 T-28로 개발자가 확인한다.

## 9. 파일

| 파일 | 내용 |
|---|---|
| `Doc/DB/Project202701_DB_환경_및_계정_명세.md` | 이 문서 |
| `Doc/DB/sql/00_bootstrap.sql` | 데이터베이스·계정·스키마 초기 구성 (psql 전용) |
| `db-migration/src/main/resources/db/migration/` | DEV-01부터 추가할 Flyway migration 위치 (`V1__...sql`) |

## 10. 변경 이력

| 날짜 | 내용 |
|---|---|
| 2026-11-27 | 최초 작성 (D-008) |
