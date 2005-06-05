\connect tracks;

drop table contexts;
create table contexts (
  id serial not null,
  name varchar(255) not null default '',
  hide int not null default 0,
  position int NOT  NULL,
  primary key (id)
);

-- Set the sequence to the proper value
select setval('contexts_id_seq', (select max(id) from contexts));


drop table projects;
create table projects (
  id serial not null,
  name varchar(255) not null default '',
  position int NOT  NULL,
  done int not null default 0,
  primary key (id)
);

-- Set the sequence to the proper value
select setval('projects_id_seq', (select max(id) from projects));

drop table todos;
create table todos (
  id serial not null,
  context_id int not null default 0,
  description varchar(100) not null default '',
  notes text,
  done int not null default 0,
  created timestamp not null default now(),
  due date default null,
  completed timestamp default null,
  project_id int default null,
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