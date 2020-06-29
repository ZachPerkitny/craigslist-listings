DROP TABLE IF EXISTS craigslist_listings;
DROP TABLE IF EXISTS craigslist_search_urls;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS subcategories;
DROP PROCEDURE IF EXISTS get_craigslist_listings;
DROP TRIGGER IF EXISTS keyword_trigger;
DROP EVENT IF EXISTS get_craigslist_listings_event;

CREATE TABLE categories (
    id int PRIMARY KEY,
    name varchar(50) NOT NULL
);

CREATE TABLE subcategories (
    id varchar(3) PRIMARY KEY,
    name varchar(50) NOT NULL
);

CREATE TABLE keywords (
    id int AUTO_INCREMENT PRIMARY KEY,
    category_id int NOT NULL,
    subcategory_id varchar(3),
    keyword varchar(100) NOT NULL,
    zip_code varchar(5) NOT NULL,
    within smallint UNSIGNED NOT NULL,
    FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE CASCADE,
    FOREIGN KEY (subcategory_id)
        REFERENCES subcategories(id)
        ON DELETE CASCADE
);

CREATE TABLE craigslist_search_urls (
    id int AUTO_INCREMENT PRIMARY KEY,
    keyword_id int NOT NULL,
    search_url varchar(1000) NOT NULL,
    FOREIGN KEY (keyword_id)
        REFERENCES keywords(id)
        ON DELETE CASCADE,
    UNIQUE KEY (keyword_id, search_url)
);

CREATE TABLE craigslist_listings (
    id int AUTO_INCREMENT PRIMARY KEY,
    craigslist_search_url_id int NOT NULL,
    listing_url varchar(1000) UNIQUE NOT NULL,
    time_scraped datetime DEFAULT CURRENT_TIMESTAMP NOT NULL,
    INDEX time_scraped_ind(time_scraped),
    FOREIGN KEY (craigslist_search_url_id)
        REFERENCES craigslist_search_urls(id)
        ON DELETE CASCADE 
);

DELIMITER $$

CREATE PROCEDURE get_craigslist_listings ()
BEGIN
    SELECT lambda_async(
        'arn:aws:lambda:REGION:ID:function:NAME',
        CONCAT('{"keyword_id":"', id, '"}')
    )
    FROM keywords;
END$$

CREATE TRIGGER keyword_trigger
    AFTER INSERT
    ON keywords FOR EACH ROW
BEGIN
    CALL mysql.lambda_async(
        'arn:aws:lambda:REGION:ID:function:NAME',
        CONCAT('{"keyword_id":"', NEW.id, '"}')
    );
END$$

CREATE EVENT get_craigslist_listings_event
ON SCHEDULE EVERY 12 HOUR
DO BEGIN
    CALL get_craigslist_listings();
END$$

DELIMITER ;

-- Insert Categories
INSERT INTO categories VALUES (1, 'community');
INSERT INTO categories VALUES (2, 'events');
INSERT INTO categories VALUES (3, 'gigs');
INSERT INTO categories VALUES (4, 'housing');
INSERT INTO categories VALUES (5, 'jobs');
INSERT INTO categories VALUES (6, 'resumes');
INSERT INTO categories VALUES (7, 'sales/wanted');
INSERT INTO categories VALUES (8, 'services');

-- Insert SubCategories
-- Community Subcategories
INSERT INTO subcategories VALUES ('ccc', 'all community');
INSERT INTO subcategories VALUES ('act', 'activity partners');
INSERT INTO subcategories VALUES ('ats', 'artists');
INSERT INTO subcategories VALUES ('kid', 'childcare');
INSERT INTO subcategories VALUES ('com', 'general');
INSERT INTO subcategories VALUES ('grp', 'groups');
INSERT INTO subcategories VALUES ('vnn', 'local news and views');
INSERT INTO subcategories VALUES ('laf', 'lost & found');
INSERT INTO subcategories VALUES ('mis', 'missed connections');
INSERT INTO subcategories VALUES ('muc', 'musicians');
INSERT INTO subcategories VALUES ('pet', 'pets');
INSERT INTO subcategories VALUES ('pol', 'politics');
INSERT INTO subcategories VALUES ('rid', 'rideshare');
INSERT INTO subcategories VALUES ('vol', 'volunteers');

-- Events Subcategories
INSERT INTO subcategories VALUES ('eee', 'all events');
INSERT INTO subcategories VALUES ('cls', 'classes');
INSERT INTO subcategories VALUES ('eve', 'events');

