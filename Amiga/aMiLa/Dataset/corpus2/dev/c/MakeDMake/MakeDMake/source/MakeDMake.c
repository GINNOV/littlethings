/*
 *      NAME:           MakeDMake v0.22
 *
 *      PURPOSE:        Automatically construct a makefile for DICE's DMake
 *
 *		PROGRAMMER:		Er... well...
 *						the idea, portability, elegant calls-by-reference &
 *						70 percent of the code -- Tim McGrath
 *
 *						quick'n'dirty globals -- Piotr Obminski
 *
 *
 *      LAST CHANGED:   04 July 1993
 *
 *      COMPILED:       with (registered) DICE (but guess HOW??)
 *
 */

#include <stdio.h>

#define LINEMAX			80		/* length of line in created DMakeFile */
#define CC_NAME         "dcc"

/*
 * default name for executable (only if if given two or more C files).
 * NO '.' (like in 'a.out') please! This is still no UNIX!
 */
#define MAIN_NAME       "main"

/*
 * default name for the executable
 */
#define OUTFILE_NAME    "DMakeFile"

/*
 * zero if we want call outfile 'DMakeFile' instead of the individualized
 * (unique) name in the form '<executable>.make'
 */
#define UNIQUE_OUTNAME	0

/*
 * ANSI sequences, #define them here as '""' (no single quotes)
 * if you hate 'em!
 */
#define	ANSI_BOLD	"›1m"
#define	ANSI_WHITE	"›2m"				/* virtual white */
#define ANSI_NORMAL	"›0m"

char main_name[ 80 ] = MAIN_NAME;

/*
 * default OPT1 & OPT2 strings -- change if you want hardwired options
 */
#define O2X_OPT         NULL            /* 'object to executable' options */
#define C2O_OPT         NULL            /* 'C to object' options */

/*
 * Something like that? Got no "Interface Style Guide" or what's it called...
 */
const char VersionString[] = "$VER: MakeDMake 0.22 (04.07.93) by Piotr Obminski";


char linking_opts[ 80 ]		= O2X_OPT;
char compi_opts[ 80 ]		= O2X_OPT;

FILE *OutFile;

void main(), depend_file(), output_objects(), start_line(), continue_line(),
	get_dependents(), move_name(), scan_file();


	void
