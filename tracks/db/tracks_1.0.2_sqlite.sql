-- SQLite dump
-- ************************************************************

-- Dump of table contexts
-- ------------------------------------------------------------

CREATE TABLE 'contexts' (
  'id' INTEGER PRIMARY KEY,
  'name' varchar(255) NOT NULL default '',
  'hide' tinyint(4) NOT NULL default '0',
  position int NOT NULL
) ;



-- Dump of table projects
-- ------------------------------------------------------------

CREATE TABLE 'projects' (
  'id' INTEGER PRIMARY KEY,
  'name' varchar(255) NOT NULL default '',
  position int NOT NULL
) ;



-- Dump of table todos
-- ------------------------------------------------------------

CREATE TABLE 'todos' (
  'id' INTEGER PRIMARY KEY,
  'context_id' int(11) NOT NULL default '0',
  'description' varchar(100) NOT NULL default '',
  'notes' text,
  'done' tinyint(4) NOT NULL default '0',
  'created' datetime NOT NULL default '0000-00-00 00:00:00',
  'due' date default NULL,
  'completed' datetime default NULL,
  'project_id' int(11) default NULL
) ;



-- Dump of table users
-- ------------------------------------------------------------

CREATE TABLE 'users' (
  'id' INTEGER PRIMARY KEY,
  'login' varchar(80) default NULL,
  'password' varchar(40) default NULL,
  'word' varchar(255) default NULL,
  'is_admin' tinyint(4) NOT NULL default '0'
) ;
