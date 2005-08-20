-- NB: This schema should be redundant, and is just included for reference. If you are
-- using Postgresql, you can just issue the following commands at your command prompt to create
-- the tables in the database you've specified in db/database.yml:
--
-- cd /PATH/TO/TRACKS
-- rake migrate

\connect tracks;

drop table contexts;
create table contexts (
  id serial not null,
  name varchar(255) not null default '',
  hide int not null default 0,
  position int not null,
  user_id int not null default 1,
  primary key (id)
);

-- Set the sequence to the proper value
select setval('contexts_id_seq', (select max(id) from contexts));


drop table projects;
create table projects (
  id serial not null,
  name varchar(255) not null default '',
  position int not null,
  done int not null default 0,
  user_id int not null default 1,
  description varchar(255) default '',
  primary key (id)
);

-- Set the sequence to the proper value
select setval('projects_id_seq', (select max(id) from projects));

create table schema_info (
    version int default null
);

drop table todos;
create table todos (
  id serial not null,
  context_id int not null default 0,
  description varchar(100) not null default '',
  notes text,
  done int not null default 0,
  created_at timestamp not null default now(),
  due date default null,
  completed timestamp default null,
  project_id int default null,
  user_id int not null default 1,  
  primary key (id)
);

-- Set the sequence to the proper value
select setval('todos_id_seq', (select max(id) from todos));

drop table users;
create table users (
  id serial not null,
  login varchar(80) default null,
  password varchar(40) default null,
  word varchar(255) default null,
  is_admin int not null default 0,
  primary key (id)
);

-- Set the sequence to the proper value
select setval('users_id_seq', (select max(id) from users));

create table notes (
  id serial not null,
  project_id int not null default 0,
  body text,
  created_at timestamp default null,
  updated_at timestamp default null,
  user_id int not null default 1,
  primary key (id)
);

-- Set the sequence to the proper value
select setval('notes_id_seq', (select max(id) from notes));