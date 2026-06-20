/*
** Config.c
**
** $VER: Config.c 1.01 (29.5.96)
**
** Copyright (C) 1996, Adam Dawes
**
** Refer to accompanying documentation for further details
*/


#include <exec/exec.h>
#include <clib/exec_protos.h>


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Config.h"



int WriteConfig(char *filename, char *section, char *item, char *data)
{
	FILE *cfgfile;
	struct List cfglist;
	char *cfgdata;

	char readbuffer[BUFFERSIZE];

	struct Node *worknode;

	int linecount = 0;
	int insection = FALSE, sectionfound = FALSE, itemfound = FALSE;


	init_list(&cfglist);


	/* read existing cfg file (if it exists) */
	cfgfile = fopen(filename,"r");
	if (cfgfile != NULL)
	{
		while (fgets(readbuffer,BUFFERSIZE,cfgfile) != NULL)
		{
			readbuffer[strlen(readbuffer)-1] = 0;		/* kill the trailing CR */
			if (strlen(readbuffer) > 0)
			{
				cfgdata = AllocVec(strlen(readbuffer)+1,MEMF_PUBLIC);
				if (cfgdata == NULL)		/* allocation error */
				{
					fclose(cfgfile);			/* close the file */
					free_list(&cfglist);		/* free everything we've allocated so far */
					return(CFG_WRITE_FAIL);	/* return an error */
				}
				strcpy(cfgdata,readbuffer);
				if (add_list_item(&cfglist,cfgdata) == FALSE)	/* error allocating node? */
				{
					fclose(cfgfile);			/* close the file */
					FreeVec(cfgdata);			/* free this line of data */
					free_list(&cfglist);		/* free everything we've allocated so far */
					return(CFG_WRITE_FAIL);	/* return an error */
				}
			}
		}
	}
	fclose(cfgfile);



	/* rewrite config file from list, adding new entry at required position */
	cfgfile = fopen(filename,"w");
	if (cfgfile == NULL)
	{
		free_list(&cfglist);
		return(CFG_WRITE_FAIL);
	}

	worknode = cfglist.lh_Head;

	while (worknode != (struct Node*)&cfglist.lh_Tail)
	{
		if (ISSECTION(worknode->ln_Name))
		{
			if (insection == TRUE && itemfound == FALSE)
			{
				/* we were in the section, but now we've found another. Therefore the data needs to be added to the previous section */
				fprintf(cfgfile,"%s = %s\n",item,data);
			}

			fprintf(cfgfile,"%s%s\n",linecount==0 ? "" : "\n", worknode->ln_Name);
			if (strnicmp(worknode->ln_Name+1,section,strlen(section)) == 0)
			{
				insection = TRUE;
				sectionfound = TRUE;
			}
			else
			{
				insection = FALSE;
			}
		}
		else
		{
			if (insection == TRUE && strnicmp(worknode->ln_Name,item,strlen(item)) == 0 && strnicmp(worknode->ln_Name + strlen(item)," = ",3) == 0)
			{
				fprintf(cfgfile,"%s = %s\n",item,data);
				itemfound = TRUE;
			}
			else
			{
				fprintf(cfgfile,"%s\n",worknode->ln_Name);
			}
		}

		worknode = worknode->ln_Succ;
		linecount += 1;
	}

	if (insection == TRUE && itemfound == FALSE)
	{
		/* we were in the section, but now we've reached the end. Therefore the data needs to be added to the previous section */
		fprintf(cfgfile,"%s = %s\n",item,data);
	}

	if (sectionfound == FALSE)
	{
		/* couldn't find the section, so create it now */
		fprintf(cfgfile,"%s[%s]\n",linecount==0 ? "" : "\n", section);
		fprintf(cfgfile,"%s = %s\n",item,data);
	}

	fclose(cfgfile);


	/* clean up */
	free_list(&cfglist);

	return(CFG_WRITE_SUCCESS);
}



int WriteConfigNumber(char *filename, char *section, char *item, long data)
{
	char numbuf[20];

	sprintf(numbuf,"%d",data);

	return(WriteConfig(filename,section,item,numbuf));
}




int ReadConfig(char *filename, char *section, char *item, char *buffer, int bufsize, char *def)
{
	FILE *cfgfile;
	char readbuffer[BUFFERSIZE];

	int insection = FALSE;

	/* First open the config file. If it can't be opened, return the default value. */
	cfgfile = fopen(filename,"r");
	if (cfgfile == NULL)
	{
		if (strlen(def) >= bufsize)
		{
			return(CFG_READ_FAIL);
		}
		else
		{
			strcpy(buffer,def);
			return(CFG_READ_SUCCESS);
		}
	}


	/* Now scan the file looking the the desired section and item */
	while (fgets(readbuffer,BUFFERSIZE,cfgfile) != NULL)
	{
		readbuffer[strlen(readbuffer)-1] = 0;		/* kill the trailing CR */
		if (strlen(readbuffer) > 0)
		{
			if (ISSECTION(readbuffer))
			{
				if (strnicmp(&readbuffer[1],section,strlen(section)) == 0)
				{
					insection = TRUE;
				}
				else
				{
					insection = FALSE;
				}
			}
			else
			{
				if (insection == TRUE && strnicmp(readbuffer,item,strlen(item)) == 0 && strnicmp(&readbuffer[strlen(item)]," = ",3) == 0)
				{
					if (strlen(&readbuffer[strlen(item)+3]) >= bufsize)
					{
						fclose(cfgfile);
						return(CFG_READ_FAIL);
					}
					else
					{
						fclose(cfgfile);
						strcpy(buffer,&readbuffer[strlen(item)+3]);
						return(CFG_READ_SUCCESS);
					}
				}
			}
		}
	}

	fclose(cfgfile);


	/* we've reached the end of the file without finding the requested item in */
	/* the requested section, so we'll return the default value instead. */

	if (strlen(def) >= bufsize)
	{
		return(CFG_READ_FAIL);
	}
	else
	{
		strcpy(buffer,def);
		return(CFG_READ_SUCCESS);
	}
}



extern long ReadConfigNumber(char *filename, char *section, char *item, long def)
{
	char numbuf[20], retbuf[20];
	char *tail;

	sprintf(numbuf,"%d",def);

	ReadConfig(filename,section,item,retbuf,20,numbuf);

	return(strtol(retbuf,&tail,10));
}




void init_list(struct List *lst)
{
	lst->lh_Head = (struct Node*)&lst->lh_Tail;
	lst->lh_Tail = 0;
	lst->lh_TailPred = (struct Node*)&lst->lh_Head;
	lst->lh_Type = NT_TASK;
}



int add_list_item(struct List *lst, char *item)
{

	struct Node *worknode;

	worknode = AllocVec(sizeof(struct Node),MEMF_PUBLIC);
	if (worknode == NULL)		/* allocation error */
	{
		return(FALSE);
	}
	worknode->ln_Name = item;
	worknode->ln_Pri = 0;
	worknode->ln_Type = NT_TASK;

	AddTail(lst,worknode);

	return(TRUE);
}


void free_list(struct List *lst)
{
	struct Node *worknode;

	while (lst->lh_Head != (struct Node*)&lst->lh_Tail)
	{
		worknode = lst->lh_Head;				/* get a pointer to this node */

		FreeVec(worknode->ln_Name);			/* free the name memory */

		RemHead(lst);								/* remove from the list */
		FreeVec(worknode);						/* and free the node */
	}
}





int is_section(char *cfgdata)
{
	return (cfgdata[0] == '[' && cfgdata[strlen(cfgdata)-1] == ']');
}