main( argc, argv )
    char	**argv;
    int 	argc;
{
    int dependent_count;
    char **dependents;
    char outfile_name[ 40 ] = OUTFILE_NAME;
	char temp[ 80 ] = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
	int good_file_count = 0;
    int i;
	char *p;

    /*
	 * no input or '?', 'h', 'H' or something beginning with '-', so
	 * he needs help!
     */
    if ( argc == 1 || ( *argv[ 1 ] == '?' ) || ( *argv[ 1 ] == '-' ) ||
            ( ( *argv[ 1 ] == 'h' ) && ( *( argv[ 1 ] + 1 ) == '\0' ) )	||
			( ( *argv[ 1 ] == 'H' ) && ( *( argv[ 1 ] + 1 ) == '\0' ) ) ) {

        puts( "------------------------------------------------------------\n"
				ANSI_BOLD "MakeDMake v0.22" ANSI_NORMAL ANSI_WHITE
				"  PD Utility for creating" ANSI_NORMAL ANSI_BOLD
				" DMakeFile" ANSI_NORMAL "'s\n"
        		"------------------------------------------------------------\n"
        		ANSI_WHITE "USAGE:  " ANSI_NORMAL "Give me names of your "
				ANSI_BOLD "source files " ANSI_NORMAL
				"and then we'll\n"
				"        get interactive.  If I'm successful, the resulting\n"
				"        " ANSI_BOLD "DMakeFile" ANSI_NORMAL
				" will be in the current directory.\n"
				"        Now that you know -- "
				ANSI_BOLD "START AGAIN" ANSI_WHITE " !\n" ANSI_NORMAL
        		"------------------------------------------------------------" );

        exit( 1 );
    }

	/*
	 * if we got only one command-line argument (from shell!), and it
	 * ends in '.c', we start by cutting off this '.c', then we look...
	 */
	if ( argc == 2 ) {
		strcpy( temp, argv[ 1 ] );
		if ( ( p = (char *)strstr( temp, ".c" ) ) &&
											( *( p + 2 ) == '\0' ) ) {
			*p = '\0';
			strcpy( main_name, temp );
		}
		else {
			puts( ANSI_BOLD "This stuff you gave me ain't no C code!. "
					ANSI_NORMAL ANSI_WHITE "Aborting!" ANSI_NORMAL );
			exit( 1 );
		}
	}

	/*
	 *	get executables name from the user
	 */
    printf( ANSI_WHITE "NAME" ANSI_NORMAL " for the " ANSI_WHITE
			"EXECUTABLE" ANSI_NORMAL " ("
			ANSI_BOLD "<RETURN>" ANSI_NORMAL " for "
			ANSI_WHITE "%s" ANSI_NORMAL "):  ", main_name );

    gets( temp );

	p = temp;
	if ( *p == ' ' || *p == 0x9 ) {
		while ( *p == ' ' || *p == 0x9 )
			p++;
	}
	if ( *p ) {
    	strcpy( main_name, p );

#if UNIQUE_OUTNAME
   		/*
		 * change name of the generated MakeFile to <executable>.make
     	 */
     	strcpy( outfile_name, temp );
     	strcat( outfile_name, ".make" );
#endif

	}

	/*
	 *	get compilation options from the user
	 */
    printf( ANSI_WHITE "OPTIONS" ANSI_NORMAL " for "
			ANSI_WHITE "COMPILATION" ANSI_NORMAL ":  " );

    gets( temp );

	p = temp;
	if ( *p == ' ' || *p == 0x9 ) {
		while ( *p == ' ' || *p == 0x9 )
			p++;
	}
    strcpy( compi_opts, p );

	/*
	 *	get linking options from the user
	 */
    printf( ANSI_WHITE "OPTIONS" ANSI_NORMAL " for "
			ANSI_WHITE "LINKING" ANSI_NORMAL ":      " );

    gets( temp );

	p = temp;
	if ( *p == ' ' || *p == 0x9 ) {
		while ( *p == ' ' || *p == 0x9 )
			p++;
	}
    strcpy( linking_opts, p );

	printf( "------------------------------------------------------------\n" );

    if ( ( OutFile = fopen( outfile_name, "w" ) ) == 0L ) {
        printf( ANSI_BOLD "CAN'T CREATE " ANSI_NORMAL ANSI_WHITE
					"%s" ANSI_NORMAL ANSI_BOLD " !\n\07" ANSI_NORMAL,
					outfile_name );
		exit( 1 );
    }

    fputs( "# DMakeFile generated by MakeDMake v0.22\n\n", OutFile );
    fprintf( OutFile, "OPT1 = %s\nOPT2 = %s\n\n", linking_opts, compi_opts );

    depend_file( argc, argv, main_name, "  ", ".o" );

    for ( i = 1; i < argc; i++ ) {
		/* we don't want MakeDMake to make a fool of himself by
		 * trying to compile various ReadMe's and Trashcan.icon!
		 * So we are skipping such stuff! However it's not always totally
		 * successful, so far...
		 */
		register char *p;
		if ( ( p = (char *)strstr( argv[ i ], ".c" ) ) &&
											( *( p + 2 ) == '\0' ) ) {
        	get_dependents( argv[ i ], &dependents, &dependent_count );
        	depend_file( dependent_count, dependents, argv[ i ], ".o", "" );
        	free_space( dependents, dependent_count );
			good_file_count++;
		}
		else {
			printf( "%s", argv[ i ] );
			if ( strlen( argv[ i ] ) < 16 )
				putchar( '\t' );
			if ( strlen( argv[ i ] ) < 8 )
				putchar( '\t' );

			/*
			 * the 'bad' input-files are NOT TOTALLY ignored, but it's
			 * only cosmetics I thing
			 */
			puts( "\t" ANSI_NORMAL ANSI_WHITE "<" ANSI_NORMAL ANSI_BOLD
					"ignored" ANSI_NORMAL ANSI_WHITE ">" ANSI_NORMAL );
		}
    }

    fclose( OutFile );
	if ( good_file_count == 0 ) {
		puts( ANSI_WHITE "Not even one good C file!" ANSI_NORMAL ANSI_BOLD
				" Who" ANSI_NORMAL "(m) " ANSI_BOLD
				"do you think you're kidding?" ANSI_NORMAL );
		exit( 1 );
	}
	exit( 0 );
}


	int
