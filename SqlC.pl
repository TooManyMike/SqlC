#!/usr/bin/perl
use Getopt::Long;
GetOptions(
	'mfc!' => \$mfc_switch,
	'sqlite3!' => \$sqlite3_switch,
);
open(FILE_IN, "input/$ARGV[0]") or die $!;
unlink glob "output/*";
#create *.h file, write header
open(FILE_OUT_H, ">output/$ARGV[1].h") or die $!;
print FILE_OUT_H "/***\n *\n";
print FILE_OUT_H " * Author: Mike\n *\n";
print FILE_OUT_H " * Description:\n";
print FILE_OUT_H " * 1.offer mapping classes of tables\n";
print FILE_OUT_H " * 2.derive insert, update SQL sentence from object\n";
if($sqlite3_switch)
{
	print FILE_OUT_H " * 3.with SQLite3 interface\n"
}
print FILE_OUT_H " *\n";
print FILE_OUT_H " * Notice:\n";
print FILE_OUT_H " * 1.Reading a field with null value will cause the program to ABORT!!!\n";
print FILE_OUT_H " *   use IsNull_* method to check it first unless you are pretty sure that this field will never be null;\n *\n";
print FILE_OUT_H " * 2.Dropped fields won't be added in SQL sentence when conducting Add or Update method,\n";
print FILE_OUT_H " *   a field is dropped when the class object is just constucted, and be no longer dropped after assigned a value or conducting SetNull_* method.\n";
print FILE_OUT_H " *\n***/\n\n";
$MACRO = uc($ARGV[1]);
print FILE_OUT_H "#ifndef ${MACRO}_H\n";
print FILE_OUT_H "#define ${MACRO}_H\n\n";
print FILE_OUT_H "#include <string>\n";
if($sqlite3_switch)
{
	print FILE_OUT_H "#include <vector>\n";
	print FILE_OUT_H "#include \"sqlite3.h\"\n";
}
print FILE_OUT_H "\nusing namespace std;\n\n";
print FILE_OUT_H "namespace $ARGV[1]\n{\n";
#analyze input file
@lines_in = <FILE_IN>;
$inside_table = 0;
foreach $line (@lines_in)
{
	if(!$inside_table)
	{
		#find new table
		if($line =~ /create table ([`'\[]?(\w+)[`'\]]?)/i)
		{
			$table_name = $1;
			$class_name = "C_$2";
			$field_count = 0;
			$inside_table = 1;
			#write class header
			print FILE_OUT_H "\tclass $class_name\n";
			print FILE_OUT_H "\t{\n";
			print FILE_OUT_H "\tpublic:\n";
			#write declaration of constructor
			print FILE_OUT_H "\t\t$class_name();\n";
			#create *.cpp file, write header
			open(FILE_OUT_CPP, ">output/$2.cpp") or die $!;
			if($mfc_switch)
			{
				print FILE_OUT_CPP "#include \"stdafx.h\"\n";
			}
			print FILE_OUT_CPP "#include <atltime.h>\n";
			print FILE_OUT_CPP "#include <assert.h>\n";
			print FILE_OUT_CPP "#include <stdlib.h>\n";
			print FILE_OUT_CPP "#include \"$ARGV[1].h\"\n\n";
			print FILE_OUT_CPP "using namespace $ARGV[1];\n\n";
			#write defination of constructor
			print FILE_OUT_CPP "$class_name::$class_name()\n";
			print FILE_OUT_CPP "{\n";
			print FILE_OUT_CPP "\tDropAllFields();\n";
			print FILE_OUT_CPP "}\n\n";
		}
	}
	else
	{
		#find new field
		if($line =~ /\s+([`'\[]?(\w+)[`'\]]?)\s+(int(eger)?|(n)?(var)?char\(\d+\)|date(time)?|time)/i)
		{
			$field_names[$field_count] = $1;
			$member_names[$field_count] = $2;
			$field_types[$field_count] = $3;
			if($field_types[$field_count] =~ /^(var)?char\((\d+)\)/i)
			{
				$member_types[$field_count] = "string";
				$max_lens[$field_count] = $2;
			}
			elsif($field_types[$field_count] =~ /int/i)
			{
				$member_types[$field_count] = "int";
			}
			elsif($field_types[$field_count] =~ /date|time/i)
			{
				$member_types[$field_count] = "string";
			}
			if($line =~ /comment\s+'\s*(\S.*)'/i)
			{
				$field_comments[$field_count] = $1;
			}
			else
			{
				$field_comments[$field_count] = 0;
			}
			$field_count++;
		}
		#find end of the table
		if($line =~ /\)\;/)
		{
			for($i = 0; $i < $field_count; $i++)
			{
				#write Get_*() method
				print FILE_OUT_H "\t\t$member_types[$i] Get_$member_names[$i]();\n";
				print FILE_OUT_CPP "$member_types[$i] ${class_name}::Get_$member_names[$i]()\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\tassert(!$member_names[$i]_IsNull_);\n";
				print FILE_OUT_CPP "\treturn $member_names[$i]_;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write Set_*(*) method
				print FILE_OUT_H "\t\tvoid Set_$member_names[$i]($member_types[$i]);\n";
				print FILE_OUT_CPP "void ${class_name}::Set_$member_names[$i]($member_types[$i] value)\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\t$member_names[$i]_ = value;\n";
				print FILE_OUT_CPP "\t$member_names[$i]_IsNull_ = false;\n";
				print FILE_OUT_CPP "\t$member_names[$i]_IsSet_ = true;\n";
				print FILE_OUT_CPP "}\n\n";
				if($field_types[$i] =~ /date|time/i)
				{
					#write SetCurrent_*() method
					print FILE_OUT_H "\t\tvoid SetCurrent_$member_names[$i]();\n";
					print FILE_OUT_CPP "void ${class_name}::SetCurrent_$member_names[$i]()\n";
					print FILE_OUT_CPP "{\n";
					print FILE_OUT_CPP "\tSYSTEMTIME st = {0};\n";
					print FILE_OUT_CPP "\tGetLocalTime(&st);\n";
					if(lc($field_types[$i]) eq "datetime")
					{
						print FILE_OUT_CPP "\tchar sz[20];\n";
						print FILE_OUT_CPP "\tsprintf(sz, \"%04d-%02d-%02d %02d:%02d:%02d\", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);\n";
					}
					elsif(lc($field_types[$i]) eq "date")
					{
						print FILE_OUT_CPP "\tchar sz[11];\n";
						print FILE_OUT_CPP "\tsprintf(sz, \"%04d-%02d-%02d\", st.wYear, st.wMonth, st.wDay);\n";
					}
					else
					{
						print FILE_OUT_CPP "\tchar sz[9];\n";
						print FILE_OUT_CPP "\tsprintf($member_names[$i]_, \"%02d:%02d:%02d\", st.wHour, st.wMinute, st.wSecond);\n";
					}
					print FILE_OUT_CPP "\t$member_names[$i]_ = sz;\n";
					print FILE_OUT_CPP "\t$member_names[$i]_IsNull_ = false;\n";
					print FILE_OUT_CPP "\t$member_names[$i]_IsSet_ = true;\n";
					print FILE_OUT_CPP "}\n\n";
				}
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write IsNull_*() method
				print FILE_OUT_H "\t\tbool IsNull_$member_names[$i]();\n";
				print FILE_OUT_CPP "bool ${class_name}::IsNull_$member_names[$i]()\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\treturn $member_names[$i]_IsNull_;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write SetNull_*() method
				print FILE_OUT_H "\t\tvoid SetNull_$member_names[$i]();\n";
				print FILE_OUT_CPP "void ${class_name}::SetNull_$member_names[$i]()\n";
				print FILE_OUT_CPP "{\n";
				if($member_types[$i] eq "int")
				{
					print FILE_OUT_CPP "\t$member_names[$i]_ = 0;\n";
				}
				else
				{
					print FILE_OUT_CPP "\t$member_names[$i]_ = \"\";\n";
				}
				print FILE_OUT_CPP "\t$member_names[$i]_IsNull_ = true;\n";
				print FILE_OUT_CPP "\t$member_names[$i]_IsSet_ = true;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write Drop_*() method
				print FILE_OUT_H "\t\tvoid Drop_$member_names[$i]();\n";
				print FILE_OUT_CPP "void ${class_name}::Drop_$member_names[$i]()\n";
				print FILE_OUT_CPP "{\n";
				if($member_types[$i] eq "int")
				{
					print FILE_OUT_CPP "\t$member_names[$i]_ = 0;\n";
				}
				else
				{
					print FILE_OUT_CPP "\t$member_names[$i]_ = \"\";\n";
				}
				print FILE_OUT_CPP "\t$member_names[$i]_IsNull_ = true;\n";
				print FILE_OUT_CPP "\t$member_names[$i]_IsSet_ = false;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			#write DropAllFields() method
			print FILE_OUT_H "\t\tvoid DropAllFields();\n";
			print FILE_OUT_CPP "void ${class_name}::DropAllFields()\n";
			print FILE_OUT_CPP "{\n";
			for($i = 0; $i < $field_count; $i++)
			{
				print FILE_OUT_CPP "\tDrop_$member_names[$i]();\n";
			}
			print FILE_OUT_CPP "}\n\n";
			#write GetInsertSql() method
			print FILE_OUT_H "\t\tstring GetInsertSql();\n";
			print FILE_OUT_CPP "string ${class_name}::GetInsertSql()\n";
			print FILE_OUT_CPP "{\n";
			print FILE_OUT_CPP "\tstring str1 = \"insert into $table_name(\";\n";
			print FILE_OUT_CPP "\tstring str2 = \"values(\";\n";
			print FILE_OUT_CPP "\tint cnt = 0;\n";
			print FILE_OUT_CPP "\tchar sz[12];\n";
			for($i = 0; $i < $field_count; $i++)
			{
				print FILE_OUT_CPP "\tif($member_names[$i]_IsSet_)\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\tstr1 += \"$field_names[$i],\";\n";
				if($member_types[$i] eq "int")
				{
					print FILE_OUT_CPP "\t\titoa($member_names[$i]_, sz, 10);\n";
					print FILE_OUT_CPP "\t\tstr2 += sz;\n";
				}
				else
				{
					print FILE_OUT_CPP "\t\tstr2 += \"'\";\n";
					if($field_types[$i] =~ /char/i)
					{
						print FILE_OUT_CPP "\t\tstr2 += SafeString(CutString($member_names[$i]_, $member_names[$i]_MaxLen_));\n";
					}
					else
					{
						print FILE_OUT_CPP "\t\tstr2 += SafeString($member_names[$i]_);\n";
					}
					print FILE_OUT_CPP "\t\tstr2 += \"'\";\n";
				}
				print FILE_OUT_CPP "\t\tstr2 += \",\";\n";
				print FILE_OUT_CPP "\t\tcnt++;\n";
				print FILE_OUT_CPP "\t}\n";
			}
			print FILE_OUT_CPP "\tif(cnt == 0)\n";
			print FILE_OUT_CPP "\t{\n";
			print FILE_OUT_CPP "\t\treturn \"\";\n";
			print FILE_OUT_CPP "\t}\n";
			print FILE_OUT_CPP "\tstr1.erase(str1.end() - 1);\n";
			print FILE_OUT_CPP "\tstr1 += \") \";\n";
			print FILE_OUT_CPP "\tstr2.erase(str2.end() - 1);\n";
			print FILE_OUT_CPP "\tstr2 += \");\";\n";
			print FILE_OUT_CPP "\treturn str1 + str2;\n";
			print FILE_OUT_CPP "}\n\n";
			#write GetUpdateSql(char*) method
			print FILE_OUT_H "\t\tstring GetUpdateSql(char*);\n";
			print FILE_OUT_CPP "string ${class_name}::GetUpdateSql(char* condition)\n";
			print FILE_OUT_CPP "{\n";
			print FILE_OUT_CPP "\tstring sql = \"update $table_name set \";\n";
			print FILE_OUT_CPP "\tint cnt = 0;\n";
			print FILE_OUT_CPP "\tchar sz[12];\n";
			for($i = 0; $i < $field_count; $i++)
			{
				print FILE_OUT_CPP "\tif($member_names[$i]_IsSet_)\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\tsql += \"$field_names[$i]=\";\n";
				if($member_types[$i] eq "int")
				{
					print FILE_OUT_CPP "\t\titoa($member_names[$i]_, sz, 10);\n";
					print FILE_OUT_CPP "\t\tsql += sz;\n";
				}
				else
				{
					print FILE_OUT_CPP "\t\tsql += \"'\";\n";
					if($field_types[$i] =~ /char/i)
					{
						print FILE_OUT_CPP "\t\tsql += SafeString(CutString($member_names[$i]_, $member_names[$i]_MaxLen_));\n";
					}
					else
					{
						print FILE_OUT_CPP "\t\tsql += SafeString($member_names[$i]_);\n";
					}
					print FILE_OUT_CPP "\t\tsql += \"'\";\n";
				}
				print FILE_OUT_CPP "\t\tsql += \",\";\n";
				print FILE_OUT_CPP "\t\tcnt++;\n";
				print FILE_OUT_CPP "\t}\n";
			}
			print FILE_OUT_CPP "\tif(cnt == 0)\n";
			print FILE_OUT_CPP "\t{\n";
			print FILE_OUT_CPP "\t\treturn \"\";\n";
			print FILE_OUT_CPP "\t}\n";
			print FILE_OUT_CPP "\tsql.erase(sql.end() - 1);\n";
			print FILE_OUT_CPP "\tif(condition && condition[0])\n";
			print FILE_OUT_CPP "\t{\n";
			print FILE_OUT_CPP "\t\tsql += \" where \";\n";
			print FILE_OUT_CPP "\t\tsql += condition;\n";
			print FILE_OUT_CPP "\t}\n";
			print FILE_OUT_CPP "\tsql += \";\";\n";
			print FILE_OUT_CPP "\treturn sql;\n";
			print FILE_OUT_CPP "}\n\n";
			if($sqlite3_switch)
			{
				#write Add(sqlite3*) method
				print FILE_OUT_H "\t\tint Add(sqlite3*);\n";
				print FILE_OUT_CPP "int ${class_name}::Add(sqlite3* db)\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\tstring sql = GetInsertSql();\n";
				print FILE_OUT_CPP "\tif(sql == \"\")\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\treturn -1;\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\tchar* pErrMsg = NULL;\n";
				print FILE_OUT_CPP "\tint rc;\n";
				print FILE_OUT_CPP "\tdo\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\trc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);\n";
				print FILE_OUT_CPP "\t\tSleep(1);\n";
				print FILE_OUT_CPP "\t} while(rc == SQLITE_BUSY);\n";
				print FILE_OUT_CPP "\treturn rc;\n";
				print FILE_OUT_CPP "}\n\n";
				#write Update(sqlite3*, char*) method
				print FILE_OUT_H "\t\tint Update(sqlite3*, char*);\n";
				print FILE_OUT_CPP "int ${class_name}::Update(sqlite3* db, char* condition)\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\tstring sql = GetUpdateSql(condition);\n";
				print FILE_OUT_CPP "\tif(sql == \"\")\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\treturn -1;\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\tchar* pErrMsg = NULL;\n";
				print FILE_OUT_CPP "\tint rc;\n";
				print FILE_OUT_CPP "\tdo\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\trc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);\n";
				print FILE_OUT_CPP "\t\tSleep(1);\n";
				print FILE_OUT_CPP "\t} while(rc == SQLITE_BUSY);\n";
				print FILE_OUT_CPP "\treturn rc;\n";
				print FILE_OUT_CPP "}\n\n";
				#write Delete(sqlite3*, char*) method
				print FILE_OUT_H "\t\tstatic int Delete(sqlite3*, char*);\n";
				print FILE_OUT_CPP "int ${class_name}::Delete(sqlite3* db, char* condition)\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\tstring sql = \"delete from $table_name\";\n";
				print FILE_OUT_CPP "\tif(condition && condition[0])\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\tsql += \" where \";\n";
				print FILE_OUT_CPP "\t\tsql += condition;\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\tsql += \";\";\n";
				print FILE_OUT_CPP "\tchar* pErrMsg = NULL;\n";
				print FILE_OUT_CPP "\tint rc;\n";
				print FILE_OUT_CPP "\tdo\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\trc = sqlite3_exec(db, sql.c_str(), NULL, NULL, &pErrMsg);\n";
				print FILE_OUT_CPP "\t\tSleep(1);\n";
				print FILE_OUT_CPP "\t} while(rc == SQLITE_BUSY);\n";
				print FILE_OUT_CPP "\treturn rc;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write property method
				print FILE_OUT_H "\t\t_declspec(property(get = Get_$member_names[$i], put = Set_$member_names[$i]))$member_types[$i] $member_names[$i];\n";
			}
			print FILE_OUT_H "\tprivate:\n";
			for($i = 0; $i < $field_count; $i++)
			{
				#write field member
				print FILE_OUT_H "\t\t$member_types[$i] $member_names[$i]_;";
				if($field_comments[$i])
				{
					print FILE_OUT_H "\t\t//$field_comments[$i]";
				}
				print FILE_OUT_H "\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				#write field status members
				print FILE_OUT_H "\t\tbool $member_names[$i]_IsNull_;\n";
				print FILE_OUT_H "\t\tbool $member_names[$i]_IsSet_;\n";
			}
			for($i = 0; $i < $field_count; $i++)
			{
				if($field_types[$i] =~ /char/i)
				{
					#write string field max length member
					print FILE_OUT_H "\t\tstatic const int $member_names[$i]_MaxLen_ = $max_lens[$i];\n";
				}
			}
			print FILE_OUT_H "\t};\n\n";
			if($sqlite3_switch)
			{
				#write GetDataSet(sqlite3*, char*, vector<*>) method
				print FILE_OUT_H "\tint GetDataSet(vector<$class_name>*, sqlite3*, char*);\n\n";
				print FILE_OUT_CPP "int $ARGV[1]::GetDataSet(vector<$class_name>* result, sqlite3* db, char* condition)\n";
				print FILE_OUT_CPP "{\n";
				print FILE_OUT_CPP "\tresult->clear();\n";
				print FILE_OUT_CPP "\tint nRow, nCol;\n";
				print FILE_OUT_CPP "\tchar** pResult = NULL;\n";
				print FILE_OUT_CPP "\tchar* pErrMsg = NULL;\n";
				print FILE_OUT_CPP "\tstring sql = \"select * from $table_name\";\n";
				print FILE_OUT_CPP "\tif(condition && condition[0])\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\tsql += \" where \";\n";
				print FILE_OUT_CPP "\t\tsql += condition;\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\tsql += \";\";\n";


				print FILE_OUT_CPP "\tint rc;\n";
				print FILE_OUT_CPP "\tdo\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\trc = sqlite3_get_table(db, sql.c_str(), &pResult, &nRow, &nCol, &pErrMsg);\n";
				print FILE_OUT_CPP "\t\tSleep(1);\n";
				print FILE_OUT_CPP "\t} while(rc == SQLITE_BUSY);\n";
				print FILE_OUT_CPP "\tif(rc != SQLITE_OK)\n";
				print FILE_OUT_CPP "\t{\n";
				print FILE_OUT_CPP "\t\treturn rc;\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\t$class_name temp;\n";
				print FILE_OUT_CPP "\tfor(int i = 0; i < nRow; i++)\n";
				print FILE_OUT_CPP "\t{\n";
				for($i = 0; $i < $field_count; $i++)
				{
					print FILE_OUT_CPP "\t\tif(pResult[(i + 1) * nCol + $i])\n";
					print FILE_OUT_CPP "\t\t{\n";
					if($member_types[$i] eq "string")
					{
						print FILE_OUT_CPP "\t\t\ttemp.$member_names[$i] = pResult[(i + 1) * nCol + $i];\n";
					}
					else
					{
						print FILE_OUT_CPP "\t\t\ttemp.$member_names[$i] = atoi(pResult[(i + 1) * nCol + $i]);\n";
					}
					print FILE_OUT_CPP "\t\t}\n";
					print FILE_OUT_CPP "\t\telse\n";
					print FILE_OUT_CPP "\t\t{\n";
					print FILE_OUT_CPP "\t\t\ttemp.SetNull_$member_names[$i]();\n";
					print FILE_OUT_CPP "\t\t}\n";
				}
				print FILE_OUT_CPP "\t\tresult->push_back(temp);\n";
				print FILE_OUT_CPP "\t}\n";
				print FILE_OUT_CPP "\tsqlite3_free_table(pResult);\n";
				print FILE_OUT_CPP "\treturn SQLITE_OK;\n";
				print FILE_OUT_CPP "}\n\n";
			}
			$inside_table = 0;
		}
	}
}
#write SafeString(string) method
print FILE_OUT_H "\tstatic string SafeString(string str)\n";
print FILE_OUT_H "\t{\n";
print FILE_OUT_H "\t\tint pos = str.find('\\'');\n";
print FILE_OUT_H "\t\tif(pos >= 0)\n";
print FILE_OUT_H "\t\t{\n";
print FILE_OUT_H "\t\t\treturn str.substr(0, pos) + \"''\" + SafeString(str.substr(pos + 1));\n";
print FILE_OUT_H "\t\t}\n";
print FILE_OUT_H "\t\telse\n";
print FILE_OUT_H "\t\t{\n";
print FILE_OUT_H "\t\t\treturn str;\n";
print FILE_OUT_H "\t\t}\n";
print FILE_OUT_H "\t}\n\n";
#write CutString(string) method
print FILE_OUT_H "\tstatic string CutString(string str, int n)\n";
print FILE_OUT_H "\t{\n";
print FILE_OUT_H "\t\tif(str.length() <= n)\n";
print FILE_OUT_H "\t\t{\n";
print FILE_OUT_H "\t\t\treturn str;\n";
print FILE_OUT_H "\t\t}\n";
print FILE_OUT_H "\t\tbool b = false;\n";
print FILE_OUT_H "\t\tunsigned char *p = (unsigned char*)str.c_str();\n";
print FILE_OUT_H "\t\tfor(int i = 0; i < n; i++)\n";
print FILE_OUT_H "\t\t{\n";
print FILE_OUT_H "\t\t\tif(p[i] > 127)\n";
print FILE_OUT_H "\t\t\t{\n";
print FILE_OUT_H "\t\t\t\tb = !b;\n";
print FILE_OUT_H "\t\t\t}\n";
print FILE_OUT_H "\t\t}\n";
print FILE_OUT_H "\t\tif(b)\n";
print FILE_OUT_H "\t\t{\n";
print FILE_OUT_H "\t\t\treturn str.substr(0, n - 1);\n";
print FILE_OUT_H "\t\t}\n";
print FILE_OUT_H "\t\treturn str.substr(0, n);\n";
print FILE_OUT_H "\t}\n";
print FILE_OUT_H "}\n\n";
print FILE_OUT_H "#endif";