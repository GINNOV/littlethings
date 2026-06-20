/* $Id: c2man.c,v 2.0.1.35 1994/10/06 06:05:26 greyham Exp $
 *
 * C Manual page generator.
 * Reads C source code and outputs manual pages.
 */
#include <ctype.h>
#include <errno.h>

#include "c2man.h"
#include "enum.h"
#include "strconcat.h"
#include "strappend.h"
#include "manpage.h"
#include "output.h"
#include "patchlevel.h"

#ifdef I_FCNTL
#include <fcntl.h>
#endif

#ifdef I_SYS_FILE
#include <sys/file.h>
#endif

#include <sys/stat.h>
#include <signal.h>

/* getopt declarations */
extern int getopt();
extern char *optarg;
extern int optind;

/* lex declarations */
extern FILE *yyin;      /* lex input stream */

/* Name of the program */
const char *progname = "c2man";

/* Program options */

/* TRUE if static declarations are also output. */
boolean static_out = FALSE;

/* TRUE if variable declarations are output. */
boolean variables_out = FALSE;

/* TRUE if formal parameter promotion is enabled. */
boolean promote_param = TRUE;

/* String output before prototype declaration specifiers */
const char *decl_spec_prefix = "";

/* String output before prototype declarator */
const char *declarator_prefix = " ";

/* String output after prototype declarator */
const char *declarator_suffix = "\n";

/* String output before the first parameter in a function prototype */
const char *first_param_prefix = "\n\t";

/* String output before each subsequent parameter in a function prototype */
const char *middle_param_prefix = "\n\t";

/* String output after the last parameter in a function prototype */
const char *last_param_suffix = "\n";

/* Directory to write output files in */
char *output_dir = NULL;

/* Name of the manual */
char *manual_name = NULL;

/* Section for manual page */
const char *manual_section = NULL;

/* prefix for generated #include lines */
char *header_prefix = NULL;

/* list of include file specified by user */
IncludeFile *first_include;
static IncludeFile **last_next_include = &first_include;

/* list of excluded sections specified by user */
ExcludeSection *first_excluded_section;
static ExcludeSection **last_next_excluded_section = &first_excluded_section;

/* do we group related stuff into one file? */
boolean group_together;

/* was terse description read from file or command line option? */
boolean terse_specified;

/* terse description when grouped together */
char *group_terse = NULL;

/* should we always document parameters, even if it's only "Not Documented" */
boolean always_document_params = TRUE;

/* default output info for each object type */
struct Output_Object_Info output_object[_OBJECT_NUM] =
{
#if 0
    {'c', "class"},
    {'s', "struct"},
    {'e', "enum"},
    {'t', "typedef"},
#endif
    {'f', "function"},
    {'v', "variable"},
    {'F', "static function"},
    {'V', "static variable"}
};

/* Include file directories */
#ifdef MSDOS
int num_inc_dir = 1;
const char *inc_dir[MAX_INC_DIR] = { ".\\" };
#elif AMIGA
int num_inc_dir = 1;
const char *inc_dir[MAX_INC_DIR] = { "include:" };
#else
int num_inc_dir = 2;
const char *inc_dir[MAX_INC_DIR] = { "./", "/usr/include/" };
#endif

/* total number of errors encountered */
int errors;

/* name of the base file being processed; NULL = stdin */
const char *basefile;
Time_t basetime;        /* modification time of base file */
boolean inbasefile;     /* are we parsing in that base file? */

/* is the base file a header file? */
boolean header_file;

#ifdef AMIGA
struct Output *output = &autodoc_output;
#else
/* use nroff output by default */
struct Output *output = &nroff_output;
#endif
/* should we generate the output file named after the input file? */
boolean use_input_name = FALSE;

/* should we generate embeddable files? */
boolean make_embeddable = FALSE;

#define USE_CPP
#ifdef USE_CPP
const char *cpp_cmd = CPP_FILE_COM;
#if defined(MSDOS)
#include "popen.h"
#define popen(c,m)      os_popen(c,m)
#define pclose(f)       os_pclose(f)
#else
#if defined (_MSC_VER)
#define popen(c,m)      _popen(c,m)
#define pclose(f)       _pclose(f)
#endif
#endif
#endif

boolean verbose = FALSE;

/* can cpp read standard input? */
static boolean cppcanstdin
#ifdef CPP_CAN_STDIN
                            = 1
