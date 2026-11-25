package com.security.controller;



import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
* DB 접속 테스트
* 앱 실행 후 브라우저에서 http://localhost:8080/samples 접속
*/
@RestController
public class testController {

 private final JdbcTemplate jdbcTemplate;

 public testController(JdbcTemplate jdbcTemplate) {
     this.jdbcTemplate = jdbcTemplate;
 }

 @GetMapping("/samples")
 public List<Map<String, Object>> samples() {
	 System.out.println("Git test");
     return jdbcTemplate.queryForList("SELECT id, name, created_dt FROM app.sample ORDER BY id");
 }
}

