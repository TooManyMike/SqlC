create table Person
(
   Id               	int not null auto_increment comment '�û�ID������',
   UnitId		int not null comment '����ID',
   Name			varchar(10) default null comment '����',
   BirthDay		date default null comment '����',
   HireDate	 	date default null comment '��ְʱ��',
   primary key (Id)
);
alter table User comment 'Ա����Ϣ';

create table Unit
(
   Id               	int not null auto_increment comment '����ID������',
   Name			varchar(50) default null comment '��������',
   primary key (Id)
);
alter table UnitInfo comment '������Ϣ';