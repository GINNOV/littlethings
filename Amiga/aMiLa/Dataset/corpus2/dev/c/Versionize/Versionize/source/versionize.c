#include  <ctype.h>		// For portability, standard ANSI functions only are used
#include  <stdio.h>
#include  <stdlib.h>
#include  <string.h>
#include  <time.h>

#include  "versionize.h"

//> Macro and types definitions
// These macros are used to set/read the mode of operation of Versionize
#define  MODE_UPDATEBUILDNUMBER		0x01
#define  MODE_UPDATEBUILDTIME		0x02
#define  MODE_UPDATEALL				(MODE_UPDATEBUILDNUMBER | MODE_UPDATEBUILDTIME)
#define  MODE_DELETEBACKUPFILE		0x04
#define  MODE_VERBOSE				0x08
#define  MODE_USELOCALENAMES		0x10
#define  UpdateBuildNumberActive()	(UpdateMode & MODE_UPDATEBUILDNUMBER)
#define  UpdateBuildTimeActive()	(UpdateMode & MODE_UPDATEBUILDTIME)
#define  DeleteBackupFile()			(UpdateMode & MODE_DELETEBACKUPFILE)
#define  Verbose()					(UpdateMode & MODE_VERBOSE)	
#define  UseLocaleNames()			(UpdateMode & MODE_USELOCALENAMES)			
// These macros are used to manage status changes during localization
#define  PATCHSTATUS_IDLE				0
#define  PATCHSTATUS_FOUNDTOKEN			1
#define  PATCHSTATUS_FOUNDMODIFIEDTOKEN	2
// Error codes
#define  ERROR_NOERROR				0
#define  ERROR_WRONGCOMMAND			10
#define  ERROR_FILENAMETOOLONG		20
#define  ERROR_CANTOPENFILE			21
#define  ERROR_CANTOPENFILEBACKUP	22
#define  ERROR_CANTOPENFILELOCALE	23
#define  ERROR_CANTRENAMEFILE		24
#define  ERROR_PROCESSINGFILE		25
#define  ERROR_PROCESSINGFILELOCALE	26
#define  ERROR_WRITINGFILE			27
#define  ERROR_CANTREMOVEBACKUP		28
#define  ERROR_CANTRENAMEFILEUPDATE	29
#define  ERROR_MACRONAMETOOLONG		30
#define  ERROR_TEMPLATETOOLONG      31
// Lenght macros for buffers
#define  MACROSTRING_MAXLENGTH	64
#define  TEMPLATE_MAXLENGTH     256
#define  FILENAME_MAXLENGTH		256
#define  LINEBUFFER_LENGTH		256
#define  MONTH_NUMBER			12
#define  WEEKDAY_NUMBER			7
#define  LOCALENAME_MAXLENGTH	32
#define  LOCALENAME_SHORTLENGTH	4
// Macros used when reading locale file
#define  LOCALECOMPLETEMONTH			0
#define  LOCALESHORTMONTH				1
#define  LOCALECOMPLETEWEEKDAY			2
#define  LOCALESHORTWEEKDAY				3
#define  LOCALEAMEQUIVALENT				4
#define  LOCALEPMEQUIVALENT				5
#define  LOCALECATEGORY_NUMBER			6
#define  LOCALECOMPLETEMONTHDEFINE		"COMPLETEMONTH"
#define  LOCALESHORTMONTHDEFINE			"SHORTMONTH"
#define  LOCALECOMPLETEWEEKDAYDEFINE	"COMPLETEWEEKDAY"
#define  LOCALESHORTWEEKDAYDEFINE		"SHORTWEEKDAY"
#define  LOCALEAMEQUIVALENTDEFINE		"AMEQUIVALENT"
#define  LOCALEPMEQUIVALENTDEFINE		"PMEQUIVALENT"
#define  LOCALENAME_DELIMITERCHAR		'"'
// Default values for unspecified options
#define  VERSIONHEADERFILE_DEFAULT		"version.h"
#define  LANGUAGEMACROCOMMAND_DEFAULT   "#define"
#define  BUILDNUMBERMACRO_DEFAULT   	"BUILD_NUMBER"
#define  BUILDDATEMACRO_DEFAULT			"BUILD_DATE"
#define  BUILDTIMEMACRO_DEFAULT			"BUILD_TIME"

