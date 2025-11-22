package com.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import com.dto.KinDTO;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class NaverService {

    // ★★★ 여기에 발급받은 키를 붙여넣으세요 ★★★
    private static final String CLIENT_ID = "B5Wb2Wthwb1Indh1vL8e"; 
    private static final String CLIENT_SECRET = "2Z2ehdjBXD";

    public List<KinDTO> searchKin(String keyword, String sort) {
        List<KinDTO> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;

        try {
            String text = URLEncoder.encode(keyword, "UTF-8");
            // API 요청 URL (100건 요청, 정렬 옵션 포함)
            String apiURL = "https://openapi.naver.com/v1/search/kin.json?query=" + text + "&display=100&sort=" + sort;
            
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", CLIENT_ID);
            con.setRequestProperty("X-Naver-Client-Secret", CLIENT_SECRET);

            int responseCode = con.getResponseCode();
            BufferedReader br;
            if(responseCode == 200) { // 정상 호출
                br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
            } else {  // 에러 발생
                br = new BufferedReader(new InputStreamReader(con.getErrorStream(), "UTF-8"));
            }

            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = br.readLine()) != null) {
                response.append(inputLine);
            }
            br.close();

            // Gson 라이브러리를 사용하여 JSON 파싱
            JsonObject jsonObj = JsonParser.parseString(response.toString()).getAsJsonObject();
            JsonArray items = jsonObj.getAsJsonArray("items");

            for (JsonElement item : items) {
                JsonObject obj = item.getAsJsonObject();
                
                // HTML 태그 제거 및 데이터 추출
                String title = obj.get("title").getAsString().replaceAll("<[^>]*>", "");
                String link = obj.get("link").getAsString();
                String desc = obj.get("description").getAsString().replaceAll("<[^>]*>", "");
                
                String postDate = ""; 
                if(obj.has("postdate")) postDate = obj.get("postdate").getAsString();

                // 날짜 포맷 변경 (YYYYMMDD -> YYYY.MM.DD)
                if(postDate.length() == 8) {
                    postDate = postDate.substring(0, 4) + "." + postDate.substring(4, 6) + "." + postDate.substring(6, 8);
                }

                list.add(new KinDTO(title, link, desc, postDate));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}