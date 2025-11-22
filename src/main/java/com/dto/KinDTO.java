package com.dto;

public class KinDTO {
    private String title;
    private String link;
    private String description;
    private String postDate;

    public KinDTO(String title, String link, String description, String postDate) {
        this.title = title;
        this.link = link;
        this.description = description;
        this.postDate = postDate;
    }

    public String getTitle() { return title; }
    public String getLink() { return link; }
    public String getDescription() { return description; }
    public String getPostDate() { return postDate; }
}