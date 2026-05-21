* PdaLink -- Connect Palm with Amiga
*
* Copyright (C) 1998-2010 Richard "Shred" Körber
*   http://pdalink.shredzone.org
*
* This library is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation, either
* version 3 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library.  If not, see <http://www.gnu.org/licenses/>.


**
* Assembler Headings
*
* @author Richard "Shred" Körber
*

		IFND    PL_LIB_I
PL_LIB_I        SET     -1

		INCLUDE exec/libraries.i
		INCLUDE exec/lists.i
		INCLUDE exec/nodes.i


*--- REVISION CONTROL SYSTEM -------------------------------------------*

VERSION         EQU     2
REVISION        EQU     2
VSTRING         MACRO
		dc.b    'pdalink 2.2 (26.03.2010)',13,10,0
		ENDM
VERS            MACRO
		dc.b    'pdalink 2.2 (26.03.2010)'
		ENDM
PRGNAME         MACRO
		dc.b    'pdalink.library'
		ENDM

*--- REVISION CONTROL SYSTEM -------------------------------------------*

		rsreset                 ;PdaLink Base
plb_Library     rs.b    LIB_SIZE        ;Library-Node
plb_Flags       rs.w    1               ; Flags
plb_SysLib      rs.l    1               ; ^SysBase
plb_SegList     rs.l    1               ; ^SegBase
plb_SIZEOF      rs.w    0

PLLB_DELEXP     EQU     0               ;Delay expire
PLLF_DELEXP     EQU     1<<PLLB_DELEXP

		ENDC

*************************************************************************

*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
