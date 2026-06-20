/*
 * EasyPools:
 *
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
 *
 * USAGE:
 *
 *      Gives simple pools results based on tables found in the
 *      'P_TABLES' file.
 *      Can send the results to a printer.
 *
 *
 *      This first version of EasyPools is a some what rushed version,
 *      and does not do nearly enough calculations to get good pools results.
 *      It is here merely as an example of using HCE with more than one C
 *      source file. Feel free to improve EasyPools.
 *
 */


#include <exec/types.h>
#include <exec/errors.h>
#include <exec/memory.h>

#include <clib/stdio.h>
#include <clib/string.h>

#include "pools.h"

/* For calculation functions. */
#define G_PLAYED 0
#define G_WON    1
#define G_DRAWN  2
#define G_LOST   3

#define SAME_PLAYED  0x00000001
#define NEAR_PLAYED  0x00000002
#define SAME_WON     0x00000004
#define NEAR_WON     0x00000008
#define SAME_DRAWN   0x00000010
#define NEAR_DRAWN   0x00000020
#define SAME_LOST    0x00000040
#define NEAR_LOST    0x00000080

extern P_TABLE *t_head;     /* Head of table list read in by read.c */


int PRINT_ON=FALSE;         /* flag. Send results to printer?. */
BYTE p_error;               /* flag. General printer error.    */

char PRT_B[5][100];         /* Printer Buffer.     */
char TXT_B[100];            /* Window text buffer. */

char draw_msg[60];  /* Prediction message. */
int home_c=0;       /* Vars - used to calculate chances of a Draw. */
int away_c=0;
int draw_c=0;
int league_c=0;     /* Show/Print league number. */
int coupon_c=0;     /* Show/Print coupon number. */

void main()
{
 long league=0;
 int i=0;
 int quit=0;

 if(!start())      /* Open screen/window/gad/printer set graphics etc. */
      exit(10);    /* EXIT_ERROR. This must succeed to continue!!.   */

 if(!readfile()) { /* Try read the pools tables from disk .*/
      close_shop("ERROR: Could not read tables from disk!!");
      }

      PRINT_ON=FALSE;   /* Keep false for now. */
      Show_LEAGUE_N();  /* Show league names to choose from.   */

 while(!quit)   /* MAIN LOOP */
  {
       league = Get_GMsgs2();   /* Get a valid league number. (gfx_win). */

    if(league != -1)
        {
           league_c = league+1;

       if(league == 1000) 
           quit++;
          else
           Do_LEAGUE(league);

           Show_LEAGUE_N();     /* Reshow league names,( might have */
           league = -1;         /* been trashed). */
        }
   }

close_shop("OK!!"); /* Ok!!. */
}

void close_shop(msg) /* Close and free everything. */
char *msg;
{
  /* printf("%s\n",msg); */
  (void)finish();  /* Must call this!!. (frees all memory gads etc). */
  exit(0);         /* OK!. */
}

