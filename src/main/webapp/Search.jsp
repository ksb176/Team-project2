<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*, java.io.*, java.util.*" %>
<%@ page import="com.google.gson.*" %>

<%!
    // [1] 데이터 그릇
    public static class KinItem {
        String title, link, desc;
        public KinItem(String t, String l, String d) {
            this.title = t; this.link = l; this.desc = d;
        }
    }

    // [2] API 호출 함수
    public List<KinItem> getNaverData(String keyword, String sort) {
        String clientId = "B5Wb2Wthwb1Indh1vL8e"; // ★ 본인 키 확인
        String clientSecret = "2Z2ehdjBXD";
        
        List<KinItem> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;

        try {
            // 100개 가져오기
            String apiURL = "https://openapi.naver.com/v1/search/kin.json?query=" 
                          + URLEncoder.encode(keyword, "UTF-8") 
                          + "&display=100&sort=" + sort;
            
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", clientId);
            con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

            BufferedReader br = new BufferedReader(new InputStreamReader(
                (con.getResponseCode() == 200) ? con.getInputStream() : con.getErrorStream(), "UTF-8"));
            
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            JsonObject jsonObj = JsonParser.parseString(sb.toString()).getAsJsonObject();
            if (jsonObj.has("items")) {
                JsonArray items = jsonObj.getAsJsonArray("items");
                for (JsonElement item : items) {
                    JsonObject obj = item.getAsJsonObject();
                    String t = obj.get("title").getAsString().replaceAll("<[^>]*>", "");
                    String l = obj.get("link").getAsString();
                    String d = obj.get("description").getAsString().replaceAll("<[^>]*>", "");
                    list.add(new KinItem(t, l, d));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
%>

<%
    // [3] 페이지 설정
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");
    String sort = request.getParameter("sort");
    String pageStr = request.getParameter("page");

    if(sort == null || sort.equals("")) sort = "sim";
    int currentPage = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
    
    // ★ 12개씩 보기 ★
    int itemsPerPage = 12; 

    List<KinItem> list = new ArrayList<>();
    if(keyword != null && !keyword.trim().isEmpty()){
        list = getNaverData(keyword, sort);
    }

    int totalCount = list.size();
    int totalPages = (int) Math.ceil((double)totalCount / itemsPerPage);
    int startIdx = (currentPage - 1) * itemsPerPage;
    int endIdx = Math.min(startIdx + itemsPerPage, totalCount);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지식인 검색</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>

    <h1>네이버 지식iN 검색</h1>

    <div class="search-area">
        <form action="Search.jsp" method="get">
            검색어: <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>">
            <button type="submit">검색</button>
            <br><br>
            <input type="radio" name="sort" value="sim" <%= sort.equals("sim")?"checked":"" %>> 정확도
            <input type="radio" name="sort" value="date" <%= sort.equals("date")?"checked":"" %>> 최신순
            <input type="radio" name="sort" value="point" <%= sort.equals("point")?"checked":"" %>> 평점순
        </form>
    </div>

    <hr>

    <div class="card-container">
        <% if(list.isEmpty()) { %>
            <h3><%= (keyword==null)?"검색어를 입력하세요":"결과가 없습니다" %></h3>
        <% } else { 
            for(int i = startIdx; i < endIdx; i++) {
                KinItem item = list.get(i);
        %>
            <div class="my-card">
                <button type="button" class="btn-jjim" onclick="doSave('<%= i+1 %>')">저장</button>
                
                <div class="card-header">[지식iN]</div>
                
                <div class="card-title">
                    <a href="<%= item.link %>" target="_blank"><%= item.title %></a>
                </div>
                <div class="card-desc">
                    <%= item.desc %>
                </div>
            </div>
        <% 
            } 
        } 
        %>
    </div>

    <div class="page-area">
        <% if(totalCount > 0) { 
            for(int p = 1; p <= Math.min(totalPages, 10); p++) { 
                String styleClass = (p == currentPage) ? "page-link current-page" : "page-link";
        %>
            <a href="Search.jsp?keyword=<%=keyword%>&sort=<%=sort%>&page=<%=p%>" class="<%=styleClass%>">
                <%= p %>
            </a>
        <% } } %>
    </div>

    <script>
        function doSave(idx) {
            alert(idx + "번 게시물 저장");
        }
    </script>

</body>
</html>