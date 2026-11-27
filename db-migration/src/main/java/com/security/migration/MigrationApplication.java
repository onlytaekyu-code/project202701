package com.security.migration;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * DB migration 전용 실행 단위.
 * 기동 시 Spring Boot Flyway 자동 구성이 classpath:db/migration 을 적용하고,
 * 웹 서버가 없으므로 적용이 끝나면 프로세스가 종료된다.
 * 적용 실패 시 예외로 기동이 중단되어 0이 아닌 종료 코드를 반환한다.
 */
@SpringBootApplication
public class MigrationApplication {

	public static void main(String[] args) {
		SpringApplication.run(MigrationApplication.class, args);
	}

}
