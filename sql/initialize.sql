DROP TABLE IF EXISTS sent_listings;
DROP TABLE IF EXISTS craigslist_search_urls;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS categories;
DROP PROCEDURE IF EXISTS get_craigslist_listings;
DROP TRIGGER IF EXISTS keyword_trigger;
DROP EVENT IF EXISTS get_craigslist_listings_event;

CREATE TABLE categories (
    id int PRIMARY KEY,
    name varchar(50) NOT NULL
);

CREATE TABLE keywords (
    id int AUTO_INCREMENT PRIMARY KEY,
    email varchar(100) NOT NULL,
    category_id int NOT NULL,
    keyword varchar(100) NOT NULL,
    zip_code varchar(5) NOT NULL,
    within smallint UNSIGNED NOT NULL,
    FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE CASCADE
);

CREATE TABLE craigslist_search_urls (
    id int AUTO_INCREMENT PRIMARY KEY,
    keyword_id int NOT NULL,
    search_url varchar(1000) NOT NULL,
    INDEX keyword_id_ind(keyword_id),
    FOREIGN KEY (keyword_id)
        REFERENCES keywords(id)
        ON DELETE CASCADE
);

CREATE TABLE sent_listings (
    id int AUTO_INCREMENT PRIMARY KEY,
    craigslist_search_url_id int NOT NULL,
    FOREIGN KEY (craigslist_search_url_id)
        REFERENCES craigslist_search_urls(id)
        ON DELETE CASCADE
);

# Insert Categories
INSERT INTO categories VALUES (1, 'community');
INSERT INTO categories VALUES (2, 'events');
INSERT INTO categories VALUES (3, 'gigs');
INSERT INTO categories VALUES (4, 'housing');
INSERT INTO categories VALUES (5, 'jobs');
INSERT INTO categories VALUES (6, 'resumes');
INSERT INTO categories VALUES (7, 'sales/wanted');
INSERT INTO categories VALUES (8, 'services');

DELIMITER $$

CREATE PROCEDURE get_craigslist_listings ()
BEGIN
    SELECT lambda_async(
        'arn:aws:lambda:REGION:ID:function:NAME',
        CONCAT('{"url":"', search_url, '"}')
    )
    FROM craigslist_search_urls;
END$$

CREATE TRIGGER keyword_trigger
    AFTER INSERT
    ON keywords FOR EACH ROW
BEGIN
    CALL lambda_async(
        'arn:aws:lambda:REGION:ID:function:NAME',
        CONCAT('{"email":"', NEW.email,
        '", "category":"', NEW.category,
        '", "keyword":"', NEW.keyword, 
        '", "zip_code":"', NEW.zip_code, 
        '", "within":"', NEW.within, '"}')
    );
END$$

CREATE EVENT get_craigslist_listings_event
ON SCHEDULE EVERY 12 HOUR
DO BEGIN
    CALL get_craigslist_listings();
END$$

DELIMITER ;