void Do_LEAGUE(id)     /* Do Fixtures until IDCMP_CLOSEWINDOW. */
int id;
{
  P_TABLE *pt;
  int i,r,home,away,near;
  WORD endall=0;
  WORD limmit = 0;
  int *h_team,*a_team;
  int *tb[30];
  WORD step;
  char *t_names[30];
  char *p,pb[2];

  draw_msg[0] = '\0';
  draw_msg[1] = '\0';
  pt=t_head;                   /* Head of table list. */

  for(i=0;i < id;i++) {        /* Find correct table. */
      if(pt->next != NULL)
         pt = pt->next;
      }
     
  if(!(Open_GWind(pt->league)))   /* Open wind with new heading. */
      return;

      limmit = pt->count;
      Show_LEAGUE(pt);            /* Show teams. */

  for(i=0;i <= limmit;i++)        /* Get pointers to team form numbers. */
      tb[i] = pt->table[i];

  for(i=0;i <= limmit;i++)        /* Get pointers to team names. */
      t_names[i] = pt->team[i];
 
      Draw_RBOX();                /* Draw pools result box. */
      g_BPEN(10);                 /* Grey. */
      Refresh_GWind();            /* Refresh gadgets in g_window. */

 while(!endall)
  {
   home_c=0;
   away_c=0;
   draw_c=0;
   near=0;
   step=0;

   if(!(Get_Team(&home,limmit))) {        /* Get valid home team. */
        (void)Close_GWind();
         return;                          /* User Quit? */
         }
        Clear_RBOX();                     /* Clear printing area. */
        g_FPEN(1);                        /* White. */
        i = strlen(t_names[home])-1;      /* Get home teams string length*/
        pb[1] = '\0';
        while(i >= 0) {                   /* Print home team in reverse, */
              pb[0] = t_names[home][i];   /* keeps it even to away team. */
              g_TXT(pb,(269-step), RS_Y); /* RS_Y: Result area Y start.  */
              step += 8;
              i--;
              }

        g_TXT("- V`s -",293, RS_Y);

   if(!(Get_Team(&away,limmit))) {  /* Get valid away team. */
        (void)Close_GWind();
         return;                    /* User Quit? */
         }
        g_TXT(t_names[away],365, RS_Y);  /* No need for reverse here. */

        h_team = tb[home];
        a_team = tb[away];
        coupon_c++; /* Inc coupon number. */

/* DEBUG **************************************************************
 printf("HOME TABLE: %d %d %d %d %d %d %d\n",
     h_team[0],h_team[1],h_team[2],h_team[3],h_team[4],h_team[5],h_team[6]);

 printf("AWAY TABLE: %d %d %d %d %d %d %d\n",
     a_team[0],a_team[1],a_team[2],a_team[3],a_team[4],a_team[5],a_team[6]);
***********************************************************************/


/****************** CALCULATIONS *******************/
 
     /* Calc home_c and away_c. */
  near |= cr_GamesPlayed(h_team,a_team);
  near |= cr_GamesWon(h_team,a_team);
  near |= cr_GamesDrawn(h_team,a_team);
  near |= cr_GamesLost(h_team,a_team);

/****** These are not really required! *****
        cr_GamesFor();
        cr_GamesAgainst();
        cr_TeamPoints();
**********************************/

     /* Work out chances of a draw. */

       if(home_c > away_c) {
          draw_c = 100 - (home_c - away_c);
          }
       if(home_c < away_c) {
          draw_c = 100 - (away_c - home_c);
          }
       if(home_c == away_c) {
          draw_c = 100;
          }
       if(draw_c < 0)
          draw_c = 0;

     /* Work out comment to go with  results */
        Do_Comment();

        strcat(draw_msg,"-(");

     if(near & SAME_PLAYED)     /* HOME & AWAY - PLAYED SAME.     */
        strcat(draw_msg,"P");
     if(near & NEAR_PLAYED)     /* HOME or AWAY - PLAYED, 1 MORE. */
        strcat(draw_msg,"p");
     if(near & SAME_WON)        /* HOME & AWAY - WON SAME.        */
        strcat(draw_msg,"W");
     if(near & NEAR_WON)        /* HOME or AWAY - WON, 1 MORE.    */
        strcat(draw_msg,"w");
     if(near & SAME_DRAWN)      /* HOME & AWAY - DRAWN SAME.      */
        strcat(draw_msg,"D");
     if(near & NEAR_DRAWN)      /* HOME or AWAY - DRAWN, 1 MORE.  */
        strcat(draw_msg,"d");
     if(near & SAME_LOST)       /* HOME & AWAY - LOST SAME.       */
        strcat(draw_msg,"L");
     if(near & NEAR_LOST)       /* HOME or AWAY - LOST, 1 MORE.   */
        strcat(draw_msg,"l");

        strcat(draw_msg,")");

/*************** END OF CALCULATIONS *******************/

/* Print results in g_window. */

     g_FPEN(5);                                    /* Blue. */
     g_TXT("COUPON-NO  LEAGUE  HOME  AWAY  DRAW   ?",156,RS_Y+20);

     g_FPEN(1);                                    /* White. */
     sprintf(TXT_B,"%d",coupon_c);                 /* Coupon No. */
     g_TXT(TXT_B,156,RS_Y+30);

     sprintf(TXT_B,"%d",league_c);                 /* League. */
     g_TXT(TXT_B,156+88,RS_Y+30);

     sprintf(TXT_B,"%d%%",home_c);                 /* Print Home. */
     g_TXT(TXT_B,156+152,RS_Y+30);

     sprintf(TXT_B,"%d%%",away_c);                 /* Print Away. */
     g_TXT(TXT_B,156+200,RS_Y+30);

     sprintf(TXT_B,"%d%%",draw_c);                 /* Print Draw. */
     g_TXT(TXT_B,156+248,RS_Y+30);

     g_FPEN(2);                                    /* Yellow. */
     g_TXT(draw_msg,156+296,RS_Y+30);              /* ?. */


  if(PRINT_ON) /* Send results to the Printer. */
    {
     sprintf(PRT_B[1],"%d  %d\r\t\b%s-%s",
     coupon_c, league_c, t_names[home], t_names[away]);
     sprintf(PRT_B[2],
"\r\t\t\t\t%d%%\r\t\t\t\t\t\b%d%%\r\t\t\t\t\t\t\b%d%%\r\t\t\t\t\t\t\t\b%s\n",
      home_c, away_c, draw_c, draw_msg);

     strcpy(PRT_B[0],PRT_B[1]);
     strcat(PRT_B[0],PRT_B[2]);

/*     printf("%s",PRT_B[0]); DEBUG */

    if((p_error = (BYTE)DO_PrtText(PRT_B[0])))
         PrtError(p_error);
     }
   }
}