#endif
;
/* does cpp ignore header files */
static boolean cppignhdrs
#ifdef CPP_IGN_HDRS
                            = 1
#endif
;

/* nifty little function for handling I/O errors */
void my_perror(action, filename)
const char *action, *filename;
{
    int err = errno;
    fprintf(stderr,"%s: %s ", progname, action);
    errno = err;
    perror(filename);
}

/* write the #include lines as specified by the user */
void print_includes(f)
FILE *f;
{
    IncludeFile *incfile;
    
    for (incfile = first_include; incfile; incfile=incfile->next)
    {
        char *name = incfile->name;
        boolean surrounded = *name == '"' || *name == '<';
        
        fputs("#include ", f);
        if (!surrounded)        fputc('<',f);
        fputs(name, f);
        if (!surrounded)        fputc('>',f);
        fputc('\n',f);
    }
}

void outmem()
{
    fprintf(stderr,"%s: Out of memory!\n", progname);
    exit(1);
}

#ifndef DBMALLOC
void *safe_malloc(size)
size_t size;
{
    void *mem;

    if ((mem = (void *)malloc(size)) == NULL)
        outmem();

    return mem;
}
#endif

/* Replace any character escape sequences in a string with the actual
 * characters.  Return a pointer to malloc'ed memory containing the result.
 * This function knows only a few escape sequences.
 */
static char *
escape_string (src)
char *src;
{
    char *result, *get, *put;

    result = strduplicate(src);
    put = result;
    get = src;
    while (*get != '\0') {
        if (*get == '\\') {
            switch (*(++get)) {
            case 'n':
                *put++ = '\n';
                ++get;
                break;
            case 't':
                *put++ = '\t';
                ++get;
                break;
            default:
                if (*get != '\0')
                    *put++ = *get++;
            }
        } else {
            *put++ = *get++;
        }
    }
    *put = *get;
    return result;
}

/* Output usage message and exit.
 */
static void
usage ()
{
    int i;

    fprintf(stderr, "usage: %s [ option ... ] [ file ... ]\n", progname);
    fputs(" -o directory\twrite output files in directory\n",stderr);
    fputs(" -p\t\tdisable prototype promotion\n", stderr);
    fputs(" -s\t\toutput static declarations\n", stderr);
    fputs(" -v\t\toutput variable declarations\n", stderr);
    fputc('\n', stderr);
    fputs(" -i incfile\n", stderr);
    fputs(" -i \"incfile\"\n", stderr);
    fputs(" -i <incfile>\tadd #include for incfile to SYNOPSIS\n",
                                                                    stderr);
    fputc('\n', stderr);
    fputs(" -H prefix\tspecify prefix for #include in SYNOPSIS\n", stderr);
    fputc('\n', stderr);
    fputs(" -g\n", stderr);
    fputs(" -G terse\tgroup info from each file into a single page\n",
                                                                    stderr);
    fputs(" -e\t\tmake embeddable files\n", stderr);
    fputc('\n', stderr);
    fputs(" -l ", stderr);
#ifdef HAS_LINK
    fputs("h|", stderr);
#endif
#ifdef HAS_SYMLINK
    fputs("s|", stderr);
#endif
    fputs("f|n|r\t", stderr);
    fputs("linking for grouped pages: ", stderr);
#ifdef HAS_LINK
                  fputs("hard, ", stderr);
#endif
#ifdef HAS_SYMLINK
                                        fputs("soft, ", stderr);
#endif
                                        fputs("file, none or remove\n", stderr);
    fputs(" -n\t\tName output file after input source file\n", stderr);
    fputs(" -L\t\tLazy: Be silent about undocumented parameters\n",
                                                                    stderr);
#ifdef AMIGA
    fputs(" -T n|l|h|t|a[,options]\tselect typesetting output format: nroff, LaTeX, HTML ,TeXinfo or AutoDoc\n",
                                                                    stderr);
    autodoc_output.print_options();
#else
    fputs(" -T n|l|h|t[,options]\tselect typesetting output format: nroff, LaTeX, HTML or TeXinfo\n",
                                                                    stderr);
#endif
    nroff_output.print_options();
    latex_output.print_options();
    html_output.print_options();
    texinfo_output.print_options();

    fputs(" -M name\tset name of the manual in which the page goes\n",
                                                                    stderr);
    fputs(" -x section\texclude section from ouput\n", stderr);
    fputc('\n', stderr);
    fputs(" -D name[=value]\n", stderr);
    fputs(" -U name\n", stderr);
    fputs(" -I directory\tC preprocessor options\n", stderr);
    fputc('\n', stderr);
    fputs(" -F template\tset prototype template in the form ", stderr);
                                    fputs("\"int f (a, b)\"\n",stderr);
    fputs(" -P preprocessor\tAlternate C preprocessor ", stderr);
                                    fputs("(e.g., \"gcc -E -C\")\n", stderr);
    fputs(" -V\t\tbe verbose and print version information\n", stderr);
    fputs(" -S section\tset the section for the manual page (default = 3)\n",
                                                                    stderr);
    fputs(" -O ", stderr);
    for (i = 0; i < _OBJECT_NUM; i++)
        fputc(output_object[i].flag, stderr);
    fputs("[subdir][.ext]", stderr);
    fputs("\tOutput control over different object types:\n\t\t", stderr);
    for (i = 0; i < _OBJECT_NUM; i++)
    {
        fputs(output_object[i].name, stderr);
        if (i <= _OBJECT_NUM - 2)
            fprintf(stderr,i == _OBJECT_NUM-2 ? " or " : ", ");
    }
    fputs(".\n", stderr);
    exit(1);
}

