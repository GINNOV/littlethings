/* CFLOW.C - A C Function Call Chart Generator
 *
 * Version 1.00         December 21st, 1986
 *
 * SYNOPSIS:
 *
 * CFLOW accepts C source code via the standard input and
 * produces a listing of the hierarchy of C function calls
 * on the standard output. Recursive functions are explicitly
 * identified in the listing. The command line format is:
 *
 *      CFLOW < source_file
 *
 * The output listing identifies all functions in the source
 * code and the functions they call (#include files are not
 * recognized). If only specific functions are of interest,
 * (e.g. - fcn1, fcn2, fcn3), a listing for these functions
 * only and the functions they call can be specified with the
 * command line:
 *
 *      CFLOW < source_file fcn1 fcn2 fcn3
 *
 * MODIFICATIONS:
 *
 *   V1.00        - beta test release
 *
 * Adapted from:  "CALLS.C"
 *                The C Programming Tutor
 *                L.A. Wortman & T.O. Sidebottom
 *                Prentice Hall Publishing
 *
 * Adaptation by: Ian Ashdown
 *                byHeart Software
 *                620 Ballantree Road
 *                West Vancouver, B.C.
 *                Canada V7S 1W3
 *
 * USAGE: CFLOW [function_name ...]
 *
 * DIAGNOSTICS:
 *
 * Exit status is 0 if no problems encountered, 2 otherwise.
 *
 * BUGS:
 *
 * Identifiers are limited to 32 characters in length.
 * Recursive calling depth is set at 25.
 *
 **********************************************************************
 *                          LAST CHANGES                              *
 **********************************************************************
 *
 * 14 June, 1994 - Jason Petty
 *
 * Now checks if called from CLI or if invalid file, shows usage then exits
 * with an error status. Does not use 'stdin' for input but instead
 * requires user to specify a filename on the command line.
 *
 * To clear things up a bit here's the Usage:
 *
 *            CFLOW <source_filename> <function name 1> <funcn2> <funcn3>
 *
 * If called:  CFLOW <filename>
 * without function name then the default is to list 'main()'. 
 *
 * Changes marked VANSOFT.
 */

/*** INCLUDE FILES ***/

#include <stdio.h>

/*** DEFINITIONS ***/

#define BOOL            int
#define DEFINED         1       /* Result of find_next() */
#define DEFINING        0       /* Result of find_next() */
#define FALSE           0
#define HASH_TABLE_FULL -1      /* Indicates hash table overflow */
#define HT_SIZE         1009    /* Must be a prime number */
#define INDENT          "    "  /* Default output indentation */
#define INDENT_SIZE     4       /* Number of spaces in indentation */
#define MAXDEPTH        25      /* Maximum recursive-calling depth */
#define MAXSYMLEN       32      /* Maximum significant characters
                                   in a symbol */
#define PGWIDTH         80      /* Default output page width */
#define TRUE            1

/*** CODE MACROS ***/

#define GENERATE_NEW_INDEX(x,y)  (((x+y*y) % HT_SIZE)+1)

/*** TYPEDEFS ***/

typedef struct itype
{
  struct ntype *name_defn;      /* Name for this instance */
  struct itype *next_callee;    /* Next instance called */
}
INSTANCE,
*P_INSTANCE;

typedef struct ntype
{
  char fcn_name[MAXSYMLEN];    /* Unique function name */
  int call_cnt,                /* Number of times function called */
      first_num;               /* Line when function name first printed */
  struct ntype *next_pname;    /* Next function name in the list */
  P_INSTANCE first_callee;     /* Pointer to instance describing the
                                * first call for this function */
}
NAME,
*P_NAME;

/*** GLOBAL VARIABLES ***/

int line_cnt = 0,       /* Line count */
    maxact_index = 0,   /* Indexes active list from 0 to MAXDEPTH */
    tabs_page = (PGWIDTH-MAXSYMLEN)/INDENT_SIZE,  /* Tabs per page */
    bkt_cnt = 0;        /* Keeps track of the nesting of brackets. A
                         * function found when "bkt_cnt" is zero
                         * must be its DEFINING occurrence, since
                         * function invocations must always appear
                         * within some block of code. */
char *hash_table[HT_SIZE];
BOOL terse = TRUE;
P_NAME name_head = NULL,
       active_list[MAXDEPTH];      /* Used by output() to avoid */
                                   /* infinite recursion */

FILE *infile=NULL;          /* Don't use stdin. Added, VANSOFT. */
char *malloc();
void usage();


