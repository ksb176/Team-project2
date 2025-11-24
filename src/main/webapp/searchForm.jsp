<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.net.*, com.google.gson.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>네이버 지식iN 검색 과제</title>
<link rel="stylesheet" href="style.css">
</head>
<body>

<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("_keyword");
    String pageNum = request.getParameter("_pageNum");
    String sort = request.getParameter("_sort"); 

    if(sort == null || sort.equals("")) sort = "sim"; 

    int currentPage = 1;
    if(pageNum != null && !pageNum.equals("")) {
        try { currentPage = Integer.parseInt(pageNum); } catch(Exception e) { currentPage = 1; }
    }
%>

    <h1>네이버 지식iN 검색</h1>

    <div class="search-box">
        <form action="searchForm.jsp" method="get">
            <div>
                <input type="text" name="_keyword" class="input-text" 
                       placeholder="검색어를 입력하세요"
                       value="<%=(keyword != null) ? keyword : "" %>">
                <input type="submit" value="검색" class="btn-search">
            </div>
            <div class="sort-radio-area">
                <input type="radio" name="_sort" value="sim" id="r1" <% if(sort.equals("sim")) out.print("checked"); %>> <label for="r1">정확도순</label>
                <input type="radio" name="_sort" value="date" id="r2" <% if(sort.equals("date")) out.print("checked"); %>> <label for="r2">날짜순</label>
                <input type="radio" name="_sort" value="point" id="r3" <% if(sort.equals("point")) out.print("checked"); %>> <label for="r3">평점순</label>
            </div>
        </form>
    </div>

<%
    if (keyword != null && !keyword.equals("")) {
        String myId = ""; // ★ 본인 ID
        String mySecret = ""; // ★ 본인 비번
        
        String apiURL = "https://openapi.naver.com/v1/search/kin.json?display=100&sort=" + sort + "&query=" + URLEncoder.encode(keyword, "UTF-8");
        
        URL url = new URL(apiURL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("X-Naver-Client-Id", myId);
        conn.setRequestProperty("X-Naver-Client-Secret", mySecret);
        
        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while((line = br.readLine()) != null) sb.append(line);
        br.close();
        
        String jsonData = sb.toString();
        JsonParser parser = new JsonParser();
        JsonObject obj = parser.parse(jsonData).getAsJsonObject();
        JsonArray items = obj.getAsJsonArray("items");
        
        List<JsonObject> list = new ArrayList<>();
        for(JsonElement j : items) list.add(j.getAsJsonObject());
        
        int totalCount = list.size();
        int pageSize = 10;
        int totalPage = (int) Math.ceil((double)totalCount / pageSize);
        int startIdx = (currentPage - 1) * pageSize;
        int endIdx = Math.min(startIdx + pageSize, totalCount);
%>
        <div class="save-area">
            <form action="saveToDB.jsp" method="post">
                <input type="hidden" name="_jsonData" value="<%= URLEncoder.encode(jsonData, "UTF-8") %>">
                <input type="submit" value="검색결과 DB 저장" class="btn-db">
            </form>
        </div>

        <table class="result-table">
            <thead>
                <tr>
                    <th width="50">번호</th>
                    <th width="20%">제목</th>
                    <th width="20%">URL</th> <th>내용요약</th>
                </tr>
            </thead>
            <tbody>
            <% 
                for(int i = startIdx; i < endIdx; i++) {
                    JsonObject item = list.get(i);
                    String title = item.get("title").getAsString();
                    String link = item.get("link").getAsString();
                    String desc = item.get("description").getAsString();
                    
                    // URL 자르기
                    String shortLink = link;
                    if(shortLink.length() > 30) {
                        shortLink = shortLink.substring(0, 30) + "...";
                    }
            %>
                <tr>
                    <td style="text-align:center;"><%= i + 1 %></td>
                    
                    <td style="font-weight:bold;">
                        <%= title %>
                    </td>
                    
                    <td>
                        <a href="<%= link %>" target="_blank" class="link-url">
                            <%= shortLink %>
                        </a>
                    </td>
                    
                    <td><%= desc %></td>
                </tr>
            <% 
                } 
            %>
            </tbody>
        </table>
        
        <div class="paging-area">
            <% 
                for(int i = 1; i <= totalPage; i++) {
                    if(i == currentPage) {
            %>
                        <span class="page-num current"><%= i %></span>
            <% 
                    } else {
            %>
                        <a href="searchForm.jsp?_keyword=<%=URLEncoder.encode(keyword,"UTF-8")%>&_pageNum=<%=i%>&_sort=<%=sort%>" class="page-num"><%= i %></a>
            <% 
                    }
                } 
            %>
        </div>
<%
    } 
%>

</body>
</html>