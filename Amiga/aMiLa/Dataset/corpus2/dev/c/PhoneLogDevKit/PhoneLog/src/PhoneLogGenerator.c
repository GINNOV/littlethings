/* Copyright © 1996 Kai Hofmann. All rights reserved.
******* PhoneLog/--history-- ************************************************
*
*   NAME
*	history -- This is the development history of the PhoneLog library
*
*   VERSION
*	$VER: PhoneLog 1.2 (03.05.96)
*
*   HISTORY
*	18.02.1996 -	Concept
*	19.02.1996 -	Implementation
*	05.03.1996 -	Writing Autodocs
*	06.03.1996 -	Improving generator and parser
*	07.03.1996 -	Wrinting Autodocs and improvements for the parser
*	15.03.1996 -	Fixing bugs - now the date/time-format is in
*			correct ISO8601 format
*			closing SGML element now correctly using '/' instead
*			of '\'
*			Better scanner - now supports empty elements
*			Changed SGML DTD - HOSTNAME ist now optional
*			Parser now initialize and insert entry and mark
*			correctly
*			Parser now checks strings for length limitation
*	03.05.1996 -	Support for busy and unanswered calls added
*
*****************************************************************************
*
*
*/

/*
******* PhoneLog/--release-- ************************************************
*
*   NAME
*	release -- This is the release history of the PhoneLog library
*
*   RELEASE
*	08.03.1996 : V1.0 -	First release on Aminet
*	15.03.1996 : v1.1 -	Second Aminet release
*	07.05.1996 : V1.2 -	Third Aminet release
*
*****************************************************************************
*
*
*/

/*
******* PhoneLog/--todo-- ***************************************************
*
*   NAME
*	todo -- This is the 'To-Do' list of the PhoneLog library
*
*   TODO
*	Nothing at the moment
*
*****************************************************************************
*
*
*/

/*
******* PhoneLog/--announce-- ***********************************************
*
*   TITLE
*	PhoneLog Developer Kit
*
*   VERSION
*	1.2
*
*   RELEASE DATE
*	07.05.1996
*
*   AUTHOR
*	Kai Hofmann (i07m@zfn.uni-bremen.de)
*	            (http://www.informatik.uni-bremen.de/~i07m)
*
*   DESCRIPTION
*	It seems that there was no standard for log files that are used to
*	log modem connections etc. As you can see programs like PhoneBill
*	(by Raymond Penners) support very much different log file formats.
*	So I decided to create a standard based on SGML (Standard Generalized
*	Markup Language) which is defined in ISO8879 and on ISO8601 which
*	defines date/time representations.
*	SGML uses the ASCII characterset as base, so it can be used on every
*	platform. On the other hand SGML gives the log file a real structure
*	that is defined by the DTD (Document Type Definition).
*	The advantage of using SGML is that these log files have a structure,
*	so they can be easily interchanged with other SGML applications like
*	databases, wordprocessors or calculation software.
*	By supporting this standard with your software you give the user the
*	possibility to create or evaluate log files with software from
*	different platforms; and you get a standard that is easily extended
*	should a need occur.
*	To make this standard widely used, I provide a generator and a parser
*	for this log file standard for free!
*
*   NEW FEATURES
*	- Support for busy and unanswered calls added
*
*   SPECIAL REQUIREMENTS
*	ANSI-C or/and C++ Compiler.
*
*   AVAILABILITY
*	ftp://wuarchive.wustl.edu/pub/aminet/dev/c/PhoneLogDevKit.lha
*	And all other Aminet sites.
*
*   PRICE
*	This is Giftware!
*
*	You "must" send me a full version of your product at no cost
*	including free updates!
*
*   DISTRIBUTION
*	You can copy and distribute this source code as long as you do not
*	take more than $5 for one disk or $40 for one CD!
*
*****************************************************************************
*
*
*/

/*
******* PhoneLog/--compiling-- **********************************************
*
*   NAME
*	compiling -- Specials for compiling the PhoneLog library
*
*   COMPILING
*	- You could compile this code as normal C or as C++
*	- You need only the follwoing files to include:
*	  PhoneLog.h, PhoneLogGenerator.h, PhoneLogParserInterface.h
*	  If you want to modifiy the scanner and/or parser, you need the
*	  following software: Aminet:dev/misc/Toolbox.lha to translate the
*	  .rex and .lalr file into C code!
*
*****************************************************************************
*
*
*/

