DELIMITER $$
DROP PROCEDURE IF EXISTS scrape_keywords$$
CREATE PROCEDURE scrape_keywords ()
BEGIN
    SELECT lambda_async('arn:aws:lambda:us-east-1:743449347746:function:scrape_keywords',
        CONCAT(
        '{"email":"', email,
        '", "category":"', category,
        '", "keyword":"', keyword, '"}')
    )
    FROM keywords;
END$$
DELIMITER ;
