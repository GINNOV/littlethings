/************************************************************************/
/*                                                                      */
/*                         FontConverter V1.3                           */
/*                                                                      */
/*                         Freeware © 1992 by                           */
/*                                                                      */
/*                            Andreas Baum                              */
/*                        Eugen-Roth-Straﬂe 25                          */
/*                           W-8430 Neumarkt                            */
/*                               Germany                                */
/*                                                                      */
/*                      Convert Fonts in C-Source                       */
/*                                                                      */
/*    Usage: FontConverter_V1.3 <Fontname> <Fontheight> <Outputfile>    */
/*                                                                      */
/*                            Needs >= OS1.2                            */
/*                                                                      */
/*                            Compiler: DICE                            */
/*                                                                      */
/*           Compilerusage: DCC -oFontConverter_V1.3 FC_V1.3.c          */
/*                                                                      */
/************************************************************************/


#include <libraries/dos.h>

UWORD YSize, XSize, Baseline, BoldSmear, Accessors, Modulo;
UWORD Dat_Value;

ULONG Font, CharData, CharLoc, CharSpace, CharKern;
ULONG In_Datei, Out_Datei;
ULONG Dat_Length, x, y;

UBYTE Style, Flags, LoChar, HiChar;
UBYTE Font_Name[50], Out_Path[100], In_Path[100], Data[100];

main(argc, argv)
LONG argc;
BYTE **argv;
  {
    if(argc != 4)
      {
        printf("\033[1mUsage: FontConverter_V1.3 <Fontname> <Fontheight> <Outputfile>\033[0m\n");
        close_all();
      }

    sprintf(In_Path,"Fonts:%s/%s",argv[1],argv[2]);
    sprintf(Font_Name,"%s%s",argv[1],argv[2]);
    sprintf(Out_Path,"%s",argv[3]);

    printf("\n\033[1m\033[33mFontConverter_V1.3\033[0m\n\n");
    printf("© 1992 by Baum Andreas\n\n");

    if(!(In_Datei=Open(In_Path,MODE_OLDFILE)))
      {
        printf("\033[1mERROR: Can't find Font  \033[3m%s \033[0m\033[1m!\033[0m\n\n",In_Path);
        close_all();
      }

    Seek(In_Datei,48,OFFSET_BEGINNING);
    Read(In_Datei,&Font,4);
    if(Font!=0x1a0f80)
      {
        printf("\033[1mError: No Font or packed Font or inadmissible Font !\033[0m\n\n");
        close_all();
      }

    if(!(Out_Datei=Open(Out_Path,MODE_NEWFILE)))
      {
        printf("\033[1mError: Can't install Outputfile  \033[3m%s \033[0m\033[1m!\033[0m\n\n",Out_Path);
        close_all();
      }

    printf("\033[3mWorking so hard ... Please Wait\033[0m\n\n");

    Seek(In_Datei,110,OFFSET_BEGINNING);
    Read(In_Datei,&YSize,2);
    Read(In_Datei,&Style,1);
    Read(In_Datei,&Flags,1);
    Read(In_Datei,&XSize,2);
    Read(In_Datei,&Baseline,2);
    Read(In_Datei,&BoldSmear,2);
    Read(In_Datei,&Accessors,2);
    Read(In_Datei,&LoChar,1);
    Read(In_Datei,&HiChar,1);
    Read(In_Datei,&CharData,4);
    Read(In_Datei,&Modulo,2);
    Read(In_Datei,&CharLoc,4);
    Read(In_Datei,&CharSpace,4);
    Read(In_Datei,&CharKern,4);

    Dat_Length=(Modulo*YSize+(HiChar-LoChar+2)*4)/2;
    if(CharSpace!=0)
      Dat_Length=Dat_Length+(HiChar-LoChar+2);
    if(CharKern!=0)
      Dat_Length=Dat_Length+(HiChar-LoChar+2);

    sprintf(Data,"/*  FontConverter_V2.0 © 1992 by Andreas Baum  */\n\n");
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"#include <graphics/text.h>\n\n");
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"UWORD %sdump[] =\n",Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"  {\n");
    Write(Out_Datei,Data,strlen(Data));

    y=1;
    for(x=0;x<Dat_Length;x++)
      {
        Read(In_Datei,&Dat_Value,2);
        if(x==Dat_Length-1)
          {
            sprintf(Data,"\t0x%04x\n",Dat_Value);
            Write(Out_Datei,Data,strlen(Data));
            y=9;
          }
        if(y<=7)
          {
            sprintf(Data,"\t0x%04x,",Dat_Value);
            Write(Out_Datei,Data,strlen(Data));
          }
        if(y==8)
          {
            y=0;
            sprintf(Data,"\t0x%04x,\n",Dat_Value);
            Write(Out_Datei,Data,strlen(Data));
          }
        y++;
      }

    sprintf(Data,"  };\n\n");
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"struct TextFont %sFont;\n\n",Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"FontInit_%s()\n",Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"  {\n");
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Message.mn_Node.ln_Name = \"%s.font\";\n",Font_Name,Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_YSize = 0x%04x;\n",Font_Name,YSize);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Style = 0x%02x;\n",Font_Name,Style);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Flags = 0x%02x;\n",Font_Name,Flags);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_XSize = 0x%04x;\n",Font_Name,XSize);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Baseline = 0x%04x;\n",Font_Name,Baseline);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_BoldSmear = 0x%04x;\n",Font_Name,BoldSmear);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Accessors = 0x%04x;\n",Font_Name,Accessors);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_LoChar = 0x%02x;\n",Font_Name,LoChar);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_HiChar = 0x%02x;\n",Font_Name,HiChar);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_CharData = (APTR)((char *)&%sdump[0]+0x%08x);\n",Font_Name,Font_Name,CharData-110);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_Modulo = 0x%04x;\n",Font_Name,Modulo);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_CharLoc = (APTR)((char *)&%sdump[0]+0x%08x);\n",Font_Name,Font_Name,CharLoc-110);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_CharSpace = (APTR)((char *)&%sdump[0]+0x%08x);\n",Font_Name,Font_Name,CharSpace-110);
    if(CharKern == 0)
      sprintf(Data,"    %sFont.tf_CharKern = 0x00000000;\n",Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"    %sFont.tf_CharKern = (APTR)((char *)&%sdump[0]+0x%08x);\n",Font_Name,Font_Name,CharKern-110);
    if(CharSpace == 0)
      sprintf(Data,"    %sFont.tf_CharSpace = 0x00000000;\n",Font_Name);
    Write(Out_Datei,Data,strlen(Data));

    sprintf(Data,"  }\n");
    Write(Out_Datei,Data,strlen(Data));

    close_all();
  }

close_all()
  {
    if(In_Datei) Close(In_Datei);
    if(Out_Datei) Close(Out_Datei);
    exit(0);
  }