/*
******* PhoneLog/--background-- *********************************************
*
*   NAME
*	PhoneLog -- Write and read entries to/from a log file (V33)
*
*   FUNCTION
*	This module has been designed to become a useful and portable library
*	and to help developers to write and read entries to/from a log file
*	in a standard SGML format.
*
*   NOTES
*	It seems that there was no standard for log files that are used to
*	log modem connections etc. As you can see programs like PhoneBill
*	(by Raymond Penners) support very much different log file formats.
*	So I decided to create a standard based on SGML (Standard Generalized
*	Markup Language) which is defined in ISO8879 and on ISO8601 which
*	defines date/time representations.
*	SGML uses the ASCII characterset as base, so it can be used on every
*	platform. On the other hand SGML gives the log file a real structure
*	that is defined by the DTD (Document Type Definition).
*	The advantage of using SGML is that these log files have a structure,
*	so they can be easily interchanged with other SGML applications like
*	databases, wordprocessors or calculation software.
*	By supporting this standard with your software you give the user the
*	possibility to create or evaluate log files with software from
*	different platforms; and you get a standard that is easily extended
*	should a need occur.
*	To make this standard widely used, I provide a generator and a parser
*	for this log file standard for free!
*
*	(English) Books which were consulted in creating this library:
*	    The SGML Handbook
*	    Charles F. Goldfarb
*	    First Edition
*	    Oxford University Press, Walton Street, Oxford (USA) 1990
*	    ISBN 0-19-853737-9
*
*   COPYRIGHT
*	This software is copyright 1996 by Kai Hofmann.
*	All rights reserved!
*
*	- Permission is hereby granted, without written agreement and without
*	  license, to USE this software and its documentation for any
*	  purpose, provided that the above copyright notice and the
*	  following paragraph appear in all copies of this software.
*
*	- THERE IS *NO* PERMISSION GIVEN TO REDISTRIBUTE THIS SOFTWARE IN A
*	  MODIFIED FORM!
*
*	  You "must" send me a full version of your product at no cost
*	  including free updates!
*
*   DISCLAIMER
*	THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
*	APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
*	HOLDER AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT
*	WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
*	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
*	A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
*	PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE
*	DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
*	CORRECTION.
*
*	IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
*	WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY REDISTRIBUTE
*	THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
*	INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES
*	ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING
*	BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR
*	LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM
*	TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER
*	PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*
*	THE AUTHOR HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
*	UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
*
*   DISTRIBUTION
*	Permission is hereby granted, without written agreement and without
*	license or royalty fees, to copy and distribute this software and its
*	documentation for any purpose, provided that the above copyright
*	notice appear in all copies of this software.
*
*   AUTHOR
*	Kai Hofmann
*	Arberger Heerstraﬂe 92
*	28307 Bremen
*	Germany
*
*	Phone: (+49)-(0)421/480780
*	       (Remember that my parents don't speak english!)
*	EMail: i07m@zfn.uni-bremen.de
*	       i07m@informatik.uni-bremen.de
*	IRC  : PowerStat@#AmigaGer
*	WWW  : http://www.informatik.uni-bremen.de/~i07m
*
*    THANKS
*	Thank you's are going to the following people:
*	Rita Reichl		- For correcting my English.
*	James Cooper and the
*	other Amiga people at
*	SAS Intitute		- For spending their unpaid free time with
*				  continuation of the Amiga SAS C/C++
*				  support :)
*
*****************************************************************************
*
*
*/


 #include "PhoneLogGenerator.h"
 #include "PhoneLog.h"
 /*#include "date.h"*/
 #include <stdio.h>


 #define PROGNAME	"MUIBill" /* Please use the name of your program here!     */
 #define PROGVERSION	0         /* Please use the version of your program here!  */
 #define PROGREVISION	1         /* Please use the revision of your program here! */
 #define MARKNAME	"LogScan"


 FILE *OpenPhoneLog(const char *const name)

