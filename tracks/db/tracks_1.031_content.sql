-- Dump of table contents
-- Sample data to populate your database
-- No data is included for users: create your own users via the http://YOURURL/signup page

-- Dump of table contexts
-- ------------------------------------------------------------

INSERT INTO contexts (id,name,position,hide,user_id) VALUES (1,'agenda',1,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (2,'call',2,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (3,'email',3,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (4,'errand',4,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (5,'lab',5,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (6,'library',6,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (7,'freetime',7,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (8,'office',8,0,1);
INSERT INTO contexts (id,name,position,hide,user_id) VALUES (11,'waiting-for',9,0,1);


-- Dump of table notes
-- ------------------------------------------------------------

INSERT INTO notes (id,user_id,project_id,body,created_at,updated_at) VALUES (1,1,1,'Notes on building time machines.','2005-08-07 17:31:25','2005-08-07 17:31:25');


-- Dump of table projects
-- ------------------------------------------------------------

INSERT INTO projects (id,name,position,done,user_id) VALUES (1,'Build a working time machine',1,0,1);
INSERT INTO projects (id,name,position,done,user_id) VALUES (2,'Make more money than Billy Gates',2,0,1);
INSERT INTO projects (id,name,position,done,user_id) VALUES (3,'Evict dinosaurs from the garden',3,0,1);


-- Dump of table schema_info
-- ------------------------------------------------------------

INSERT INTO schema_info (version) VALUES (4);


-- Dump of table todos
-- ------------------------------------------------------------

INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (1,1,2,'Call Bill Gates to find out how much he makes per day',NULL,0,'2004-11-28 16:01:00','2004-10-30',NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (2,2,3,'Call dinosaur exterminator','Ask him if I need to hire a skip for the corpses.',0,'2004-11-28 16:06:08','2004-11-30',NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (3,4,NULL,'Buy milk',NULL,1,'2004-11-28 16:06:31',NULL,'2004-11-28 00:00:00',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (4,4,NULL,'Buy bread',NULL,1,'2004-11-28 16:06:58',NULL,'2004-11-28 00:00:00',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (5,5,1,'Construct time dilation device',NULL,0,'2004-11-28 16:07:33',NULL,NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (6,2,1,'Phone Grandfather to ask about the paradox','Added some _notes_.',0,'2004-11-28 16:08:33','2004-12-30',NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (7,6,3,'Get a book out of the library','Dinosaurs R Us',0,'2004-12-22 14:07:06',NULL,NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (8,4,NULL,'Upgrade to Rails 0.9.1',NULL,1,'2004-12-20 17:02:52','2004-12-21','2004-12-20 00:00:00',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (9,1,NULL,'This should be due today',NULL,0,'2004-12-31 17:23:06','2004-12-31',NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (10,1,NULL,'foo',NULL,1,'2004-12-31 18:38:34','2005-01-05','2005-01-02 12:27:10',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (11,1,2,'Buy shares',NULL,0,'2005-01-01 12:40:26','2005-02-01',NULL,1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (12,1,3,'Buy stegosaurus bait',NULL,1,'2005-01-01 12:53:12','2005-01-02','2005-01-01 15:44:19',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (13,1,3,'New action in context','Some notes',1,'2005-01-02 14:52:49','2005-03-01','2005-01-02 15:44:19',1);
INSERT INTO todos (id,context_id,project_id,description,notes,done,created_at,due,completed,user_id) VALUES (14,2,2,'Call stock broker','tel: 12345',0,'2005-01-03 11:38:25',NULL,NULL,1);