-- Gigs Subcategories
INSERT INTO subcategories VALUES ('ggg', 'all gigs');
INSERT INTO subcategories VALUES ('cpg', 'computer');
INSERT INTO subcategories VALUES ('crg', 'creative');
INSERT INTO subcategories VALUES ('cwg', 'crew');
INSERT INTO subcategories VALUES ('dmg', 'domestic');
INSERT INTO subcategories VALUES ('evg', 'event');
INSERT INTO subcategories VALUES ('lbg', 'labor');
INSERT INTO subcategories VALUES ('tlg', 'talent');
INSERT INTO subcategories VALUES ('wrg', 'writing');

-- Housing Subcategories
INSERT INTO subcategories VALUES ('hhh', 'all housing');
INSERT INTO subcategories VALUES ('hou', 'apts wanted');
INSERT INTO subcategories VALUES ('apa', 'apts/housing for rent');
INSERT INTO subcategories VALUES ('swp', 'housing swap');
INSERT INTO subcategories VALUES ('hsw', 'housing wanted');
INSERT INTO subcategories VALUES ('off', 'office / commercial');
INSERT INTO subcategories VALUES ('prk', 'parking / storage');
INSERT INTO subcategories VALUES ('rea', 'real estate - all');
INSERT INTO subcategories VALUES ('reb', 'real estate - broker');
INSERT INTO subcategories VALUES ('reo', 'real estate - owner');
INSERT INTO subcategories VALUES ('rew', 'real estate wanted');
INSERT INTO subcategories VALUES ('roo', 'rooms & shares');
INSERT INTO subcategories VALUES ('sha', 'rooms wanted');
INSERT INTO subcategories VALUES ('sbw', 'sublet/temp wanted');
INSERT INTO subcategories VALUES ('sub', 'sublets & temporary');
INSERT INTO subcategories VALUES ('vac', 'vacation rentals');

-- Job Subcategories
INSERT INTO subcategories VALUES ('jjj', 'all jobs');
INSERT INTO subcategories VALUES ('ofc', 'admin/office');
INSERT INTO subcategories VALUES ('med', 'art/media/design');
INSERT INTO subcategories VALUES ('bus', 'business/mgmt');
INSERT INTO subcategories VALUES ('csr', 'customer service');
INSERT INTO subcategories VALUES ('edu', 'education');
INSERT INTO subcategories VALUES ('egr', 'engineering');
INSERT INTO subcategories VALUES ('etc', 'etcetera');
INSERT INTO subcategories VALUES ('acc', 'finance');
INSERT INTO subcategories VALUES ('fbh', 'food/bev/hosp');
INSERT INTO subcategories VALUES ('lab', 'general labor');
INSERT INTO subcategories VALUES ('gov', 'government');
INSERT INTO subcategories VALUES ('hea', 'healthcare');
INSERT INTO subcategories VALUES ('hum', 'human resource');
INSERT INTO subcategories VALUES ('lgl', 'legal');
INSERT INTO subcategories VALUES ('mnu', 'manufacturing');
INSERT INTO subcategories VALUES ('mar', 'marketing');
INSERT INTO subcategories VALUES ('npo', 'nonprofit');
INSERT INTO subcategories VALUES ('rej', 'real estate');
INSERT INTO subcategories VALUES ('ret', 'retail/wholesale');
INSERT INTO subcategories VALUES ('sls', 'sales');
INSERT INTO subcategories VALUES ('spa', 'salon/spa/fitness');
INSERT INTO subcategories VALUES ('sci', 'science');
INSERT INTO subcategories VALUES ('sec', 'security');
INSERT INTO subcategories VALUES ('trd', 'skilled trades');
INSERT INTO subcategories VALUES ('sof', 'software');
INSERT INTO subcategories VALUES ('sad', 'systems/networking');
INSERT INTO subcategories VALUES ('tch', 'tech support');
INSERT INTO subcategories VALUES ('trp', 'transport');
INSERT INTO subcategories VALUES ('tfr', 'tv video radio');
INSERT INTO subcategories VALUES ('web', 'web design');
INSERT INTO subcategories VALUES ('wri', 'writing');

-- Resumes Subcategories
INSERT INTO subcategories VALUES ('res', 'all resumes');

