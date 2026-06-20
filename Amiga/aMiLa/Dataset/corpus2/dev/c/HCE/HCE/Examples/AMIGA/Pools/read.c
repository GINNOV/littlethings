/*
 * Copyright (c) 1994. Author: Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *    read.c:
 *
 *      Read league names and league tables from 'P_TABLES' file.
 *
 */

#include <exec/types.h>
#include <clib/stdio.h>
#include <clib/string.h>
#include <clib/ctype.h>
#include <libraries/dos.h>
#include <dos/dosextens.h>

#include "pools.h"

#define EOP         '\0'    /* End of file or pools input.     */
#define EOK          1      /* Success and not EOP and not EOT. */
#define EOT          2      /* Possible Success but endof table.*/
#define ENT          3      /* No more tables. */

#define TEND        '}'     /* Symbol used to find EOT. */

#define IN_LEN       1024   /* Max chars read at any one time.(file). */
#define SEARCH_NUM   5      /* Number of dirs to search for 'P_TABLES'*/

#define ISWHITE(c)  ((c) == '\t' || (c) == ' ' || (c) == '\n')

char inbuffer[IN_LEN];      /* Read buffer.   */
char prbuf[250];            /* Extract buffer.*/
char g_BUF[128];            /* Any use. */

/* Search paths for the script file. */
char *SCAN_PATH[6] = {"RAM:P_TABLES","P_TABLES", "SYS:P_TABLES",
             "SYS:s/P_TABLES","SYS:devs/P_TABLES",NULL};

/* What to look for in the script file. */
char *W_TYPE[3] = {"LEAGUE", "TABLE", NULL};

/* What to find and avoid getting. */
char V_TYPE[4] = { '{', '=', ',', '\0'};

P_TABLE *t_head=NULL;
P_TABLE *t_end=NULL;

void Test_Incode();
char charin();
int readfile(), readtable();

char charin (infp)        /* Fill inbuffer and keep returning single char,*/
struct FileHandle *infp;  /* repeat till end of file. */
{
    static LONG inpoint=(IN_LEN  - 1);
    static LONG maxin=(IN_LEN - 1);
    LONG Read ();
    char ch;

      if(++inpoint>=maxin)
        {
         maxin=Read(infp,inbuffer,IN_LEN);
         inpoint=0;
         }
    if (maxin==0)
        return (EOP);                   /* End of file. */
    if (maxin == -1) {
        /* printf("Read ERROR!!\n"); */
        return (EOP);                   /* End of file. */
        }

    ch=inbuffer[inpoint];               /* Get a Single char. */

    if (ch < ' ' && ch != '\0' && ch != '\n') /* Remove any weird chars. */
        ch = ' ';

   return (ch);
}


/* Get league name, team & table entries. */

int readtable(infp)
struct FileHandle *infp;
{
  P_TABLE *p;
  int rv;

moret:

  if(!(p = (P_TABLE *) malloc((int)sizeof(P_TABLE)))) {
       /* printf("no memory!!\n"); */
       return(NULL);
       }

/* First find 'LEAGUE' and get league name. */ 

       if(!(rv = Find_SYM(infp,W_TYPE[0])))
            return(ENT);                 /* No more tables. */
       if(rv == EOT)                     /* Should not find EOT yet! */
            return(NULL);
       if(!(rv = Next_SYM(infp,g_BUF)))  /* This should be league name. */
          return(NULL);
       if(rv == EOT)
          return(NULL);
          strcpy(p->league,g_BUF);       /* Get what should be league name*/

/* Next find 'TABLE' and fill *p with team names + team form numbers. */

       if(!(rv = Find_SYM(infp,W_TYPE[1])))
            return(NULL);
       if(rv == EOT)                    /* Should not find EOT yet! */
            return(NULL);
       if(!(rv = Fill_TABLE(infp,p)))   /* Fill table. team names+entries. */
            return(NULL);
       if(rv != EOT)                    /* Should be EOT here. */
            return(NULL);

  if(t_head == NULL) {    /* Add new table to list. */
     p->next = NULL;
     t_head = p;
     t_end = t_head;
     }
    else {
           t_end->next = p;
           t_end = t_end->next;
           t_end->next=NULL;
          }

 goto moret;
}

/* Fill a pools table with team name + form numbers. */

