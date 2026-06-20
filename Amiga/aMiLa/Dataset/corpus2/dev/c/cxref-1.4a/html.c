/***************************************
  $Header: /home/amb/cxref/RCS/html.c 1.22 1997/11/20 19:19:06 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.4a.

  Writes the HTML output.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96,97 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#ifdef AMIGA
#include "amiga.h"
#endif /* AMIGA */

#include "memory.h"
#include "datatype.h"
#include "cxref.h"

/*+ The name of the output tex file that includes each of the others. +*/
#define HTML_FILE        ".html"
#define HTML_FILE_BACKUP ".html~"

/*+ The name of the output tex file that contains the appendix. +*/
#define HTML_APDX        ".apdx"

/*+ The comments are to be inserted verbatim. +*/
extern int option_verbatim_comments;

/*+ The name of the directory for the output. +*/
extern char* option_odir;

/*+ The base name of the file for the output. +*/
extern char* option_name;

/*+ The directories to go back to get to the base output directory. +*/
static char* goback=NULL;

static void WriteHTMLFilePart(File file);
static void WriteHTMLInclude(Include inc);
static void WriteHTMLSubInclude(Include inc,int depth);
static void WriteHTMLDefine(Define def);
static void WriteHTMLTypedef(Typedef type);
static void WriteHTMLStructUnion(StructUnion su,int depth);
static void WriteHTMLVariable(Variable var);
static void WriteHTMLFunction(Function func);

static void WriteHTMLDocument(char* name,int appendix);
static void WriteHTMLPreamble(FILE* f,char* title,int sourcefile);
static void WriteHTMLPostamble(FILE* f,int sourcefile);

static char* html(char* c);

/*+ The output file for the HTML. +*/
static FILE* of;

/*++++++++++++++++++++++++++++++++++++++
  Write an html file for a complete File structure and all components.

  File file The File structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteHTMLFile(File file)
{
 char* ofile;
 int i;

 /* Write the including file. */

 WriteHTMLDocument(file->name,0);

 /* Open the file */

 ofile=ConcatStrings(4,option_odir,"/",file->name,HTML_FILE);

 of=fopen(ofile,"w");
 if(!of)
   {
    struct stat stat_buf;
    int i,ofl=strlen(ofile);

    for(i=strlen(option_odir)+1;i<ofl;i++)
       if(ofile[i]=='/')
         {
          ofile[i]=0;
          if(stat(ofile,&stat_buf))
             mkdir(ofile,S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
          ofile[i]='/';
         }

    of=fopen(ofile,"w");
   }

 if(!of)
   {fprintf(stderr,"cxref: Failed to open the HTML output file '%s'\n",ofile);exit(1);}

 for(goback="",i=strlen(file->name);i>0;i--)
    if(file->name[i]=='/')
       goback=ConcatStrings(2,goback,"../");

 /* Write out a header. */

 WriteHTMLPreamble(of,ConcatStrings(5,"Cross reference for ",file->name," of ",option_name,"."),0);

 /*+ The file structure is broken into its components and they are each written out. +*/

 WriteHTMLFilePart(file);

 if(file->includes)
   {
    Include inc =file->includes;
    fprintf(of,"\n<hr>\n<h2>Included Files</h2>\n\n");
    do{
       WriteHTMLInclude(inc);
      }
    while((inc=inc->next));
   }

 if(file->defines)
   {
    Define def =file->defines;
    fprintf(of,"\n<hr>\n<h2>Preprocessor definitions</h2>\n\n");
    do{
       if(def!=file->defines)
          fprintf(of,"<p>\n");
       WriteHTMLDefine(def);
      }
    while((def=def->next));
   }

 if(file->typedefs)
   {
    Typedef type=file->typedefs;
    do{
       WriteHTMLTypedef(type);
      }
    while((type=type->next));
   }

 if(file->variables)
   {
    int any_to_mention=0;
    Variable var=file->variables;

    do{
       if(var->scope&(GLOBAL|LOCAL|EXTERNAL|EXTERN_F))
          any_to_mention=1;
      }
    while((var=var->next));

    if(any_to_mention)
      {
       int first_ext=1,first_local=1;
       Variable var=file->variables;
       do{
          if(var->scope&GLOBAL)
             WriteHTMLVariable(var);
         }
       while((var=var->next));
       var=file->variables;
       do{
          if(var->scope&(EXTERNAL|EXTERN_F) && !(var->scope&GLOBAL))
            {
             if(first_ext)
               {fprintf(of,"\n<hr>\n<h2>External Variables</h2>\n\n"); first_ext=0;}
             else
                fprintf(of,"<p>\n");
             WriteHTMLVariable(var);
            }
         }
       while((var=var->next));
       var=file->variables;
       do{
          if(var->scope&LOCAL)
            {
             if(first_local)
               {fprintf(of,"\n<hr>\n<h2>Local Variables</h2>\n\n"); first_local=0;}
             else
                fprintf(of,"<p>\n");
             WriteHTMLVariable(var);
            }
         }
       while((var=var->next));
      }
   }

 if(file->functions)
   {
    Function func=file->functions;
    do{
       if(func->scope&(GLOBAL|EXTERNAL))
          WriteHTMLFunction(func);
      }
    while((func=func->next));
    func=file->functions;
    do{
       if(func->scope&LOCAL)
          WriteHTMLFunction(func);
      }
    while((func=func->next));
   }

 WriteHTMLPostamble(of,0);

 fclose(of);

/* Clear the memory in html() */

 html(NULL); html(NULL); html(NULL); html(NULL);
}


