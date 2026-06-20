/* Copyright (c) 1994, by Jason Petty.
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
 * Hce_MenuCtrl.c:
 *                 Do all Menu Events.
 */

#include <intuition/intuition.h>
#include <clib/string.h>
#include <clib/stdio.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"

int screen_flg=0;               /* Is screen at Front or Back?. */
char *a_templist[56] = NULL;    /* Holds files to be assembled.*/
char *l_templist[56] = NULL;    /* Holds files to be linked.   */
extern char LinkedFile[GB_MAX]; /* Copy of final output name from linker.*/

int MenuEvents(e)  /* Console window menu events. */
UWORD e;
{
  int m,it;

     m = MENUNUM(e);
    it = ITEMNUM(e);
/*  si = SUBNUM(e); */

/* Don`t clear block marks if block menu or if compiler test item. */
   if((m != 6) && !((m == 2) && (it == 0))) {
      Check_MMARK();  /* Check not in mouse marked state. */
      Check_KMARK();  /* Check not in key marked state.   */
      }
 
   Show_FreeMem();    /* Show free mem on status bar. */

   switch(m)  /* Which Menu?. */
    {
      case 0:                    /* Menu 0 - Hce. */
          if(ME_Menu0(it))
             return(1);          /* Quit. */
             break;
      case 1:                    /* Menu 1 - Disk. */
             ME_Menu1(it);
             break;
      case 2:                    /* Menu 2 - Compile. */
             ME_Menu2(it);
             break;
      case 3:                    /* Menu 3 - Assemble. */
             ME_Menu3(it);
             break;
      case 4:                    /* Menu 4 - Link. */
             ME_Menu4(it);
             break;
      case 5:                    /* Menu 5 - Other. */
             ME_Menu5(it);
             break;
      case 6:                    /* Menu 6 - Block. */
             ME_Menu6(it);
             break;
      case 7:                    /* Menu 7 - Search/Cursor. */
             ME_Menu7(it);
             break;
     default:
             break;
     }
  Show_FreeMem();
  return(0);
}

int ME_Menu0(it)    /* Menu 0 - Hce.  */
int it;
{
 long fsiz;

   switch(it) {
              case 0:          /* Editor about. */
                     Hce_Credits();
                     break;
              case 1:          /* Compiler about. */
                     Hcc_Credits();
                     break;
              case 2:          /* Clear text buf. */
                     if(TXT_CHANGED) {
                        if(!Do_ReqV2("Confirm - File Modified!"))
                            return;
                      }
                     Reset_VARS();          /* LINE_X/Y/CURS_Y.  */
                     ClearTextBuf();        /* Empty 'LINE[][]'  */
                     LINE[0][0] = '\n';     /* Declare line 0,   */
                     LINE[0][1] = '\0';     /* as available.     */
                     LINE[1][0] = '\0';
                     IO_FileName[0] = '\0'; /* Reset IO filename. */
                     FixDisplay();          /* Redisp wind lines. */
                     c_PlaceCURS(0,0);      /* Reset cursor pos.  */
                     udel.ud_flag=UD_NONE;  /* Nothing to undelete*/
                     Get_FstERR(NULL);      /* No errors.         */
                     Show_StatOK(1);        /* Normal status.     */
                     TXT_CHANGED=FALSE;     /* No changes yet.    */
                     break;
              case 3:          /* First error. */
                     Show_FstERR();
                     break;
              case 4:          /* First warning. */
                     Show_FstWARN();
                     break;
              case 5:          /* Print. */
                  if(Open_P_Wind())
                     Do_GadMsgs();
                     break;
              case 6:          /* Prefs. */
                  if(Open_Prefs_W())
                     Do_GadMsgs();
                     break;
              case 7:          /* New Cli. */
                   Scr_to_Back();
                   strcpy(PR_BUF,"Run NewCli ");
                   strcat(PR_BUF,"WINDOW=CON:30/30/500/100/AmigaShell/CLOSE");
                   strcat(PR_BUF,",FROM=S:Shell-Startup");
               if(!(Do_QuickY(PR_BUF)))
                   Show_Status("Open failure!, Check - SYS:c/NewCli");
                     break;
              case 8:          /* Show new executables Name + Size. */
               if(LinkedFile[0] != '\0') {
                    fsiz = (long)fsize(LinkedFile);
                  if(fsiz != -1) {
                    sprintf(PR_OTHER,"File: %s Size: %ld",LinkedFile,fsiz);
                    Show_Status(PR_OTHER);
                    } else {
                            Print_IO_ERR();
                            }
                  }
                     break;
              case 9:          /* Quit Hce. */
                     return(1);
                     break;
               }
return(0);
}

