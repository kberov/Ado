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
  name VARCHAR(255) UNIQUE NOT NULL,
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
  login_password varchar(80) NOT NULL,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
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


-- 'Sites managed by this system'
DROP TABLE IF EXISTS domains;
CREATE TABLE IF NOT EXISTS domains (
--  'Id referenced by pages that belong to this domain.'
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
--  'Domain name as in $ENV{HTTP_HOST}.'
  domain VARCHAR(63) UNIQUE NOT NULL, 
--  'The name of this site.'
  site_name VARCHAR(63) NOT NULL,
--  'Site description'
  description VARCHAR(255) NOT NULL DEFAULT '',
--   'User for which the permissions apply (owner).'
  owner_id INTEGER REFERENCES users(id),
--  'Group for which the permissions apply.'
  group_id INTEGER  REFERENCES groups(id),
--  'Domain permissions',
  permissions VARCHAR(10) NOT NULL DEFAULT '-rwxr-xr-x' ,
--  '0=not published, 1=for review, 2=published'
  published INT(1) NOT NULL DEFAULT 0
);
CREATE INDEX domains_published ON domains(published);

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
  id VARCHAR(40) PRIMARY KEY,
--  'Which user is this session for?',
  user_id INT(11)  REFERENCES users(id),
--  'Last modification time - last HTTP request.',
  tstamp INT(11) NOT NULL DEFAULT 0,
--  'Session data serialized in JSON and packed with Base64',
  sessiondata BLOB NOT NULL
);

DROP TABLE IF EXISTS sessions_old;
CREATE TABLE IF NOT EXISTS sessions_old (
--  'Mojo::Util::sha1_hex(id)',
  id VARCHAR(40) PRIMARY KEY,
--  'Count ID - number of unique visitors so far.',
  user_id INT(11),
--  'Last modification time - last HTTP request.',
  tstamp INT(11) NOT NULL DEFAULT 0,
--  'Session data serialized in JSON and packed with Base64',
  sessiondata BLOB NOT NULL
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
