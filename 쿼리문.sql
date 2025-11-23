-- 1. 기존에 같은 이름의 테이블이 있으면 삭제하는 용도
DROP TABLE IF EXISTS MY_WISHLIST;

-- 2. 찜하기 목록 테이블 생성
CREATE TABLE MY_WISHLIST (
    NO INT AUTO_INCREMENT PRIMARY KEY,    -- 번호 (자동으로 1씩 증가)
    TITLE VARCHAR(300),                   -- 제목
    LINK VARCHAR(1000),                   -- 링크
    DESCRIPTION VARCHAR(2000),            -- 내용
    SAVED_DATE DATETIME DEFAULT NOW()     -- 저장 날짜 (입력 안 하면 현재시간 자동 입력)
);

-- 3. (참고용) 데이터를 저장할 때 사용하는 쿼리 예시
-- 번호(NO)와 날짜(SAVED_DATE)는 자동으로 들어가니 생략합니다.
-- INSERT INTO MY_WISHLIST (TITLE, LINK, DESCRIPTION) VALUES ('제목입니다', 'http://naver.com...', '내용입니다...');

-- 4. 잘 들어갔는지 확인
-- SELECT * FROM MY_WISHLIST;