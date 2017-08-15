/***
 *
 * Author: Mike
 *
 * Description:
 * 1.offer mapping classes of tables
 * 2.derive insert, update SQL sentence from object
 * 3.with SQLite3 interface
 *
 * Notice:
 * 1.Reading a field with null value will cause the program to ABORT!!!
 *   use IsNull_* method to check it first unless you are pretty sure that this field will never be null;
 *
 * 2.Dropped fields won't be added in SQL sentence when conducting Add or Update method,
 *   a field is dropped when the class object is just constucted, and be no longer dropped after assigned a value or conducting SetNull_* method.
 *
***/

#ifndef MYNAMESPACE_H
#define MYNAMESPACE_H

#include <string>
#include <vector>
#include "sqlite3.h"

using namespace std;

namespace MyNameSpace
{
	class C_Person
	{
	public:
		C_Person();
		int Get_Id();
		int Get_UnitId();
		string Get_Name();
		string Get_BirthDay();
		string Get_HireDate();
		void Set_Id(int);
		void Set_UnitId(int);
		void Set_Name(string);
		void Set_BirthDay(string);
		void SetCurrent_BirthDay();
		void Set_HireDate(string);
		void SetCurrent_HireDate();
		bool IsNull_Id();
		bool IsNull_UnitId();
		bool IsNull_Name();
		bool IsNull_BirthDay();
		bool IsNull_HireDate();
		void SetNull_Id();
		void SetNull_UnitId();
		void SetNull_Name();
		void SetNull_BirthDay();
		void SetNull_HireDate();
		void Drop_Id();
		void Drop_UnitId();
		void Drop_Name();
		void Drop_BirthDay();
		void Drop_HireDate();
		void DropAllFields();
		string GetInsertSql();
		string GetUpdateSql(char*);
		int Add(sqlite3*);
		int Update(sqlite3*, char*);
		static int Delete(sqlite3*, char*);
		_declspec(property(get = Get_Id, put = Set_Id))int Id;
		_declspec(property(get = Get_UnitId, put = Set_UnitId))int UnitId;
		_declspec(property(get = Get_Name, put = Set_Name))string Name;
		_declspec(property(get = Get_BirthDay, put = Set_BirthDay))string BirthDay;
		_declspec(property(get = Get_HireDate, put = Set_HireDate))string HireDate;
	private:
		int Id_;		//用户ID，自增
		int UnitId_;		//部门ID
		string Name_;		//姓名
		string BirthDay_;		//生日
		string HireDate_;		//入职时间
		bool Id_IsNull_;
		bool Id_IsSet_;
		bool UnitId_IsNull_;
		bool UnitId_IsSet_;
		bool Name_IsNull_;
		bool Name_IsSet_;
		bool BirthDay_IsNull_;
		bool BirthDay_IsSet_;
		bool HireDate_IsNull_;
		bool HireDate_IsSet_;
		static const int Name_MaxLen_ = 10;
	};

	int GetDataSet(vector<C_Person>*, sqlite3*, char*);

	class C_Unit
	{
	public:
		C_Unit();
		int Get_Id();
		string Get_Name();
		void Set_Id(int);
		void Set_Name(string);
		bool IsNull_Id();
		bool IsNull_Name();
		void SetNull_Id();
		void SetNull_Name();
		void Drop_Id();
		void Drop_Name();
		void DropAllFields();
		string GetInsertSql();
		string GetUpdateSql(char*);
		int Add(sqlite3*);
		int Update(sqlite3*, char*);
		static int Delete(sqlite3*, char*);
		_declspec(property(get = Get_Id, put = Set_Id))int Id;
		_declspec(property(get = Get_Name, put = Set_Name))string Name;
	private:
		int Id_;		//部门ID，自增
		string Name_;		//部门名称
		bool Id_IsNull_;
		bool Id_IsSet_;
		bool Name_IsNull_;
		bool Name_IsSet_;
		static const int Name_MaxLen_ = 50;
	};

	int GetDataSet(vector<C_Unit>*, sqlite3*, char*);

	static string SafeString(string str)
	{
		int pos = str.find('\'');
		if(pos >= 0)
		{
			return str.substr(0, pos) + "''" + SafeString(str.substr(pos + 1));
		}
		else
		{
			return str;
		}
	}

	static string CutString(string str, int n)
	{
		if(str.length() <= n)
		{
			return str;
		}
		bool b = false;
		unsigned char *p = (unsigned char*)str.c_str();
		for(int i = 0; i < n; i++)
		{
			if(p[i] > 127)
			{
				b = !b;
			}
		}
		if(b)
		{
			return str.substr(0, n - 1);
		}
		return str.substr(0, n);
	}
}

#endif