void usage(op) /* Added. VANSOFT. */
int op;
{
 printf("\n\nCFLOW V1.0 - 21.12.86.\n");
 printf("Authors:  L.A. Wortman, T.O. Sidebottom & Ian Ashdown.\n\n");
 
 printf("SYNOPSIS:\n");
 printf("CFLOW accepts C source code via the standard input and\n");
 printf("produces a listing of the hierarchy of C function calls\n");
 printf("on the standard output. Recursive functions are explicitly\n");
 printf("identified in the listing.\n\n");

 printf("USAGE:  CFLOW <source_file> <function_name1> <funcn2> <funcn3>\n\n");

 if(!op) /* exit error. */
    exit(10);
}

/*** MAIN BODY OF CODE ***/

int main(argc,argv)
int argc;
char *argv[];
{
  int actlist_index,
      arg_index = 2,
      fcn_use,
      hashtbl_index;
  char id[MAXSYMLEN];
  P_NAME pcaller,
         pname,
         look_for(),
         find_name();
  BOOL insert_word();
  void new_fcn(),
       output(),
       error();

     if(!argc)     /* May have been run from Workbench. VANSOFT. */
        exit(10);
     if(argc <= 1) /* Not enough args. VANSOFT. */
        usage(NULL);

     if(!(infile = fopen(argv[1], "r"))) /* Added, VANSOFT. */
           {
            usage(1);  /* 1 = don't 'exit()' yet. */
            fprintf(stdout, "%s: Can't access %s!\n\n",argv[0],argv[1]);
            exit(10);  /* exit error. */ 
            }

  /* Initialize the hash table */

  for(hashtbl_index = 0; hashtbl_index < HT_SIZE; hashtbl_index++)
    hash_table[hashtbl_index] = NULL;

  /* The following are keywords that look like function calls in C */

  insert_word("for");
  insert_word("if");
  insert_word("return");
  insert_word("sizeof");
  insert_word("switch");
  insert_word("while");

  /* Initialize the active list */

  for(actlist_index = 0; actlist_index < MAXDEPTH; )
    active_list[actlist_index++] = NULL;

  /* Parse the input stream and build the appropriate tables */

  pcaller = NULL;
  while((fcn_use = find_next(id,pcaller)) != EOF)
    if(fcn_use == DEFINING)
      pcaller = find_name(id);
    else
      new_fcn(id,pcaller);

  /* If there are any command line arguments, they are the names
   * of the functions from which to begin the call charts.
   */

  if(arg_index < argc)
  {
    do
    {
      if(pname = look_for(argv[arg_index]))
      {
        output(pname,NULL);
        putchar('\n');
      }
      else
        printf("\007\nERROR: Function %s not found.\n",
            argv[arg_index]);
    }
    while((++arg_index) < argc)
      ;
  }
  else
  {
    /* Print beginning with "main", if there is one */

    if(pname = look_for("main"))
    {
      output(pname,NULL);
      putchar('\n');
      pname->call_cnt = 1;  /* Don't print "main" again later */
    }

    /* Now print all functions not called by anyone else */

    for(pname = name_head; pname; pname = pname->next_pname)
      if(pname->call_cnt == NULL)
      {
        output(pname,NULL);
        putchar('\n');
      }

    /* Finally, print any mutually recursive functions */

    for(pname = name_head; pname; pname = pname->next_pname)
      if(pname->first_num == NULL)
      {
        output(pname,NULL);
        putchar('\n');
      }
  }
}

/*** FUNCTIONS ***/

/* FIND_NEXT() - Sets its argument to the name of the next function
 *               found in the input stream. It returns as its value
 *               DEFINING if this is the defining occurrence of the
 *               function, DEFINED if it is simply an invocation of
 *               the function, and EOF if the input stream is
 *               exhausted.
 */