void Do_Comment() /* Work out comment to go with results. */
{
     if(draw_c <= 55)
         strcpy(draw_msg,"*");
     if(draw_c > 55 && draw_c < 66)
         strcpy(draw_msg,"**");
     if(draw_c > 65 && draw_c < 80)
         strcpy(draw_msg,"***");
     if(draw_c > 79 && draw_c < 90)
         strcpy(draw_msg,"****");
     if(draw_c > 89)
         strcpy(draw_msg,"!* DRAW *!");
}

void Print_Heading()  /* Print pools heading ready for results to follow. */
{                     /* Uses workbench printer prefs.     */
                      /* 'DO_PrtText()' is found in Gfx.c. */
 strcpy(PRT_B[0],"\nCN LG         TEAMS");
 strcat(PRT_B[0],
 "\r\t\t\t\tHOME\r\t\t\t\t\t\bAWAY\r\t\t\t\t\t\t\bDRAW\r\t\t\t\t\t\t\t\b ?");
 strcat(PRT_B[0],"\n\n");

/*     printf("%s",PRT_B[0]); DEBUG */

  if((p_error = (BYTE)DO_PrtText(PRT_B[0])))
         PrtError(p_error);
}

void Show_LEAGUE(pt)      /* Show leagues-teams.(g_window)*/
P_TABLE *pt;
{
 WORD i = 0;
 WORD len = 0;
 WORD inn = INN_X+37;     /* near left edge.    */
 WORD mid = MID_X+37;     /* middle area.       */
 WORD out = OUT_X+37;     /* near right edge.   */
 WORD top = TOP_Y+9;      /* From top edge.     */
 WORD gap = GAP_Y+WID_Y;  /* Dist between gads. */

     g_FPEN(1);
     g_BPEN(0);

     len = pt->count;

 while(i <= len)       /* Print league '*pt' points to. */
  {
        g_TXT(pt->team[i],inn,top);
        i++;
     if(!(i <= len))
        return;
        g_TXT(pt->team[i],mid,top);
        i++;
     if(!(i <= len))
        return;
        g_TXT(pt->team[i],out,top);
        i++;
    top += gap;
   }
}

void Show_LEAGUE_N()   /* Show all league names. (gfx_window). */
{
 P_TABLE *pt;
 WORD out = c_OUT_X+45;       /* From left edge. */
 WORD top = c_TOP_Y+10;       /* From top edge.  */
 WORD gap = c_GAP_Y+c_WID_Y;  /* Dist between gads. */

     gfx_FPEN(4);
     gfx_BPEN(0);
     gfx_TXT("-------------------------------",(out-53),(top-22));
     gfx_FPEN(2);
     gfx_TXT(" USE MOUSE TO SELECT A LEAGUE.",(out-53),(top-30));

     gfx_FPEN(5);

     pt=t_head;

    while(pt != NULL) {
       gfx_TXT(pt->league,out,top);
       top += gap;
       pt = pt->next;
       }
}

int Get_Team(tm,tsize)  /* Get a Valid Team number. (g_window). */
int *tm, tsize;
{
 long msg = -1;

  do {
      if((msg = Get_GMsgs()) == 1000)
          return(0); /* Quit. */
       if(msg != -1)
         {
          switch(msg)
            {
                case 27:             /* Give user some help. */
                          Clear_RBOX();
                          Help();
                          break;
                case 28: /* Set/Unset printer flag. */
                          Clear_RBOX(); /* Clear result box. */
                      if(!PRINT_ON) {
                          RB_Msg("RESULTS TO SCREEN AND PRINTER.");
                          PRINT_ON=TRUE;
                          }
                        else {
                          RB_Msg("PRINTER-INACTIVE");
                          PRINT_ON=FALSE;
                          }
                         break;
                 case 29:               /* Print results heading. */
                     if(PRINT_ON)
                         Print_Heading();
                         break;
                 case 30:               /* Received new coupon number */
                         coupon_c -= 1;
                      if(coupon_c < 0)
                         coupon_c = 0;  /* Minimum coupon number is 1. */
                         break;
                 default:
                         break;
             }
          }
      } 
  while((msg < 0) || (msg > tsize));

  if(msg > tsize)
     msg = tsize;
   
 *tm = (int)msg;
return(1);
}