void ME_Menu1(it)      /* Menu 1 - Disk. */
int it;
{
 char *p;
 WORD l=0;

  if(it == 1) {  /* Load+Lock. */
     it=0;
     l++;
     }
  if(it == 2) {  /* Load-Append. */
     curs_jump_TO(Buf_Used());
     it=0;
     l=2;
     }

  switch(it) {
        case 0:           /* Open and load a c/asm-source  file.*/
           if(TXT_CHANGED && l != 2) {
                     if(!Do_ReqV2("Confirm - File Modified!"))
                            return;
                            }

           if(!(Get_IO_NAME(IO_LOAD,PR_OTHER))) { /* Use Asl Filereq. */
              return;
              }
           if(!(IO_readfile(PR_OTHER,l))) {   /* Does own error messages.*/
             if(l != 2)                       /* Erase only if not append.*/
              IO_FileName[0] = '\0';
              Reset_VARS();
              FixDisplay();
              c_PlaceCURS(0,0);
              udel.ud_flag = UD_NONE;         /* Cannot undelete now. */
              Show_StatOK(0);
              return;
              }
           if(l==2) {    /* If Append-File, keep old values. */
              TXT_CHANGED=TRUE;
              FixDisplay();
              c_PlaceCURS(LINE_X,CURS_Y);
              } 
             else        /* If New-File, reset all. */
              {
               TXT_CHANGED=FALSE;
               strcpy(IO_FileName, PR_OTHER);
               Reset_VARS();
               FixDisplay();
               c_PlaceCURS(0,0);
               udel.ud_flag = UD_NONE;
               }
           if(l==1) {    /* Make new files directory the current one. */
               if(!(p = (char *)StripFN(IO_FileName))) {
                  Show_StatOK(0);
                  Show_Status("Loaded, Already Locked...");
                  break;
                  }
               if(DirToCurrent(p,NULL)) {
                  Clear_FRDir();          /* Clear Filereq directory draw.*/
                  StripPATH(IO_FileName); /* Remove path from filename. */
                  Show_Status("Loaded/Locked...");
                  }
                else Print_IO_ERR();
                  Show_StatOK(0);
                  free(p);
              }
            else
              Show_StatOK(1);
              break;
       case 3:                          /* Save a c/asm-source file. */
             if(!TXT_CHANGED)
               {
                if(!Do_ReqV2("No changes - Save anyway?"))
                   return;
                }

            if(IO_FileName[0] == '\0') {
                   if(IO_Save_AS()) {    /* Uses 'Asl' file requester. */
                            TXT_CHANGED=FALSE;
                            Show_StatOK(1);
                            }
                 } else {
                       if(IO_writefile(IO_FileName)) {
                            TXT_CHANGED=FALSE;
                            Show_StatOK(1);
                            }
                         }
              break;
       case 4:                                  /* Save as.. */
           if(IO_Save_AS()) {
              TXT_CHANGED=FALSE;
              Show_StatOK(1);
              }
              break;
        }
}

void free_AsmList()    /* Free last list of compiled files. */
{
 register int r=0;
   while(a_templist[r] != NULL) {
         free(a_templist[r]);
         a_templist[r++] = NULL;
         }
}

void free_LinkList()    /* Free last list of assembled files. */
{
 register int r=0;
   while(l_templist[r] != NULL) {
         free(l_templist[r]);
         l_templist[r++] = NULL;
         }
}

