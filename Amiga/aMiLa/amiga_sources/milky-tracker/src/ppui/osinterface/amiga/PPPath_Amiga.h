/*
 *  ppui/osinterface/amiga/PPPath_Amiga.h
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

#ifndef __PPPATH_AMIGA_H__
#define __PPPATH_AMIGA_H__

#include "PPPath.h"

#include <proto/exec.h>
#include <proto/dos.h>

class PPPathEntry_Amiga : public PPPathEntry
{
public:
	PPPathEntry_Amiga() { }

	virtual void create(const PPSystemString& path, const PPSystemString& name);
    virtual void createDosDevice(const PPSystemString& dosDevice);
};

class PPPath_Amiga : public PPPath
{
protected:
	PPSystemString current;
	PPPathEntry_Amiga entry;
    BPTR dirLock;
    struct FileInfoBlock * dirFIB;
    struct DosList * dosList;
    bool isDosList;

    virtual bool isRootDirectory() const;
	virtual bool updatePath();
public:
	PPPath_Amiga();
	PPPath_Amiga(const PPSystemString& path);
	virtual ~PPPath_Amiga() {}

	virtual const PPSystemString getCurrent();

	virtual bool change(const PPSystemString& path);
	virtual bool stepInto(const PPSystemString& directory);

	virtual const PPPathEntry* getFirstEntry();
	virtual const PPPathEntry* getNextEntry();

	virtual bool canGotoHome() const;
	virtual void gotoHome();
	virtual bool canGotoRoot() const;
	virtual void gotoRoot();
	virtual bool canGotoParent() const;
	virtual void gotoParent();

	virtual char getPathSeparatorAsASCII() const;
	virtual const PPSystemString getPathSeparator() const;

	virtual bool fileExists(const PPSystemString& fileName) const;
};

#endif

