#include "stdafx.h"
#include <atltime.h>
#include <assert.h>
#include <stdlib.h>
#include "MyNameSpace.h"

using namespace MyNameSpace;

C_Unit::C_Unit()
{
	DropAllFields();
}

int C_Unit::Get_Id()
{
	assert(!Id_IsNull_);
	return Id_;
}

string C_Unit::Get_Name()
{
	assert(!Name_IsNull_);
	return Name_;
}

void C_Unit::Set_Id(int value)
{
	Id_ = value;
	Id_IsNull_ = false;
	Id_IsSet_ = true;
}

void C_Unit::Set_Name(string value)
{
	Name_ = value;
	Name_IsNull_ = false;
	Name_IsSet_ = true;
}

bool C_Unit::IsNull_Id()
{
	return Id_IsNull_;
}

bool C_Unit::IsNull_Name()
{
	return Name_IsNull_;
}

void C_Unit::SetNull_Id()
{
	Id_ = 0;
	Id_IsNull_ = true;
	Id_IsSet_ = true;
}

void C_Unit::SetNull_Name()
{
	Name_ = "";
	Name_IsNull_ = true;
	Name_IsSet_ = true;
}

void C_Unit::Drop_Id()
{
	Id_ = 0;
	Id_IsNull_ = true;
	Id_IsSet_ = false;
}

void C_Unit::Drop_Name()
{
	Name_ = "";
	Name_IsNull_ = true;
	Name_IsSet_ = false;
}

void C_Unit::DropAllFields()
{
	Drop_Id();
	Drop_Name();
}

string C_Unit::GetInsertSql()
{
	string str1 = "insert into Unit(";
	string str2 = "values(";
	int cnt = 0;
	char sz[12];
	if(Id_IsSet_)
	{
		str1 += "Id,";
		itoa(Id_, sz, 10);
		str2 += sz;
		str2 += ",";
		cnt++;
	}
	if(Name_IsSet_)
	{
		str1 += "Name,";
		str2 += "'";
		str2 += SafeString(CutString(Name_, Name_MaxLen_));
		str2 += "'";
		str2 += ",";
		cnt++;
	}
	if(cnt == 0)
	{
		return "";
	}
	str1.erase(str1.end() - 1);
	str1 += ") ";
	str2.erase(str2.end() - 1);
	str2 += ");";
	return str1 + str2;
}

string C_Unit::GetUpdateSql(char* condition)
{
	string sql = "update Unit set ";
	int cnt = 0;
	char sz[12];
	if(Id_IsSet_)
	{
		sql += "Id=";
		itoa(Id_, sz, 10);
		sql += sz;
		sql += ",";
		cnt++;
	}
	if(Name_IsSet_)
	{
		sql += "Name=";
		sql += "'";
		sql += SafeString(CutString(Name_, Name_MaxLen_));
		sql += "'";
		sql += ",";
		cnt++;
	}
	if(cnt == 0)
	{
		return "";
	}
	sql.erase(sql.end() - 1);
	if(condition && condition[0])
	{
		sql += " where ";
		sql += condition;
	}
	sql += ";";
	return sql;
}

int C_Unit::Add(sqlite3* db)
{
	string sql = GetInsertSql();
	if(sql == "")
	{
		return -1;
	}
	char* pErrMsg = NULL;
	int rc;
	do
	{
		rc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);
		Sleep(1);
	} while(rc == SQLITE_BUSY);
	return rc;
}

int C_Unit::Update(sqlite3* db, char* condition)
{
	string sql = GetUpdateSql(condition);
	if(sql == "")
	{
		return -1;
	}
	char* pErrMsg = NULL;
	int rc;
	do
	{
		rc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);
		Sleep(1);
	} while(rc == SQLITE_BUSY);
	return rc;
}

int C_Unit::Delete(sqlite3* db, char* condition)
{
	string sql = "delete from Unit";
	if(condition && condition[0])
	{
		sql += " where ";
		sql += condition;
	}
	sql += ";";
	char* pErrMsg = NULL;
	int rc;
	do
	{
		rc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);
		Sleep(1);
	} while(rc == SQLITE_BUSY);
	return rc;
}

int MyNameSpace::GetDataSet(vector<C_Unit>* result, sqlite3* db, char* condition)
{
	result->clear();
	int nRow, nCol;
	char** pResult = NULL;
	char* pErrMsg = NULL;
	string sql = "select * from Unit";
	if(condition && condition[0])
	{
		sql += " where ";
		sql += condition;
	}
	sql += ";";
	int rc;
	do
	{
		rc = sqlite3_get_table(db, sql.c_str(), &pResult, &nRow, &nCol, &pErrMsg);
		Sleep(1);
	} while(rc == SQLITE_BUSY);
	if(rc != SQLITE_OK)
	{
		return rc;
	}
	C_Unit temp;
	for(int i = 0; i < nRow; i++)
	{
		if(pResult[(i + 1) * nCol + 0])
		{
			temp.Id = atoi(pResult[(i + 1) * nCol + 0]);
		}
		else
		{
			temp.SetNull_Id();
		}
		if(pResult[(i + 1) * nCol + 1])
		{
			temp.Name = pResult[(i + 1) * nCol + 1];
		}
		else
		{
			temp.SetNull_Name();
		}
		result->push_back(temp);
	}
	sqlite3_free_table(pResult);
	return SQLITE_OK;
}