/*********************** CALCULATION FUNCTIONS ********************/

/* GAMES PLAYED. */
cr_GamesPlayed(h_team,a_team)
int *h_team,*a_team;
{
   int i,near=0;
   int n = 5;

/* [0] = Games played. */
/* Take n% from the team which played more.*/

     if(h_team[G_PLAYED] == a_team[G_PLAYED])  /* Played the same. */
        return(SAME_PLAYED);

     if(h_team[G_PLAYED] > a_team[G_PLAYED])   /* Home played more */
       {
         if((i = (h_team[G_PLAYED] - a_team[G_PLAYED])) == 1)
            near = NEAR_PLAYED;

            while(i--)
                  home_c -= n;
        } 
      else                      /* Away played more */
        {
         if(a_team[G_PLAYED] > h_team[G_PLAYED]) 
           {
            if((i = (a_team[G_PLAYED] - h_team[G_PLAYED])) == 1)
                near = NEAR_PLAYED;

            while(i--)
                  away_c -= n;
            }
         }
return(near);
}

/* GAMES WON. */
cr_GamesWon(h_team,a_team)
int *h_team,*a_team;
{
  int i,near = 0;
  int n = 6;

/* Give n% to the team which has won the most. */

     if(h_team[G_WON] == a_team[G_WON])  /* Won the same. */
        return(SAME_WON);

     if(h_team[G_WON] > a_team[G_WON]) {         /* [1] = Games won. */
        
        if((i = (h_team[G_WON] - a_team[G_WON])) == 1) /* Home won most */ 
            near=NEAR_WON;

         while(i--)
               home_c += n;

        }
       else      /* Away won most. */
         {
           if(a_team[G_WON] > h_team[G_WON])
              {
               if((i = (a_team[G_WON] - h_team[G_WON])) == 1)
                   near=NEAR_WON;

                while(i--)
                      away_c += n;
               }
          }
return(near);
}

/* GAMES DRAWN. */
cr_GamesDrawn(h_team,a_team)
int *h_team,*a_team;
{
 int i,near=0;
 int n = 2;

 /* Give n% to the team which has drawn the least. */

 if(h_team[G_DRAWN] == a_team[G_DRAWN]) /* Drawn the same. */
    return(SAME_DRAWN);
 
 if(h_team[G_DRAWN] > a_team[G_DRAWN])  /* [2] = NUMBER OF DRAWS. */
   {
    if((i = (h_team[G_DRAWN] - a_team[G_DRAWN])) == 1) /* AWAY HAS LESS. */
       near=NEAR_DRAWN;

    while(i--)
          away_c += n;

   } 
 else          /* AWAY HAS MORE DRAWS. */
   {
    if(a_team[G_DRAWN] > h_team[G_DRAWN]) 
      {
        if((i = (a_team[G_DRAWN] - h_team[G_DRAWN])) == 1)
           near=NEAR_DRAWN;

        while(i--)
           home_c += n;
       }
     }
return(near);
}

/* GAMES LOST. */
cr_GamesLost(h_team,a_team)
int *h_team,*a_team;
{
 int i,near=0;
 int n = 6;

 /* Give n% to the team which has lost the least. */

 if(h_team[G_LOST] == a_team[G_LOST]) /* Lost the same. */
    return(SAME_LOST);

 if(h_team[G_LOST] > a_team[G_LOST])  /* [3] = GAMES LOST. */
   {
       if((i = (h_team[G_LOST] - a_team[G_LOST])) == 1) /* HOME LOST MORE. */
          near=NEAR_LOST;

    while(i--)
          away_c += n;
   } 
 else          /* AWAY LOST MORE. */
   {
    if(a_team[G_LOST] > h_team[G_LOST]) 
      {
        if((i = (a_team[G_LOST] - h_team[G_LOST])) == 1)
           near=NEAR_LOST;

        while(i--)
           home_c += n;
        }
     }
return(near);
}