void ME_Menu2(it)      /* Menu 2 - Compile. */
int it;
{
 char *p,*t,*v;
 int r;
 int i=0;

  Show_FreeMem();

     switch(it) {
             case 0:         /* Compile only. (test). */
                 if(C_GadBN[2] != 1) {    /* Compile editor file?. */
                      if(!(p = (char *)Do_Compile(NULL)))
                          return;
                      if(!C_GadBN[0])
                          DeleteFile(p);
                          free(p);
                     }
                 if(C_GadBN[2] && C_WorkList[0] != '\0') /* List?. */
                    {
                   while((v = (char *)com_ARG(C_WorkList,&i)) != NULL)
                      {
                       if(chk_ESC()) {        /* Check escape gadget. */
                          free(v);
                          return;
                          }
                       if(!is_asm(v)) {       /* '.a'/'.asm' - Asm file? */
                          if(!(p = (char *)Do_Compile(v))) {
                               free(v);
                               return;
                               }
                          if(!C_GadBN[0])     /* [0]. Keep Quad?. */
                               DeleteFile(p);
                               free(p);       /* *p. Hcc`s outname. */
                          }
                        free(v); /* Free Compiler innames.*/
                       } 
                     }
                     Show_Status("No-Errors");
                     break;
             case 1:          /* Compile+optimize. */
                     free_AsmList();
                     r=0;
                 if(C_GadBN[2] != 1) {   /* Compile editor file? */
                    if(!(p = (char *)PROCESS_1(NULL))) {
                         Fix_SCREEN();
                         return;
                         }
                         a_templist[0] = p;
                         r++;
                    }
                 if(C_GadBN[2] && C_WorkList[0] != '\0') /* List?. */
                     {
                      while((v = (char *)com_ARG(C_WorkList,&i)) != NULL)
                       {
                         if(chk_ESC()) {  /* Check escape gadget. */
                            free(v);
                            return;
                            }
                         if(!is_asm(v))   /* Check not asm file first!. */
                           {
                             if(!(p = (char *)PROCESS_1(v))) {
                                Fix_SCREEN();
                                free(v);
                                return;
                                }
                            if(r < 55)
                             a_templist[r++] = p;  /* Keep opt outnames. */
                            }
                          free(v);  /* Free Compiler innames.*/
                        }
                     }
                     Fix_SCREEN();
                  if(r)
                     Show_Status("No-Errors");
                     break;
             case 2:          /* Comp + O + Assem.   */
                    free_AsmList();
                    free_LinkList();
                    r=0;
                 if(C_GadBN[2] != 1) {    /* Compile editor file?. */
                         if(!(p = (char *)PROCESS_2(NULL))) {
                              Fix_SCREEN();
                              return;
                              }
                              l_templist[r++] = p;
                    }
                 if(C_GadBN[2] && C_WorkList[0] != '\0') /* List? */
                     {
                      while((v = (char *)com_ARG(C_WorkList,&i)) != NULL)
                         {
                         if(chk_ESC()) {  /* Check escape gadget. */
                             free(v);
                             return;
                             }
                         if(!(p = (char *)PROCESS_2(v))) {
                             Fix_SCREEN();
                             free(v);
                             return;
                             }
                            if(r < 55)
                             l_templist[r++] = p;  /* Asm outnames */
                             free(v);              /* Compiler inname.  */
                         }
                     }
                    Fix_SCREEN();
                  if(r)
                    Show_Status("No-Errors");
                    break;
             case 3:                 /* Compile+o+a List only. */
                 if(C_WorkList[0] != '\0')
                     {
                      free_AsmList();
                      free_LinkList();
                      r=0;
                      while((v = (char *)com_ARG(C_WorkList,&i)) != NULL)
                         {
                         if(chk_ESC()) {  /* Check escape gadget. */
                             free(v);
                             return;
                             }
                         if(!(p = (char *)PROCESS_2(v))) {
                             Fix_SCREEN();
                             free(v);
                             return;
                             }
                            if(r < 55)
                             l_templist[r++] = p; /* Asm outname */
                             free(v);             /* Compiler inname.  */
                         }
                      Fix_SCREEN();
                      Show_Status("No-Errors");
                     }
                    else
                      Show_Status("List buffer is empty!");
                    break;
             case 4:               /* Comp + O + A + Link. */
                    free_AsmList();
                    free_LinkList();
                    r=0;
                 if(C_GadBN[2] != 1) {    /* Compile editor file?. */
                         if(!(p = (char *)PROCESS_2(NULL))) {
                              Fix_SCREEN();
                              return;
                              }
                              l_templist[0] = p;
                              r++;
                     }
                 if(C_GadBN[2] && C_WorkList[0] != '\0') /* List? */
                     {
                      while((v = (char *)com_ARG(C_WorkList,&i)) != NULL)
                         {
                         if(chk_ESC()) {  /* Check escape gadget. */
                             free(v);
                             return;
                             }
                         if(!(p = (char *)PROCESS_2(v))) {
                             Fix_SCREEN();
                             free(v);
                             return;
                             }
                            if(r < 55)
                             l_templist[r++] = p; /* Keep linker names. */
                             free(v);             /* Compiler inname.  */
                          }
                     }
                  if(r) {
                    if((PROCESS_3(NULL))) {          /* Link. */
                         r=0;
                     while(l_templist[r] != NULL && L_GadBN[3] != 1) {
                      if(!C_GadBN[0])
                         DeleteFile(l_templist[r]);  /* Del objects?. */
                         r++;
                         }
                      if(!L_undefsym())
                        Show_Status("No-Errors");
                      }
                    }
                    if(!C_GadBN[0] && L_GadBN[3] != 1) /* Free list? */
                       free_LinkList();
                       Fix_SCREEN();
                     break;
             case 5: /* Dummy line.(----------). */
                    break;
             case 6:                 /* Optimizer options. */
                if (Open_O_Wind())   /* Open g_window with 'Opt' gadgets.  */
                    Do_GadMsgs();    /* Process and act on IDCMP messages. */
                    break;
             case 7:                 /* Compiler options. */
                if (Open_C_Wind())
                    Do_GadMsgs();
                    break;
     }
  Show_FreeMem();
}


