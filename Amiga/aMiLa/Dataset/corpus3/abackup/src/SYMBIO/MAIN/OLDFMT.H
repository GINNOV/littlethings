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
/*  _______________________________________________________________________

    ABackup 5.0
    oldfmt.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 23-Sep-93
    Modified: 26-Nov-93
    _______________________________________________________________________
*/

#ifndef ABACKUP_OLDFMT_H
#define ABACKUP_OLDFMT_H

/* various area sizes */

#define OLD_XPKLEN	6
#define OLD_MINNAME	32
#define OLD_MAXNOTE	80
#define OLD_MAXNAME	256
#define OLD_MAXHEAD	512

/* device definition */

struct OldDeviceDef
{
  LONG		  d_unit;			/* exec unit number	    */
  BYTE		  d_name[OLD_MINNAME+1];	/* device name		    */
  LONG		  d_openf;			/* flags for OpenDevice()   */
  struct DosEnvec d_env;			/* private copy of DosEnvec */
};

/* object definition */

struct OldObject
{
  struct OldObject     *o_suiv;
  struct OldObject     *o_pere;
  struct OldObject     *o_fils; 	/* ptr to OldDeviceDef for devices */
  LONG			o_flags;
  LONG			o_size; 	/* number of childs for directory  */
  LONG			o_bits;
  struct DateStamp	o_date;
  BYTE			o_name[OLD_MINNAME+2];
};

/* header definition */

struct OldHeader
{
  LONG		   th_idnt1;
  LONG		   th_type;
  LONG		   th_idnt2;
  struct OldObject th_obj;
  /* for HT_NDOS, the following field is used to save the MyDeviceDef struct */
  BYTE		   th_fname[OLD_MAXNAME+1];
  BYTE		   th_comment[OLD_MAXNOTE+1];
  LONG		   th_dsknum;
  LONG		   th_catalog;	/* 1st catalog sector, -1 on all disks but the last */
  /* the rest is used only for files */
  LONG		   th_seqnum;			/* for HT_FILEX/NDOSX	    */
  LONG		   th_ssize;			/* saved file size	    */
  LONG		   th_ctype;			/* compression type	    */
  BYTE		   th_method[OLD_XPKLEN];	/* compression method (XPK) */
  LONG		   th_version;			/* ABackup version	    */
  BYTE		   pad[58];
  LONG		   th_crypt;			/* Checksum if crypted	    */
};

/* old header mark (th_idnt fields) */

#define OLD_IDNT	MAKE_ID( 'A','B','C','K' )

/* catalog definition */

struct OldCatalog
{
  struct OldObject c_obj;
  LONG		   c_disk;
  LONG		   c_offset;
  BYTE		   c_name[1];
};

#endif	// ABACKUP_OLDFMT_H