/*
******* PhoneLogGenerator/OpenPhoneLog **************************************
*
*   NAME
*	OpenPhoneLog -- Opens a log file for write operations (V33)
*
*   SYNOPSIS
*	file = OpenPhoneLog(name);
*
*	FILE *OpenPhoneLog(const char *const name);
*
*   FUNCTION
*	Opens a log file for appending new entries. If the log file doesn't
*	exist, a new one will be created.
*
*   INPUTS
*	name - The name of the log file.
*
*   RESULT
*	file - stdio.h file descriptor for a level 2 file or NULL if an error
*	    occurs.
*
*   EXAMPLE
*	...
*	FILE *file;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	None
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	ClosePhoneLog(),WritePhoneLogStartEntry(),WritePhoneLogEndEntry(),
*	WritePhoneLogEntry(),WritePhoneLogMark()
*
*****************************************************************************
*
*
*/

  {
   FILE *file;

   file = fopen(name,"a");
   if (file != NULL)
    {
     fpos_t fpos;

     /*result=*/ fgetpos(file,&fpos);
     if (fpos == 0)
      {
       fprintf(file,"<PHONELOG");
       fprintf(file," version=1 revision=2");
       fprintf(file,">\n");
      }
    }
   return(file);
  }


 void ClosePhoneLog(FILE *const file)

/*
******* PhoneLogGenerator/ClosePhoneLog *************************************
*
*   NAME
*	ClosePhoneLog -- Close a log file (V33)
*
*   SYNOPSIS
*	ClosePhoneLog(file);
*
*	void ClosePhoneLog(FILE *const file);
*
*   FUNCTION
*	Close a log file opened by OpenPhoneLog().
*
*   INPUTS
*	file - The stdio.h file descriptor for a level 2 file that you got
*	    from OpenPhoneLog().
*
*   RESULT
*	None
*
*   EXAMPLE
*	...
*	FILE *file;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	None
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	OpenPhoneLog(),WritePhoneLogStartEntry(),WritePhoneLogEndEntry(),
*	WritePhoneLogEntry(),WritePhoneLogMark()
*
*****************************************************************************
*
*
*/

  {
   fclose(file);
  }


 void WritePhoneLogStartEntry(FILE *const file, const struct PhoneLogEntry *const item)

/*
******* PhoneLogGenerator/WritePhoneLogStartEntry ***************************
*
*   NAME
*	WritePhoneLogStartEntry -- Write the start to a log file (V33)
*
*   SYNOPSIS
*	WritePhoneLogStartEntry(file, item);
*
*	void WritePhoneLogStartEntry(FILE *const file,
*	    const struct PhoneLogEntry *const item);
*
*   FUNCTION
*	Write the start data for a connection to a log file opened by
*	OpenPhoneLog().
*
*   INPUTS
*	file - The stdio.h file descriptor for a level 2 file that you got
*	    from OpenPhoneLog().
*	item - PhoneLogEntry structure. You must fill in following fields:
*	    Number, StartDay, StartMonth, StartYear, StartHour,
*	    StartMin, StartSec, Type.
*	    The fields Name and Reason are optional and will only be written
*	    if the string length is greater than 0.
*
*   RESULT
*	None
*
*   EXAMPLE
*	...
*	FILE *file;
*	struct PhoneLogEntry item;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	strcpy(item.Number,"1234567890");
*	strcpy(item.Name,"University");
*	item.Type = PhoneLog_NORMAL;
*	item.StartDay = 5;
*	item.StartMonth = 3;
*	item.StartYear = 1996; \* NOT 96! *\
*	item.StartHour = 12;
*	item.StartMin = 3;
*	item.StartSec = 0;
*	WritePhoneLogStartEntry(file,item);
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	Set Reason[0] = '\0' if you not want that this will be written to
*	the log file.
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	OpenPhoneLog(),ClosePhoneLog(),WritePhoneLogEndEntry(),
*	WritePhoneLogEntry(),WritePhoneLogMark()
*
*****************************************************************************
*
*
*/

  {
   fprintf(file,"\n<ENTRY>\n");
   fprintf(file,"  <HOST>\n");
   fprintf(file,"    <NUMBER>");
   fprintf(file,"%s",item->Number);
   fprintf(file,"</NUMBER>\n");
   if (item->Name[0] != '\0')
    {
     fprintf(file,"    <HOSTNAME>");
     fprintf(file,"%s",item->Name);
     fprintf(file,"</HOSTNAME>\n");
    }
   if (item->Reason[0] != '\0')
    {
     fprintf(file,"    <REASON>");
     fprintf(file,"%s",item->Reason);
     fprintf(file,"</REASON>\n");
    }
   fprintf(file,"  </HOST>\n");
   switch (item->Type)
    {
     case PhoneLog_NORMAL   : fprintf(file,"  <START>\n");
                              break;
     case PhoneLog_BUSY     : fprintf(file,"  <BUSY>\n");
                              break;
     case PhoneLog_NOANSWER : fprintf(file,"  <NOANSWER>\n");
                              break;
    }
   fprintf(file,"    <DATE>");
   fprintf(file,"%04d-%02hu-%02hu",item->StartYear,item->StartMonth,item->StartDay);
   fprintf(file,"</DATE>\n");
   fprintf(file,"    <TIME>");
   fprintf(file,"%02hu:%02hu:%02hu",item->StartHour,item->StartMin,item->StartSec);
   fprintf(file,"</TIME>\n");
   switch (item->Type)
    {
     case PhoneLog_NORMAL   : fprintf(file,"  </START>\n");
                              break;
     case PhoneLog_BUSY     : fprintf(file,"  </BUSY>\n");
                              break;
     case PhoneLog_NOANSWER : fprintf(file,"  </NOANSWER>\n");
                              break;
    }
  }


 void WritePhoneLogEndEntry(FILE *const file, const struct PhoneLogEntry *const item)

