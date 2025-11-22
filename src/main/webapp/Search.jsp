<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.dto.KinDTO" %>
<%@ page import="com.service.NaverService" %>

<%
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");
    String sort = request.getParameter("sort");

    if(sort == null || sort.equals("")) sort = "sim"; 

    List<KinDTO> list = new ArrayList<>();
    
    if(keyword != null && !keyword.trim().isEmpty()){
        try {
            NaverService service = new NaverService();
            list = service.searchKin(keyword, sort);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>지식iN 검색 서비스</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>

<div class="container">
    <div class="header-area">
        <h2 style="color: #03C75A; margin-bottom: 15px;">지식iN 질문 검색</h2>
        
        <form action="Search.jsp" method="get" class="search-form">
            <div class="search-box">
                <input type="text" name="keyword" placeholder="궁금한 내용을 입력하세요" value="<%= keyword != null ? keyword : "" %>">
                <button type="submit">검색</button>
            </div>

            <div class="filter-bar">
                <input type="radio" id="sort_sim" name="sort" value="sim" 
                       onchange="this.form.submit()" <%= sort.equals("sim") ? "checked" : "" %>>
                <label for="sort_sim" class="sort-label">⚡ 정확도순</label>

                <input type="radio" id="sort_date" name="sort" value="date" 
                       onchange="this.form.submit()" <%= sort.equals("date") ? "checked" : "" %>>
                <label for="sort_date" class="sort-label">⏰ 최신순</label>

                <input type="radio" id="sort_point" name="sort" value="point" 
                       onchange="this.form.submit()" <%= sort.equals("point") ? "checked" : "" %>>
                <label for="sort_point" class="sort-label">🏆 평점순</label>
            </div>
        </form>
    </div>

    <div class="card-grid" id="resultGrid"></div>
    <div class="pagination" id="pagination"></div>
</div>

<script>
    const serverData = [
        <% for(int i=0; i<list.size(); i++) { 
            KinDTO dto = list.get(i); 
            String safeTitle = dto.getTitle().replace("\"", "\\\"").replace("'", "\\'").replace("\n", " ");
            String safeDesc = dto.getDescription().replace("\"", "\\\"").replace("'", "\\'").replace("\n", " ");
        %>
        {
            id: <%= i %>,
            title: "<%= safeTitle %>",
            desc: "<%= safeDesc %>",
            link: "<%= dto.getLink() %>",
            saved: false
        }<%= i < list.size()-1 ? "," : "" %>
        <% } %>
    ];

    let currentPage = 1;
    const itemsPerPage = 12; 

    function render() {
        const grid = document.getElementById("resultGrid");
        const pagination = document.getElementById("pagination");
        
        grid.innerHTML = "";
        pagination.innerHTML = "";

        if(serverData.length === 0) {
            <% if(keyword != null && !keyword.isEmpty()) { %>
                grid.innerHTML = "<div style='text-align:center; width:100%; grid-column: 1 / -1; padding:50px; color:#666;'>검색 결과가 없습니다.</div>";
            <% } else { %>
                grid.innerHTML = "<div style='text-align:center; width:100%; grid-column: 1 / -1; padding:50px; color:#666;'>검색어를 입력해주세요.</div>";
            <% } %>
            return;
        }

        const start = (currentPage - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        const pageData = serverData.slice(start, end);

        pageData.forEach(item => {
            const heartClass = item.saved ? "btn-save active" : "btn-save";
            
            const cardHTML = `
                <div class="card" onclick="window.open('\${item.link}')">
                    <div class="\${heartClass}" onclick="toggleSave(event, \${item.id})" title="저장하기">♥</div>
                    
                    <div class="card-top">
                        <span class="tag">지식iN</span>
                    </div>
                    
                    <div class="card-title">\${item.title}</div>
                    <div class="card-desc">\${item.desc}</div>
                </div>
            `;
            grid.innerHTML += cardHTML;
        });

        const totalPages = Math.ceil(serverData.length / itemsPerPage);
        createPageBtn("<", currentPage > 1, () => changePage(currentPage - 1));
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        for (let i = startPage; i <= endPage; i++) {
            createPageBtn(i, true, () => changePage(i), i === currentPage);
        }
        createPageBtn(">", currentPage < totalPages, () => changePage(currentPage + 1));
    }

    function createPageBtn(text, enabled, onClick, isActive = false) {
        const pagination = document.getElementById("pagination");
        const btn = document.createElement("button");
        btn.className = `page-btn \${isActive ? 'active' : ''}`;
        btn.innerHTML = text;
        btn.disabled = !enabled;
        btn.onclick = onClick;
        pagination.appendChild(btn);
    }

    function changePage(page) {
        currentPage = page;
        render();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function toggleSave(event, id) {
        event.stopPropagation(); 
        const targetItem = serverData.find(item => item.id === id);
        if(targetItem) {
            targetItem.saved = !targetItem.saved;
            event.currentTarget.classList.toggle("active");
            if(targetItem.saved) {
                alert("✅ DB 저장 요청: " + targetItem.title);
            } else {
                alert("❎ 저장 취소");
            }
        }
    }

    render();
</script>

</body>
</html>