/* name of the temporary file; kept here so we can blast it if hit with ctrl-C
 */
static char temp_name[20];
Signal_t (*old_interrupt_handler)();

/* ctrl-C signal handler for use when we have a temporary file */
static Signal_t interrupt_handler(sig)
int sig;
{
    unlink(temp_name);
    exit(128 + sig);
}

/* open a unique temporary file.
 * To be universally accepted by cpp's, the file's name must end in .c; so we
 * can't use mktemp, tmpnam or tmpfile.
 * returns an open stream & sets ret_name to the name.
 */
FILE *open_temp_file()
{
    int fd;
    long n = getpid();
    FILE *tempf;
    boolean remove_temp_file();

    /* keep generating new names until we hit one that does not exist */
    do
    {
        /* ideally we'd like to put the temporary file in /tmp, but it must go
         * in the current directory because when cpp processes a #include, it
         * looks in the same directory as the file doing the include; so if we
         * use /tmp/blah.c to fake reading fred.h via `#include "fred.h"', cpp
         * will look for /tmp/fred.h, and fail.
         */
        sprintf(temp_name,"c2man%ld.c",n++ % 1000000);
    }
    while((fd =
#ifdef HAS_OPEN3
        open(temp_name,O_WRONLY|O_CREAT|O_EXCL,0666)
#else
        creat(temp_name,O_EXCL|0666)            /* do it the old way */
#endif
                                                ) == -1
                                                        && errno == EEXIST);

    /* install interrupt handler to remove the temporary file */
    old_interrupt_handler = signal(SIGINT, interrupt_handler);

    /* convert it to a stream */
    if ((fd == -1 && errno != EEXIST) || (tempf = fdopen(fd, "w")) == NULL)
    {
        my_perror("error fdopening temp file",temp_name);
        remove_temp_file();
        return NULL;
    }

    return tempf;
}

/* remove the temporary file & restore ctrl-C handler.
 * returns FALSE in the event of failure.
 */
boolean remove_temp_file()
{
    int ok = unlink(temp_name) == 0;    /* this should always succeed */
    signal(SIGINT, old_interrupt_handler);
    return ok;
}

/* process the specified source file through the pre-processor.
 * This is a lower level routine called by both process_stdin and process_file
 * to actually get the work done once any required temporary files have been
 * generated.
 */
int process_file_directly(base_cpp_cmd, name)
const char *base_cpp_cmd;
const char *name;
{
    char *full_cpp_cmd;

#ifdef DEBUG
    fprintf(stderr,"process_file_directly: %s, %s\n", base_cpp_cmd, name);
#endif

#ifdef USE_CPP
    full_cpp_cmd = strconcat(base_cpp_cmd, " ", name, NULLCP);
    if (verbose)
        fprintf(stderr,"%s: running `%s'\n", progname, full_cpp_cmd);

    if ((yyin = popen(full_cpp_cmd, "r")) == NULL) {
        my_perror("error running", base_cpp_cmd);
        free(full_cpp_cmd);
        return 0;
    }
#else
    if (verbose)        fprintf(stderr,"%s: reading %s\n", progname, name);
    if (name && freopen(name, "r", yyin) == NULL)
    {
        my_perror("cannot open", name);
        return 0;
    }
#endif

    parse_file(name);

#ifdef USE_CPP
    free(full_cpp_cmd);
    if (pclose(yyin) & 0xFF00)
        return 0;
#else
    if (fclose(yyin))
    {
        my_perror("error closing", name);
        return 0;
    }
#endif

    return !errors;
}