int Fill_TABLE(infp,p)
struct FileHandle *infp;
P_TABLE *p;
{
 char c;
 int rv;
 int xcount=0;
 int ycount=0;

  while((rv = Next_SYM(infp,g_BUF)))
        {
         c = g_BUF[0];

        if(rv == EOT) {             /* End of table? */
           p->count = ycount-1;
           return(EOT);
           }
        if((ycount-1) >= MAX_TABLE) {   /* More teams than allowed?. */
           p->count = ycount-1;
           return(EOT);
           }
        if(isdigit(c)) {            /* Number to get?. */
           if(xcount >= MAX_ENTRIES) {
/*            printf("Team: %s has to many numbers\n", p->team[ycount-1]); */
              xcount++;
              }
             else {
/*                 printf(":%s:    - %d\n", g_BUF, atoi(g_BUF)); */
                   p->table[ycount-1][xcount] = atoi(g_BUF);
                   xcount++;
                   }
           }
         else                     /* Team to get?. */
           {
            strcpy(p->team[ycount],g_BUF);
            ycount++;
            xcount=0;
            }
        }
  p->count = 0;
return(NULL);
}

int readfile()    /* Open P_TABLE file and read tables in. */
{
    struct FileHandle *infp=NULL;
    BPTR lock=NULL;
    int i=0;

                     /* Search RAM:," ",SYS:, SYS:s/ ,SYS:devs/ */
                     /* for the script file.                    */
   while(lock==NULL && SCAN_PATH[i] != NULL)
           {
            lock=(BPTR)Lock(SCAN_PATH[i],(int)ACCESS_READ);
            i++;
            }

 if(lock==NULL) {
    gfx_FPEN(1);
    gfx_TXT("Could not open 'P_TABLES' file! - (BYE ... BYE ...)",25,6);
    Delay(200);
    return(NULL);    /* no script file!. */
    }
     if(!(infp=(struct FileHandle *)OpenFromLock((BPTR)lock))) {
       /*  printf("No open from lock!!\n"); */
           UnLock(lock);
           return(NULL);
           }

  /* Search for league heading then read table in. */

      if(!(readtable(infp))) {
           gfx_FPEN(1);
           gfx_TXT("WARN: Error reading 'P_TABLES' file!!",25,6);
           Close(infp);
           return(NULL);
           }

      Close(infp);
 return (1);
}


int ch_OK(c)  /* Check for symbols to be avoided Example: '{' or '=' */
char c;       /* if symbol found return 0 else 1. */
{
 int i=0;

  while(V_TYPE[i] != '\0')
      {
      if(V_TYPE[i++] == c)
         return(0);
       }

return(1);
}

int Next_SYM(infp,s)       /* Find next valid Word/Symbol and put it in *s */
struct FileHandle *infp;
char *s;
{
 char c;
 int i;

redo:

     i=0;

   do {                  /* Find first legal character. */
          c = charin(infp);

       if(c == '*' || c == ';') /* Skip Comment, goto next line. */
            while(c != '\n' && c != EOP)
                  c = charin(infp);                
       }
   while(c != EOP && ISWHITE(c));

  if(c == EOP) {
     return(NULL);
     }

   do {                  /* Found first so see if its a word. */
       if(ch_OK(c)) {
          prbuf[i++] = c;
          c = charin(infp);
          }
        else {
               c = ' ';
              }
       }
   while(c != EOP && c != ' ' && c != '\n');

          prbuf[i] = '\0';

       if(prbuf[0] != '\0') {   /* Found a valid Word/Symbol */
              strcpy(s,prbuf);
           if(prbuf[0] == TEND)
              return(EOT);
            else
              return(EOK);
              }
         
         prbuf[0] = '\0';

  if(c == EOP) {
     return(NULL);
     }

 goto redo;
}

int Find_SYM(infp,s)     /* Find symbol *s, if reached EOP return NULL. */
struct FileHandle *infp;
char *s;
{
 char c;
 int rv;

  while((rv = Next_SYM(infp,g_BUF)))
       {
        if(rv == EOT)             /* End of table? */
           return(EOT);
        if(!(stricmp(g_BUF,s)))   /* Found symbol? */
           return(EOK);
        }

return(NULL);
}


void Test_Incode()      /* Show all tables found. */
{
 int i;

  if(!(readfile()))     /* find and read in P_TABLE file. */
     {
      exit(0);
      }

 if(t_head != NULL) 
  {
  while(t_head != NULL) 
    {
     if(t_head->league[0] != '\0')
        printf("League: %s\n",t_head->league);     /* LEAGUE. */
        i=0;

     while(i <= t_head->count)
        {
     if(t_head->team[i][0] != '\0')
        printf("Team0: %s ",t_head->team[i]);      /* Team NAME. */

        printf("Form:  ");

        printf("%d,",t_head->table[i][0]);         /* Team FORM. */
        printf("%d,",t_head->table[i][1]);
        printf("%d,",t_head->table[i][2]);
        printf("%d,",t_head->table[i][3]);
        printf("%d,",t_head->table[i][4]);
        printf("%d,",t_head->table[i][5]);
        printf("%d\n", t_head->table[i][6]);
        i++;
        }

        t_head = t_head->next;
     }
  }
exit(0);
}
