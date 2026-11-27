package com.security.web.controller;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * DEV-00 WAR/JSP/JSTL 렌더링 확인용 첫 화면.
 * DEV-02에서 인증 적용 후 로그인(UI-00)/대시보드(UI-01) 흐름으로 대체한다.
 * 조회 전용이며 DB·내부 설정 등 민감 정보를 화면에 내보내지 않는다.
 */
@Controller
public class HomeController {

	/** 화면 표시 기준 시간대 (저장은 UTC, 화면은 Asia/Seoul: 기획안 v0.3 §7) */
	private static final ZoneId DISPLAY_ZONE = ZoneId.of("Asia/Seoul");
	private static final DateTimeFormatter DISPLAY_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	private final String applicationName;

	public HomeController(@Value("${spring.application.name}") String applicationName) {
		this.applicationName = applicationName;
	}

	@GetMapping("/")
	public String home(Model model) {
		model.addAttribute("applicationName", applicationName);
		model.addAttribute("renderedAt", ZonedDateTime.now(DISPLAY_ZONE).format(DISPLAY_FORMAT));
		return "index";
	}

}
