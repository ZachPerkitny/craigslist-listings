CREATE TABLE sent_listings (
    id int AUTO_INCREMENT PRIMARY KEY,
    keyword_id int NOT NULL,
    craigslist_url VARCHAR(1000) NOT NULL,
    INDEX keyword_cl_ind(keyword_id, craigslist_url),
    FOREIGN KEY (keyword_id)
        REFERENCES keyword(id)
        ON DELETE CASCADE
);