int find_next(id,cur_fcn)
char *id;
P_NAME cur_fcn;
{
  int cur_ch;
  BOOL find_word(),
       is_valid(),
       seen();
  void scan(),
       error();

  while(TRUE)
  {
    cur_ch = getc(infile);
    if(is_valid(cur_ch))
    {
      ungetc(cur_ch,infile);
      scan(id);
    }
    else
    {
      switch(cur_ch)
      {
        case '\t':      /* Skip over white space */
        case ' ':
          break;
        case '\n':      /* Skip over preprocessor lines */
          if((cur_ch = getc(infile)) == EOF)
            return EOF;
          else if(cur_ch == '#')
          {
            while((cur_ch = getc(infile)) != '\n')
              if(cur_ch == '\\')
                getc(infile); /* Continuation */
          }
          else
            ungetc(cur_ch,infile);
          break;
        case '\'':      /* Skip over character literals */              
          id[0] = '\0';
          while((cur_ch = getc(infile)) != '\'')
            if(cur_ch == '\\')
              getc(infile);   /* Continuation */
          break;
        case '\"':      /* Skip over string literals */
          while((cur_ch = getc(infile)) != '\"')
            if(cur_ch == '\\')
              getc(infile);     /* Continuation */
          break;
        case '\\':
          id[0] = '\0';
          getc(infile);
          break;
        case '{':
          bkt_cnt++;
          id[0] = '\0';
          break;
        case '}':
          bkt_cnt--;
          if(bkt_cnt < 0)
            error("Brackets are not properly nested.");
          id[0] = '\0';
          break;
        case '(':
          if(id[0] == '\0')
            break;               /* No function name was found */
          if(!find_word(id))     /* Ignore any words in hash table */
          {
            if(bkt_cnt == NULL)  /* Not within body of a function */
              return DEFINING;
            else if(!seen(id,cur_fcn))
              return DEFINED;   /* Ignore multiples occurrences within
                                 * a function */
          }
          id[0] = '\0';
          break;
        case EOF:
          return EOF;
        case '/':
          if((cur_ch = getc(infile)) == '*')  /* Skip over comments */
          {
            while(TRUE)
            {
              while(getc(infile) != '*')
                ;
              if((cur_ch = getc(infile)) == '/')
                break;
              ungetc(cur_ch,infile);
            }
          }
          else
            ungetc(cur_ch,infile);  /* Must be delimit identifiers */
          break;
        default:
          id[0] = '\0';
          break;
      }
    }
  }
}

/* SCAN() - Scans the input stream until a token is found that
 *          might be the name of a function. It returns the atom
 *          found.
 */

void scan(token)
char *token;
{
  int cur_ch,
      str_index;
  BOOL is_valid();
  void error();

  for(str_index = 0; cur_ch = getc(infile),is_valid(cur_ch); )
  {
    token[str_index++] = cur_ch;
    if(str_index >= MAXSYMLEN)
      error("Symbol name too long.");
  }
  token[str_index] = '\0';
  ungetc(cur_ch,infile);
}

/* FIND_WORD() - Looks up an identifier in the hash table and returns
 *               TRUE or FALSE to indicate the presence or absence of
 *               the identifier.
 */

BOOL find_word(word)
char *word;
{
  int hashtbl_index;

  hashtbl_index = hash(word);
  if((hashtbl_index == HASH_TABLE_FULL) ||
      (hash_table[hashtbl_index] == NULL))
    return FALSE;
  else
    return TRUE;
}

/* SEEN() - Determines if the argument string "check_id" has already
 *          been seen as the argument function.
 */

BOOL seen(check_id,cur_fcn)
char *check_id;
P_NAME cur_fcn;
{
  P_INSTANCE pinstance;

  for(pinstance = cur_fcn->first_callee; pinstance != NULL;
      pinstance = pinstance->next_callee)
    if(!strcmp(check_id,(pinstance->name_defn)->fcn_name))
      return TRUE;

  return FALSE;
}

/* FIND_NAME() - Returns a pointer to the argument name on the
 *               linked list of names. If the name is not there,
 *               a new "name" is created.
 */

P_NAME find_name(name)
char *name;
{
  P_NAME last_pname = NULL,
         pname,
         new_pname,
         add_name();
  int strtest;

  /* Search for the name in the current list of known, defined
   * functions. Since the names are inserted in sorted order, stop
   * when we have passed the new name in the list.
   */

  for(pname = name_head;
      pname != NULL &&
      (strtest = strcmp(name,pname->fcn_name)) >= NULL;
      last_pname = pname,pname = pname->next_pname)
    if(!strtest)
      return pname;

  /* Name not found, so add it */

  new_pname = add_name();
  strcpy(new_pname->fcn_name,name);

  /* Link the new name entry into the appropriate place in the chain */ 

  new_pname->next_pname = pname;
  if(!last_pname)
    name_head = new_pname;
  else
    last_pname->next_pname = new_pname;

  return new_pname;
}

/* ADD_NAME() - Allocate storage for a name entry */

