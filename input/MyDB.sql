create table Person
(
   Id               	int not null auto_increment comment '用户ID，自增',
   UnitId		int not null comment '部门ID',
   Name			varchar(10) default null comment '姓名',
   BirthDay		date default null comment '生日',
   HireDate	 	date default null comment '入职时间',
   primary key (Id)
);
alter table User comment '员工信息';

create table Unit
(
   Id               	int not null auto_increment comment '部门ID，自增',
   Name			varchar(50) default null comment '部门名称',
   primary key (Id)
);
alter table UnitInfo comment '部门信息';