/*
******* PhoneLogGenerator/WritePhoneLogEndEntry *****************************
*
*   NAME
*	WritePhoneLogEndEntry -- Write the end to a log file (V33)
*
*   SYNOPSIS
*	WritePhoneLogEndEntry(file, item);
*
*	void WritePhoneLogEndEntry(FILE *const file,
*	    const struct PhoneLogEntry *const item);
*
*   FUNCTION
*	Write the end data for a connection to a log file opened by
*	OpenPhoneLog() after you have used WritePhoneLogStartEntry()!
*
*   INPUTS
*	file - The stdio.h file descriptor for a level 2 file that you got
*	    from OpenPhoneLog().
*	item - PhoneLogEntry structure. You must fill in following fields:
*	    EndDay, EndMonth, EndYear, EndHour, EndMin, EndSec, Type.
*	    If you want you can optionally fill in the fields:
*	    Hours, Mins, Secs.
*
*   RESULT
*	None
*
*   EXAMPLE
*	...
*	FILE *file;
*	struct PhoneLogEntry item;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	item.Type = PhoneLog_NORMAL;
*	item.EndDay = 5;
*	item.EndMonth = 3;
*	item.EndYear = 1996; \* NOT 96! *\
*	item.EndHour = 12;
*	item.EndMin = 17;
*	item.EndSec = 0;
*	WritePhoneLogEndEntry(file,item);
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	If you want to write the optional fields Hours, Mins, Secs to the log
*	file, please remove the second comment from the source code!
*	If you want that EndDay, EndMonth and EndYear will only be written
*	to the log file if they are different to the start date, then please
*	remove the first comment from the source code, but keep in mind
*	that you now must fill the structure with StartDay, StartMonth and
*	StartYear too!
*	Don't forget to remove the comment for the #include "date.h"!
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	OpenPhoneLog(),ClosePhoneLog(),WritePhoneLogStartEntry(),
*	WritePhoneLogEntry(),WritePhoneLogMark()
*
*****************************************************************************
*
*
*/

  {
   if (item->Type == PhoneLog_NORMAL)
    {
     fprintf(file,"  <END>\n");
     /*if (date_Compare2Dates(item-StartDay,item->StartMonth,item->StartYear,item->EndDay,item->EndMonth,item->EndYear) != 0)*/
      {
       fprintf(file,"    <DATE>");
       fprintf(file,"%04d-%02hu-%02hu",item->EndYear,item->EndMonth,item->EndDay);
       fprintf(file,"</DATE>\n");
      }
     fprintf(file,"    <TIME>");
     fprintf(file,"%02hu:%02hu:%02hu",item->EndHour,item->EndMin,item->EndSec);
     fprintf(file,"</TIME>\n");
     fprintf(file,"  </END>\n");
     /*
     if ((item->Hours > 0) || (item->Mins > 0) || (item->Secs > 0))
      {
       fprintf(file,"  <PERIOD>");
       if (item->Hours > 0)
        {
         fprintf(file,"%huH",item->Hours);
        }
       if (item->Mins > 0)
        {
         fprintf(file,"%02huM",item->Mins);
        }
       if (item->Secs > 0)
        {
         fprintf(file,"%02huS",item->Secs);
        }
       fprintf(file,"</PERIOD>\n");
      }
     */
    }

   fprintf(file,"</ENTRY>\n");
  }


 void WritePhoneLogEntry(FILE *const file, const struct PhoneLogEntry *const item)

