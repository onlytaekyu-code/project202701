package com.security.web;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 웹 WAR 진입점. 관리·조회·작업 등록만 담당하며 원격 대상 및 수집기와 직접 통신하지 않는다.
 * DB 스키마 변경은 db-migration 모듈이 전담하므로 이 모듈에는 Flyway 의존성을 두지 않는다.
 */
@SpringBootApplication
public class WebApplication {

	public static void main(String[] args) {
		SpringApplication.run(WebApplication.class, args);
	}

}
