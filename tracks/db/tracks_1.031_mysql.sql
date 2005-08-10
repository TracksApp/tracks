-- NB: This schema should be redundant, and is just included for reference. If you are
-- using MySQL, you can just issue the following commands at your command prompt to create
-- the tables in the database you've specified in db/database.yml:
--
-- cd /PATH/TO/TRACKS
-- rake migrate

-- Dump of table contexts
-- ------------------------------------------------------------

CREATE TABLE `contexts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `position` int(11) NOT NULL default '0',
  `hide` tinyint(1) default '0',
  `user_id` int(11) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

-- Dump of table projects
-- ------------------------------------------------------------

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `position` int(11) NOT NULL default '0',
  `done` tinyint(1) default '0',
  `user_id` int(11) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

-- Dump of table schema_info
-- ------------------------------------------------------------

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) TYPE=MyISAM;

-- Dump of table todos
-- ------------------------------------------------------------

CREATE TABLE `todos` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `context_id` int(11) NOT NULL default '0',
  `project_id` int(11) default NULL,
  `description` varchar(255) NOT NULL default '',
  `notes` text,
  `done` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  `due` date default NULL,
  `completed` datetime default NULL,
  `user_id` int(11) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

-- Dump of table users
-- ------------------------------------------------------------

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(80) NOT NULL default '',
  `password` varchar(40) NOT NULL default '',
  `word` varchar(255) default NULL,
  `is_admin` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

-- Dump of table notes
-- ------------------------------------------------------------

CREATE TABLE `notes` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL default '1',
  `project_id` int(11) NOT NULL default '0',
  `body` text,
  `created_at` datetime default '0000-00-00 00:00:00',
  `updated_at` datetime default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

