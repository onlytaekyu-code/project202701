<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Project202701</title>
</head>
<body>
	<header>
		<h1>Project202701</h1>
		<p>개발환경</p>
	</header>
	<main>
		<p>웹 애플리케이션이 기동되었습니다. 이 화면은 JSP/JSTL 렌더링 확인용입니다.</p>
		<dl>
			<dt>애플리케이션</dt>
			<dd><c:out value="${applicationName}"/></dd>
			<dt>렌더링 시각 (Asia/Seoul)</dt>
			<dd><c:out value="${renderedAt}"/></dd>
		</dl>
	</main>
</body>
</html>
