/*
 *  tracker/amiga/Amiga_KeyTranslation.h
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

#ifndef TRACKER_AMIGA_KEYTRANSLATION_H
#define TRACKER_AMIGA_KEYTRANSLATION_H

#include "BasicTypes.h"

struct AmigaKeyInputData {
    pp_uint16 code;
    pp_uint16 qual;
    pp_int16  sym;
};

pp_uint16 toVK(const AmigaKeyInputData& key);
pp_uint16 toSC(const AmigaKeyInputData& key);

#endif