/* process a specified file */
int process_file(base_cpp_cmd, name)
const char *base_cpp_cmd;
const char *name;
{
    char *period;
    struct stat statbuf;
    
#ifdef DEBUG
    fprintf(stderr,"process_file: %s, %s\n", base_cpp_cmd, name);
#endif
    basefile = name;
    header_file = (period = strrchr(name,'.')) &&
                                        (period[1] == 'h' || period[1] == 'H');

    /* use the file's date as the date in the manual page */
    if (stat(name,&statbuf) != 0)
    {
        my_perror("can't stat", name);
        return 0;
    }
    basetime = statbuf.st_mtime;

    /* should we do this via a temporary file?
     * Only if it's a header file and either CPP ignores them, or the user
     * has specified files to include.
     *
     * For HP/Apollo (SR10.3, CC 6.8), we must always use a temporary file,
     * because its compiler recognizes the special macro "__attribute(p)",
     * which we cannot redefine in the command line because it has parameters.
     */
#ifndef apollo
    if (header_file && (cppignhdrs || first_include))
#endif
    {
        FILE *tempf;
        int ret;

        if (verbose)
            fprintf(stderr, "%s: preprocessing via temporary file\n", progname);

        if ((tempf = open_temp_file()) == NULL)
            return 0;

        print_includes(tempf);
        if (verbose)    print_includes(stderr);

#ifdef apollo
        fprintf(tempf,"#define __attribute(p)\n", basefile);
#endif
        fprintf(tempf,"#include \"%s\"\n", basefile);
        if (verbose)    fprintf(stderr,"#include \"%s\"\n", basefile);

        if (fclose(tempf) == EOF)
        {
            my_perror("error closing temp file", temp_name);
            remove_temp_file();
            return 0;
        }

        /* since we're using a temporary file, it's not the base file */
        inbasefile = 0;
        ret = process_file_directly(base_cpp_cmd, temp_name);
        remove_temp_file();
        return ret;
    }

    /* otherwise, process it directly */
    inbasefile = 1;

    return process_file_directly(base_cpp_cmd,name);
}

/* process the thing on the standard input */
int process_stdin(base_cpp_cmd)
const char *base_cpp_cmd;
{
    if (isatty(fileno(stdin)))
        fprintf(stderr,"%s: reading standard input\n", progname);

    header_file = 0;    /* assume it's not since it's from stdin */
    basefile = NULL;

    /* use the current date in the man page */
    basetime = time((Time_t *)NULL);

    inbasefile = 1;             /* reading stdin, we start in the base file */

    /* always use a temp file if the preprocessor can't read stdin, otherwise
     * only use one if the user specified files for inclusion.
     */
    if (!cppcanstdin || first_include)  /* did user specify include files? */
    {
        FILE *tempf;
        int c, ret;

        if (verbose)
            fprintf(stderr,"%s: reading stdin to a temporary file\n", progname);

        if ((tempf = open_temp_file()) == NULL)
            return 0;

        print_includes(tempf);
        if (verbose)    print_includes(stderr);
        fprintf(tempf,"#line 1 \"stdin\"\n");

        while ((c = getchar()) != EOF)
            putc(c,tempf);

        if (fclose(tempf) == EOF)
        {
            my_perror("error closing temp file", temp_name);
            remove_temp_file();
            return 0;
        }
        ret = process_file_directly(base_cpp_cmd, temp_name);
        remove_temp_file();
        return ret;
    }
    else
    {
        char *full_cpp_cmd = strconcat(base_cpp_cmd," ", CPP_STDIN_FLAGS,
                                                                   NULLCP);
    
        if (verbose)
            fprintf(stderr,"%s: running `%s'\n", progname, full_cpp_cmd);
    
        if ((yyin = popen(full_cpp_cmd, "r")) == NULL) {
            my_perror("error running", full_cpp_cmd);
            return 0;
        }
    
        parse_file(basefile);
    
        free(full_cpp_cmd);
        if (pclose(yyin) & 0xFF00)
            return 0;
    
        return !errors;
    }
}