/*++++++++++++++++++++++++++++++++++++++
  Write a File structure out.

  File file The File to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLFilePart(File file)
{
 int i;

 fprintf(of,"<h1><a name=\"file\">File %s</a></h1>\n",html(file->name));

 if(file->comment)
    if(option_verbatim_comments)
       fprintf(of,"<pre>\n%s\n</pre>\n\n",html(file->comment));
    else
      {
       char *rcs1=strstr(file->comment,"$Header"),*rcs2=NULL;
       if(rcs1)
         {
          rcs2=strstr(&rcs1[1],"$");
          if(rcs2)
            {
             rcs2[0]=0;
             fprintf(of,"<b>RCS %s</b>\n<p>\n",html(&rcs1[1]));
             rcs2[0]='$';
            }
         }
       if(rcs2)
          fprintf(of,"%s\n<p>\n",html(&rcs2[2]));
       else
          fprintf(of,"%s\n<p>\n",html(file->comment));
      }

 if(file->inc_in->n)
   {
    int i;

    fprintf(of,"<dl compact>\n<dt>Included in:\n<dd><ul>\n");
    for(i=0;i<file->inc_in->n;i++)
       fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#file\">%s</a><br>\n",goback,file->inc_in->s[i],html(file->inc_in->s[i]));
    fprintf(of,"</ul></dl>\n");
   }

 if(file->f_refs->n || file->v_refs->n)
    fprintf(of,"<dl compact>\n");

 if(file->f_refs->n)
   {
    int others=0;
    fprintf(of,"<dt>References Functions:\n<dd><ul>\n");
    for(i=0;i<file->f_refs->n;i++)
       if(file->f_refs->s2[i])
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,file->f_refs->s2[i],file->f_refs->s1[i],html(file->f_refs->s1[i]),html(file->f_refs->s2[i]));
       else
          others++;

    if(others)
      {
       fprintf(of,"<li>");
       for(i=0;i<file->f_refs->n;i++)
          if(!file->f_refs->s2[i])
             fprintf(of,--others?" %s(),":" %s()",html(file->f_refs->s1[i]));
       fprintf(of,"\n");
      }
    fprintf(of,"</ul>\n");
   }

 if(file->v_refs->n)
   {
    int others=0;
    fprintf(of,"<dt>References Variables:\n<dd><ul>\n");
    for(i=0;i<file->v_refs->n;i++)
      {
       if(file->v_refs->s2[i])
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#var-%s\">%s  :  %s</a>\n",goback,file->v_refs->s2[i],file->v_refs->s1[i],html(file->v_refs->s1[i]),html(file->v_refs->s2[i]));
       else
          others++;
      }

    if(others)
      {
       fprintf(of,"<li>");
       for(i=0;i<file->v_refs->n;i++)
          if(!file->v_refs->s2[i])
             fprintf(of,--others?" %s,":" %s",html(file->v_refs->s1[i]));
       fprintf(of,"\n");
      }
    fprintf(of,"</ul>\n");
   }

 if(file->f_refs->n || file->v_refs->n)
    fprintf(of,"</dl>\n");
}


/*++++++++++++++++++++++++++++++++++++++
  Write an Include structure out.

  Include inc The Include structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLInclude(Include inc)
{
 if(inc->comment)
    fprintf(of,"%s\n<p>\n",html(inc->comment));

 fprintf(of,"<ul>\n");

 if(inc->scope==LOCAL)
    fprintf(of,"<li><tt><a href=\"%s%s"HTML_FILE"#file\">#include &quot;%s&quot;</a></tt>\n",goback,inc->name,html(inc->name));
 else
    fprintf(of,"<li><tt>#include &lt;%s&gt;</tt>\n",html(inc->name));

 if(inc->includes)
    WriteHTMLSubInclude(inc->includes,1);

 fprintf(of,"</ul>\n");
}


/*++++++++++++++++++++++++++++++++++++++
  Write an Sub Include structure out. (An include structure that is included from another file.)

  Include inc The Include structure to output.

  int depth The depth of the include hierarchy.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLSubInclude(Include inc,int depth)
{
 fprintf(of,"<ul>\n");

 while(inc)
   {
    if(inc->scope==LOCAL)
       fprintf(of,"<li><tt><a href=\"%s%s"HTML_FILE"#file\">#include &quot;%s&quot;</a></tt>\n",goback,inc->name,html(inc->name));
    else
       fprintf(of,"<li><tt>#include &lt;%s&gt;</tt>\n",html(inc->name));

    if(inc->includes)
       WriteHTMLSubInclude(inc->includes,depth+1);

    inc=inc->next;
   }

 fprintf(of,"</ul>\n");
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Define structure out.

  Define def The Define structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLDefine(Define def)
{
 int i;
 int pargs=0;

 if(def->comment)
    fprintf(of,"%s\n<p>\n",html(def->comment));

 fprintf(of,"<tt>#define %s",html(def->name));

 if(def->value)
    fprintf(of," %s",html(def->value));

 if(def->args->n)
   {
    fprintf(of,"( ");
    for(i=0;i<def->args->n;i++)
       fprintf(of,i?", %s":"%s",html(def->args->s1[i]));
    fprintf(of," )");
   }
 fprintf(of,"</tt><br>\n");

 for(i=0;i<def->args->n;i++)
    if(def->args->s2[i])
       pargs=1;

 if(pargs)
   {
    fprintf(of,"<dl compact>\n");
    for(i=0;i<def->args->n;i++)
       fprintf(of,"<dt><tt>%s</tt>\n<dd>%s\n",html(def->args->s1[i]),def->args->s2[i]?html(def->args->s2[i]):"");
    fprintf(of,"</dl>\n");
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Typedef structure out.

  Typedef type The Typedef structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLTypedef(Typedef type)
{
 fprintf(of,"\n<hr>\n<h2>");

 if(!strncmp("enum",type->name,4))
    fprintf(of,"<a name=\"type-enum-%s\">",&type->name[5]);
 else
    if(!strncmp("union",type->name,5))
       fprintf(of,"<a name=\"type-union-%s\">",&type->name[6]);
    else
       if(!strncmp("struct",type->name,6))
          fprintf(of,"<a name=\"type-struct-%s\">",&type->name[7]);
       else
          fprintf(of,"<a name=\"type-%s\">",type->name);

 if(type->type)
    fprintf(of,"Typedef %s",html(type->name));
 else
    fprintf(of,"Type %s",html(type->name));

 fprintf(of,"</a></h2>\n");

 if(type->comment)
    fprintf(of,"%s\n<p>\n",html(type->comment));

 if(type->type)
    fprintf(of,"<tt>typedef %s</tt><br>\n",html(type->type));

 if(type->sutype)
   {
    fprintf(of,"<ul>\n");
    WriteHTMLStructUnion(type->sutype,0);
    fprintf(of,"</ul>\n");
   }
 else
    if(type->typexref)
      {
       fprintf(of,"<dl compact>\n<dt>See:\n<dd><ul>\n");
       if(type->typexref->type)
          fprintf(of,"<li><a href=\"#type-%s\">Typedef %s</a>\n",type->typexref->name,html(type->typexref->name));
       else
          if(!strncmp("enum",type->typexref->name,4))
             fprintf(of,"<li><a href=\"#type-enum-%s\">Type %s</a>\n",&type->typexref->name[5],html(type->typexref->name));
          else
             if(!strncmp("union",type->typexref->name,5))
                fprintf(of,"<li><a href=\"#type-union-%s\">Type %s</a>\n",&type->typexref->name[6],html(type->typexref->name));
             else
                if(!strncmp("struct",type->typexref->name,6))
                   fprintf(of,"<li><a href=\"#type-struct-%s\">Type %s</a>\n",&type->typexref->name[7],html(type->typexref->name));
       fprintf(of,"</ul></dl>\n");
      }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a structure / union structure out.

  StructUnion su The structure / union to write.

  int depth The current depth within the structure.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLStructUnion(StructUnion su, int depth)
{
 int i;
 char* splitsu=NULL;

 splitsu=strstr(su->name,"{...}");
 if(splitsu) splitsu[-1]=0;

 if(depth && su->comment && !su->comps)
    fprintf(of,"<li><tt>%s;      </tt>%s<br>\n",html(su->name),html(su->comment));
 else
    fprintf(of,"<li><tt>%s%s</tt><br>\n",html(su->name),su->comps?"":";");

 if(su->comps)
   {
    fprintf(of,"<ul>\n");

    fprintf(of,"<li><tt>{</tt><br>\n");

    for(i=0;i<su->n_comp;i++)
       WriteHTMLStructUnion(su->comps[i],depth+1);

    fprintf(of,"<li><tt>}</tt><br>\n");

    fprintf(of,"</ul>\n");

    if(splitsu)
      {
       if(depth && su->comment)
          fprintf(of,"<li><tt>%s;      </tt>%s<br>\n",splitsu[5]?html(&splitsu[6]):"",html(su->comment));
       else
          fprintf(of,"<li><tt>%s;</tt><br>\n",splitsu[5]?html(&splitsu[6]):"");
      }
   }

 if(splitsu) splitsu[-1]=' ';
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Variable structure out.

  Variable var The Variable structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLVariable(Variable var)
{
 int i;

 if(var->scope&GLOBAL)
    fprintf(of,"\n<hr>\n<h2><a name=\"var-%s\">Global Variable %s</a></h2>\n",var->name,html(var->name));
 else
    fprintf(of,"<b><a name=\"var-%s\">%s</a></b><br>\n",var->name,html(var->name));

 if(var->comment)
    fprintf(of,"%s\n<p>\n",html(var->comment));

 fprintf(of,"<tt>");

 if(var->scope&LOCAL)
    fprintf(of,"static ");
 else
    if(!(var->scope&GLOBAL) && var->scope&(EXTERNAL|EXTERN_F))
       fprintf(of,"extern ");

 fprintf(of,"%s</tt><br>\n",html(var->type));

 if(var->scope&(GLOBAL|LOCAL))
   {
    if(var->incfrom || var->visible->n || var->used->n)
       fprintf(of,"<dl compact>\n");

    if(var->incfrom)
      {
       fprintf(of,"<dt>Included from:\n<dd><ul>\n");
       fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#var-%s\">%s</a>\n",goback,var->incfrom,var->name,html(var->incfrom));
       fprintf(of,"</ul>\n");
      }

    if(var->visible->n)
      {
       fprintf(of,"<dt>Visible in:\n<dd><ul>\n");
       for(i=0;i<var->visible->n;i++)
          if(var->visible->s1[i][0]=='$')
             fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#file\">%s</a>\n",goback,var->visible->s2[i],html(var->visible->s2[i]));
          else
             fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,var->visible->s2[i],var->visible->s1[i],html(var->visible->s1[i]),html(var->visible->s2[i]));
       fprintf(of,"</ul>\n");
      }

    if(var->used->n)
      {
       fprintf(of,"<dt>Used in:\n<dd><ul>\n");
       for(i=0;i<var->used->n;i++)
         {
          if(var->used->s1[i][0]=='$')
             fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#file\">%s</a>\n",goback,var->used->s2[i],html(var->used->s2[i]));
          else
            {
             if(var->scope&LOCAL)
                fprintf(of,"<li><a href=\"#func-%s\">%s()</a>\n",var->used->s1[i],html(var->used->s1[i]));
             else
                fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,var->used->s2[i],var->used->s1[i],html(var->used->s1[i]),html(var->used->s2[i]));
            }
         }
       fprintf(of,"</ul>\n");
      }

    if(var->incfrom || var->visible->n || var->used->n)
       fprintf(of,"</dl>\n");
   }
 else
    if(var->scope&(EXTERNAL|EXTERN_F) && var->defined)
      {
       fprintf(of,"<dl compact>\n<dt>Defined in:\n<dd><ul>\n");
       fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#var-%s\">%s</a>",goback,var->defined,html(var->name),var->defined);
       fprintf(of,"</ul></dl>\n");
      }
}


/*++++++++++++++++++++++++++++++++++++++
  Write a Function structure out.

  Function func The Function structure to output.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLFunction(Function func)
{
 int i,pret,pargs;
 char* comment2=NULL,*type;

 if(func->scope&GLOBAL)
    fprintf(of,"\n<hr>\n<h2><a name=\"func-%s\">Global Function %s()</a></h2>\n",func->name,html(func->name));
 else
    fprintf(of,"\n<hr>\n<h2><a name=\"func-%s\">Local Function %s()</a></h2>\n",func->name,html(func->name));

 if(func->comment)
    if(option_verbatim_comments)
       fprintf(of,"<pre>\n%s\n</pre>\n\n",html(func->comment));
    else
      {
       comment2=strstr(func->comment,"\n\n");
       if(comment2)
          comment2[0]=0;
       fprintf(of,"%s\n<p>\n",html(func->comment));
      }

 fprintf(of,"<tt>");

 if(func->scope&LOCAL)
    fprintf(of,"static ");
 if(func->scope&INLINED)
   fprintf(of,"inline ");

 if((type=strstr(func->type,"()")))
    type[0]=0;
 fprintf(of,"%s ( ",html(func->type));

 for(i=0;i<func->args->n;i++)
    fprintf(of,i?", %s":"%s",html(func->args->s1[i]));

 if(type)
   {fprintf(of," %s</tt><br>\n",html(&type[1]));type[0]='(';}
 else
    fprintf(of," )</tt><br>\n");

 pret =strncmp("void ",func->type,5) && func->cret;
 for(pargs=0,i=0;i<func->args->n;i++)
    pargs = pargs || ( strcmp("void",func->args->s1[i]) && func->args->s2[i] );

 if(pret || pargs)
   {
    fprintf(of,"<dl compact>\n");
    if(pret)
       fprintf(of,"<dt><tt>%s</tt>\n<dd>%s\n",html(func->type),func->cret?html(func->cret):"&nbs;");
    if(pargs)
       for(i=0;i<func->args->n;i++)
          fprintf(of,"<dt><tt>%s</tt>\n<dd>%s\n",html(func->args->s1[i]),func->args->s2[i]?html(func->args->s2[i]):"&nbs;");
    fprintf(of,"</dl>\n");
   }

 if(comment2)
   {
    fprintf(of,"%s\n<p>\n",html(&comment2[2]));
    comment2[0]='\n';
   }

 if(func->protofile || func->incfrom || func->calls->n || func->called->n || func->used->n || func->f_refs->n || func->v_refs->n)
    fprintf(of,"<dl compact>\n");

 if(func->protofile)
   {
    fprintf(of,"<dt>Prototyped in:\n<dd><ul>\n");
    fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#file\">%s</a>\n",goback,func->protofile,html(func->protofile));
    fprintf(of,"</ul>\n");
   }

 if(func->incfrom)
   {
    fprintf(of,"<dt>Included from:\n<dd><ul>\n");
    fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s</a>\n",goback,func->incfrom,func->name,html(func->incfrom));
    fprintf(of,"</ul>\n");
   }

 if(func->calls->n)
   {
    int others=0;
    fprintf(of,"<dt>Calls:\n<dd><ul>\n");
    for(i=0;i<func->calls->n;i++)
      {
       if(func->calls->s2[i])
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,func->calls->s2[i],func->calls->s1[i],html(func->calls->s1[i]),html(func->calls->s2[i]));
       else
          others++;
      }

    if(others)
      {
       fprintf(of,"<li>");
       for(i=0;i<func->calls->n;i++)
          if(!func->calls->s2[i])
             fprintf(of,--others?"%s(), ":"%s()",html(func->calls->s1[i]));
       fprintf(of,"\n");
      }
    fprintf(of,"</ul>\n");
   }

 if(func->called->n)
   {
    fprintf(of,"<dt>Called by:\n<dd><ul>\n");
    for(i=0;i<func->called->n;i++)
       fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,func->called->s2[i],func->called->s1[i],html(func->called->s1[i]),html(func->called->s2[i]));
    fprintf(of,"</ul>\n");
   }

 if(func->used->n)
   {
    fprintf(of,"<dt>Used in:\n<dd><ul>\n");
    for(i=0;i<func->used->n;i++)
      {
       if(func->used->s1[i][0]=='$')
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#file\">%s</a>\n",goback,func->used->s2[i],html(func->used->s2[i]));
       else
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,func->used->s2[i],func->used->s1[i],html(func->used->s1[i]),html(func->used->s2[i]));
      }
    fprintf(of,"</ul>\n");
   }

 if(func->f_refs->n)
   {
    int others=0;
    fprintf(of,"<dt>References Functions:\n<dd><ul>\n");
    for(i=0;i<func->f_refs->n;i++)
      {
       if(func->f_refs->s2[i])
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",goback,func->f_refs->s2[i],func->f_refs->s1[i],html(func->f_refs->s1[i]),html(func->f_refs->s2[i]));
       else
          others++;
      }

    if(others)
      {
       fprintf(of,"<li>");
       for(i=0;i<func->f_refs->n;i++)
          if(!func->f_refs->s2[i])
             fprintf(of,--others?"%s(), ":"%s()",html(func->f_refs->s1[i]));
       fprintf(of,"\n");
      }
    fprintf(of,"</ul>\n");
   }

 if(func->v_refs->n)
   {
    int others=0;
    fprintf(of,"<dt>References Variables:\n<dd><ul>\n");
    for(i=0;i<func->v_refs->n;i++)
      {
       if(func->v_refs->s2[i])
          fprintf(of,"<li><a href=\"%s%s"HTML_FILE"#var-%s\">%s  :  %s</a>\n",goback,func->v_refs->s2[i],func->v_refs->s1[i],html(func->v_refs->s1[i]),html(func->v_refs->s2[i]));
       else
          others++;
      }

    if(others)
      {
       fprintf(of,"<li>");
       for(i=0;i<func->v_refs->n;i++)
          if(!func->v_refs->s2[i])
             fprintf(of,--others?"%s, ":"%s",html(func->v_refs->s1[i]));
       fprintf(of,"\n");
      }
    fprintf(of,"</ul>\n");
   }

 if(func->protofile || func->incfrom || func->calls->n || func->called->n || func->used->n || func->f_refs->n || func->v_refs->n)
    fprintf(of,"</dl>\n");
}


/*++++++++++++++++++++++++++++++++++++++
  Write out a file that will include the current information.

  char* name The name of the file.

  int appendix set to non-zero if the appendix file is to be added, else a normal source file.  
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLDocument(char* name,int appendix)
{
 FILE *in,*out;
 char line[256];
 int seen=0;
 char *inc_file,*ofile,*ifile;

 if(appendix)
    inc_file=ConcatStrings(4,"<a href=\"",name,HTML_FILE,"\">Appendix</a><br>\n");
 else
    inc_file=ConcatStrings(6,"<a href=\"",name,HTML_FILE,"#file\">",name,"</a><br>\n");
 ifile=ConcatStrings(4,option_odir,"/",option_name,HTML_FILE);
 ofile=ConcatStrings(4,option_odir,"/",option_name,HTML_FILE_BACKUP);

 in =fopen(ifile,"r");
 if(!in)
   {
    in =fopen(ifile,"w");
    if(!in)
      {fprintf(stderr,"cxref: Failed to open the main HTML output file '%s'\n",ifile);exit(1);}

    WriteHTMLPreamble(in,ConcatStrings(3,"Cross reference of ",option_name,"."),1);
    WriteHTMLPostamble(in,1);
    fclose(in);

    in =fopen(ifile,"r");
   }

 out=fopen(ofile,"w");

 if(!out)
   {fprintf(stderr,"cxref: Failed to open the main HTML output file '%s'\n",ofile);exit(1);}

 while(fgets(line,256,in))
   {
    if(!strcmp(inc_file,line) ||
       (!strncmp("<!--",line,4) && !strncmp(inc_file,line+4,strlen(inc_file))) ||
       (!strncmp("<!-- ",line,5) && !strncmp(inc_file,line+5,strlen(inc_file))))
      {seen=1;break;}
    if(line[0]=='<' && !strcmp("<!-- End-Of-Source-Files -->\n",line))
      {
       if(appendix)
         {
          fputs(line,out);
          fputs("\n",out);
          fputs("<!-- Appendix -->\n",out);
          fputs("\n",out);
          fputs("<hr>\n",out);
          fputs("<h1>Appendix</h1>\n",out);
          fputs("\n",out);
          fputs(inc_file,out);
         }
       else
         {
          fputs(inc_file,out);
          fputs("\n",out);
          fputs(line,out);
         }
      }
    else
       fputs(line,out);
   }

 fclose(in);
 fclose(out);

 if(!seen)
   {
    unlink(ifile);
    rename(ofile,ifile);
   }
 else
    unlink(ofile);
}


/*++++++++++++++++++++++++++++++++++++++
  Write out a standard pre-amble.

  FILE* f The file to write the pre amble to.

  char* title The title of the file.

  int sourcefile True if the Source-Files line is to be included.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLPreamble(FILE* f,char* title,int sourcefile)
{
 fputs("<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">\n",f);
 fputs("\n",f);
 fputs("<!-- This HTML file generated by cxref. -->\n",f);
 fputs("<!-- cxref program (c) Andrew M. Bishop 1995,96,97. -->\n",f);
 fputs("\n",f);
 fputs("<HTML>\n",f);
 fputs("\n",f);
 fputs("<HEAD>\n",f);
 fputs("<TITLE>",f);
 fputs(title,f);
 fputs("</TITLE>\n",f);
 fputs("</HEAD>\n",f);
 fputs("\n",f);
 fputs("<BODY>\n",f);
 fputs("\n",f);
 if(sourcefile)
   {
    fputs("<h1>Source Files</h1>\n",f);
    fputs("\n",f);
    fputs("<!-- Begin-Of-Source-Files -->\n",f);
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Write out a standard post-amble. This includes the end of document marker.

  FILE* f The file to write the post amble to.

  int sourcefile True if the Source-Files line is to be included.
  ++++++++++++++++++++++++++++++++++++++*/

