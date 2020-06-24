DELIMITER $$
DROP EVENT IF EXISTS scrape_keywords_event$$
CREATE EVENT scrape_keywords_event
ON SCHEDULE EVERY 12 HOUR
DO BEGIN
    CALL scrape_keywords();
END$$
DELIMITER ;
