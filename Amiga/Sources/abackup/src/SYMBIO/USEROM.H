/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
// SAS functions replacement:
#define getcwd(buf,len)			GetCurrentDirName(buf,len)
#define memcpy(dest,source,size)	CopyMem(source,dest,size)
#define remove(name)			DeleteFile(name)
#define stricmp				Stricmp
#define strnicmp			Strnicmp

#define chdir(name)			ChDir(name)