static void WriteHTMLPostamble(FILE* f,int sourcefile)
{
 if(sourcefile)
   {
    fputs("\n",f);
    fputs("<!-- End-Of-Source-Files -->\n",f);
   }
 fputs("\n",f);
 fputs("</BODY>\n",f);
 fputs("</HTML>\n",f);
}


/*++++++++++++++++++++++++++++++++++++++
  Write out the appendix information.

  StringList files The list of files to write.

  StringList2 funcs The list of functions to write.

  StringList2 vars The list of variables to write.

  StringList2 types The list of types to write.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteHTMLAppendix(StringList files,StringList2 funcs,StringList2 vars,StringList2 types)
{
 char* ofile;
 int i;

 /* Write the bits to the including file. */

 WriteHTMLDocument(ConcatStrings(2,option_name,HTML_APDX),1);

 /* Open the file */

 ofile=ConcatStrings(5,option_odir,"/",option_name,HTML_APDX,HTML_FILE);

 of=fopen(ofile,"w");

 if(!of)
   {fprintf(stderr,"cxref: Failed to open the HTML appendix file '%s'\n",ofile);exit(1);}

 /* Write the file structure out */

 WriteHTMLPreamble(of,ConcatStrings(3,"Cross reference index of ",option_name,"."),0);

 fprintf(of,"<h1>Cross References</h1>\n");

 /* Write out the appendix of files. */

 if(files->n)
   {
    fprintf(of,"\n<hr>\n<h2><a name=\"files\">Files</a></h2>\n");
    fprintf(of,"<ul>\n");
    for(i=0;i<files->n;i++)
       fprintf(of,"<li><a href=\"%s"HTML_FILE"#file\">%s</a>\n",files->s[i],html(files->s[i]));
    fprintf(of,"</ul>\n");
   }

 /* Write out the appendix of functions. */

 if(funcs->n)
   {
    fprintf(of,"\n<hr>\n<h2><a name=\"functions\">Global Functions</a></h2>\n");
    fprintf(of,"<ul>\n");
    for(i=0;i<funcs->n;i++)
       fprintf(of,"<li><a href=\"%s"HTML_FILE"#func-%s\">%s()  :  %s</a>\n",funcs->s2[i],funcs->s1[i],html(funcs->s1[i]),html(funcs->s2[i]));
    fprintf(of,"</ul>\n");
   }

 /* Write out the appendix of variables. */

 if(vars->n)
   {
    fprintf(of,"\n<hr><h2><a name=\"variables\">Global Variables</a></h2>\n");
    fprintf(of,"<ul>\n");
    for(i=0;i<vars->n;i++)
       fprintf(of,"<li><a href=\"%s"HTML_FILE"#var-%s\">%s  :  %s</a>\n",vars->s2[i],vars->s1[i],html(vars->s1[i]),html(vars->s2[i]));
    fprintf(of,"</ul>\n");
   }

 /* Write out the appendix of types. */

 if(types->n)
   {
    fprintf(of,"\n<hr><h2><a name=\"types\">Defined Types</a></h2>\n");
    fprintf(of,"<ul>\n");
    for(i=0;i<types->n;i++)
       if(!strncmp("enum",types->s1[i],4))
          fprintf(of,"<li><a href=\"%s"HTML_FILE"#type-enum-%s\">%s  :  %s</a>\n",types->s2[i],&types->s1[i][5],html(types->s1[i]),html(types->s2[i]));
       else
          if(!strncmp("union",types->s1[i],5))
             fprintf(of,"<li><a href=\"%s"HTML_FILE"#type-union-%s\">%s  :  %s</a>\n",types->s2[i],&types->s1[i][6],html(types->s1[i]),html(types->s2[i]));
          else
             if(!strncmp("struct",types->s1[i],6))
                fprintf(of,"<li><a href=\"%s"HTML_FILE"#type-struct-%s\">%s  :  %s</a>\n",types->s2[i],&types->s1[i][7],html(types->s1[i]),html(types->s2[i]));
             else
                fprintf(of,"<li><a href=\"%s"HTML_FILE"#type-%s\">%s  :  %s</a>\n",types->s2[i],types->s1[i],html(types->s1[i]),html(types->s2[i]));
    fprintf(of,"</ul>\n");
   }

 WriteHTMLPostamble(of,0);

 fclose(of);