-- Sale/Wanted Subcategories
INSERT INTO subcategories VALUES ('sss', 'all sale/wanted');
INSERT INTO subcategories VALUES ('ata', 'antiques');
INSERT INTO subcategories VALUES ('ppa', 'appliances');
INSERT INTO subcategories VALUES ('ara', 'arts & crafts');
INSERT INTO subcategories VALUES ('sna', 'atv / utv / snowmobile');
INSERT INTO subcategories VALUES ('pta', 'auto parts');
INSERT INTO subcategories VALUES ('ava', 'aviation');
INSERT INTO subcategories VALUES ('baa', 'baby & kid stuff');
INSERT INTO subcategories VALUES ('bar', 'barter');
INSERT INTO subcategories VALUES ('bia', 'bicycles');
INSERT INTO subcategories VALUES ('bip', 'bike parts');
INSERT INTO subcategories VALUES ('bpa', 'boat parts');
INSERT INTO subcategories VALUES ('boo', 'boats');
INSERT INTO subcategories VALUES ('bka', 'books & magazines');
INSERT INTO subcategories VALUES ('bfa', 'business/commercial');
INSERT INTO subcategories VALUES ('cta', 'cars & trucks');
INSERT INTO subcategories VALUES ('ema', 'cd / dvd / vhs');
INSERT INTO subcategories VALUES ('moa', 'cell phones');
INSERT INTO subcategories VALUES ('cla', 'clothing & accessories');
INSERT INTO subcategories VALUES ('cba', 'collectibles');
INSERT INTO subcategories VALUES ('syp', 'computer parts');
INSERT INTO subcategories VALUES ('sya', 'computers & tech');
INSERT INTO subcategories VALUES ('ela', 'electronics');
INSERT INTO subcategories VALUES ('gra', 'farm & garden');
INSERT INTO subcategories VALUES ('zip', 'free stuff');
INSERT INTO subcategories VALUES ('fua', 'furniture');
INSERT INTO subcategories VALUES ('gms', 'garage sales');
INSERT INTO subcategories VALUES ('foa', 'general');
INSERT INTO subcategories VALUES ('haa', 'health and beauty');
INSERT INTO subcategories VALUES ('hva', 'heavy equipment');
INSERT INTO subcategories VALUES ('hsa', 'household items');
INSERT INTO subcategories VALUES ('waa', 'items wanted');
INSERT INTO subcategories VALUES ('jwa', 'jewelry');
INSERT INTO subcategories VALUES ('maa', 'materials');
INSERT INTO subcategories VALUES ('mpa', 'motorcycle parts');
INSERT INTO subcategories VALUES ('mca', 'motorcycles / scooters');
INSERT INTO subcategories VALUES ('msa', 'musical instruments');
INSERT INTO subcategories VALUES ('pha', 'photo/video');
INSERT INTO subcategories VALUES ('rva', 'recreational vehicles');
INSERT INTO subcategories VALUES ('sga', 'sporting goods');
INSERT INTO subcategories VALUES ('tia', 'tickets');
INSERT INTO subcategories VALUES ('tla', 'tools');
INSERT INTO subcategories VALUES ('taa', 'toys & games');
INSERT INTO subcategories VALUES ('tra', 'trailers');
INSERT INTO subcategories VALUES ('vga', 'video gaming');
INSERT INTO subcategories VALUES ('wta', 'wheels & tires');

-- Services Subcategories
INSERT INTO subcategories VALUES ('bbb', 'all services');
INSERT INTO subcategories VALUES ('aos', 'automotive');
INSERT INTO subcategories VALUES ('bts', 'beauty');
INSERT INTO subcategories VALUES ('cms', 'cell phone / mobile services');
INSERT INTO subcategories VALUES ('cps', 'computer');
INSERT INTO subcategories VALUES ('crs', 'creative');
INSERT INTO subcategories VALUES ('cys', 'cycle services');
INSERT INTO subcategories VALUES ('evs', 'event services');
INSERT INTO subcategories VALUES ('fgs', 'farm & garden');
INSERT INTO subcategories VALUES ('fns', 'financial');
INSERT INTO subcategories VALUES ('hss', 'household');
INSERT INTO subcategories VALUES ('lbs', 'labor & moving');
INSERT INTO subcategories VALUES ('lgs', 'legal');
INSERT INTO subcategories VALUES ('lss', 'lessons & tutoring');
INSERT INTO subcategories VALUES ('mas', 'marine services');
INSERT INTO subcategories VALUES ('pas', 'pet services');
INSERT INTO subcategories VALUES ('rts', 'real estate');
INSERT INTO subcategories VALUES ('sks', 'skilled trade');
INSERT INTO subcategories VALUES ('biz', 'small biz ads');
INSERT INTO subcategories VALUES ('trv', 'travel/vacation');
INSERT INTO subcategories VALUES ('wet', 'write/edit/trans');
