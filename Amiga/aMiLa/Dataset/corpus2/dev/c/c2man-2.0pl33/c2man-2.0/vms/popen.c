/* Implement unix popen and pclose in vms by using mailboxes
   and lib$spawn.
   17-APR-91 -GJC@MITECH.COM version 1.0
*/

#include <stdio.h>
#include <descrip.h>
#include <ssdef.h>
#include <string.h>

FILE *popen();
int pclose();

globalvalue CLI$M_NOWAIT;

void p_describe(); /* a non-unix function */

static struct dsc$descriptor *set_dsc_cst();
static int create_mbx();

#define mailbox_size (512)
#define mailbox_byte_quota (3*mailbox_size)
#define mailbox_protection_mask (0x0000F000)

struct popen_cell
{FILE *fp;
 char *mbx_name;
 short mbx_chan;
 long pid;
 long completed;
 long comp_status;
 struct popen_cell *next;
 struct popen_cell *prev;};

static struct popen_cell *popen_list = NULL;

static struct popen_cell *find_popen_cell(fp)
     FILE *fp;
{struct popen_cell *l;
 for(l=popen_list;l != NULL; l = l->next)
   if (l->fp == fp) return(l);
 return(NULL);}

void p_describe(fp)
     FILE *fp;
{struct popen_cell *cell;
 if (!(cell = find_popen_cell(fp)))
   {printf("File pointer is not from popen, or it has been closed\n");
    return;}
 printf("FILE *fp                = %08X\n",cell->fp);
 printf("char *mbx_name          = %s\n",cell->mbx_name);
 printf("short mbx_chan          = %d\n",cell->mbx_chan);
 printf("long pid                = %08X\n",cell->pid);
 printf("long completed          = %d\n",cell->completed);
 printf("long comp_status        = %d\n",cell->comp_status);
 printf("struct popen_cell *next = %08X\n",cell->next);
 printf("struct popen_cell *prev = %08X\n",cell->prev);}

static void proc_exit_ast(cell)
     struct popen_cell *cell;
{cell->completed = 1;}

static void pclose_cleanup(cell)
     struct popen_cell *cell;
{sys$dassgn(cell->mbx_chan);
 free(cell->mbx_name);
 if (!cell->completed)
   sys$delprc(&cell->pid,0);
 memset(cell,0,sizeof(struct popen_cell));
 free(cell);}

static void pclose_delq(cell)
     struct popen_cell *cell;
{if (cell->prev)
   {cell->prev->next = cell->next;
    if (cell->next)
      cell->next->prev = cell->prev;}
 else
   {popen_list = cell->next;
    if (cell->next)
      cell->next->prev = NULL;}}

static void popen_push(cell)
     struct popen_cell *cell;
{if (popen_list)
   popen_list->prev = cell;
 cell->prev = NULL;
 cell->next = popen_list;
 popen_list = cell;}

int pclose(fp)
     FILE *fp;
{int i;
 struct popen_cell *cell;
 i = fclose(fp);
 if (cell = find_popen_cell(fp))
   {pclose_delq(cell);
    pclose_cleanup(cell);}
 return(i);}

FILE *popen(command,mode)
     char *command,*mode;
{char *temp;
 struct popen_cell *cell;
 int readp,n,mask,ret;
 char *name,*prompt,*in,*out;
 struct dsc$descriptor comm_d,in_d,out_d,name_d,prompt_d;
 
 if (strcmp(mode,"r") == 0)
   readp = 1;
 else if (strcmp(mode,"w") == 0)
   readp = 0;
 else
   return(NULL);

 temp = mktemp("POPEN_MB_XXXXXXXXXX");
 n = strlen(temp);
  cell =  (struct popen_cell *) malloc(sizeof(struct popen_cell));
 cell->mbx_name = (char *) malloc(n+1);
 strcpy(cell->mbx_name,temp);
 if ((cell->mbx_chan = create_mbx(cell->mbx_name)) < 0)
   {cell->completed = 1;
    pclose_cleanup(cell);
    return(NULL);}

 if (readp)
   {in = "NL:";
    out = cell->mbx_name;}
 else
   {in = cell->mbx_name;
    out = "NL:";}

 name = 0;
 prompt = 0;
 mask = CLI$M_NOWAIT;

 cell->completed = 0;

 ret = lib$spawn((command) ? set_dsc_cst(&comm_d,command) : 0,
                 (in) ? set_dsc_cst(&in_d,in) : 0,
                 (out) ? set_dsc_cst(&out_d,out) : 0,
                 &mask,
                 (name)  ? set_dsc_cst(&name_d,name) : 0,
                 &cell->pid,
                 &cell->comp_status,
                 0, /* event flag */
		 proc_exit_ast,
		 cell,
                 (prompt) ? set_dsc_cst(&prompt_d,prompt) : 0,
                 0 /* cli */
                 );
 
 if (ret != SS$_NORMAL)
   {cell->completed = 1;
    pclose_cleanup(cell);
    return(NULL);}

 if (!(cell->fp = fopen(cell->mbx_name,mode)))
   {pclose_cleanup(cell);
    return(NULL);}

 popen_push(cell);

 return(cell->fp);}

static struct dsc$descriptor *set_dsc_cst(x,buff)
     struct dsc$descriptor *x;
     char *buff;
{(*x).dsc$w_length = strlen(buff);
 (*x).dsc$a_pointer = buff;
 (*x).dsc$b_class = DSC$K_CLASS_S;
 (*x).dsc$b_dtype = DSC$K_DTYPE_T;
 return(x);}

static int create_mbx(name)
  char *name;
{short chan;
 int prmflg,maxmsg,bufquo,promsk,acmode,iflag,retval;
 struct dsc$descriptor lognam;
 prmflg = 0;
 maxmsg = mailbox_size;
 bufquo = mailbox_byte_quota;
 promsk = mailbox_protection_mask;
 acmode = 0;
 set_dsc_cst(&lognam,name);
 retval = sys$crembx(prmflg,&chan,maxmsg,bufquo,promsk,acmode,&lognam);
 if (retval != SS$_NORMAL) return(-1);
 return(chan);}
