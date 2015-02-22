-- foo.sql

-- a dummy update just for testing $app->do_sql_file
UPDATE users SET description =(SELECT description FROM users WHERE id=0)
WHERE id=0;