void ME_Menu3(it)      /* Menu 3 - Assemble. */
int it;
{
 char *p,*t;
 int r;

     switch(it) {
             case 0:         /* Assemble this file. */
                if(IO_FileName[0] == '\0') {
                    Show_Status("File must be saved first!");
                    break;
                    }
                    free_LinkList();
                if(A_GadBN[2])
                    Scr_to_Back();
                    Show_StatV3("Assembling:  %s ...",IO_FileName);
                if(!(p = (char *)Do_ASSEMBLER(IO_FileName))) {
                      if(A_GadBN[2])
                         Scr_to_Front();
                         Show_Status("Assembler file error!!");
                         break;
                    }
                if(A_GadBN[2]) {       /* [2].Assembler Verbose. */
                    Delay(STD_DELAY);  /* Incase of quick assembles. */
                    Scr_to_Front();
                    }
                    l_templist[0] = p;
                    Show_Status("No-Errors");
                    break;
             case 1:         /* Assem (all files) last compiled. */
                if(a_templist[0] == NULL) {
                    Show_Status("Nothing to Assemble!");
                    break;
                    }
                    free_LinkList();
                if(A_GadBN[2])
                    Scr_to_Back();
                    r=0;
                while(a_templist[r] != NULL)
                   {
                     Show_StatV3("Assembling:  %s ...", a_templist[r]);
                   if(!(p = (char *)Do_ASSEMBLER(a_templist[r]))) {
                       if(A_GadBN[2])
                          Scr_to_Front();
                          Show_Status("Assembler file error!!");
                          return;
                          }
                   if(!C_GadBN[0] && L_GadBN[3] != 1) /* [0]. Keep Quad?. */
                     DeleteFile(a_templist[r]);
                     l_templist[r++] = p;    /* Keep linker names. */
                    }
                 if(A_GadBN[2]) {            /* [2].Assembler verbose. */
                    Delay(STD_DELAY);        /* Incase of quick assembles. */
                    Scr_to_Front();
                    }
                 if(!C_GadBN[0] && L_GadBN[3] != 1)  /* [3].Using linklist. */
                    free_AsmList();
                    Show_Status("No-Errors");
                    break;
             case 2:         /* Assem selected. */
                 if(!(Get_IO_NAME(IO_LOAD,PR_OTHER))) { /* Asl file req. */
                    break;
                    }
                    free_LinkList();
                    t = (char *)strdup(PR_OTHER);
                 if(A_GadBN[2])
                    Scr_to_Back();
                    Show_StatV3("Assembling:  %s ...", t);
                 if(!(p = (char *)Do_ASSEMBLER(t))) {
                   if(A_GadBN[2])
                    Scr_to_Front();
                    free(t);
                    Show_Status("Assembler file error!!");
                    break;
                    }
                    l_templist[0] = p;        /* Keep linker inname. */
                    free(t);
                 if(A_GadBN[2])
                    Scr_to_Front();
                    Show_Status("No-Errors");
                    break;
             case 3:         /* Assem+Link (all files) last compiled. */
                if(a_templist[0] == NULL) {
                    Show_Status("Nothing to Assemble!");
                    break;
                    }
                    free_LinkList();
                if(A_GadBN[2])
                    Scr_to_Back();
                    r=0;
                while(a_templist[r] != NULL)
                   {
                     Show_StatV3("Assembling:  %s ...", a_templist[r]);
                   if(!(p = (char *)Do_ASSEMBLER(a_templist[r]))) {
                       if(A_GadBN[2])
                          Scr_to_Front();
                          Show_Status("Assembler file error!!");
                          return;
                          }
                         l_templist[r++] = p;         /* Keep linker names. */
                   if(!C_GadBN[0] && L_GadBN[3] != 1) /* Del opt outfiles?. */
                     DeleteFile(a_templist[r]);
                    }
                  if((PROCESS_3(NULL)))  {       /* Link. */
                      r=0;
                  while(l_templist[r] != NULL && L_GadBN[3] != 1) {
                   if(!C_GadBN[0])               /* Del asm objects.*/
                      DeleteFile(l_templist[r]);
                      r++;
                      }
                   if(!C_GadBN[0] && L_GadBN[3] != 1) { /* Free lists? */
                      free_AsmList();
                      free_LinkList();
                      }
                   if(!L_undefsym())
                      Show_Status("No-Errors");
                   }
                     Fix_SCREEN();  /* Linker Verbose. */
                  if(A_GadBN[2])    /* Assem Verbose. */
                     Scr_to_Front();
                    break;
             case 4: /* Dummy line.(----------) */
                    break;
             case 5:         /* Assem options. */
                if (Open_A_Wind())
                    Do_GadMsgs();
                    break;
     }
}

