# CocoaMySQL dump
# Version 0.5
# http://cocoamysql.sourceforge.net
#
# Host: localhost (MySQL 4.0.20-max)
# Database: todo
# Generation Time: 2005-03-02 15:40:19 +0000
# ************************************************************

# Dump of table contexts
# ------------------------------------------------------------

INSERT INTO `contexts` (`id`,`name`) VALUES ("1","agenda","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("2","call","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("3","email","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("4","errand","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("5","lab","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("6","library","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("7","freetime","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("8","office","0");
INSERT INTO `contexts` (`id`,`name`) VALUES ("11","waiting-for","0");


# Dump of table projects
# ------------------------------------------------------------

INSERT INTO `projects` (`id`,`name`) VALUES ("1","Build a working time machine");
INSERT INTO `projects` (`id`,`name`) VALUES ("2","Make more money than Billy Gates");
INSERT INTO `projects` (`id`,`name`) VALUES ("3","Evict dinosaurs from the garden");


# Dump of table todos
# ------------------------------------------------------------

INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("1","1","Call Bill Gates to find out how much he makes per day","","0","2004-11-28 16:01:00","2004-10-30",NULL,"2");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("52","2","Call dinosaur exterminator","Ask him if I need to hire a skip for the corpses.","0","2004-11-28 16:06:08","2004-11-30",NULL,"3");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("53","4","Buy milk","","1","2004-11-28 16:06:31","0000-00-00","2004-11-28 16:06:42",NULL);
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("54","4","Buy bread","","1","2004-11-28 16:06:58","0000-00-00","2004-11-30 13:41:09",NULL);
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("55","5","Construct time dilation device","","0","2004-11-28 16:07:33","0000-00-00",NULL,"1");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("56","2","Phone Grandfather to ask about the paradox","Added some _notes_.","0","2004-11-28 16:08:33","2004-12-30",NULL,"1");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("61","6","Get a book out of the library","Dinosaurs\'R\'Us","0","2004-12-22 14:07:06","0000-00-00",NULL,"3");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("60","4","Upgrade to Rails 0.9.1","","1","2004-12-20 17:02:52","2004-12-21","2004-12-20 17:06:48",NULL);
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("65","1","This should be due today","","0","2004-12-31 17:23:06","2004-12-31",NULL,NULL);
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("75","1","foo","","1","2004-12-31 18:38:34","2005-01-05","2005-01-02 12:27:10",NULL);
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("81","1","Buy shares","","0","2005-01-01 12:40:26","2005-02-01",NULL,"2");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("85","1","Buy stegosaurus bait","","1","2005-01-01 12:53:12","2005-01-02","2005-01-01 12:53:43","3");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("92","1","New action in context","Some notes","1","2005-01-02 14:52:49","2005-03-01","2005-01-02 15:44:19","3");
INSERT INTO `todos` (`id`,`context_id`,`description`,`notes`,`done`,`created`,`due`,`completed`,`project_id`) VALUES ("97","2","Call stock broker","tel: 12345","0","2005-01-03 11:38:25","0000-00-00",NULL,"2");



