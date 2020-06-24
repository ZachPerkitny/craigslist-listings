DELIMITER $$
DROP PROCEDURE IF EXISTS scrape_keywords$$
CREATE PROCEDURE scrape_keywords ()
BEGIN
    SELECT lambda_async('arn:aws:lambda:REGION:ID:function:NAME',
        CONCAT(
        '{"email":"', email,
        '", "category":"', category,
        '", "keyword":"', keyword, '"}')
    )
    FROM keywords;
END$$
DELIMITER ;