void ME_Menu4(it)       /* Menu 4 - Link. */
int it;
{
 char *t;
 int i;

     switch(it) {
             case 0:    /* Link (all files) last assembled, */
                        /* all files in LinkList or both. */
                   if((l_templist[0] != NULL) || (L_GadBN[3])) 
                     {
                       if((L_GadBN[3] == 1) && (L_LinkList[0] == '\0')) {
                          Show_Status("Nothing to link!");
                          break;
                          }
                       if(L_GadBN[0])
                          Scr_to_Back();
                       if(PROCESS_3(NULL) && !L_undefsym())
                          Show_Status("No-Errors");
                       if(L_GadBN[0]) {
                          Delay(STD_DELAY);
                          Scr_to_Front();
                          }
                     }
                    else  Show_Status("Nothing to link!");
                    break;
             case 1:            /* Link selected. */
                 if(!(Get_IO_NAME(IO_LOAD,PR_OTHER))) { /* Asl file req. */
                    break;
                    }
                    Fix_RAMDISK((t = (char *)strdup(PR_OTHER)));
                    free_LinkList(); /* l_templist[] */
                 if(L_GadBN[0])
                    Scr_to_Back();
                 if(PROCESS_3(t) && !L_undefsym())
                    Show_Status("No-Errors");
                    free(t);
                 if(L_GadBN[0]) {
                    Delay(STD_DELAY);
                    Scr_to_Front();
                    }
                    break;
             case 2:            /* Link List. */
                 if(L_LinkList[0] != '\0') {
                       if(L_GadBN[0])
                          Scr_to_Back();
                          i = L_GadBN[3];
                          L_GadBN[3] = 1;
                       if(PROCESS_3(NULL) && !L_undefsym())
                          Show_Status("No-Errors");
                          L_GadBN[3] = i;
                       if(L_GadBN[0]) {
                          Delay(STD_DELAY);
                          Scr_to_Front();
                          }
                     } 
                    else  Show_Status("Nothing to link!");
                    break;
             case 3: /* Dummy line.(----------) */
                    break;
             case 4:            /* Link Options. */
                if (Open_L_Wind())
                    Do_GadMsgs();
                    break;
     }
}

