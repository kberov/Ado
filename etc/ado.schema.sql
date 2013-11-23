--<queries>
-- <create_schema_and_user><![CDATA[
-- Example: Not executed by MYDLjE::Plugin::SystemSetup::init_database($dbix, $log);
-- Uncomment the SQL lines below and execute them using some mysql client.
-- CREATE USER 'mydlje'@'localhost' IDENTIFIED BY  'mydljep';
-- GRANT USAGE ON * . * TO  'mydlje'@'localhost' IDENTIFIED BY  'mydljep' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;
-- CREATE DATABASE IF NOT EXISTS  `mydlje` ;
-- GRANT ALL PRIVILEGES ON  `mydlje` . * TO  'mydlje'@'localhost';
-- ALTER DATABASE  `mydlje` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
--]]></create_schema_and_user>
-- <do id="disable_foreign_key_checks"><![CDATA[
SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
DROP TABLE IF EXISTS `abilities`, `content`, `domains`, `groups`, `group_abilities`, `pages`, `sessions`, `users`, `user_group`;
DROP VIEW IF EXISTS vguest_content, varticle;

--]]></do>
-- <table name="groups"><![CDATA[
DROP TABLE IF EXISTS `groups`;
CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `namespaces` varchar(255) NOT NULL DEFAULT 'MYDLjE::Site' COMMENT 'MYDLjE::Site (outsiders), MYDLjE::ControlPanel (insiders)',
  `created_by` int(11) NOT NULL DEFAULT '1' COMMENT 'id of who created this group.',
  `changed_by` int(11) NOT NULL DEFAULT '1' COMMENT 'id of who changed this group.',
  `disabled` tinyint(1) NOT NULL DEFAULT '0',
  `start` int(11) NOT NULL DEFAULT '0',
  `stop` int(11) NOT NULL DEFAULT '0',
  `properties` blob COMMENT 'Serialized/cached properties inherited by the users in this group',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `created_by` (`created_by`),
  KEY `namespaces` (`namespaces`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
--]]></table>

-- <table name="users"><![CDATA[
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL COMMENT 'Primary group for this user',
  `login_name` varchar(100) NOT NULL,
  `login_password` varchar(100) NOT NULL COMMENT 'Mojo::Util::md5_sum($login_name.$login_password)',
  `first_name` varchar(255) NOT NULL DEFAULT '',
  `last_name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT 'email@domain.com',
  `description` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL DEFAULT '1'  COMMENT 'id of who created this user.',
  `changed_by` int(11) NOT NULL DEFAULT '1' COMMENT 'Who modified this user the last time?',
  `tstamp` int(11) NOT NULL DEFAULT '0' COMMENT 'last modification time',
  `reg_tstamp` int(11) NOT NULL DEFAULT '0' COMMENT 'registration time',
  `disabled` tinyint(1) NOT NULL DEFAULT '0',
  `start` int(11) NOT NULL DEFAULT '0',
  `stop` int(11) NOT NULL DEFAULT '0',
  `properties` blob COMMENT 'Serialized/cached properties inherited and overided from group',
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_name` (`login_name`),
  UNIQUE KEY `email` (`email`),
  KEY `group_id` (`group_id`),
  KEY `reg_tstamp` (`reg_tstamp`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='This table stores the users';
--]]></table>


-- <table name="sessions"><![CDATA[
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(32) NOT NULL DEFAULT '' COMMENT 'md5_sum-med session id',
  `cid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Count ID - number of unique visitors so far.',
  `user_id` int(11) NOT NULL COMMENT 'Which user is this session for?',
  `tstamp` int(11) NOT NULL DEFAULT '0' COMMENT 'Last modification time - last visit.',
  `sessiondata` blob NOT NULL COMMENT 'Session data freezed with Storable and packed with Base64',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cid` (`cid`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Users sessions storage table';
--]]></table>

-- <table name="domains"><![CDATA[
DROP TABLE IF EXISTS `domains`;
CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id referenced by pages that belong to this domain.',
  `domain` varchar(63) NOT NULL COMMENT 'Domain name as in $ENV{HTTP_HOST}, but without "www.".',
  `name` varchar(63) NOT NULL COMMENT 'The name of this site.',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT 'Site description',
  `user_id` int(11) NOT NULL COMMENT  'User for which the permissions apply (owner).',
  `group_id` int(11) NOT NULL DEFAULT '1' COMMENT 'Group for which the permissions apply.',
  `permissions` varchar(10) NOT NULL DEFAULT '-rwxr-xr-x' COMMENT 'Domain permissions',
  `published` int(1) NOT NULL DEFAULT '0' COMMENT '0=not published, 1=for review, 2=published',

  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`),
  KEY `user_id_group_id` (`user_id`, `group_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Sites managed by this system';
--]]></table>

-- <table name="pages"><![CDATA[

DROP TABLE IF EXISTS `pages`;
CREATE TABLE IF NOT EXISTS `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT 'Parent page id',
  `domain_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Refrerence to domain.id to which this page belongs.',
  `alias` varchar(32) NOT NULL DEFAULT '' COMMENT 'Alias for the page which may be used instead of the id ',
  `page_type` varchar(32) NOT NULL COMMENT 'Regular,Folder, Site Root etc',
  `sorting` int(11) NOT NULL DEFAULT '1',
  `template` text COMMENT 'TT2 code to display this page. Default template is used if not specified.',
  `cache` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=yes 0=no',
  `expiry` int(11) NOT NULL DEFAULT '86400' COMMENT 'expiry tstamp if cache==1',
  `permissions` varchar(10) NOT NULL DEFAULT '-rwxr-xr-x' COMMENT 'Page editing permissions',
  `user_id` int(11) NOT NULL COMMENT  'User for which the permissions apply (owner).',
  `group_id` int(11) NOT NULL DEFAULT '1' COMMENT 'Group for which the permissions apply.',
  `tstamp` int(11) NOT NULL DEFAULT '0',
  `start` int(11) NOT NULL DEFAULT '0',
  `stop` int(11) NOT NULL DEFAULT '0',
  `published` int(1) NOT NULL DEFAULT '0' COMMENT '0=not published, 1=for review, 2=published',
  `hidden` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is this page hidden? 0=No, 1=Yes',
  `deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Is this page deleted? 0=No, 1=Yes',
  `changed_by` int(11) NOT NULL COMMENT 'Who modified this page the last time?',
  PRIMARY KEY (`id`),
  UNIQUE KEY `alias_in_domain_id` (`alias`,`domain_id`),
  KEY `tstamp` (`tstamp`),
  KEY `page_type` (`page_type`),
  KEY `user_id_group_id` (`user_id`, `group_id`),
  KEY `hidden` (`hidden`),
  KEY `pid` (`pid`),
  KEY `domain_id` (`domain_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Pages holding various content elements';

--]]></table>

-- <table name="content"><![CDATA[

DROP TABLE IF EXISTS `content`;
CREATE TABLE IF NOT EXISTS `content` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary unique identyfier',
  `alias` varchar(255) NOT NULL DEFAULT 'seo-friendly-id' COMMENT 'Unidecoded, lowercased and trimmed of \\W characters unique identifier for the row data_type',
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT 'Parent content: Question, Article, Note, Book ID etc.',
  `from_id` int(11) NOT NULL DEFAULT 0 COMMENT 'Id from which this content is copied (translated), if not original content.',
  `page_id` int(11) NOT NULL DEFAULT '0' COMMENT 'page.id to which this content belongs. Default: 0 ',
  `user_id` int(11) NOT NULL COMMENT  'User for which the permissions apply (owner).',
  `group_id` int(11) NOT NULL COMMENT 'Group for which the permissions apply.(primary group of the user by default)',
  `sorting` int(10) NOT NULL DEFAULT '0' COMMENT 'For sorting chapters in a book, pages in a menu etc.',
  `data_type` varchar(32) NOT NULL DEFAULT 'note' COMMENT 'Semantic Content Types. See MYDLjE::M::Content::*.',
  `data_format` varchar(32) NOT NULL DEFAULT 'text' COMMENT 'Corresponding engine will be used to process the content before output. Ie Text::Textile for textile.',
  `time_created` int(11) NOT NULL DEFAULT '0' COMMENT 'When this content was inserted',
  `tstamp` int(11) NOT NULL DEFAULT '0' COMMENT 'Last time the record was touched',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT 'Used in title html tag for pages or or as h1 for other data types.',
  `description` varchar(255) NOT NULL DEFAULT '' COMMENT 'Used in description meta tag when appropriate.',
  `keywords` varchar(255) NOT NULL DEFAULT '' COMMENT 'Used in keywords meta tag.',
  `tags` varchar(100) NOT NULL DEFAULT '' COMMENT 'Used in tag cloud boxes. merged with keywords and added to keywords meta tag.',
  `body` text COMMENT 'Main content when applicable.',
  `box`  varchar(35) NOT NULL DEFAULT 'MAIN_AREA' COMMENT 'Content box (defined in "layouts/${DOMAIN.id}/pre_process.tt") in which this element should be displayed.',
  `language` varchar(5) NOT NULL DEFAULT '' COMMENT 'Language of this content. All languages when empty string',
  `permissions` char(10) NOT NULL DEFAULT '-rwxr-xr-x' COMMENT 'tuuugggooo - Experimental permissions for the content.',
  `featured` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Show on top independently of other sorting.',
  `accepted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Answer accepted?',
  `bad` tinyint(2) NOT NULL DEFAULT '0' COMMENT 'Reported as inapropriate offensive etc. higher values -very bad.',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'When set to 1 the record is not visible anywhere.',
  `start` int(11) NOT NULL DEFAULT '0' COMMENT 'Date/Time from which the record will be accessible in the site.',
  `stop` int(11) NOT NULL DEFAULT '0' COMMENT 'Date/Time till which the record will be accessible in the site.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `alias_with_data_type_in_page_id` (`alias`,`data_type`,`page_id`),
  KEY `pid` (`pid`),
  KEY `tstamp` (`tstamp`),
  KEY `tags` (`tags`),
  KEY `permissions` (`permissions`),
  KEY `user_id_group_id` (`user_id`, `group_id`),
  KEY `data_type` (`data_type`),
  KEY `language` (`language`),
  KEY `page_id` (`page_id`),
  KEY `deleted` (`deleted`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 
COMMENT='MYDLjE content elements. Different  data_typeS may be used.';

--]]></table>

-- <table name="user_group"><![CDATA[
DROP TABLE IF EXISTS `user_group`;
CREATE TABLE IF NOT EXISTS `user_group` (
  `user_id` int(11) NOT NULL COMMENT 'ID of the user belonging to the group with group_id.',
  `group_id` int(11) NOT NULL COMMENT 'ID of the group to which the user with user_id belongs.',
  PRIMARY KEY `user_id_group_id` (`user_id`, `group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Which user to which group belongs';
--]]></table>

-- <table name="abilities"><![CDATA[
DROP TABLE IF EXISTS `abilities`;
CREATE TABLE IF NOT EXISTS `abilities` (
  `ability` varchar(30) NOT NULL COMMENT 'Group or/and user abilities to do or be something',
  `description` varchar(255) NOT NULL COMMENT 'What this ability means?',
  `default_value` varchar(255) NOT NULL DEFAULT '' COMMENT 'Default value for this ability?',
  PRIMARY KEY (`ability`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 
COMMENT='Abilities which can be used as permissions, capabilities or whatever business logic you put in.';
--]]></table>

-- <table name="group_abilities"><![CDATA[
DROP TABLE IF EXISTS `group_abilities`;
CREATE TABLE IF NOT EXISTS `group_abilities` (
  `group_id` int(11) NOT NULL COMMENT 'All users in the group with this group_id have the ability',
  `ability` varchar(30) NOT NULL COMMENT 'The ability',
  `a_value` varchar(255) NOT NULL COMMENT 'Value interpreted depending on business logic',
  PRIMARY KEY (`group_id`,`ability`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Users having abilities.';
--]]></table>

--
-- Views which will be used instead of directly content
-- Note: MySQL 5 required
-- 03.04.11 20:00
--
-- Note: from selects below are visible interdependencies
-- 
-- TODO: make MYDLjE::M::Content work automatically with views
-- when a database suports this.
-- EXAMPLE EDITABLE VIEWS
--<view name="vguest_content"><![CDATA[
DROP VIEW IF EXISTS  vguest_content;
CREATE VIEW vguest_content AS SELECT 
`id`, `alias`, `pid`, `page_id`, `user_id`, `group_id`, `sorting`, `data_type`, `data_format`, 
`time_created`, `tstamp`, `title`, `description`, `keywords`, `tags`, `body`, 
`language`, `permissions`, `featured`, `accepted`, `bad`
FROM content WHERE(
  deleted = 0 AND (
    (start = 0 OR start < UNIX_TIMESTAMP()) AND (STOP = 0 OR STOP > UNIX_TIMESTAMP())
  )
  AND `permissions` LIKE '%r__'
);
--]]></view>

--<view name="varticle"><![CDATA[
DROP VIEW IF EXISTS  varticle;
--]]></view>
--<do id="constraints"><![CDATA[
ALTER TABLE `users`
  ADD CONSTRAINT `users_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`);

ALTER TABLE `user_group`
  ADD CONSTRAINT `user_group_groups_id_fk` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  ADD CONSTRAINT `user_group_users_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `domains`
  ADD CONSTRAINT `domains_user_id_group_id_fk` FOREIGN KEY (`user_id`, `group_id`) REFERENCES `user_group` (`user_id`, `group_id`);

ALTER TABLE `pages`
  ADD CONSTRAINT `pages_pid_fk` FOREIGN KEY (`pid`) REFERENCES `pages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pages_user_id_group_id_fk` FOREIGN KEY (`user_id`, `group_id`) REFERENCES `user_group` (`user_id`, `group_id`) ,
  ADD CONSTRAINT `pages_domain_id_fk` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`);

ALTER TABLE `content`
  ADD CONSTRAINT `content_page_id_fk` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `content_pid_fk` FOREIGN KEY (`pid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `content_user_id_group_id_fk` FOREIGN KEY (`user_id`, `group_id`) REFERENCES `user_group` (`user_id`, `group_id`);

ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `group_abilities`
  ADD CONSTRAINT `group_abilities_ability_fk` FOREIGN KEY (`ability`) REFERENCES `abilities` (`ability`),
  ADD CONSTRAINT `group_abilities_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `user_group` (`group_id`);

--]]></do>
--<do id="enable_foreign_key_checks"><![CDATA[
SET FOREIGN_KEY_CHECKS=1;
--]]></do>

-- Examples here are just stored as snippets for my reference. They are not executed by mydlje
-- <example><![CDATA[
-- SET FOREIGN_KEY_CHECKS=0;
-- DROP TABLE IF EXISTS `abilities`, `content`, `domains`, `groups`, `group_abilities`, `pages`, `sessions`, `users`, `user_group`;
-- DROP VIEW IF EXISTS vguest_content, varticle;
--]]></example>

--</queries>