struct  LOCALIZEDSTRINGS
{
	char  MonthName[MONTH_NUMBER][LOCALENAME_MAXLENGTH];				// Array of strings for localized month names
	char  MonthShortName[MONTH_NUMBER][LOCALENAME_SHORTLENGTH];			// Array of strings for localized month short names
	char  WeekDayName[WEEKDAY_NUMBER][LOCALENAME_MAXLENGTH];            // Array of strings for localized week day names
	char  WeekDayShortName[WEEKDAY_NUMBER][LOCALENAME_SHORTLENGTH];     // Array of strings for localized week day short names
	char  AmEquivalent[LOCALENAME_SHORTLENGTH];                         // String with localized AM equivalent
	char  PmEquivalent[LOCALENAME_SHORTLENGTH];                         // String with localized PM equivalent
};
///
//> Internal prototypes
void  VersionizeCleanUp(void);		// CleanUp function is called when exiting to clean up environment; this is needed when Versionize exits because of some errors
void  VersionizeExit(int  error);	// Exit Versionize and report error cause
void  VersionizeUsage(void);		// Print the help text
int  LocaleFileRead(void);			// Read the specified locale file
unsigned char  PatchTemplates(void);		// Localize the Date and Time templates
unsigned char  PatchString(char *source);// Localize a template searching for month and week day tokens.
///
//> Global variables
time_t  VersionCurrentTime;			// Time of execution of Versionize in time_t format
struct tm  *LocalTime;				// Time of execution of Versionize in struct tm format
FILE  *VersionFilePointer = 0;		// Pointer to the original file holding version information
FILE  *UpdateFilePointer = 0;       // Pointer to the updated copy of the original file holding version information
FILE  *LocaleFilePointer = 0;       // Pointer to the locale file
char  VersionHeaderFile[FILENAME_MAXLENGTH] = VERSIONHEADERFILE_DEFAULT;	// Name of the file holding version information
char  VersionHeaderFileUpdate[FILENAME_MAXLENGTH + 4]; 						// Name of the updated copy of the original file holding version information
char  VersionHeaderFileBackup[FILENAME_MAXLENGTH + 4]; 						// Name of the copy of the original file holding version information
char  LocaleFile[FILENAME_MAXLENGTH];										// Name of the locale file
char  LanguageMacroCommand[MACROSTRING_MAXLENGTH] = LANGUAGEMACROCOMMAND_DEFAULT;	// Name of the language command used to define macros
char  BuildNumberMacro[MACROSTRING_MAXLENGTH] = BUILDNUMBERMACRO_DEFAULT;	// Macro, defined in the file holding version information, used for the build number
char  BuildDateMacro[MACROSTRING_MAXLENGTH] = BUILDDATEMACRO_DEFAULT;       // Macro, defined in the file holding version information, used for the date of compilation
char  BuildTimeMacro[MACROSTRING_MAXLENGTH] = BUILDTIMEMACRO_DEFAULT;       // Macro, defined in the file holding version information, used for the time of compilation
char  LineBuffer[LINEBUFFER_LENGTH];			// Buffer used when reading files
char  TokenSymbol = '%';
char  DateFormat[TEMPLATE_MAXLENGTH] = "%x";	// Template for Date of compilation representation
char  TimeFormat[TEMPLATE_MAXLENGTH] = "%X";	// Template for Time of compilation representation
const char  *LocaleCategory[LOCALECATEGORY_NUMBER] = {LOCALECOMPLETEMONTHDEFINE, LOCALESHORTMONTHDEFINE, LOCALECOMPLETEWEEKDAYDEFINE, LOCALESHORTWEEKDAYDEFINE, LOCALEAMEQUIVALENTDEFINE, LOCALEPMEQUIVALENTDEFINE};
struct LOCALIZEDSTRINGS  LocalizedStrings;
unsigned char  UpdateMode = MODE_UPDATEALL | MODE_DELETEBACKUPFILE;			// Mode of operation as specified by user options
char  VersionString[] = VERSION_STRING;
///