/* Clear the memory in html() */

 html(NULL); html(NULL); html(NULL); html(NULL);
}


/*++++++++++++++++++++++++++++++++++++++
  Delete the HTML file and main file reference that belong to the named file.

  char *name The name of the file to delete.
  ++++++++++++++++++++++++++++++++++++++*/

void WriteHTMLFileDelete(char *name)
{
 FILE *in,*out;
 char line[256];
 int seen=0;
 char *inc_file,*ofile,*ifile;

 ofile=ConcatStrings(4,option_odir,"/",name,HTML_FILE);
 unlink(ofile);

 inc_file=ConcatStrings(6,"<a href=\"",name,HTML_FILE,"#file\">",name,"</a><br>\n");
 ifile=ConcatStrings(4,option_odir,"/",option_name,HTML_FILE);
 ofile=ConcatStrings(4,option_odir,"/",option_name,HTML_FILE_BACKUP);

 in =fopen(ifile,"r");
 out=fopen(ofile,"w");

 if(in && !out)
   {fprintf(stderr,"cxref: Failed to open the main LaTeX output file '%s'\n",ofile);fclose(in);}
 else if(in)
   {
    while(fgets(line,256,in))
      {
       if(!strcmp(inc_file,line) ||
          (!strncmp("<!--",line,4) && !strncmp(inc_file,line+4,strlen(inc_file)-1)) ||
          (!strncmp("<!-- ",line,5) && !strncmp(inc_file,line+5,strlen(inc_file)-1)))
          seen=1;
       else
          fputs(line,out);
      }

    fclose(in);
    fclose(out);

    if(seen)
      {
       unlink(ifile);
       rename(ofile,ifile);
      }
    else
       unlink(ofile);
   }
 else if(out)
   {
    fclose(out);
    unlink(ofile);
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Make the input string safe to output as HTML ( not < > & " ).

  char* html Returns a safe HTML string.

  char* c A non-safe HTML string.

  The function can only be called four times in each fprintf() since it returns one of only four static strings.
  ++++++++++++++++++++++++++++++++++++++*/

static char* html(char* c)
{
 static char safe[4][256],*malloced[4]={NULL,NULL,NULL,NULL};
 static int which=0;
 int i=0,j=0,len=256-5;              /* 5 is the longest possible inserted amount */
 int eol=1,copy=0,skip=0;
 char* ret;

 which=(which+1)%4;
 ret=safe[which];

 if(malloced[which])
   {Free(malloced[which]);malloced[which]=NULL;}

 if(c)
    do
      {
       for(;j<len && c[i];i++)
          if(copy)
            {ret[j++]=c[i]; if(c[i]=='\n') copy=0;}
          else if(skip)
            {               if(c[i]=='\n') skip=0;}
          else switch(c[i])
            {
            case '<':
             eol=0;
             ret[j++]='&';
             ret[j++]='l';
             ret[j++]='t';
             ret[j++]=';';
             break;
            case '>':
             eol=0;
             ret[j++]='&';
             ret[j++]='g';
             ret[j++]='t';
             ret[j++]=';';
             break;
            case '"':
             eol=0;
             ret[j++]='&';
             ret[j++]='q';
             ret[j++]='u';
             ret[j++]='o';
             ret[j++]='t';
             ret[j++]=';';
             break;
            case '&':
             eol=0;
             ret[j++]='&';
             ret[j++]='a';
             ret[j++]='m';
             ret[j++]='p';
             ret[j++]=';';
             break;
            case '\n':
             eol=1;
             if(j && ret[j-1]=='\n')
               {
                ret[j-1]='<';
                ret[j++]='b';
                ret[j++]='r';
                ret[j++]='>';
               }
             ret[j++]=c[i];
             break;
            default:
             if(eol)
               {
                if(!strncmp(c+i,"+html+",6) || !strncmp(c+i,"-latex-",7))
                  {
                   do { i++; } while(c[i]!='-' && c[i]!='+'); i++;
                   copy=1;
                   break;
                  }
                if(!strncmp(c+i,"-html-",6) || !strncmp(c+i,"+latex+",7) || !strncmp(c+i,"+none+",6))
                  {
                   do { i++; } while(c[i]!='-' && c[i]!='+'); i++;
                   skip=1;
                   break;
                  }
                if(c[i]!=' ' && c[i]!='\t')
                   eol=0;
               }
             ret[j++]=c[i];
            }

       if(c[i])                 /* Not finished */
         {
          if(malloced[which])
             malloced[which]=Realloc(malloced[which],len+256+5);
          else
            {malloced[which]=Malloc(len+256+5); strncpy(malloced[which],ret,(unsigned)j);}
          ret=malloced[which];
          len+=256;
         }
       else
         {ret[j]=0; ret=NULL;}
      }
    while(ret);
 else
    safe[which][0]=0;

 return(malloced[which]?malloced[which]:safe[which]);
}
