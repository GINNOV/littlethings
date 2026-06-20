/************************************************************************/
/*                                                                      */
/*                         FontConverter V2.0                           */
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
/*                      Usage: FontConverter_V2.0                       */
/*                                                                      */
/*                              Needs OS2                               */
/*                                                                      */
/*                            Compiler: DICE                            */
/*                                                                      */
/*           Compilerusage: DCC -oFontConverter_V2.0 FC_V2.0.c          */
/*                                                                      */
/************************************************************************/


#include <libraries/dos.h>
#include <libraries/asl.h>
#include <utility/tagitem.h>

struct FontRequester   *FontRequester;
struct FileRequester   *FileRequester;
struct TagItem         *MyTags;
struct WBArg           *fargs;

UWORD YSize, XSize, Baseline, BoldSmear, Accessors, Modulo;
UWORD Dat_Value;

ULONG Font, CharData, CharLoc, CharSpace, CharKern;
ULONG In_Datei, Out_Datei, Dat_Length;
ULONG x, y;

UBYTE Style, Flags, LoChar, HiChar;
UBYTE In_Name[200], Out_Name[200], Font_Name[50], Data[100], Compal[]=":";

main()
  {
    printf("\n\033[1m\033[33mFontConverter_V2.0\033[0m\n\n");
    printf("© 1992 by Baum Andreas\n\n");

    FontRequester=(struct FontRequester *)AllocAslRequest(ASL_FontRequest,NULL);

    MyTags=(struct MyTags *)AllocateTagItems(3);

    MyTags[0].ti_Tag=ASL_Hail;
    MyTags[0].ti_Data="Select Font";
    MyTags[1].ti_Tag=ASL_MaxHeight;
    MyTags[1].ti_Data=25;
    MyTags[2].ti_Tag=TAG_DONE;

    if(AslRequest(FontRequester, MyTags))
      {
        FreeTagItems(MyTags);
        FreeAslRequest(FontRequester);

        sprintf(In_Name,"Fonts:%s/%d",strtok(FontRequester->fo_Attr.ta_Name,"."),FontRequester->fo_Attr.ta_YSize);
        sprintf(Font_Name,"%s%d",strtok(FontRequester->fo_Attr.ta_Name,"."),FontRequester->fo_Attr.ta_YSize);

        if(In_Datei=Open(In_Name,MODE_OLDFILE))
          {
            Seek(In_Datei,48,OFFSET_BEGINNING);
            Read(In_Datei,&Font,4);
            if(Font==0x1a0f80)
              {
                FileRequester=(struct FileRequester *)AllocAslRequest(ASL_FileRequest,NULL);

                MyTags=(struct MyTags *)AllocateTagItems(5);

                MyTags[0].ti_Tag=ASL_Hail;
                MyTags[0].ti_Data="Select Datei";
                MyTags[1].ti_Tag=ASL_FuncFlags;
                MyTags[1].ti_Data=FILF_SAVE;
                MyTags[2].ti_Tag=ASL_File;
                MyTags[2].ti_Data="Font.c";
                MyTags[3].ti_Tag=ASL_Dir;
                MyTags[3].ti_Data="Ram:";
                MyTags[4].ti_Tag=TAG_DONE;

                if(AslRequest(FileRequester, MyTags))
                  {
                    printf("\033[3mWorking so hard ... Please Wait\033[0m\n\n");

                    FreeTagItems(MyTags);

                    FreeAslRequest(FileRequester);

                    if(strcmp(FileRequester->rf_Dir[strlen(FileRequester->rf_Dir)-1],Compal[0]))
                      sprintf(Out_Name,"%s/%s",FileRequester->rf_Dir,FileRequester->rf_File);
                    else
                      sprintf(Out_Name,"%s%s",FileRequester->rf_Dir,FileRequester->rf_File);

                    Out_Datei=Open(Out_Name,MODE_NEWFILE);

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

                    sprintf(Data,"\n");
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
                  }
              }
            else
              printf("\033[1mError: No Font or packed Font or inadmissible Font !\033[0m\n\n");
          }
        else
          printf("\033[1mError: Must be a Ram-Font !\033[0m\n\n");
      }
    close_all();
    exit(0);
  }

close_all()
  {
    if(In_Datei) Close(In_Datei);
    if(Out_Datei) Close(Out_Datei);
  }