/*
******* PhoneLogGenerator/WritePhoneLogEntry ********************************
*
*   NAME
*	WritePhoneLogEntry -- Write a full entry to a log file (V33)
*
*   SYNOPSIS
*	WritePhoneLogEntry(file, item);
*
*	void WritePhoneLogEntry(FILE *const file,
*	    const struct PhoneLogEntry *const item);
*
*   FUNCTION
*	Write a full entry for a connection to a log file opened by
*	OpenPhoneLog().
*
*   INPUTS
*	file - The stdio.h file descriptor for a level 2 file that you got
*	    from OpenPhoneLog().
*	item - PhoneLogEntry structure. You must fill in following fields:
*	    Number, Name, StartDay, StartMonth, StartYear, StartHour,
*	    StartMin, StartSec, EndDay, EndMonth, EndYear, EndHour, EndMin,
*	    EndSec, Type.
*	    If you want you can optionally fill in the fields:
*	    Hours, Mins, Secs.
*
*   RESULT
*	None
*
*   EXAMPLE
*	...
*	FILE *file;
*	struct PhoneLogEntry item;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	strcpy(item.Number,"1234567890");
*	strcpy(item.Name,"University");
*	item.Type = PhoneLog_NORMAL;
*	item.StartDay = 5;
*	item.StartMonth = 3;
*	item.StartYear = 1996; \* NOT 96! *\
*	item.StartHour = 12;
*	item.StartMin = 3;
*	item.StartSec = 0;
*	item.EndDay = 5;
*	item.EndMonth = 3;
*	item.EndYear = 1996; \* NOT 96! *\
*	item.EndHour = 12;
*	item.EndMin = 17;
*	item.EndSec = 0;
*	WritePhoneLogEntry(file,item);
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	If you want to write the optional fields Hours, Mins, Secs to the log
*	file, please remove the second comment from the source code of the
*	function WritePhoneLogEndEntry().
*	If you want that EndDay, EndMonth and EndYear will only be written
*	to the log file if they are different to the start date, then please
*	remove the first comment from the source code of the function
*	WritePhoneLogEndEntry().
*	Don't forget to remove the comment for the #include "date.h"!
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	OpenPhoneLog(),ClosePhoneLog(),WritePhoneLogStartEntry(),
*	WritePhoneLogEndEntry(),WritePhoneLogMark()
*
*****************************************************************************
*
*
*/

  {
   WritePhoneLogStartEntry(file,item);
   WritePhoneLogEndEntry(file,item);
  }


 void WritePhoneLogMark(FILE *const file)

/*
******* PhoneLogGenerator/WritePhoneLogMark *********************************
*
*   NAME
*	WritePhoneLogMark -- Write a mark to a log file (V33)
*
*   SYNOPSIS
*	WritePhoneLogMark(file);
*
*	void WritePhoneLogMark(FILE *const file);
*
*   FUNCTION
*	Write a mark to a log file opened by OpenPhoneLog().
*
*   INPUTS
*	file - The stdio.h file descriptor for a level 2 file that you got
*	    from OpenPhoneLog().
*
*   RESULT
*	None
*
*   EXAMPLE
*	...
*	FILE *file;
*
*	file = OpenPhoneLog("AmiTCP:log/AmiLog.log");
*	...
*	WritePhoneLogMark(file);
*	...
*	ClosePhoneLog(file);
*	...
*
*   NOTES
*	This function is for programs that evaluate log files only!
*	After such a program has parsed the log file it can write a mark,
*	so it knows the next time it parses the log file which data is
*	already known.
*
*   BUGS
*	No known bugs.
*
*   SEE ALSO
*	OpenPhoneLog(),ClosePhoneLog(),WritePhoneLogStartEntry(),
*	WritePhoneLogEndEntry(),WritePhoneLogEntry()
*
*****************************************************************************
*
*
*/

  {
   fprintf(file,"\n<MARK>\n");
   fprintf(file,"  <PROGRAM ");
   fprintf(file,"version=%u ",PROGVERSION);
   fprintf(file,"revision=%u",PROGREVISION);
   fprintf(file,">");
   fprintf(file,"%s",PROGNAME);
   fprintf(file,"</PROGRAM>\n");
   fprintf(file,"  <MARKNAME>");
   fprintf(file,"%s",MARKNAME);
   fprintf(file,"</MARKNAME>\n");
   fprintf(file,"</MARK>\n");
  }
