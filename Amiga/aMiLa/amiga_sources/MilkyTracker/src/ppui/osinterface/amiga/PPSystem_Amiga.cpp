/*
 *  ppui/osinterface/amiga/PPSystem_Amiga.cpp
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


#include "PPSystem_Amiga.h"

extern "C" void usleep(unsigned long microseconds);

SYSCHAR System::buffer[108+1];

const SYSCHAR* System::getTempFileName()
{
    strcpy(buffer, "RAM:milkytracker.tmp");
	return buffer;
}

const SYSCHAR* System::getConfigFileName()
{
    strcpy(buffer, "ENVARC:milkytracker.cfg");
	return buffer;
}

void System::msleep(int msecs)
{
	if (msecs < 0)
		return;
	usleep(msecs*1000);
}
