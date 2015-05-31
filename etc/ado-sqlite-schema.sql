/**
 Careful developers will not make any assumptions about whether or not
 foreign keys are enabled by default but will instead enable or disable
 them as necessary.
 http://www.sqlite.org/foreignkeys.html#fk_enable
 http://www.sqlite.org/pragma.html
*/
PRAGMA encoding = "UTF-8"; 
PRAGMA foreign_keys = OFF;

-- 'Groups for users in a multidomain Ado system.'
DROP TABLE IF EXISTS groups;
CREATE TABLE IF NOT EXISTS groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) UNIQUE NOT NULL,
  description VARCHAR(255) NOT NULL,
--  'id of who created this group.'
  created_by INTEGER REFERENCES users(id),
--  'id of who changed this group.'
  changed_by INTEGER REFERENCES users(id), 
  disabled INT(1) NOT NULL DEFAULT 1
);

-- 'This table stores the users'
DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
--  'Primary group for this user'
  group_id INTEGER REFERENCES groups(id),
  login_name varchar(100) UNIQUE,
--  'Mojo::Util::sha1_hex($login_name.$login_password)'
  login_password varchar(40) NOT NULL,
  first_name varchar(100) NOT NULL DEFAULT '',
  last_name varchar(100) NOT NULL DEFAULT '',
  email varchar(255) NOT NULL UNIQUE,
  description varchar(255) DEFAULT NULL,
--  'id of who created this user.'
  created_by INTEGER REFERENCES users(id),
--  'Who modified this user the last time?'
  changed_by INTEGER REFERENCES users(id), 
--  'last modification time'
--  'All dates are stored as seconds since the epoch(1970) in GMT. In Perl we use gmtime as object from Time::Piece'
  tstamp INTEGER NOT NULL DEFAULT 0,
--  'registration time',,
  reg_date INTEGER NOT NULL DEFAULT 0, 
  disabled INT(1) NOT NULL DEFAULT 1,
  start_date INTEGER NOT NULL DEFAULT 0,
  stop_date INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX user_start_date ON users(start_date);
CREATE INDEX user_stop_date ON users(stop_date);


-- 'Which user to which group belongs'
DROP TABLE IF EXISTS user_group;
CREATE TABLE IF NOT EXISTS user_group (
--  'ID of the user belonging to the group with group_id.'
  user_id INTEGER  REFERENCES users(id),
--  'ID of the group to which the user with user_id belongs.'
  group_id INTEGER  REFERENCES groups(id),
  PRIMARY KEY(user_id, group_id)
);

-- 'Users sessions storage table'
/**
  Records older than a week will be be moved every day
  from this table to table sessions_old and will be kept
  for statistical purposes only.
*/
DROP TABLE IF EXISTS sessions;
CREATE TABLE IF NOT EXISTS sessions (
--  'Mojo::Util::sha1_hex(id)',
  id CHAR(40) PRIMARY KEY,
--  'Last modification time - last HTTP request. Only for statistics',
  tstamp INT(11) NOT NULL DEFAULT 0,
--  'Session data serialized in JSON and packed with Base64',
  sessiondata BLOB NOT NULL
);

DROP TABLE IF EXISTS sessions_old;
CREATE TABLE IF NOT EXISTS sessions_old (
--  'Mojo::Util::sha1_hex(id)',
  id CHAR(40) PRIMARY KEY,
--  'Last modification time - last HTTP request. Only for statistics',
  tstamp INT(11) NOT NULL DEFAULT 0,
--  'Session data serialized in JSON and packed with Base64',
  sessiondata BLOB NOT NULL
);

-- Here we store Intrenationalized messages and labels
DROP TABLE IF EXISTS i18n;
CREATE TABLE i18n (
  lang VARCHAR(5) DEFAULT 'en',
  msgid VARCHAR(255),
  -- files where this message is used
  locations TEXT DEFAULT '',
  msgstr TEXT DEFAULT '',
  -- Set to 1 when the msgstr in the default language changes
  fuzzy INT(1)  NOT NULL DEFAULT 0,
  PRIMARY KEY (lang, msgid)
);

PRAGMA foreign_keys = ON;
/*
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS domains;
DROP TABLE IF EXISTS user_group;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS sessions_old;
PRAGMA foreign_keys = ON;
*/
