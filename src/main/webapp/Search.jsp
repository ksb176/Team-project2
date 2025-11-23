<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*, java.io.*, java.util.*" %>
<%@ page import="com.google.gson.*" %>

<%!
    // [1] 데이터를 담을 단순한 클래스
    public static class KinItem {
        String title, link, desc;
        public KinItem(String t, String l, String d) {
            this.title = t; this.link = l; this.desc = d;
        }
    }

    // [2] 네이버 API 호출 함수
    public List<KinItem> getNaverData(String keyword, String sort) {
        // ★ API 키 입력 ★
        String clientId = "B5Wb2Wthwb1Indh1vL8e"; 
        String clientSecret = "2Z2ehdjBXD";       
        
        List<KinItem> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;

        try {
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
    // [3] 요청 처리 (페이지 로직)
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");
    String sort = request.getParameter("sort");
    String pageStr = request.getParameter("page");

    if(sort == null || sort.equals("")) sort = "sim";
    int currentPage = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
    int itemsPerPage = 12; // 12개씩 카드 보여주기

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
    <style>
        body {
            text-align: center; /* 모든 걸 가운데 정렬 */
            background-color: #f9f9f9;
        }

        h1 { color: green; }

        /* 검색창 */
        .search-area {
            background-color: #ddd;
            padding: 15px;
            border: 1px solid black;
            width: 80%;
            margin: 0 auto; /* 가운데 정렬 */
        }

        /* 카드들이 들어갈 공간 */
        .card-container {
            width: 90%;
            margin: 20px auto;
        }

        .my-card {
            /* 옆으로 나열하기 위해 inline-block 사용 */
            display: inline-block;
            width: 250px;
            height: 200px;
            
            /* 직각 테두리 */
            border: 2px solid black;
            background-color: white;
            
            margin: 10px;
            padding: 10px;
            vertical-align: top; /* 카드 높이 맞추기 */
            text-align: left; /* 글자는 왼쪽 정렬 */
            
            /* 내용 넘치면 숨김 */
            overflow: hidden;
        }

        .card-header {
            font-weight: bold;
            color: green;
            margin-bottom: 5px;
        }

        .card-title a {
            color: blue;
            text-decoration: underline; /* 링크 밑줄  */
            font-weight: bold;
            font-size: 16px;
        }

        .card-desc {
            font-size: 12px;
            color: #555;
            margin-top: 10px;
        }

        /* 버튼 */
        .btn-jjim {
            float: right; /* 오른쪽으로 붙이기 */
            border: 1px solid black;
            background-color: #eee;
            cursor: pointer;
        }

        /* 페이지 번호 */
        .page-link {
            text-decoration: none;
            color: black;
            border: 1px solid black;
            padding: 5px;
            margin: 3px;
            background-color: white;
        }
        .current-page {
            background-color: green;
            color: white;
            font-weight: bold;
        }
    </style>
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
            <h3>검색 결과가 없습니다.</h3>
        <% } else { 
            // 자바 for문으로 카드 반복 출력
            for(int i = startIdx; i < endIdx; i++) {
                KinItem item = list.get(i);
        %>
            <div class="my-card">
                <div class="card-header">
                    [지식iN]
                    <button type="button" class="btn-jjim" onclick="alert('<%= i+1 %>번 글 저장')">저장</button>
                </div>
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

    <div style="margin: 30px;">
        <% if(totalCount > 0) { %>
            <% for(int p = 1; p <= Math.min(totalPages, 5); p++) { 
                String styleClass = (p == currentPage) ? "page-link current-page" : "page-link";
            %>
                <a href="Search.jsp?keyword=<%=keyword%>&sort=<%=sort%>&page=<%=p%>" class="<%=styleClass%>">
                    <%= p %>
                </a>
            <% } %>
        <% } %>
    </div>

</body>
</html>