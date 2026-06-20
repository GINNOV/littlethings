/*
 *  ppui/osinterface/amiga/PPPath_Amiga.cpp
 *
 *  Copyright 2020 neoman
 *
 *  This file is part of Milkytracker.
 *
 *  Milkytracker is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Milkytracker is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Milkytracker.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "PPPath_Amiga.h"

#define PPMAX_DIR_PATH 1024

static BPTR currentDirLock = 0;

extern BPTR GetProgramDirLock();

void PPPathEntry_Amiga::createDosDevice(const PPSystemString& dosDevice)
{
    this->name = dosDevice;
    this->name.append(":");
    this->type = Directory;
    this->size = 0;
}

void PPPathEntry_Amiga::create(const PPSystemString& path, const PPSystemString& name)
{
    BPTR lock;
    char dirname[PPMAX_DIR_PATH + 1];

	this->name = name;
    this->type = Nonexistent;

    strcpy(dirname, path.getStrBuffer());

    if(AddPart(dirname, name.getStrBuffer(), PPMAX_DIR_PATH)) {
        if((lock = Lock(dirname, SHARED_LOCK)) != 0) {
            struct FileInfoBlock * fib;

            if((fib = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, TAG_END))) {
                if(Examine(lock, fib)) {
                    if(fib->fib_DirEntryType < 0) {
                        type = File;
                        size = fib->fib_Size;
                    } else {
                        type = Directory;
                        size = 0;
                    }
                }

                FreeDosObject(DOS_FIB, fib);
            }

            UnLock(lock);
        }
    }
}

PPPath_Amiga::PPPath_Amiga()
: dirLock(0)
, dirFIB(NULL)
, isDosList(false)
, dosList(NULL)
{
	current = getCurrent();
    updatePath();
}

PPPath_Amiga::PPPath_Amiga(const PPSystemString& path)
: dirLock(0)
, dirFIB(NULL)
, isDosList(false)
, dosList(NULL)
, current(path)
{
    updatePath();
}

bool PPPath_Amiga::updatePath()
{
    if(currentDirLock && currentDirLock != GetProgramDirLock()) {
        UnLock(currentDirLock);
    }

    if(current.length() == 0) {
        currentDirLock = GetProgramDirLock();
        current = getCurrent();
    } else {
        if(!(currentDirLock = Lock(current.getStrBuffer(), SHARED_LOCK))) {
            return false;
        }
    }

    return true;
}

const PPSystemString PPPath_Amiga::getCurrent()
{
	STRPTR cwd = (STRPTR) AllocMem(PPMAX_DIR_PATH+1, MEMF_CLEAR);
  	PPSystemString path;

    if(!currentDirLock) {
        currentDirLock = GetProgramDirLock();
    }

    if(NameFromLock(currentDirLock, cwd, PPMAX_DIR_PATH)) {
        path = cwd;
    } else {
        path = "PROGDIR:";
    }

    if(path[strlen(path)-1] != ':') {
        path.ensureTrailingCharacter(getPathSeparatorAsASCII());
    }

	return path;
}

bool PPPath_Amiga::change(const PPSystemString& path)
{
    PPSystemString old = current;
	current = path;

	bool res = updatePath();
	if (res)
		return true;

	current = old;
	return false;
}

bool PPPath_Amiga::stepInto(const PPSystemString& directory)
{
	PPSystemString old = current;

    char dirname[PPMAX_DIR_PATH + 1];
    strcpy(dirname, current.getStrBuffer());

    if(AddPart(dirname, directory.getStrBuffer(), PPMAX_DIR_PATH)) {
        PPSystemString newdir(dirname);
        if(change(newdir))
            return true;
    }

	return false;
}

const PPPathEntry* PPPath_Amiga::getFirstEntry()
{
    if(isDosList) {
        dosList = LockDosList(LDF_VOLUMES | LDF_READ);
        return getNextEntry();
    }

    if((dirLock = Lock(current.getStrBuffer(), SHARED_LOCK)) != 0) {
        if((dirFIB = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, TAG_END))) {
            if(Examine(dirLock, dirFIB)) {
                if(dirFIB->fib_DirEntryType > 0) {
                    return getNextEntry();
                }
            }
            FreeDosObject(DOS_FIB, dirFIB);
            dirFIB = NULL;
        }
        UnLock(dirLock);
        dirLock = 0;
    }

    return NULL;
}

const PPPathEntry* PPPath_Amiga::getNextEntry()
{
    if(isDosList) {
		dosList = NextDosEntry(dosList, LDF_VOLUMES);
        if(dosList != NULL) {
            char dname[256] = {0};

            // Decode BCPL string (sigh)
            char * str = (char *) (dosList->dol_Name * 4);
            char len = str[0];
            memcpy(dname, str+1, len);
            dname[len] = '\0';

            PPSystemString device(dname);

            this->entry.createDosDevice(device);

            return &this->entry;
        }
        UnLockDosList(LDF_VOLUMES | LDF_READ);
        dosList = NULL;
        isDosList = false;
    } else {
        if(dirLock && dirFIB) {
            LONG ret = ExNext(dirLock, dirFIB);
            if(ret) {
                PPSystemString file(dirFIB->fib_FileName);

                this->entry.create(current, file);

                return &this->entry;
            } else {
                FreeDosObject(DOS_FIB, dirFIB);
                dirFIB = NULL;

                UnLock(dirLock);
                dirLock = 0;
            }
        }
    }

    return NULL;
}

bool PPPath_Amiga::canGotoHome() const
{
	return currentDirLock != GetProgramDirLock();
}

void PPPath_Amiga::gotoHome()
{
    currentDirLock = GetProgramDirLock();
    current = getCurrent();
}

bool PPPath_Amiga::canGotoRoot() const
{
	return true;
}

void PPPath_Amiga::gotoRoot()
{
    isDosList = true;
}

bool PPPath_Amiga::canGotoParent() const
{
	return true;
}

void PPPath_Amiga::gotoParent()
{
    if(isRootDirectory()) {
        isDosList = true;
    } else {
        currentDirLock = ParentDir(currentDirLock);
        current = getCurrent();
    }
}

char PPPath_Amiga::getPathSeparatorAsASCII() const
{
	return '/';
}

const PPSystemString PPPath_Amiga::getPathSeparator() const
{
	return PPSystemString(getPathSeparatorAsASCII());
}

bool PPPath_Amiga::fileExists(const PPSystemString& fileName) const
{
	return false;
}

bool PPPath_Amiga::isRootDirectory() const
{
    return current.charAt(current.length() - 1) == ':';
}
