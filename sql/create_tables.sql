DROP TABLE IF EXISTS sent_listings;
DROP TABLE IF EXISTS keywords;

CREATE TABLE keywords (
    id int AUTO_INCREMENT PRIMARY KEY,
    email varchar(100) NOT NULL,
    category varchar(50) NOT NULL,
    keyword varchar(100) NOT NULL
);

CREATE TABLE sent_listings (
    id int AUTO_INCREMENT PRIMARY KEY,
    keyword_id int NOT NULL,
    craigslist_url VARCHAR(1000) NOT NULL,
    INDEX keyword_cl_ind(keyword_id, craigslist_url),
    FOREIGN KEY (keyword_id)
        REFERENCES keyword(id)
        ON DELETE CASCADE
);