void ME_Menu5(it)     /* Menu 5 - Other. */
int it;
{
 char *t,*s,*v;
 BPTR lock=NULL;
 int rf_numargs;
 WORD counter=0;

  switch(it) {
        case 0:         /* Run linked.   */
           if(LinkedFile[0] != '\0') {
                 Scr_to_Back();
                 counter = (WORD)Do_QuickY(LinkedFile);
                 ActivateCW();                /* Activate console window.*/
              if(P_GadBN[0])                  /* Wait for Key, */
                 while(!checkinput());
                else                          /* or delay?. */
                 Delay((counter>0 ? MIN_DELAY : STD_DELAY));
                 Scr_to_Front();
             if(!counter)
                 Print_IO_ERR();
                else
                 Show_StatOK(1);
              }
              break;
        case 1:         /* Run selected. */
           if(!(Get_IO_NAME(IO_RUN,PR_OTHER))) /* Asl file req. */
                break;
                Scr_to_Back();
           if(!(t = (char *)strdup(PR_OTHER)))
                break;
                Fix_RAMDISK(t);
                counter = (WORD)Do_QuickY(t);
                ActivateCW();             /* Activate console window.*/
           if(P_GadBN[0]) {               /* Wait for key, */
                while(!(lock)) {
                        lock = checkinput();
                    if((lock) && (lock==IDCMP_ACTIVEWINDOW 
                        || lock==IDCMP_INACTIVEWINDOW))
                        lock=NULL;
                        }
               } else                     /* or delay?.    */
                        Delay((counter>0 ? MIN_DELAY : STD_DELAY));
                Scr_to_Front();
                free(t); 
           if(!counter)
                Print_IO_ERR();
               else
                Show_StatOK(1);
              break;
        case 2: /* Make current source files path the current directory. */
           if(!(t = (char *)StripFN(IO_FileName))) {
              Show_Status("Already Locked!");
              break;
              }
           if(DirToCurrent(t,NULL)) {
              Clear_FRDir();          /* Clear the FileReq directory draw. */
              StripPATH(IO_FileName); /* Remove path from filename. */
              Show_StatOK(0);         /* Show mem,file. */
              Show_StatV3("Locked... %s", t);
              } else Print_IO_ERR();
              free(t);
              break;
        case 3:  /* Lock disk in drive DF0: */
                  if(DirToCurrent("DF0:", NULL)) {
                     Clear_FRDir();
                     Show_Status("DF0: Locked...");
                     } else Print_IO_ERR();
              break;
        case 4:      /* Lock any directory. */
           if(!(Get_IO_NAME(IO_LOCK,PR_BUF))) { /* Asl file req. */
              break;
              }
           if(!(t = (char *)StripFN(PR_BUF))) {
              Show_Status("Already Locked!");
              break;
              }
           if(DirToCurrent(t,NULL)) {
              Clear_FRDir();
              Show_StatV3("Locked... %s", t);
              } else Print_IO_ERR();
              free(t);
              break;
        case 5:       /* Copy file(s). (multiselect). */
           if(!(Get_IO_NAME(IO_DEST,PR_BUF))) {                  /* to path */
              break;
              }
              s = StripFN(PR_BUF);              /* Don`t want filename here */
              Clear_FRDir();
           if(!(rf_numargs = Get_IO_NAME(IO_SOURCE,PR_OTHER))) { /* from pth*/
              free(s);
              break;
              }
           if(!(t = strdup(PR_OTHER)))
              break;
           while((rf_numargs > 0) && (io_arglist != NULL)) {
             if(!(v = malloc((strlen(s)+strlen(io_arglist->wa_Name)) + 1)))
                  break;
                  strcpy(v,s);                          /* Get dest path   */
                  strcat(v,io_arglist->wa_Name);        /* add file to dest*/
                  strcpy(PR_OTHER,t);                   /* Get src path    */
                  strcat(PR_OTHER,io_arglist->wa_Name); /* add file to src */
                if(!(copy_FILE(v,PR_OTHER))) {
                  free(v);
                  break;
                  }
                  free(v);
                 io_arglist++;
                counter++;
               rf_numargs--;
              }
            if(counter) {
               if(counter == 1)                  
                  Show_Status("Copied 1 file...");
                else
                  Show_StatV3("Copied %d files...",counter);
              }
              free(s);
              free(t);
              break;
        case 6:       /* Delete last file linked. */
            if(LinkedFile[0] != '\0') {
                   if(DeleteFile(LinkedFile)) {
                      Show_StatV3("Deleted - %s",LinkedFile);
                      LinkedFile[0] = '\0';
                      }
                    else Print_IO_ERR();
               }
               break;
        case 7:       /* Delete selected file(s)/dir. (multiselect) */
              if((rf_numargs = Get_IO_NAME(IO_DELETE,PR_OTHER)))
               {
                 if(!(s = strdup(PR_OTHER)))
                    break;
                 while((rf_numargs > 0) && (io_arglist != NULL)) {
                       strcpy(PR_OTHER,s);                   /* get dir */
                       strcat(PR_OTHER,io_arglist->wa_Name); /* add file*/
                   if(DeleteFile(PR_OTHER)) {                /* del file*/
                       Show_StatV3("Deleted - %s", PR_OTHER);
                       } else  {
                           Print_IO_ERR();                   /* error. */
                           break;
                           }
                     io_arglist++;
                    rf_numargs--;
                   }
                 free(s);
                }
              break;
        case 8:       /* Make directory. */
            if(Get_IO_NAME(IO_MAKEDIR,PR_OTHER))
                {
                 if((lock = (BPTR)CreateDir(PR_OTHER))) {
                    UnLock(lock);
                    Show_StatV3("Created %s ...", PR_OTHER);
                    }
                  else Print_IO_ERR();
                 }
              break;
        case 9:       /* Assign device to path. */
           if(!(Do_ReqWin("Enter device:")))
              break;
              t = ReqBuf;
              while(*t++ != '\0')     /* Remove ':' or '/' not allowed. */
                 if(*t == ':' || *t == '/')
                    *t = '\0';

           if(!(s = strdup(ReqBuf)))
              break;
           if(!(Do_ReqWin("Enter path:"))) {
              free(s);
              break;
              }
           if(!(t = strdup(ReqBuf)))
              break;
           if((AssignPath(s,t))) {
               Show_StatV3("Assigned: %s to %s",s,t);
               }
             else Print_IO_ERR();
              free(s);
              free(t);
              break;
        case 10:      /* Rename volume,directory or file. */
               Clear_FRFile();
               v=NULL;
            if(!(Get_IO_NAME(IO_RENAME1,PR_BUF)))
               break;
            if(!(s = strdup(PR_BUF)))
               break;

             /* Volume or directory name?. use ReqWin. */

               counter = strlen(s)-1;
           if(s[counter] == ':' || s[counter] == '/')
              {
               if(!(Do_ReqWin("Rename as...?"))) {
                     free(s);
                     Show_Status("Cancelled...");
                     break;
                     }
               if(s[counter] == '/')      /* Dir name. */
                  {     s[counter] = '\0';
                     if(!(t = strdup(s))) {
                        free(s);
                        break;
                        }
                    /* Keep path to old dir. */
                     while(counter && t[counter] != '/' && t[counter] != ':')
                           counter--;
                     if(!counter)
                       t[counter] = '\0';
                      else
                       t[++counter] = '\0';

                     if(!(v = malloc((strlen(t) + strlen(ReqBuf))+2))) {
                        free(t);
                        free(s);
                        break;
                       }
                       strcpy(v,t);       /* Get old path. */
                       free(t);
                     if(!(t = strdup(ReqBuf))) {
                       free(v);
                       free(s);
                       break;
                       }                  /* Remove '/' from new dir. */
                       counter = strlen(t)-1;
                     if(t[counter] == '/')
                       t[counter] = '\0';

                       strcat(v,t);       /* Add new dir to old path. */

                       counter = Rename(s,v);
                    /* printf("<DIR> src: %s  dst: %s\n",s,v); */
                    }
                    else {                /* Vol name?. */
                        if(!(t = strdup(ReqBuf))) {
                             free(s);
                             break;
                             }
                             counter = strlen(t)-1;
                        if(t[counter] == ':')
                             t[counter] = '\0';
                             counter = Relabel(s,t);
                          /* printf("<VOL> src: %s  dst: %s\n",s,t); */
                         }
                } 
               else {  /* Must be File name. Use File Req.*/

                        if(!(Get_IO_NAME(IO_RENAME2,PR_BUF))) {
                            free(s);
                            break;
                            }
                        if(!(t = strdup(PR_BUF))) {
                            free(s);
                            break;
                            }
                           counter = Rename(s,t);
                           /* printf("<FILE> src: %s  dst: %s\n",s,t); */
                        }
              if(counter) {
                 sprintf(PR_OTHER,"Renamed: %s as %s",s,(v != NULL) ? v : t);
                 Show_Status(PR_OTHER);
                } else Print_IO_ERR();
              if(v)
                 free(v);
                 free(t);
                 free(s);
              break;
       }
 Show_FreeMem();
}

