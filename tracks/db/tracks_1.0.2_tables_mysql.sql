# CocoaMySQL dump
# Version 0.5
# http://cocoamysql.sourceforge.net
#
# Host: localhost (MySQL 4.0.20-max)
# Database: todo
# Generation Time: 2005-03-02 15:39:14 +0000
# ************************************************************

# Dump of table contexts
# ------------------------------------------------------------

CREATE TABLE `contexts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `hide` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;



# Dump of table projects
# ------------------------------------------------------------

CREATE TABLE `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;



# Dump of table todos
# ------------------------------------------------------------

CREATE TABLE `todos` (
  `id` int(11) NOT NULL auto_increment,
  `context_id` int(11) NOT NULL default '0',
  `description` varchar(100) NOT NULL default '',
  `notes` text,
  `done` tinyint(4) NOT NULL default '0',
  `created` datetime NOT NULL default '0000-00-00 00:00:00',
  `due` date default NULL,
  `completed` datetime default NULL,
  `project_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;



# Dump of table users
# ------------------------------------------------------------

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(80) default NULL,
  `password` varchar(40) default NULL,
  `word` varchar(255) default NULL,
  `is_admin` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;



