-- Project202701 개발 DB 초기 구성 (D-008)
--
-- 실행 주체: 개발자 (PostgreSQL 관리자 계정, 예: postgres). AI 도구는 실행하지 않는다.
-- 실행 횟수: 빈 PostgreSQL 서버에서 1회. 이미 객체가 있으면 첫 오류에서 중단된다.
-- 실행 방법: psql 전용 스크립트다(\password, \c 사용). pgAdmin Query Tool로는 실행하지 않는다.
--   psql -h <host> -p 5432 -U postgres -d postgres -f Doc/DB/sql/00_bootstrap.sql
-- 비밀번호: 이 파일에 쓰지 않는다. 실행 중 \password 프롬프트에서 직접 입력한다.
-- 테이블·컬럼·함수 권한은 이 스크립트 범위가 아니다. DEV-01 Flyway migration에서 부여한다.
-- 명세: Doc/DB/Project202701_DB_환경_및_계정_명세.md

\encoding UTF8
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------
-- 1. 계정 (관리자 DB에서 실행)
--    migration(DDL)과 런타임(web, collector) 계정을 분리한다 (기획안 v0.3 §7·§12.2)
-- ---------------------------------------------------------------
CREATE ROLE p27_migration LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE p27_web       LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE p27_collector LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;

\echo '[p27_migration] 비밀번호를 입력하세요'
\password p27_migration
\echo '[p27_web] 비밀번호를 입력하세요'
\password p27_web
\echo '[p27_collector] 비밀번호를 입력하세요'
\password p27_collector

-- ---------------------------------------------------------------
-- 2. 데이터베이스
--    소유자는 migration 계정. 시각 컬럼은 timestamptz로 저장한다(기획안 v0.3 §7).
-- ---------------------------------------------------------------
CREATE DATABASE project202701
    OWNER p27_migration
    ENCODING 'UTF8'
    TEMPLATE template0;

-- psql 등 클라이언트가 시간대를 지정하지 않을 때의 기본값. JDBC는 JVM 시간대를 세션에 전달한다.
ALTER DATABASE project202701 SET timezone TO 'UTC';

-- 기본 PUBLIC 권한(CONNECT, TEMPORARY)을 회수하고 런타임 계정에만 접속을 허용한다.
REVOKE ALL ON DATABASE project202701 FROM PUBLIC;
GRANT CONNECT ON DATABASE project202701 TO p27_web, p27_collector;

-- ---------------------------------------------------------------
-- 3. 스키마 (새 DB에서 실행)
-- ---------------------------------------------------------------
\c project202701

-- public 스키마는 사용하지 않는다.
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- 업무 스키마. 객체 생성은 소유자(p27_migration)만 할 수 있다.
CREATE SCHEMA app AUTHORIZATION p27_migration;
GRANT USAGE ON SCHEMA app TO p27_web, p27_collector;

ALTER ROLE p27_migration IN DATABASE project202701 SET search_path = app;
ALTER ROLE p27_web       IN DATABASE project202701 SET search_path = app;
ALTER ROLE p27_collector IN DATABASE project202701 SET search_path = app;

\echo '초기 구성 완료: project202701 / app / p27_migration, p27_web, p27_collector'