void ME_Menu6(it)       /* Menu 6 - Block. */
int it;
{
   switch(it) {
        case 0:                     /* Mark. */
           if(!BLOCK_ON) {          /* Already on? */
               Show_Status("Marking out - Block...");
               B_Start();           /* Mark Block. */
               }
               break;
        case 1:                     /* Hide. */
           if(BLOCK_ON || MOUSE_MARKED) {
               B_Hide();
               }
               break;
        case 2:                          /* Cut.  */
           if(BLOCK_ON || MOUSE_MARKED)  /* No go? */
               {
                 B_End();
              if(B_Copy()) {        /* Copy block. */
                  if(B_Cut()) {     /* Cut on win & buf. */
                       Show_Status("Block cut to clip...");
                       BLOCK_ON = FALSE;
                       MOUSE_MARKED=FALSE;
                       TXT_CHANGED=TRUE;
                       }
                   }
               }
               break;
        case 3:                         /* Copy. */
           if(BLOCK_ON || MOUSE_MARKED) /* No go? */
              {
                B_End();
             if(B_Copy()) {
                FixDisplay();
                c_PlaceCURS(LINE_X, CURS_Y);
                Show_Status("Block copied to clip...");
                BLOCK_ON = FALSE;
                MOUSE_MARKED=FALSE;
                }
               }
              break;
        case 4:                     /* Insert. */
           if(!BLOCK_ON)
              B_Insert();
              TXT_CHANGED=TRUE;
              break;
        case 5:                     /* Print. */
           if(!BLOCK_ON)
              B_Print();
              break;
        }
}

void ME_Menu7(it)       /* Menu 7 - Search/Cursor. */
int it;
{
   switch(it) {
         case 0:                 /* Find */
            if (Open_F_Wind())
            if (Do_GadMsgs()) {  /* Fill char 'Search_Name[]' */             
            if (Search_Name[0] && Search_LINE())
                Show_Status("Found...");
               else
                Show_Status("Not-Found...");
                }
                break;
         case 1:               /* Find Next. */
             if (Search_Name[0] && Search_LINE())
                Show_Status("Found...");
               else
                Show_Status("Not-Found...");
                break;
         case 2:               /* Find Replace. */
            if (Open_R_Wind()) {
                if(Do_GadMsgs()) {
                     if(!Replace_JOB())
                         Show_Status("Not-Found...");
                     }
                }
                break;
         case 3: /* Dummy line.(---------) */
                break;
         case 4:               /* Beg/End of Line. */
                Curs_to_BEL();
                break;
         case 5:               /* Beg/End of File. */ 
                Curs_to_BEF();
                break;
         case 6:               /* Jump to Line. */
            if (Open_J_Wind()) {
                if(Do_GadMsgs())
                   curs_jump_TO((jump_to_num-1));
                }
                break;
     }
}