P_NAME add_name()
{
  P_NAME pname;
  char *malloc();
  void error();

  if(!(pname = (NAME *)malloc(sizeof(NAME))))
    error("Ran out of memory.");

  /* Initialize the new entry */

  pname->fcn_name[0] = '\0';
  pname->call_cnt = 0;
  pname->first_num = 0;
  pname->first_callee = NULL;
  pname->next_pname = NULL;

  return pname;
}

/* NEW_FCN() - Creates an instance for a function use. */

void new_fcn(name,pcaller)
char *name;
P_NAME pcaller;
{
  P_INSTANCE pinstance,
             new_pinstance,
             add_instance();
  P_NAME pname,
         find_name();
  
  /* Create the new instance and link it with a name that
   * describes it.
   */

  pinstance = pcaller->first_callee;
  pname = find_name(name);
  new_pinstance = add_instance();
  new_pinstance->name_defn = pname;

  if(pinstance != NULL)
  {
    /* Run down the callee chain until a NULL link is found */

    for(;pinstance->next_callee != NULL;
        pinstance = pinstance->next_callee)
      ;         /* No body */

    /* Now add the instance to the callee chain */

    pinstance->next_callee = new_pinstance;
  }
  else
    pcaller->first_callee = new_pinstance;

  /* Increment the callee's call count */

  (pname->call_cnt)++;
}

/* ADD_INSTANCE() - Allocate storage for an instance. */

P_INSTANCE add_instance()
{
  P_INSTANCE pinstance;
  char *malloc();
  void error();

  if(!(pinstance = (INSTANCE *)malloc(sizeof(INSTANCE))))
    error("Ran out of memory.");

  pinstance->name_defn = NULL;
  pinstance->next_callee = NULL;

  return pinstance;
}

/* LOOK_FOR() - Looks for its argument name on the linked list
 *              of names. If found, it returns a pointer to the
 *              entry; otherwise it returns NULL.
 */

P_NAME look_for(name)
char *name;
{
  P_NAME pname;

  for(pname = name_head; pname != NULL; pname = pname->next_pname)
    if(!strcmp(name,pname->fcn_name))
      return pname;

  return NULL;
}

/* OUTPUT() - A recursive routine that prints one tab for each
 *            level of nesting, then the name of the function
 *            called, followed by the next function called at the
 *            same level. In doing this, it invokes itself to
 *            output the names of the functions called by the
 *            current function. It maintains an active list of
 *            functions currently being output by the different
 *            levels of recursion, and if it finds itself being
 *            asked to output one which is already active, it
 *            terminates, marking that call with an asterisk.
 */

void output(pname,cur_tab)
P_NAME pname;
int cur_tab;
{
  int loop_cnt,
      num_tabs,
      tab_cnt;
  P_INSTANCE pinstance;
  BOOL page_overflow,
       make_active();
  void backup(),
       output();

  num_tabs = cur_tab;
  line_cnt++;
  printf("\n%4d",line_cnt);
  if(!make_active(pname))
    putchar('*');       /* Calls nested too deep */
  else
  {
    for(tab_cnt = 0; num_tabs > tabs_page; tab_cnt++)
      num_tabs -= tabs_page;
    for(loop_cnt = 0; loop_cnt < tab_cnt; loop_cnt++)
      putchar('<');
    putchar(' ');
    for(loop_cnt = 0; loop_cnt < num_tabs; loop_cnt++)
      printf(INDENT);

    if(isactive(pname))  /* Recursive call */
      printf("%s [recursive]",pname->fcn_name);
    else
    {
      pinstance = pname->first_callee;
      if(pinstance != NULL)
      {
        printf("%s",pname->fcn_name);
        if(!terse || (pname->first_num == 0))
        {
          cur_tab++;
          if(pname->first_num == 0)
            pname->first_num = line_cnt;
          if((cur_tab > tabs_page) &&
              (cur_tab % tabs_page == 1) &&
              (pinstance->next_callee != NULL))
          {
            printf("\n- - - - - - - - - - - - - - - - -");
            printf(" - - - - - - - - - - - - - - - - -");
            page_overflow = TRUE;
          }
          else
            page_overflow = FALSE;

          for(; pinstance != NULL; pinstance = pinstance->next_callee)
            output(pinstance->name_defn,cur_tab);

          if(page_overflow)
          {
            printf("\n- - - - - - - - - - - - - - - - -");
            printf(" - - - - - - - - - - - - - - - - -");
            page_overflow = FALSE;
          }
        }
        else if(pinstance != NULL)
          printf(" ... [see line %d]",pname->first_num);
      }
      else  /* Library, external or macro call */
        printf("%s",pname->fcn_name);
    }
    backup();
    if(pname->first_num == 0)
      pname->first_num = line_cnt;
  }
}