free_space( dp, dc )
/*
 * Purpose: free up list of file names
 * Inputs:  dp - points to list of pointers to strings
 *          dc - number of pointers in the list
 */
    char	**dp;
    int 	dc;
{
    while ( dc > 0 ) {
        free( *dp++ );
		dc--;
    }
    /* free( dp ); <--- bad, bad boy! */
}


	char *
file_exten( pgm_name, xtension, bufout )
/*
 * Purpose: append new extension onto file name
 * Inputs:  pgm_name - pointer to name of file
 *          xtension - pointer to new file name extension (2 chars only)
 * Outputs: bufout - points to area for new file name
 * Returns: bufout
 */
     char *pgm_name, *xtension, *bufout;
{
    int i = 0;

    while ( *pgm_name ) {
        bufout[ i++ ] = *pgm_name;
        if ( *pgm_name++ == '.' && xtension[ 0 ] != '\0' ) {
            bufout[ i++ ] = xtension[ 1 ];
            break;
        }
    }
    bufout[ i ] = '\0';  return( bufout );
}


	void
depend_file( ct, flist, pgm_name, pgmx, filex )
/*
 * Purpose: print file name and list of dependents
 * Inputs:  ct - number of dependents in the list
 *          flist - pointer to a list of pointers to dependent names
 *          pgm_name - name of file whose dependents are being printed
 *          pgmx - extension for pgm_name file (or "" if none)
 *          filex - extension for dependent file names (or "" if none)
 */
    char **flist, *pgm_name, *pgmx, *filex;
    int ct;
{
    int i;
    char buf[ LINEMAX ], add_name[ LINEMAX ], pname[ LINEMAX ];
    char bare_name[ LINEMAX ];

    {
        register short i = 0;

        do {
            bare_name[ i ] = pgm_name[ i ];
        } while ( pgm_name[ i ] && ( pgm_name[ i++ ] != '.' ) );

        bare_name[ --i ] = '\0';
    }

	start_line( file_exten( pgm_name, pgmx, pname ), buf );

    if ( strcmp( pgm_name, main_name ) )
		strcat( strcat( buf, " " ), pgm_name );

    for ( i = 1; i < ct; i++ ) {

		file_exten( flist[ i ], filex, add_name );

        if ( columns( buf ) + strlen( add_name ) + 1 >= LINEMAX - 1 ) {
            fputs( buf, OutFile ); fputs( "\\\n", OutFile );
            continue_line( file_exten( NULL, NULL, pname ), buf );
        }
        strcat( strcat( buf, " " ), add_name );
    }
    fputs( buf, OutFile ); fputc( '\n', OutFile );

    if ( strcmp( pgm_name, main_name ) ) {
        fprintf( OutFile,"\t%s $(OPT2) -c %s.o %s.c\n\n",
										CC_NAME, bare_name, bare_name );
    }
    else {
        fprintf( OutFile, "\t%s $(OPT1) -o %s ", CC_NAME, main_name );
        output_objects( flist, ct );
        fputs( "\n\n", OutFile );
    }
}


	void
output_objects( files, count )
    char **files;
    int count;
{
    unsigned short i, col, len;
    char arr[ 40 ], *brk1, *brk2;
    register char *p;

    col = 32;       /* more or less initial column */

    for ( i = 1; i < count; i++ ) {
		/* see if file has legal name ending in '.c'
		 */
		if ( ( p = (char *)strstr( files[ i ], ".c" ) ) &&
											( *( p + 2 ) == '\0' ) ) {

        	strcpy( arr, files[ i ] );

        	len = strlen( arr );
        	col += len;

        	if ( col >= LINEMAX - 2 ) {
            	brk1 = "\\\n\t\t\t";
            	brk2 = "";
            	col = 32 + len + 1;
        	}
        	else {
            	brk1 = " ";
            	brk2 = "";
       		}

        	p = (char *)strchr( arr, '.' );
        	*++p = 'o';

        	fprintf( OutFile, "%s%s%s", brk1, arr, brk2 );
		}
    }
}


	void
