package com.security.collector;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 수집기 독립 실행 진입점.
 * 웹과 직접 통신하지 않고 DB 작업 테이블로만 연계한다. 원격 자격증명은 수집기 로컬에만 둔다.
 * 작업 claim/lease/heartbeat 및 어댑터는 DEV-03 이후 구현하며, 현재는 실행 골격만 제공한다.
 */
@SpringBootApplication
public class CollectorApplication {

	public static void main(String[] args) {
		SpringApplication.run(CollectorApplication.class, args);
	}

}