/* MAKE_ACTIVE() - Puts a pointer to the argument "cur_name"
 *                 into the "active_list". FALSE is returned if
 *                 the argument fails because the function nesting
 *                 is too deep; otherwise TRUE is returned.
 */

BOOL make_active(cur_name)
P_NAME cur_name;
{
  if(maxact_index < MAXDEPTH)
  {
    active_list[maxact_index++] = cur_name;
    return TRUE;
  }
  else
    return FALSE;
}

/* ISACTIVE() - Checks if its argument is already on the active
 *              list.
 */

BOOL isactive(cur_name)
P_NAME cur_name;
{
  int actlist_index;

  for(actlist_index = 0; actlist_index < maxact_index - 1;
      actlist_index++)
    if(cur_name == active_list[actlist_index])
      return TRUE;

  return FALSE;
}

/* BACKUP() - Pops an item from the active stack. */

void backup()
{
  void  error();

  if(!(maxact_index > 0))
    error("Recursion depth exceeds permissible number of levels.");
  active_list[maxact_index--] = NULL;
}

/* COPY() - Copies a string and returns the address of the copy */

char *copy(old_str)
char *old_str;
{
  char *new_str,
       *str_ptr,
       *malloc();

  /* Allocate a string able to hold the length of the string plus one
   * for the terminator.
   */

  str_ptr = new_str = malloc(strlen(old_str) + 1);

  /* Copy the the string and return a pointer to it */

  while(*new_str++ = *old_str++)
    ;

  return str_ptr;
}

/* ERROR() - Report any errors detected and return 2 to parent
 *           process.
 */

void error(message)
char *message;
{
  fprintf(stderr,"\007\nERROR: %s\n",message);
  exit(2);
}

/* HASH() - Generates a unique hash table index for the argument 
 *          identifier. The value of HASH_TABLE_FULL is returned
 *          if the hash table overflows.
 */

int hash(word)
char *word;
{
  int hashtbl_index,
      init_index,
      probe_cnt = 0;

  hashtbl_index = init_index = transform(word);
  if(hash_table[hashtbl_index] == NULL)
    ;   /* Got it */
  else  /* Have we found the correct index? */
    if(!strcmp(word,hash_table[hashtbl_index]))
      ; /* Direct hit */
    else        /* Collision - generate indices */
      for(; probe_cnt < (HT_SIZE/2); probe_cnt++)
      {
        hashtbl_index = GENERATE_NEW_INDEX(init_index,probe_cnt);
        if((hash_table[hashtbl_index] == NULL) ||
            !strcmp(word,hash_table[hashtbl_index]))
          break;        /* We've got it */
      }
  if(probe_cnt >= (HT_SIZE/2))
    return HASH_TABLE_FULL;
  return hashtbl_index;
}

/* INSERT_WORD() - Inserts an identifier into the hash table and
 *                 returns TRUE. If the hash table overflows, FALSE
 *                 is returned.
 */

BOOL insert_word(word)
char *word;
{
  int hashtbl_index;

  if((hashtbl_index = hash(word)) == HASH_TABLE_FULL)
    return FALSE;

  /* Add word to the hash table if it is not already present */

  if(hash_table[hashtbl_index] == NULL)
    hash_table[hashtbl_index] = copy(word);

  return TRUE;
}

/* IS_VALID() - Returns 1 if 'ch' is a valid character to begin a C
 *             token, 0 otherwise.
 */

BOOL is_valid(ch)
char ch;
{
  return (isalpha(ch) || ch == '_') ? 1 : 0;
}

/* TRANSFORM() - Converts an identifier into an integer within the
 *               index range of the hash table. A polynomial is
 *               generated and reduced modulo HT_SIZE to produce
 *               this number.
 */

int transform(word)
char word[];
{
  int term = 0,
      wordindex;

  for(wordindex = strlen(word)-1; wordindex >= 0; wordindex--)
    term = (257 * term) + word[wordindex];
  term = term < 0 ? -term : term;
  return term % HT_SIZE;
}

/*
 * Returns true if the character c is alpha.
 */

isalpha(c)
char c;
{
 if ( ('A' <= c && c <= 'Z')
   || ('a' <= c && c <= 'z') )
   return 1;
 return 0;
}

/* End of CFLOW.C */