start_line( with_name, buf )
/*
 * Purpose: give each line a standard indentation
 * Inputs:  with_name - name of root file on each line
 *          buf - place to put indented line
 */
    char *with_name, *buf;
{
    strcpy( buf, with_name ); strcat( buf, "\t" );

    if ( columns( buf ) < 16 )
		strcat( buf, "\t" );

    if ( columns( buf ) < 24 )
		strcat( buf, "\t" );

    strcat( buf, ":" );
}


	void
continue_line( with_name, buf )
/*
 * Purpose: let the line continue after '\' and '\n'
 * Inputs:  with_name - name of root file on each line
 *          buf - place to put indented line
 */
    char *with_name, *buf;
{
    strcpy( buf, with_name );
	strcat( buf, "\t " );

    if ( columns( buf ) < 16 )
		strcat( buf, "\t " );

    if ( columns( buf ) < 24 )
		strcat( buf, "\t " );
}


	int
columns( s )
/*
 * Purpose: count the number of columns a line spans
 * Inputs:  s - the characters in a line
 * Returns: the number of columns ( including tab expansion )
 */
    char *s;
{
    int col = 0;

    while ( *s ) {
        if ( *s++ == '\t' )
			while ( ++col & 7 )
				;
        else ++col;
    }
    return( col );
}


	void
get_dependents( fn, depv, depc )
/*
 * Purpose: return a list of files depending on a C source file
 * Inputs:  fn - name of the c source file
 * Outputs: depv - list of dependents (an array of pointers to filenames)
 *          depc - number of dependents
 */
     char *fn, ***depv;
     int *depc;
{
    char **lst;
    int i;

    lst = (char **)malloc( 1024 * sizeof( char * ) );
    move_name( &lst[ 0 ], fn );
    fputs( fn, stdout ); fputc( '\n', stdout ); i = 0;

    scan_file( lst, &i, fn ); *depv = lst; *depc = i + 1;
}


	void
move_name( p, s )
/*
 * Purpose: Allocate space for a new filename and copy it
 * Inputs:  p - location for new pointer to filename
 *          s - pointer to file name
 */
     char **p, *s;
{
    *p = (char *)malloc( strlen( s ) + 1 );
	strcpy( *p, s );
}


	void
scan_file( file_name_list, last_list_used, fn )
/*
 * Purpose: search a C source file file #includes, and search the #includes
 *          for nested #includes
 * Inputs:  fn - name of file to scan
 * Outputs: file_name_list - list of included files
 *          last_list_used - last used filename position in file_name_list
 */
    char **file_name_list, *fn;
    int *last_list_used;
{
    FILE *fp;
    char buf[ 1024 ], ifn[ LINEMAX ];
    int j,k;

    fp = fopen( fn, "r" );

    if ( ! fp ) {
		fprintf( stdout, ANSI_BOLD "\tcouldn't open file "
					ANSI_NORMAL ANSI_WHITE "%s\n" ANSI_NORMAL, fn );
		return;
	}

    while ( fgets( buf, 1024, fp ) ) {
    	if ( strncmp( buf, "#include", 8 ) == 0 ) {
        	j = 8;
        	while ( buf[ j ] == ' ' || buf[ j ] == '\t' )
				j++;
        	if ( buf[ j++ ] != '"' )
                continue;
            k = 0;
            while ( buf[ j ] ) {
                if ( buf[ j ] == '"' || buf[ j ] == '\n' )
					break;
            	else
					ifn[ k++ ] = buf[ j++ ];
        	}
        	ifn[ k ] = '\0';
        	if ( add_name( file_name_list, last_list_used, ifn ) )
            	scan_file( file_name_list, last_list_used, ifn );
        }
    }
    fclose( fp );
}


	int
add_name( file_name_list, last_list_used, fn )
/*
 * Purpose: Add a file name to the list if it's not there already
 * Inputs:  file_name_list - pointer to array of pointers to file names
 *          last_list_used - last element in array with a filename
 *          fn - name of file
 * Returns: 1 if file name added, 0 otherwise
 */
    char **file_name_list, *fn;
    int *last_list_used;
{
    int i;

    for ( i = 0; i <= *last_list_used; i++ )
        if ( ! strcmp( file_name_list[ i ], fn ) )
			return( 0 );

    *last_list_used += 1;
    move_name( &file_name_list[ *last_list_used ], fn );
    return( 1 );
}

