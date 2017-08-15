#include "stdafx.h"
#include <atltime.h>
#include <assert.h>
#include <stdlib.h>
#include "MyNameSpace.h"

using namespace MyNameSpace;

C_Person::C_Person()
{
	DropAllFields();
}

int C_Person::Get_Id()
{
	assert(!Id_IsNull_);
	return Id_;
}

int C_Person::Get_UnitId()
{
	assert(!UnitId_IsNull_);
	return UnitId_;
}

string C_Person::Get_Name()
{
	assert(!Name_IsNull_);
	return Name_;
}

string C_Person::Get_BirthDay()
{
	assert(!BirthDay_IsNull_);
	return BirthDay_;
}

string C_Person::Get_HireDate()
{
	assert(!HireDate_IsNull_);
	return HireDate_;
}

void C_Person::Set_Id(int value)
{
	Id_ = value;
	Id_IsNull_ = false;
	Id_IsSet_ = true;
}

void C_Person::Set_UnitId(int value)
{
	UnitId_ = value;
	UnitId_IsNull_ = false;
	UnitId_IsSet_ = true;
}

void C_Person::Set_Name(string value)
{
	Name_ = value;
	Name_IsNull_ = false;
	Name_IsSet_ = true;
}

void C_Person::Set_BirthDay(string value)
{
	BirthDay_ = value;
	BirthDay_IsNull_ = false;
	BirthDay_IsSet_ = true;
}

void C_Person::SetCurrent_BirthDay()
{
	SYSTEMTIME st = {0};
	GetLocalTime(&st);
	char sz[11];
	sprintf(sz, "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
	BirthDay_ = sz;
	BirthDay_IsNull_ = false;
	BirthDay_IsSet_ = true;
}

void C_Person::Set_HireDate(string value)
{
	HireDate_ = value;
	HireDate_IsNull_ = false;
	HireDate_IsSet_ = true;
}

void C_Person::SetCurrent_HireDate()
{
	SYSTEMTIME st = {0};
	GetLocalTime(&st);
	char sz[11];
	sprintf(sz, "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
	HireDate_ = sz;
	HireDate_IsNull_ = false;
	HireDate_IsSet_ = true;
}

bool C_Person::IsNull_Id()
{
	return Id_IsNull_;
}

bool C_Person::IsNull_UnitId()
{
	return UnitId_IsNull_;
}

bool C_Person::IsNull_Name()
{
	return Name_IsNull_;
}

bool C_Person::IsNull_BirthDay()
{
	return BirthDay_IsNull_;
}

bool C_Person::IsNull_HireDate()
{
	return HireDate_IsNull_;
}

void C_Person::SetNull_Id()
{
	Id_ = 0;
	Id_IsNull_ = true;
	Id_IsSet_ = true;
}

void C_Person::SetNull_UnitId()
{
	UnitId_ = 0;
	UnitId_IsNull_ = true;
	UnitId_IsSet_ = true;
}

void C_Person::SetNull_Name()
{
	Name_ = "";
	Name_IsNull_ = true;
	Name_IsSet_ = true;
}

void C_Person::SetNull_BirthDay()
{
	BirthDay_ = "";
	BirthDay_IsNull_ = true;
	BirthDay_IsSet_ = true;
}

void C_Person::SetNull_HireDate()
{
	HireDate_ = "";
	HireDate_IsNull_ = true;
	HireDate_IsSet_ = true;
}

void C_Person::Drop_Id()
{
	Id_ = 0;
	Id_IsNull_ = true;
	Id_IsSet_ = false;
}

void C_Person::Drop_UnitId()
{
	UnitId_ = 0;
	UnitId_IsNull_ = true;
	UnitId_IsSet_ = false;
}

void C_Person::Drop_Name()
{
	Name_ = "";
	Name_IsNull_ = true;
	Name_IsSet_ = false;
}

void C_Person::Drop_BirthDay()
{
	BirthDay_ = "";
	BirthDay_IsNull_ = true;
	BirthDay_IsSet_ = false;
}

void C_Person::Drop_HireDate()
{
	HireDate_ = "";
	HireDate_IsNull_ = true;
	HireDate_IsSet_ = false;
}

void C_Person::DropAllFields()
{
	Drop_Id();
	Drop_UnitId();
	Drop_Name();
	Drop_BirthDay();
	Drop_HireDate();
}

string C_Person::GetInsertSql()
{
	string str1 = "insert into Person(";
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
	if(UnitId_IsSet_)
	{
		str1 += "UnitId,";
		itoa(UnitId_, sz, 10);
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
	if(BirthDay_IsSet_)
	{
		str1 += "BirthDay,";
		str2 += "'";
		str2 += SafeString(BirthDay_);
		str2 += "'";
		str2 += ",";
		cnt++;
	}
	if(HireDate_IsSet_)
	{
		str1 += "HireDate,";
		str2 += "'";
		str2 += SafeString(HireDate_);
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

string C_Person::GetUpdateSql(char* condition)
{
	string sql = "update Person set ";
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
	if(UnitId_IsSet_)
	{
		sql += "UnitId=";
		itoa(UnitId_, sz, 10);
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
	if(BirthDay_IsSet_)
	{
		sql += "BirthDay=";
		sql += "'";
		sql += SafeString(BirthDay_);
		sql += "'";
		sql += ",";
		cnt++;
	}
	if(HireDate_IsSet_)
	{
		sql += "HireDate=";
		sql += "'";
		sql += SafeString(HireDate_);
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

int C_Person::Add(sqlite3* db)
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

int C_Person::Update(sqlite3* db, char* condition)
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

int C_Person::Delete(sqlite3* db, char* condition)
{
	string sql = "delete from Person";
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

int MyNameSpace::GetDataSet(vector<C_Person>* result, sqlite3* db, char* condition)
{
	result->clear();
	int nRow, nCol;
	char** pResult = NULL;
	char* pErrMsg = NULL;
	string sql = "select * from Person";
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
	C_Person temp;
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
			temp.UnitId = atoi(pResult[(i + 1) * nCol + 1]);
		}
		else
		{
			temp.SetNull_UnitId();
		}
		if(pResult[(i + 1) * nCol + 2])
		{
			temp.Name = pResult[(i + 1) * nCol + 2];
		}
		else
		{
			temp.SetNull_Name();
		}
		if(pResult[(i + 1) * nCol + 3])
		{
			temp.BirthDay = pResult[(i + 1) * nCol + 3];
		}
		else
		{
			temp.SetNull_BirthDay();
		}
		if(pResult[(i + 1) * nCol + 4])
		{
			temp.HireDate = pResult[(i + 1) * nCol + 4];
		}
		else
		{
			temp.SetNull_HireDate();
		}
		result->push_back(temp);
	}
	sqlite3_free_table(pResult);
	return SQLITE_OK;
}

