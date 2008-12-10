-- Dump of table contents
-- Sample data to populate your database
-- No data is included for users: create your own users via the http://YOURURL/signup page

-- Dump of table contexts
-- ------------------------------------------------------------

INSERT INTO "contexts" VALUES(1,'agenda',1,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(2,'call',2,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(3,'email',3,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(4,'errand',4,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(5,'lab',5,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(6,'library',6,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(7,'freetime',7,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(8,'office',8,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');
INSERT INTO "contexts" VALUES(9,'waiting for',9,'f',1,'2008-02-25 20:21:09','2008-03-24 19:23:53');

-- Dump of table notes
-- ------------------------------------------------------------

INSERT INTO "notes" VALUES(1,1,1,'Need to collect a catalogue from Time Machines R Us','2006-06-10 14:36:02','2006-06-10 14:36:02');
INSERT INTO "notes" VALUES(2,1,1,'Should I go for a swirly effect or a whooshy one?','2006-06-10 14:36:02','2006-06-10 14:36:02');


-- Dump of table projects
-- ------------------------------------------------------------

INSERT INTO "projects" VALUES(1,'Build a working time machine',1,1,'','active','2008-02-25 20:21:09','2008-03-24 19:23:53',NULL,NULL);
INSERT INTO "projects" VALUES(2,'Make more money than Billy Gates',2,1,'','active','2008-02-25 20:21:09','2008-03-24 19:23:53',NULL,NULL);
INSERT INTO "projects" VALUES(3,'Evict dinosaurs from the garden',3,1,'','active','2008-02-25 20:21:09','2008-03-24 19:23:53',NULL,NULL);


-- Dump of table schema_info
-- ------------------------------------------------------------

INSERT INTO "schema_migrations" VALUES('44');


-- Dump of table todos
-- ------------------------------------------------------------

INSERT INTO "todos" VALUES(1,1,2,'Call Bill Gates to find out how much he makes per day',NULL,'2006-06-03 14:36:02','2006-06-23 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-03 14:36:02');
INSERT INTO "todos" VALUES(2,2,3,'Call dinosaur exterminator','Ask him if I need to hire a skip for the corpses.','2006-06-10 14:36:02','2006-06-23 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(3,4,NULL,'Buy milk',NULL,'2006-06-10 14:36:02',NULL,NULL,1,NULL,'completed',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(4,4,NULL,'Buy bread',NULL,'2006-06-10 14:36:02',NULL,NULL,1,NULL,'completed',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(5,5,1,'Construct time dilation device',NULL,'2006-06-10 14:36:02',NULL,NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(6,2,1,'Phone Grandfather to ask about the paradox','Added some _notes_.','2006-06-10 14:36:02','2006-06-02 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(7,6,3,'Get a book out of the library','Dinosaurs''R','2006-06-10 14:36:02',NULL,NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(8,4,NULL,'Upgrade to Rails 0.9.1',NULL,'2006-06-10 14:36:02','2006-06-09 23:00:00',NULL,1,NULL,'completed',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(9,1,NULL,'This should be due today',NULL,'2006-06-10 14:36:02','2006-06-09 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(10,1,NULL,'foo',NULL,'2006-06-10 14:36:02','2005-01-05 00:00:00',NULL,1,NULL,'completed',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(11,1,2,'Buy shares',NULL,'2006-06-10 14:36:02','2005-02-01 00:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(12,1,3,'Buy stegosaurus bait',NULL,'2006-06-10 14:36:02','2006-06-16 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(13,1,3,'New action in context','Some notes','2006-06-10 14:36:02','2006-06-16 23:00:00',NULL,1,NULL,'active',NULL,'2006-06-10 14:36:02');
INSERT INTO "todos" VALUES(14,2,2,'Call stock broker','tel: 12345','2006-06-03 14:36:02',NULL,NULL,1,NULL,'active',NULL,'2006-06-03 14:36:02');