//> int  main(int argc, char *argv[])
int  main(int argc, char *argv[])
{
    int  error = 0;
	int  i;
	char  *linepointer;
	unsigned char  foundstring, stringized;
	
	atexit(VersionizeCleanUp);	// register CleanUp() function to be executed at exit()
    for (i = 1; i < argc; ++i)
	{	// read options
    	if ((strlen(argv[i]) != 2) || (argv[i][0] != '-'))
			error = ERROR_WRONGCOMMAND;	// each option should start with a '-' followed by the option switch char
        else
		{	// look if the option switch is supported
            switch (argv[i][1])
			{
				case  'b':	// "-b" tells Versionize to not delete the copy of the orignal file holding version information
					UpdateMode &= ~MODE_DELETEBACKUPFILE;
					break;
				case  'c':	// "-c command" specify the command, as defined by the programming language, used to define macros
					if (++i < argc)
						if (strlen(argv[i]) < MACROSTRING_MAXLENGTH)
							strcpy(LanguageMacroCommand, argv[i]);
						else
							error = ERROR_MACRONAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'd':	// "-d datemacro" specify the name of the macro, defined in the file holding version information, used for the date of compilation
					if (++i < argc)
						if (strlen(argv[i]) < MACROSTRING_MAXLENGTH)
							strcpy(BuildDateMacro, argv[i]);
						else
							error = ERROR_MACRONAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'f':  // "-f filename" specify the filename for the file holding version information
					if (++i < argc)
						if (strlen(argv[i]) < FILENAME_MAXLENGTH)
							strcpy(VersionHeaderFile, argv[i]);
						else
							error = ERROR_FILENAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'h':	// "-h" tells Versionize to output help text; all other options are ignored and Versionize exits without doing anything
                    VersionizeUsage();
					exit(0);
				case  'l': 	// "-l filename" tells Versionize to use filename as the file holding localized month and week day names
					if (++i < argc)
						if (strlen(argv[i]) < FILENAME_MAXLENGTH)
						{
							strcpy(LocaleFile, argv[i]);
							UpdateMode |= MODE_USELOCALENAMES;
						}
						else
							error = ERROR_FILENAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'm':	// "-m a" updates both build number and time/date information, "-m n" updates build number only, "-m t" updates time/date information only
				    if (++i < argc)
						if (strlen(argv[i]) == 1)
						    switch(argv[i][0])
                            {
                                case  'a':
                                	UpdateMode |= MODE_UPDATEALL;
									break; 
                            	case  'n':
                            		UpdateMode = (UpdateMode & (~MODE_UPDATEALL)) | MODE_UPDATEBUILDNUMBER;
                            		break;
                        		case  't':
                        			UpdateMode = (UpdateMode & (~MODE_UPDATEALL)) | MODE_UPDATEBUILDTIME;
                        			break;
                    			default:
                    				error = ERROR_WRONGCOMMAND;	
							}
						else
							error = ERROR_MACRONAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'n':  // "-n buildnumbermacro" specify the name of the macro, defined in the file holding version information, used for the build number
					if (++i < argc)
						if (strlen(argv[i]) < MACROSTRING_MAXLENGTH)
							strcpy(BuildNumberMacro, argv[i]);
						else
							error = ERROR_MACRONAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  't':	// "-t timemacro" specify the name of the macro, defined in the file holding version information, used for the time of compilation
					if (++i < argc)
						if (strlen(argv[i]) < MACROSTRING_MAXLENGTH)
							strcpy(BuildTimeMacro, argv[i]);
						else
							error = ERROR_MACRONAMETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
					break;
				case  'v':	// "-v" tells Versionize to give a detailed report of operations
					UpdateMode |= MODE_VERBOSE;
					break;
				case  'D':	// "-D template" specify a template for formatting Date information
				    if (++i < argc)
						if (strlen(argv[i]) < TEMPLATE_MAXLENGTH)
							strcpy(DateFormat, argv[i]);
						else
							error = ERROR_TEMPLATETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
				    break;
				case  'T':  // "-T template" specify a template for formatting Time information
				    if (++i < argc)
						if (strlen(argv[i]) < TEMPLATE_MAXLENGTH)
							strcpy(TimeFormat, argv[i]);
						else
							error = ERROR_TEMPLATETOOLONG;
					else
						error = ERROR_WRONGCOMMAND;
				    break;
                case  '!':  // "-!" specify to use the '!' char instead of the '%' char for token identification
                    TokenSymbol = '!';
                    if (DateFormat[0] = '%')
                        DateFormat[0] = '!';	// Change the default template for Date of compilation
                    if (TimeFormat[0] = '%')
                        TimeFormat[0] = '!';	// Change the default template for Time of compilation
                    break;
                default:
                    error = ERROR_WRONGCOMMAND;
            }
            if (error)
            	VersionizeExit(error);
        }
	}
	if (Verbose())
		fprintf(stdout, "%s\nMacro definition command: %s\nVersion header file: %s\nBuild number macro: %s\nBuild date macro: %s\n", VersionString + 6, LanguageMacroCommand, VersionHeaderFile, BuildNumberMacro, BuildDateMacro);
	time(&VersionCurrentTime);	// read current time and date
	LocalTime = localtime(&VersionCurrentTime);
	if (PatchTemplates())
		VersionizeExit(ERROR_TEMPLATETOOLONG);
	strcpy(VersionHeaderFileUpdate, VersionHeaderFile);
	strcat(VersionHeaderFileUpdate, ".new");
	if (!(VersionFilePointer = fopen(VersionHeaderFile, "r"))) // open the original file (read) and the update file (write) to start updating it
		VersionizeExit(ERROR_CANTOPENFILE);
	if (!(UpdateFilePointer = fopen(VersionHeaderFileUpdate, "w")))
		VersionizeExit(ERROR_CANTOPENFILEBACKUP);
	while (fgets(LineBuffer, LINEBUFFER_LENGTH, VersionFilePointer)) // scan original file reading a line of text at a time
	{
		if (ferror(VersionFilePointer))
			VersionizeExit(ERROR_PROCESSINGFILE); 					// exit on errors while reading original file
		foundstring = 0;
		stringized = 0;
		if (linepointer = strstr(LineBuffer, LanguageMacroCommand)) // search for "#define" (or user defined commands) occurences
		{
			for (linepointer += strlen(LanguageMacroCommand); isspace(*linepointer); ++linepointer);
			if (!strncmp(linepointer, BuildNumberMacro, strlen(BuildNumberMacro)))	// search for "#define BuildNumberMacro" occurences
			{
				if (UpdateBuildNumberActive() && isspace(*(linepointer + strlen(BuildNumberMacro))))
				{   // if found, replace old build number with the new one (it is incremented)
					int  buildnumber;

					foundstring = 1;
					*linepointer = 0;
	                fputs(LineBuffer, UpdateFilePointer);
	                fputs(BuildNumberMacro, UpdateFilePointer);
					for (linepointer += strlen(BuildNumberMacro); isspace(*linepointer); ++linepointer)
						fputc(*linepointer, UpdateFilePointer);
					if (Verbose())
						fprintf(stdout, "Old build number: %s", linepointer);
					if (*linepointer == '"')	// if the build number is between double quotes, replicates them
                    {
                         stringized = 1;
                         fputc('"', UpdateFilePointer);
                         *linepointer++;
                    }
					buildnumber = atoi(linepointer) + 1;
					if (Verbose())
						fprintf(stdout, "New build number: %d\n", buildnumber);
					fprintf(UpdateFilePointer, "%d", buildnumber);
					if (stringized)
                         fputc('"', UpdateFilePointer);
                    fputc('\n', UpdateFilePointer);
				}
			}
			else if (!strncmp(linepointer, BuildDateMacro, strlen(BuildDateMacro))) // search for "#define BuildDateMacro" occurences
			{
				if (UpdateBuildTimeActive() && isspace(*(linepointer + strlen(BuildDateMacro))))
				{	// if found, replace old date of compilation  with the new one (as specified by template)
					foundstring = 1;
					*linepointer = 0;
	                fputs(LineBuffer, UpdateFilePointer);
					fputs(BuildDateMacro, UpdateFilePointer);
					for (linepointer += strlen(BuildDateMacro); isspace(*linepointer); ++linepointer)
                        fputc(*linepointer, UpdateFilePointer);
					if (Verbose())
						fprintf(stdout, "Old date: %s", linepointer);
					if (*linepointer == '"')	// if the date of compilation is between double quotes, replicates them
                    {
                         stringized = 1;
                         fputc('"', UpdateFilePointer);
                         *linepointer++;
                    }
					strftime(LineBuffer, LINEBUFFER_LENGTH - 1, DateFormat, LocalTime);
                    if (Verbose())
						fprintf(stdout, "New date: %s\n", LineBuffer);
					fputs(LineBuffer, UpdateFilePointer);
                    if (stringized)
                         fputc('"', UpdateFilePointer);
                    fputc('\n', UpdateFilePointer);
				}
			}
			else if (!strncmp(linepointer, BuildTimeMacro, strlen(BuildTimeMacro))) // search for "#define BuildTimeMacro" occurences
			{
				if (UpdateBuildTimeActive() && isspace(*(linepointer + strlen(BuildTimeMacro))))
				{   // if found, replace old time of compilation  with the new one (as specified by template)
					foundstring = 1;
					*linepointer = 0;
	                fputs(LineBuffer, UpdateFilePointer);
					fputs(BuildTimeMacro, UpdateFilePointer);
					for (linepointer += strlen(BuildTimeMacro); isspace(*linepointer); ++linepointer)
                        fputc(*linepointer, UpdateFilePointer);
					if (Verbose())
						fprintf(stdout, "Old time: %s", linepointer);
					if (*linepointer == '"')    // if the time of compilation is between double quotes, replicates them
                    {
                         stringized = 1;
                         fputc('"', UpdateFilePointer);
                         *linepointer++;
                    }
					strftime(LineBuffer, LINEBUFFER_LENGTH - 1, TimeFormat, LocalTime);
                    if (Verbose())
						fprintf(stdout, "New time: %s\n", LineBuffer);
                    fputs(LineBuffer, UpdateFilePointer);
                    if (stringized)
                         fputc('"', UpdateFilePointer);
                    fputc('\n', UpdateFilePointer);
				}
			}
		}
		if (!foundstring)
			fputs(LineBuffer, UpdateFilePointer);  // if no macro has been patched, simply copy the line of text to destination file
		if (ferror(UpdateFilePointer))
			VersionizeExit(ERROR_WRITINGFILE);      // exit on errors while writing updated file
	}
	fclose(UpdateFilePointer);
	fclose(VersionFilePointer);
	strcpy(VersionHeaderFileBackup, VersionHeaderFile);
	strcat(VersionHeaderFileBackup, ".bak");
	if (UpdateFilePointer = fopen(VersionHeaderFileBackup, "r"))
	{
		fclose(UpdateFilePointer);
		if (remove(VersionHeaderFileBackup))
            VersionizeExit(ERROR_CANTREMOVEBACKUP);
	}
	if (rename(VersionHeaderFile, VersionHeaderFileBackup))		    // rename the original file holding version information adding the ".bak" extension to make a copy
		VersionizeExit(ERROR_CANTRENAMEFILE);
	if (rename(VersionHeaderFileUpdate, VersionHeaderFile))		    // rename the update file holding version information as the new original file
	{
		rename(VersionHeaderFileBackup, VersionHeaderFile);			// try to rename the backup file with the original name
		VersionizeExit(ERROR_CANTRENAMEFILE);
	}
	if (DeleteBackupFile())
		remove(VersionHeaderFileBackup);	// if "-b" option wasn't specified, the backup file is deleted
	exit(0);
}
///
//> void  VersionizeCleanUp(void)
void  VersionizeCleanUp(void)
{	// force clean up of environment on exit(), useful when exiting because of an error
	if (VersionFilePointer)
    	fclose(VersionFilePointer);
	if (UpdateFilePointer)
		fclose(UpdateFilePointer);
	if (LocaleFilePointer)
 		fclose(LocaleFilePointer);
}
///
//> void  VersionizeExit(int error)
void  VersionizeExit(int error)
{	// report error cause and exit
    switch (error)
    {
    	case  ERROR_WRONGCOMMAND:
            VersionizeUsage();
            break;
		case  ERROR_FILENAMETOOLONG:
			fputs("File name is too long (max 256 chars)\n", stdout);
			break;
		case  ERROR_CANTOPENFILE:
			fprintf(stdout, "Can't open file %s\n", VersionHeaderFile);
			break;
		case  ERROR_CANTOPENFILEBACKUP:
			fprintf(stdout, "Can't open file %s\n", VersionHeaderFileBackup);
			break;
		case  ERROR_CANTOPENFILELOCALE:
			fprintf(stdout, "Can't open file %s\n", LocaleFile);
			break;
		case  ERROR_CANTRENAMEFILE:
			fprintf(stdout, "Can't rename file %s as %s\n", VersionHeaderFile, VersionHeaderFileBackup);
			break;
		case  ERROR_PROCESSINGFILE:
			fprintf(stdout, "Error processing file %s\n", VersionHeaderFileBackup);
			break;
		case  ERROR_PROCESSINGFILELOCALE:
			fprintf(stdout, "Error processing file %s\n", LocaleFile);
			break;  
		case  ERROR_WRITINGFILE:
			fprintf(stdout, "Can't write file %s\n", VersionHeaderFileBackup);
			break;
        case  ERROR_CANTREMOVEBACKUP:
			fprintf(stdout, "Can't remove file %s\n", VersionHeaderFileBackup);
			break;   
        case  ERROR_CANTRENAMEFILEUPDATE:
			fprintf(stdout, "Can't rename file %s as %s\n", VersionHeaderFileUpdate, VersionHeaderFile);
			break;
		case  ERROR_MACRONAMETOOLONG:
			fputs("Macro name is too long (max 64 chars)\n", stdout);
			break;
		case  ERROR_TEMPLATETOOLONG:
		    fputs("Template is too long (max 64 chars)\n", stdout);
            break;
		default:
			fputs("Unknown error\n", stdout);
    }
    exit(error);
}
///
//> void  VersionizeUsage(void)
void  VersionizeUsage(void)
{	// print help text
	fputs(VersionString + 6, stdout);
	fputs("\nUsage: versionize [opt1...]\nPossible options:\n", stdout);
	fputs("-b, keep backup copy of old header file (default: simply overwrite)\n", stdout);
	fputs("-c, command used by language to define macros (default: #define)\n", stdout);
	fputs("-d datemacro, specify macro used for compilation date (default: BUILD_DATE)\n", stdout);
	fputs("-f filename, specify version heaer file (default: version.h)\n", stdout);
	fputs("-h, help on this command; no operation is executed\n", stdout);
	fputs("-l localefile, read localized names from localefile\n", stdout);
	fputs("-m M, M=a update all, M=n build number, M=t date & time (default: M=a)\n", stdout);
    fputs("-n buildmacro, specify macro used for build number (default: BUILD_NUMBER)\n", stdout);
	fputs("-t timemacro, specify macro used for compilation time (default: BUILD_TIME)\n", stdout);
	fputs("-v, specify verbose behaviour (default: no verbose)\n", stdout);
	fputs("-D template, format of date string (default: %x)\n", stdout);
	fputs("-T template, format of time string (default: %X)\n", stdout);
	fputs("-!, '!' is used to identify tokens (default: '%' is used)\n", stdout);
	fputs("You can use the following tokens in date and time templates:\n", stdout);
	fputs("%a  short week day name    %A  complete week day name\n", stdout);
	fputs("%b  short month name       %B  complete month name\n", stdout);
	fputs("%c  local date and time    %d  month day (01-31)\n", stdout);
	fputs("%H  hour (00-23)           %I  hour (01-12)\n", stdout);
	fputs("%j  year day (001-366)     %m  month (01-12)\n", stdout);
	fputs("%M  minutes (00-59)        %p  local AM/PM equivalent\n", stdout);
	fputs("%S  seconds (00-61)        %U  week number starting on Sunday (00-53)\n", stdout);
	fputs("%w  week day (00-06)       %W  week number starting on Monday (00-53)\n", stdout);
	fputs("%x  local date             %X  local time\n", stdout);
	fputs("%y  year number (00-99)    %Y  year number (yyyy)\n", stdout);
	fputs("%Z  time zone name         %%  % char\n", stdout);
	fputs("%!  ! char                 %_  space char\n", stdout);
	fputs("Use %-t format for any token t to prevent zero padding\n", stdout);
}
///
//> int  LocaleFileRead(void)
int  LocaleFileRead(void)
{	// read file with localized month and week day names
	char  *linepointer, i;
	
 	if (!(LocaleFilePointer = fopen(LocaleFile, "r")))
		return  ERROR_CANTOPENFILELOCALE;
	for (i = 0; i < MONTH_NUMBER; ++i)	// fill buffers with zeros to provide terminated strings in any case
	{
		memset(LocalizedStrings.MonthName[i], 0, LOCALENAME_MAXLENGTH);
		memset(LocalizedStrings.MonthShortName[i], 0, LOCALENAME_SHORTLENGTH);
	}
	for (i = 0; i < WEEKDAY_NUMBER; ++i)
	{
		memset(LocalizedStrings.WeekDayName[i], 0, LOCALENAME_MAXLENGTH);
		memset(LocalizedStrings.WeekDayShortName[i], 0, LOCALENAME_SHORTLENGTH);
	}
	memset(LocalizedStrings.AmEquivalent, 0 ,LOCALENAME_SHORTLENGTH);
	memset(LocalizedStrings.PmEquivalent, 0 ,LOCALENAME_SHORTLENGTH);
	while (fgets(LineBuffer, LINEBUFFER_LENGTH, LocaleFilePointer))
	{	// read locale file one line at a time
		if (ferror(LocaleFilePointer))
			return  ERROR_PROCESSINGFILELOCALE; 		// exit on errors
		for (i = 0; i < LOCALECATEGORY_NUMBER; ++i)
			if (linepointer = strstr(LineBuffer, LocaleCategory[i]))
				break;
		if (i < LOCALECATEGORY_NUMBER)
		{
			unsigned char  read_index = 0, max_index, max_length;
			void  *locale_string;

			switch (i)
			{
				case  LOCALECOMPLETEMONTH:      // LOCALECOMPLETEMONTHDEFINE string
					read_index = 1;
					max_index = MONTH_NUMBER;
					max_length = LOCALENAME_MAXLENGTH;
					locale_string = LocalizedStrings.MonthName;
					break;
				case  LOCALESHORTMONTH:         // LOCALESHORTMONTHDEFINE string
					read_index = 1;
					max_index = MONTH_NUMBER;
					max_length = LOCALENAME_SHORTLENGTH;
					locale_string = LocalizedStrings.MonthShortName;
					break;
				case  LOCALECOMPLETEWEEKDAY:    // LOCALECOMPLETEWEEKDAYDEFINE string
					read_index = 1;
					max_index = WEEKDAY_NUMBER;
					max_length = LOCALENAME_MAXLENGTH;
					locale_string = LocalizedStrings.WeekDayName;
					break;
				case  LOCALESHORTWEEKDAY:       // LOCALESHORTWEEKDAYDEFINE string
					read_index = 1;
                    max_index = WEEKDAY_NUMBER;
					max_length = LOCALENAME_SHORTLENGTH;
					locale_string = LocalizedStrings.WeekDayShortName;
					break;
				case  LOCALEAMEQUIVALENT:       // LOCALEAMEQUIVALENTDEFINE string
					max_length = LOCALENAME_SHORTLENGTH;
					locale_string = LocalizedStrings.AmEquivalent;
					break;
				case  LOCALEPMEQUIVALENT:       // LOCALEPMEQUIVALENTDEFINE string
					max_length = LOCALENAME_SHORTLENGTH;
					locale_string = LocalizedStrings.PmEquivalent;
					break;
				default:
					locale_string = 0;
			}
			if (read_index)
			{
				unsigned long int  l;
				
				l = strtoul(linepointer + strlen(LocaleCategory[i]), &linepointer, 10);		// read following number n
				if ((l > 0) && (l <= max_index))	// if is a valid number, increment buffer pointer
					locale_string = (void *)((unsigned long int)locale_string + (l - 1) * max_length);
				else
					locale_string = 0;
			}
			if (locale_string)
			{		// read the following string: it must be enclosed in double quotes and of appropriate length
				char  *start, *end;
				
				if ((start = strchr(linepointer, LOCALENAME_DELIMITERCHAR) + 1) && (end = strchr(start, LOCALENAME_DELIMITERCHAR)) && (end - start < max_length))
					strncpy((char *)locale_string, start, end - start);     // locale_string is the pointer to the buffer with the localized name
                else
					return  ERROR_PROCESSINGFILELOCALE;
			}
		}
	}
	fclose(LocaleFilePointer);
	if (Verbose())
	{
		for (i = 0; i < MONTH_NUMBER; ++i)
			fprintf(stdout, "Month%d complete: %s, short: %s\n", i + 1, LocalizedStrings.MonthName[i], LocalizedStrings.MonthShortName[i]);
		for (i = 0; i < WEEKDAY_NUMBER; ++i)
			fprintf(stdout, "WeekDay%d complete: %s, short: %s\n", i + 1, LocalizedStrings.WeekDayName[i], LocalizedStrings.WeekDayShortName[i]);
		fprintf(stdout, "AM equivalent: %s, PM equivalent: %s\n", LocalizedStrings.AmEquivalent, LocalizedStrings.PmEquivalent);
	}
	return  ERROR_NOERROR;
}
///
//> unsigned char  PatchTemplates(void)
unsigned char  PatchTemplates(void)
{	// patch templates
	int  error = 0;
	
	if (UseLocaleNames())
	{	// if a "-l localefile" switch has been given, localefile is read and the Time and Date templates are localized
 		if (error = LocaleFileRead())
			VersionizeExit(error);
	}	
	error = PatchString(DateFormat);
	error |= PatchString(TimeFormat);
	return  error;
}
///
//> unsigned char  PatchString(char *s)
unsigned char  PatchString(char *s)
{	// localize a string replacing %A, &a, %B and %b tokens respectively with localized week day name, localized week day short name, localized month name and localized month short name
	char  templatecopy[TEMPLATE_MAXLENGTH], *patched_string, patch_buffer[5];
	unsigned short int  si, di;
	unsigned char  patch_status = PATCHSTATUS_IDLE, exit = 0, terminated = 0, modifiedtoken_found;

	for (si = di = 0; (exit == 0) && (si < TEMPLATE_MAXLENGTH); ++si)
	{													// scan templatecopy searching for tokens
  		switch (patch_status)
		{
			case  PATCHSTATUS_IDLE:					// previous char was not a '%' char:
				if (s[si] == TokenSymbol)			// if this is a '%' char, wait for the next char
				{
					if (di >= TEMPLATE_MAXLENGTH - 1)
						exit = 1;						// exit if there is no space left
					else
						patch_status = PATCHSTATUS_FOUNDTOKEN;
				}
				else 									// if it's not a '%' char simply copy it back in s
     			{
					if (!(templatecopy[di] = s[si]))	// if it's the termination char exit
    				    exit = terminated = 1;
   				    else if (++di >= TEMPLATE_MAXLENGTH)
       					exit = 1;                       // exit if there is no space left
              	}	
				break;
			case  PATCHSTATUS_FOUNDTOKEN:            // previous char was a '%' char:
			case  PATCHSTATUS_FOUNDMODIFIEDTOKEN:	 // previous chars were "%-":
				modifiedtoken_found = 0;
				patched_string = 0;
				switch (s[si])
				{
					case  'A': 							// %A token found: replace it with LocaleWeekDayName
						patched_string = UseLocaleNames() ? LocalizedStrings.WeekDayName[LocalTime->tm_wday] : 0;
						break;
					case  'B':                          // %B token found: replace it with LocaleMonthName
						patched_string = UseLocaleNames() ? LocalizedStrings.MonthName[LocalTime->tm_mon] : 0;
						break;
					case  'a':                          // %a token found: replace it with LocaleWeekDayShortName
						patched_string = UseLocaleNames() ? LocalizedStrings.WeekDayShortName[LocalTime->tm_wday] : 0;
						break;
					case  'b':                          // %b token found: replace it with LocaleMonthShortName
						patched_string = UseLocaleNames() ? LocalizedStrings.MonthShortName[LocalTime->tm_mon] : 0;
						break;
					case  'p':                          // %p token found: replace it with LocaleAm/PmEquivalent
						patched_string = UseLocaleNames() ? ((LocalTime->tm_hour < 12) ? LocalizedStrings.AmEquivalent : LocalizedStrings.PmEquivalent) : 0;
						break;
					case  '_':                          // %_ token found: replace with a space char
						patched_string = " ";
						break;
					case  '!':                          // %! token found: replace with a ! char          
						patched_string = "!";
						break;
					case  '-':							// %- token found: see if it is a modified token (no zero padding)
						modifiedtoken_found = 1;
						break;
					default:
						if (patch_status == PATCHSTATUS_FOUNDMODIFIEDTOKEN)
						{   							// search for tokens to be patched (%- option)
							int  patch_value;
							unsigned char  patch_found;

							switch (s[si])	// the following tokens are replaced to avoid zero padding
							{
								case  'd':
									patch_value = LocalTime->tm_mday;
									patch_found = 1;
									break;
								case  'H':
									patch_value = LocalTime->tm_hour;
									patch_found = 1;
									break;
								case  'I':
									patch_value = (LocalTime->tm_hour > 12) ? (LocalTime->tm_hour - 12) : (LocalTime->tm_hour > 0) ? LocalTime->tm_hour : 12;
									patch_found = 1;
									break;
								case  'j':
									patch_value = LocalTime->tm_yday;
									patch_found = 1;
									break;
								case  'm':
									patch_value = LocalTime->tm_mon + 1;
									patch_found = 1;
									break;
								case  'M':
									patch_value = LocalTime->tm_min;
									patch_found = 1;
									break;
								case  'S':
									patch_value = LocalTime->tm_sec;
									patch_found = 1;
									break;
								case  'w':
									patch_value = LocalTime->tm_wday;
									patch_found = 1;
									break;
								case  'y':
									patch_value = (LocalTime->tm_year + 1900) % 100;
									patch_found = 1;
									break;
								case  'Y':
									patch_value = LocalTime->tm_year + 1900;
									patch_found = 1;
									break;
			     				default:
									patch_found = 0;
							}
							if (patch_found)
							{
								sprintf(patch_buffer, "%d", patch_value);
								patched_string = patch_buffer;
							}
						}
				}
				if (modifiedtoken_found && (patch_status != PATCHSTATUS_FOUNDMODIFIEDTOKEN))
					patch_status = PATCHSTATUS_FOUNDMODIFIEDTOKEN;
				else
				{
					patch_status = PATCHSTATUS_IDLE;					
					if (patched_string)					// if localization is needed copy patched_string in s
					{
						if ((di + strlen(patched_string)) < TEMPLATE_MAXLENGTH)
						{
							strcpy(&templatecopy[di], patched_string);
	     					di += strlen(patched_string);
	      				}	
						else
							exit = 1;                       // exit if there is no space left
					}
					else
					{
						templatecopy[di++] = '%';	        // else copy '%' and current char in s
						if (!(templatecopy[di] = s[si]))    // if it's the termination char exit
	    					exit = terminated = 1;
	   					else if (++di >= TEMPLATE_MAXLENGTH)
							exit = 1;                       // exit if there is no space left
					}
				}
				break;
		}
	}
	if (terminated)     // if the templated was correctly localized copy back the localized template s and return 0
	{
		strcpy(s, templatecopy);						
		return  0;
	}
	else
		return  1;		// return 1 if an error occurred
}
///