int
main (argc, argv)
int argc;
char **argv;
{
    int i, c, ok = 0;
    char *s, cbuf[2];
    const char *base_cpp_cmd;
    IncludeFile *includefile;
    ExcludeSection *excludesection;
    char *cpp_opts;
    const char *default_section = "3";
#ifdef HAS_LINK
    enum LinkType link_type = LINK_HARD;        /* for -g/G */
#else
    enum LinkType link_type = LINK_FILE;
#endif

#ifdef YYDEBUG
    extern int yydebug;
#endif

    /* initialise CPP options with -D__C2MAN__ */
    cbuf[0] = VERSION + '0';
    cbuf[1] = '\0';
#ifdef VMS
    cpp_opts = strconcat("-\"D__C2MAN__=", cbuf, "\"",NULLCP);
#else
    cpp_opts = strconcat("-D__C2MAN__=", cbuf, NULLCP);
#ifdef NeXT
    cpp_opts = strappend(cpp_opts, " -D_NEXT_SOURCE", NULLCP);
#endif /* !NeXT */
#endif /* !VMS  */

    /* Scan command line options. */
    while ((c = getopt(argc, argv, "P:D:F:I:psU:Vvo:eM:H:G:gi:x:S:l:LT:nO:"))
                                                                    != EOF)
    {
        switch (c) {
        case 'I':
        case 'D':
        case 'U':
            cbuf[0] = c; cbuf[1] = '\0';
            if (cpp_opts)
                cpp_opts = strappend(cpp_opts," -",cbuf,optarg,NULLCP);
            else
                cpp_opts = strconcat("-",cbuf,optarg,NULLCP);
            break;
        case 'P':
            cpp_cmd = optarg;

            /* with no better info to go on, we have to assume that this
             * preprocessor is minimally capable.
             */
            cppcanstdin = 0;
            cppignhdrs = 1;
            break;
        case 'G':
            group_terse = optarg;
            terse_specified = TRUE;
            /* FALLTHROUGH */
        case 'g':
            group_together = TRUE;
            break;
        case 'F':
            s = escape_string(optarg);

            decl_spec_prefix = s;
            while (*s != '\0' && isascii(*s) && !isalnum(*s)) ++s;
            if (*s == '\0') usage();
            *s++ = '\0';
            while (*s != '\0' && isascii(*s) && isalnum(*s)) ++s;
            if (*s == '\0') usage();

            declarator_prefix = s;
            while (*s != '\0' && isascii(*s) && !isalnum(*s)) ++s;
            if (*s == '\0') usage();
            *s++ = '\0';
            while (*s != '\0' && isascii(*s) && isalnum(*s)) ++s;
            if (*s == '\0') usage();

            declarator_suffix = s;
            while (*s != '\0' && *s != '(') ++s;
            if (*s == '\0') usage();
            *s++ = '\0';

            first_param_prefix = s;
            while (*s != '\0' && isascii(*s) && !isalnum(*s)) ++s;
            if (*s == '\0') usage();
            *s++ = '\0';
            while (*s != '\0' && *s != ',') ++s;
            if (*s == '\0') usage();

            middle_param_prefix = ++s;
            while (*s != '\0' && isascii(*s) && !isalnum(*s)) ++s;
            if (*s == '\0') usage();
            *s++ = '\0';
            while (*s != '\0' && isascii(*s) && isalnum(*s)) ++s;
            if (*s == '\0') usage();

            last_param_suffix = s;
            while (*s != '\0' && *s != ')') ++s;
            *s = '\0';

            break;
        case 'p':
            promote_param = FALSE;
            break;
        case 's':
            static_out = TRUE;
            break;
        case 'V':
            verbose = TRUE;
            fprintf(stderr, "%s: Version %d, Patchlevel %d\n",
                                        progname, VERSION, PATCHLEVEL);
            break;
        case 'v':
            variables_out = TRUE;
            break;
        case 'o':
            output_dir = optarg;
            break;
        case 'M':
            manual_name = optarg;
            break;
        case 'H':
            header_prefix = optarg;
            break;
        case 'i':
            *last_next_include = includefile =
                            (IncludeFile *)safe_malloc(sizeof *includefile);
            includefile->name = optarg;
            includefile->next = NULL;
            last_next_include = &includefile->next;
            break;
        case 'x':
            *last_next_excluded_section = excludesection =
                            (ExcludeSection *)safe_malloc(sizeof *excludesection);
            excludesection->name = optarg;
            excludesection->next = NULL;
            last_next_excluded_section = &excludesection->next;
            break;
        case 'S':
            manual_section = optarg;
            break;
        case 'l':
            switch(optarg[0])
            {
#ifdef HAS_LINK
            case 'h':   link_type = LINK_HARD;  break;
#endif
#ifdef HAS_SYMLINK
            case 's':   link_type = LINK_SOFT;  break;
#endif
            case 'f':   link_type = LINK_FILE;  break;
            case 'n':   link_type = LINK_NONE;  break;
            case 'r':   link_type = LINK_REMOVE;break;
            default:    usage();
            }
            break;
        case 'e':
            make_embeddable = TRUE;
            break;
        case 'n':
            use_input_name = TRUE;
            break;
        case 'L':
            always_document_params = FALSE;
            break;
        case 'T':
            switch(optarg[0])
            {
            case 'n':   output = &nroff_output; default_section = "3";
                        break;
            case 'l':   output = &latex_output; default_section = "tex";
                        break;
            case 't':   output = &texinfo_output; default_section = "texi";
                        break;
            case 'h':   output = &html_output; default_section = "html";
                        break;
            case 'a':   output = &autodoc_output; default_section = "doc";
                        break;
            default:    usage();
            }
            s = strtok(&optarg[1], ",");
            if (s && *output->parse_option == NULL) usage();
            while(s)
            {
              if (output->parse_option(s)) usage();
              s = strtok(NULL, ",");
            }
            break;
        case 'O':
            for (i = 0; i < _OBJECT_NUM; i++)
                if (output_object[i].flag == optarg[0])
                    break;

            if (i == _OBJECT_NUM)
            {
                fprintf(stderr,"%s: -O option must specify one of:\n\t",
                                                                progname);
                for (i = 0; i < _OBJECT_NUM; i++)
                {
                    fprintf(stderr,"%c (%s)", output_object[i].flag,
                        output_object[i].name);
                    if (i <= _OBJECT_NUM - 2)
                        fprintf(stderr,i == _OBJECT_NUM-2 ? " or " : ", ");
                }
                fprintf(stderr, ".\n");
                exit(1);
            }

            if ((s = strchr(++optarg,'.')))     /* look for an extension */
            {
                output_object[i].subdir = alloc_string(optarg, s);
                output_object[i].extension = strduplicate(s+1);
            }
            else
                output_object[i].subdir = strduplicate(optarg);

            break;
        case '?':
        default:
            usage();
        }
    }

    /* make sure we have a manual section */
    if (manual_section == NULL) manual_section = default_section;

#ifdef MALLOC_DEBUG
    getchar();  /* wait so we can start up NeXT MallocDebug tool */
#endif
#ifdef YYDEBUG
    yydebug = 1;
#endif

    if (cpp_opts)
    {
        base_cpp_cmd = strconcat(cpp_cmd, " ", cpp_opts, NULLCP);
        free(cpp_opts);
    }
    else
        base_cpp_cmd = cpp_cmd;

    if (optind == argc) {
        if (use_input_name)
        {
            fprintf(stderr,"%s: %s\n", progname,
                "cannot name output after input file if there isn't one!");
            usage();
        }
        ok = process_stdin(base_cpp_cmd);
    }    
    else
        for (i = optind; i < argc; ++i)
            if (!(ok = process_file(base_cpp_cmd,argv[i])))     break;

    if (ok && firstpage)
        output_manual_pages(firstpage,argc - optind, link_type);
    free_manual_pages(firstpage);
    destroy_enum_lists();

    if (cpp_opts)       free((char *)base_cpp_cmd);

    for (includefile = first_include; includefile;)
    {
        IncludeFile *next = includefile->next;
        free(includefile);
        includefile = next;
    }

    for (excludesection = first_excluded_section; excludesection;)
    {
        ExcludeSection *next = excludesection->next;
        free(excludesection);
        excludesection = next;
    }

    for (i = 0; i < _OBJECT_NUM; i++)
    {
        safe_free(output_object[i].subdir);
        safe_free(output_object[i].extension);
    }

#ifdef DBMALLOC
    malloc_dump(2);
    malloc_chain_check(1);
#endif
#ifdef MALLOC_DEBUG
    sleep(1000000);
#endif
    return !ok;
}
