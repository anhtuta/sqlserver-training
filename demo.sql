-- concat with separator
SELECT CONCAT_WS('.', 'www', 'W3Schools', 'com');

SELECT CAST(25.65 AS int);

SELECT CURRENT_USER;

SELECT COALESCE(NULL, NULL, NULL, 'W3Schools.com', NULL, 'Example.com');

-- Return "YES" if the condition is TRUE, or "NO" if the condition is FALSE:
SELECT IIF(500<1000, 'YES', 'NO');

-- Return the specified value IF the expression is NULL, otherwise return the expression:
SELECT ISNULL(NULL, 'W3Schools.com');

UNION
common table expression