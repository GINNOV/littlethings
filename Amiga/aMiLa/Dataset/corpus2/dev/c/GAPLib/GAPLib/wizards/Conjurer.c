/*
 * The GAP Conjurer (C)1999 Peter Bengtsson
 *
 * Note: This source is one big hack, so do not expect too much structure
 *       or readability from it.
 *
 * History:
 *
 *		22/4-1999: v1.0
 *			First version
 *
 *		23/4-1999: v1.1
 *			Consistently use 0 for exit in menues.
 *			Changed menu named to reflect their position in the hierarchy.
 *
 *		24/4-1999: v1.2
 *			Added setting of some rudimentary genome data.
 *
 *		25/4-1999: v1.3
 *			Fixed potential problem with special characters in project name.
 *
 *		26/4-1999:	v1.4
 *			Rewrote data filter to enable using more comples templates.
 *			Fixed a bug in the code generation for multiple source files.
 *			Fixed a bug which initialized the bitstring length to 0 as default.
 *
 *		7/5-1999:	v1.5
 *			Added default extension ".spell" to save filename.
 *
 *		18/5-1999:	v1.6
 *			Implemented help in the menu() function.
 *			Started writing help texts.
 *
 *		21/5-1999:	v1.7
 *			Added support for indexed reports.
 *			Improved the help user-interface.
 *			Added more help texts.
 *			Added external fitness function loading.
 *
 *		24/5-1999:	v1.8
 *			Fixed a bug in the BitMatrix template file.
 *			Fixed a potential NULL-reference in menu().
 *			Fixed save/load to handle external fitness functions.
 *			Added 1 line of missing initialization code.
 *
 *		25/5-1999:	v1.9
 *			Added a missing ',' in the comment level helptext array.
 *			Wrote more helptexts again.
 *
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <errno.h>

#include "data/bs_c.c"
#include "data/bm_c.c"
#include "data/bv_c.c"
#include "data/sk_c.c"
#include "data/report_h.c"
#include "data/report_c.c"
#include "data/mk.c"


/* Undefine this to make this program strictly conforming to ISO-C. */

#define	IMPURE


#define	_STRM(x)	#x
#define	STRM(x)	_STRM(x)

const char * const __v__="$VER: GAP-Conjurer 1.9 (25.5.99) ©1999 Peter Bengtsson";

#define	CLEAR	"\x1b[H\x1b[J"

#define	SPECIALCHARS	" !@#$%^&*()\\/+[];:?><~'`"

#define	TF(x)	((x)?"TRUE":"FALSE")

#define	DIR_SEPARATOR	'/'

#ifdef	AMIGA
#define	CURRENT_DIR	""
#else
#define	CURRENT_DIR	"."
#endif

#define	Rnd(a)	(rand()%a)
#define	InitRand(a)	srand((unsigned int)a)

#define	YES	'Y'
#define	NO		'N'

#define	DEFY	"[Y/n]"
#define	DEFN	"[y/N]"

#define	MN_IGN	0
#define	MN_STR	1
#define	MN_INT	2
#define	MN_BOL	3
#define	MN_EXT	-1

#define	WIZFLG_PLOT		(1<<0)
#define	WIZFLG_PSPLOT	(1<<1)
#define	WIZFLG_MPASS	(1<<2)
#define	WIZFLG_INDXD	(1<<3)

#define	DEF_GENERATIONS	32

#define	DEF_BRVLEN	3

#define	DEF_NAME	"Manhattan"

#define	NUM_DEFNAMES	11

char	*includes[] = {
	"stdio",
	"stdlib",
	"string",
	"math",
	"time",
	"GAP",
	NULL
};

char	*FitnessMenu[] = {
	"Empty function",
	"From file",
	0
};

char	*SelectNames[] = {
	"Double Random",
	"Fitness Proportionate",
	"Sigma Scaled",
	"Tournament",
	"Inorder",
	"Boltzmann",
	"Universal",
	NULL
};

char *SelectHelp[] = {
	"Select a random individual but not the fittest one, then select an\nindividual with higher fitness than the first.",
	"Individuals are selected in a linear fashion according to their fitness.",
	"Fitness proportionate with scaling based on the standard deviation.",
	"The two fittest of 4 random individuals are selected.",
	"The fittest individual is selected with all others.",
	"Selection with variable preassure. See documentation for more info.",
	"Normalized fitness proportionate selection.",
	NULL
};

char	*RepDefs[] = {
	"AVERAGE",
	"MEDIAN",
	"TYPECOUNT",
	"MAX",
	"MIN",
	"STDDEV"
};

char *RepNames[] = {
	"Average",
	"Median",
	"Typecount",
	"Maximum",
	"Minimum",
	"Standard Deviation"
};

char *RepExts[] = {
	"avg",
	"med",
	"typ",
	"max",
	"min",
	"dev"
};

char	*SelectDefs[] = {
	"DRANDOM",
	"FITPROP",
	"SIGMA",
	"TOURNAMENT",
	"INORDER",
	"TEMPERATURE",
	"UNIVERSAL"
};

char	*CrossoverNames[] = {
	"Singlepoint",
	"Multipoint",
	"Custom",
	NULL
};

char	*InitNames[] = {
	"Random init",
	"Zero init",
	"Custom init",
	NULL
};

char	*CLNames[] = {
	"None",
	"Normal",
	"Verbose",
	"Irritating",
	"Overwhelming",
	NULL
};

char *CLHelp[] = {
	"No comments at all.",
	"Only the most important and informative comments.",
	"Comments on most code passages.",
	"Lots of comments, even some useless ones.",
	"Parts of the function reference inlined as comments.",
	0
};

char	**CLMenu = CLNames;

#define	PTYPE_Bitstring	0
#define	PTYPE_Bitmatrix	1
#define	PTYPE_BRVector		2
#define	PTYPE_Custom		3

char	*GenomeNames[] = {
	"Bitstring",
	"Bitmatrix",
	"Bounded double vector",
	"Custom",
	NULL
};

char	*GenomeHelp[] = {
	"Simple bitstring",
	"Bitmatrix with 2-dimensional crossover.",
	"Vector of floating point values constrained to specified ranges.\nCrossover is either on a per element basis or numerical.",
	"This option requires you to write all code yourself.\nOnly empty functions are provided.",
	0
};

char	**GenomeMenu = GenomeNames;

char	*DefNames[] = {
	"Tourist",
	"Hacker",
	"Gnome",
	"Borg",
	"Bug",
	"Zool",
	"Ghost",
	"Hobbit",
	"Haddock",
	"Dinosaur",
	"Polyphant",
	NULL
};

struct VDisp {
	int	Type;
	long	Val;
};

char	*Menu1[] = {
	"Project parameters",
	"Population parameters",
	"Make project",
	"Save configuration",
	"Load configuration",
	"Quit",
	NULL
};

struct VDisp MainVals[] = {
	{MN_IGN,0},
	{MN_IGN,0},
	{MN_IGN,0},
	{MN_IGN,0},
	{MN_IGN,0},
	{MN_EXT,0}
};

char	*PrParms[] = {
	"Project name",
	"No. of populations",
	"Comment level",
	"Multiple sourcefiles",
	"GNUPlot script",
	"PostScript plots",
	"Exit",
	NULL
};

char *PrHelp[] = {
	"The name of this project and also the basename for the generated\nsource files.",
	"Number of populations in this project.",
	"Selects how heavily commented the generated code should be.",
	"Put the fitness function(s) in a separate source file.",
	"Automatically plot data with GNUPlot after running a session.\n(Does not work with indexed reports yet.)",
	"Make postscript plots of the generated data after a run.\n(Does not work with indexed reports yet.)",
	"Exit the menu.",
	0
};

struct VDisp PrVals[] = {
	{MN_STR,0},
	{MN_INT,0},
	{MN_STR,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_EXT,0}
};

char	*PoParms[] = {
	"Change name",
	"Change size",
	"Genome type",
	"Environment parameters",
	"Report parameters",
	"Fitness function",
	"Exit",
	NULL
};

struct VDisp PoVals[] = {
	{MN_STR,0},
	{MN_INT,0},
	{MN_STR,0},
	{MN_IGN,0},
	{MN_IGN,0},
	{MN_STR,0},
	{MN_EXT,0}
};

char	*Flags[] = {
	"Init type",
	"Selection method",
	"Crossover",
	"Crowding",
	"Mutation",
	"Pre-mutate",
	"Elitism",
	"Dump worst",
	"Init dumped",
	"Newbies",
	"Erase best",
	"Make stats",
	"Exit",
	NULL
};

char	*FlagsHelp[] = {
	"How to initialize the individuals in a newly created population.",
	"What type of selection to use.",
	"How to perform crossover of two individuals.",
	"With crowding enabled each new individual replaces that individual\nin the old population that it resembles the most. This aids\ndiversity and makes for overlapping generations.",
	"Determines if mutation is to take place.",
	"Mutate after evaluation, this is to simulate mutation occuring\nin mature individuals. This means that the fitness of an\nindividual might not reflect the actual fitness of its genome.",
	"Copy a number of the best individuals instead of generating a whole\nnew population. ",
	"Remove the worst individuals from the population before generating the\nnext one. This increases the chances of the fittest individuals.",
	"If \"dump worst\" above is greater than zero, re-initialize the worst\nindividuals instead of removing them.",
	"Randomly replace individuals with new ones.",
	"If \"newbies\" above is greater than zero, replace the fittest individuals\nwith newly generated ones. This is to keep the population\naverage down eg. when co-evolving populations.",
	"Generate statistics for eg. making report files.",
	"Exit the menu",
	0
};

char	*FlagTags[] = {
	"EVL_Evaluator",
	"EVL_Select",
	"EVL_Crosser",
	"EVL_Crowding",
	"EVL_Mutator",
	"EVL_PreMutate",
	"EVL_Elite",
	"EVL_Dump",
	"EVL_InitDumped",
	"EVL_Newbies",
	"EVL_EraseBest",
	"EVL_Stats"
};

struct VDisp FlagVals[] = {
	{MN_STR,0},
	{MN_STR,0},
	{MN_STR,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_INT,0},
	{MN_INT,0},
	{MN_BOL,0},
	{MN_INT,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_EXT,0}
};

char	*RFlagMenu[] = {
	"Average",
	"Median",
	"Typecount",
	"Max",
	"Min",
	"Standard Deviation",
	"Toggle All",
	"Runs to average",
	"Indexed reports",
	"Exit",
	NULL
};

char *RFlagHelp[] = {
	"Report average fitness.",
	"Report median fitness.",
	"Report the number of occurances of the most common fitness.",
	"Report the maximum fitness.",
	"Report the minimum fitness.",
	"Report the standard deviation of the population fitness values.",
	"Toggle the above flags.",
	"Generate average values of N runs. Note that all reports are saved\nafter being generated in this case.",
	"Do not overwrite old report files but instead generate new names\nfor each run of the program.",
	"Exit the menu",
	0
};

struct VDisp RFlagVals[] = {
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_BOL,0},
	{MN_IGN,0},
	{MN_INT,0},
	{MN_BOL,0},
	{MN_EXT,0}
};

struct NPop {
	char	*Name;
	int	Size;
	int	Type;
	int	Flags[12];
	int	RFlags[6];
	int	GData;
	char	*FFile;
};

struct {
	char	*Name;
	int	NumPops,CLevel;
	struct NPop *Pops;
	int rep,sep,flags,pass;
} Project;

char	*MOTD;

int	mcount(char **);

int	menu(char *,char **,struct VDisp *,char **);
int	msg(char *);
int	int_query(char *,int);
char *str_query(char *,char *);
int	bool_query(char *,int);
void	save_template(char *);
void	load_template(char *);
void	save_pop(FILE *,struct NPop);
void	load_pop(FILE *,int);
void	create_project(char *);
char *addpart(char *,char *);
void filtdump(FILE *,unsigned char *,int);
int	file_write(char *);
void filtdump2(FILE *,char *,int,int);


int main(int cnt,char *arg[])
{
char	z,buf[255],buf2[64],*tmenu[16],*p;
struct VDisp tvals[16];
int	i,n;

InitRand(time(NULL));

Project.Name=malloc(strlen(DEF_NAME)+1);
strcpy(Project.Name,DEF_NAME);
Project.NumPops=1;
Project.Pops = NULL;
Project.CLevel = 1;
PrVals[0].Val = (long)Project.Name;
PrVals[1].Val = 1;
PrVals[2].Val = (long)CLNames[1];
PrVals[3].Val = 0;
Project.sep=0;
Project.Pops = malloc(sizeof(struct NPop));
memset(Project.Pops,0,sizeof(struct NPop));
Project.Pops[0].Name = malloc(10);
strcpy(Project.Pops[0].Name,"Polyphant");
Project.Pops[0].Flags[4] = 1;	/* Do mutate */
Project.Pops[0].Size = 20;
Project.Pops[0].GData = 4;
Project.Pops[0].FFile = 0;
Project.flags=0;
Project.pass=1;

MOTD = malloc(1024);

strcpy(MOTD,"Welcome.");

switch(cnt) {
case	1:
	z=msg(CLEAR "\nWelcome! This is the GAP Conjurer.\n\nConjure a skeleton? " DEFY " : ");
break;

case	2:
	if(strcmp(arg[1],"-h") || strcmp(arg[1],"--help")) {
		fprintf(stderr,"%s [Template] [Dest. Dir]\n",arg[0]);
		goto tixE;
	}
	load_template(arg[1]);
	z = 1;
break;

case	3:
	load_template(arg[1]);
	create_project(arg[2]);
	goto tixE;
break;

default:
	fprintf(stderr,"%s [Template] [Dest. Dir]\n",arg[0]);
	goto tixE;
}

if(toupper(z)!=NO) {
	do {
		i=menu("Main Menu",Menu1,MainVals,0);
		switch(i) {
		case	1:
			do {
				i = menu("Main/Project parameters",PrParms,PrVals,PrHelp);
				switch(i) {
				case	1:	/* Project Name */
					free(Project.Name);
					Project.Name = str_query("Project name [" DEF_NAME "] ?",DEF_NAME);
					PrVals[0].Val = (long)Project.Name;
					for(i=0;i!=strlen(SPECIALCHARS);i++) {
						if(strchr(Project.Name,SPECIALCHARS[i])!=NULL) {
							msg("The useage of special characters is STRONGLY discouraged. [ENTER]");
						}
					}
					sprintf(MOTD,"Project name is now %s.",Project.Name);
				break;

				case	2:	/* # of pops */
					i = int_query("How many populations in project [1] ?",1);
					if(i>0) {
						for(n=0;n!=Project.NumPops;n++) {
							if(Project.Pops[n].Name!=NULL) {
								free(Project.Pops[n].Name);
							}
						}
						Project.NumPops = i;
						PrVals[1].Val = Project.NumPops;
						if(Project.Pops!=NULL) free(Project.Pops);
						Project.Pops = malloc(Project.NumPops*sizeof(struct NPop));
						memset(Project.Pops,0,Project.NumPops*sizeof(struct NPop));
						n=Rnd(NUM_DEFNAMES);
						for(i=0;i!=Project.NumPops;i++) {
							sprintf(buf,"Name for population #%d [%s]? :",i,DefNames[(i+n)%NUM_DEFNAMES]);
							Project.Pops[i].Name = str_query(buf,DefNames[(i+n)%NUM_DEFNAMES]);
							Project.Pops[i].Flags[4] = 1;	/* Do mutate */
							Project.Pops[i].Size = 20;
							Project.Pops[i].GData = 4;
							Project.Pops[i].FFile = 0;
						}
					}
					sprintf(MOTD,"%d populations created.",Project.NumPops);
				break;

				case	3:	/* Comment level */
					Project.CLevel = menu("Main/Project/Comment level",CLMenu,NULL,CLHelp)-1;
					PrVals[2].Val = (long)CLNames[Project.CLevel];
					sprintf(MOTD,"Comment level set to %s.",CLNames[Project.CLevel]);
				break;

				case	4:
					Project.sep^=1;
					PrVals[3].Val^=1;
				break;

				case	5:
					Project.flags ^= WIZFLG_PLOT;
					PrVals[4].Val = Project.flags&WIZFLG_PLOT;
				break;

				case	6:
					Project.flags ^= WIZFLG_PSPLOT;
					PrVals[5].Val = Project.flags&WIZFLG_PSPLOT;
				break;

				}
			} while(i!=mcount(PrParms));
			i=1;
		break;

		case	2:	/* Pop params */
			if(Project.NumPops>0) {
				do {
					if(Project.NumPops>1) {
						for(i=0;i!=Project.NumPops;i++) {
							tmenu[i] = Project.Pops[i].Name;
							tvals[i].Type = MN_IGN;
						}
						tvals[i].Type = MN_EXT;
						tmenu[i] = "Exit";
						tmenu[i+1] = 0;
						n = menu("Main/Select Population",tmenu,tvals,0)-1;
						if(n==(mcount(tmenu)-1)) {
							break;
						}
					} else {
						n = 0;
					}
					PoVals[0].Val = (long)Project.Pops[n].Name;
					PoVals[1].Val = Project.Pops[n].Size;
					PoVals[2].Val = (long)GenomeNames[Project.Pops[n].Type];
					PoVals[5].Val = (long)((Project.Pops[n].FFile==0)?"Empty":Project.Pops[n].FFile);
					do {
						sprintf(buf,"Main/Pop/Parameters for %s population",Project.Pops[n].Name);
						i = menu(buf,PoParms,PoVals,0);
						switch(i) {
						case	1:	/* Name */
							strcpy(buf,Project.Pops[n].Name);
							free(Project.Pops[n].Name);
							Project.Pops[n].Name = str_query("New name: ",buf);
							PoVals[0].Val = (long)Project.Pops[n].Name;
							sprintf(MOTD,"Name changed to %s.",Project.Pops[n].Name);
						break;

						case	2:	/* Size */
							sprintf(buf,"New population size [%d]? : ",Project.Pops[n].Size);
							Project.Pops[n].Size = int_query(buf,Project.Pops[n].Size);
							PoVals[1].Val = Project.Pops[n].Size;
							sprintf(MOTD,"Size changed to %d.",Project.Pops[n].Size);
						break;

						case	3: /* Genome type */
							i = menu("Main/Pop/Param/Select genome type",GenomeMenu,NULL,GenomeHelp);
							Project.Pops[n].Type = i-1;
							switch(Project.Pops[n].Type) {
							case	PTYPE_Bitstring:
								Project.Pops[n].GData = int_query("Byte length of bitstring [4]? ",4);
							break;

							case	PTYPE_BRVector:
								Project.Pops[n].GData = int_query("Elements in vector? [" STRM(DEF_BRVLEN) "]? ",DEF_BRVLEN);
							break;

							case	PTYPE_Bitmatrix:
								Project.Pops[n].GData = int_query("Height of matrix [8]? ",8);
								Project.Pops[n].GData |= int_query("Width of matrix [8]? ",8)<<16;
							break;

							default:
								;
							}
							PoVals[2].Val=(long)GenomeNames[i-1];
							sprintf(MOTD,"%s genome type set to %s.",Project.Pops[n].Name,GenomeNames[i-1]);
						break;

						case	4: /* Flags */
							sprintf(buf,"Main/Pop/Param/Flags for %s population",Project.Pops[n].Name);
							do {
								FlagVals[0].Val = (long)InitNames[Project.Pops[n].Flags[0]];
								FlagVals[1].Val = (long)SelectNames[Project.Pops[n].Flags[1]];
								FlagVals[2].Val = (long)CrossoverNames[Project.Pops[n].Flags[2]];
								FlagVals[3].Val = Project.Pops[n].Flags[3];
								FlagVals[4].Val = Project.Pops[n].Flags[4];
								FlagVals[5].Val = Project.Pops[n].Flags[5];
								FlagVals[6].Val = Project.Pops[n].Flags[6];
								FlagVals[7].Val = Project.Pops[n].Flags[7];
								FlagVals[8].Val = Project.Pops[n].Flags[8];
								FlagVals[9].Val = Project.Pops[n].Flags[9];
								FlagVals[10].Val = Project.Pops[n].Flags[10];
								FlagVals[11].Val = Project.Pops[n].Flags[11];
								FlagVals[12].Val = Project.Pops[n].Flags[12];
								i = menu(buf,Flags,FlagVals,FlagsHelp);
								switch(i) {
								case	1:	/* Init */
									Project.Pops[n].Flags[0] = menu("Main/Pop/Param/Flags/Select initialization type",InitNames,NULL,0)-1;
								break;
								case	2:	/* Select */
									Project.Pops[n].Flags[1] = menu("Main/Pop/Param/Flags/Select selection type",SelectNames,NULL,SelectHelp)-1;
								break;
								case	3:	/* Crossover */
									Project.Pops[n].Flags[2] = menu("Main/Pop/Param/Flags/Select crossover type",CrossoverNames,NULL,0)-1;
								break;
								case	4:	/* Crowding */
									Project.Pops[n].Flags[3] ^= 1;
 								break;
								case	5:	/* Mutation */
									Project.Pops[n].Flags[4] ^= 1;
								break;
								case	6:	/* Pre-Mutation */
									Project.Pops[n].Flags[5] ^= 1;
								break;
								case	7:	/* Elitism */
									Project.Pops[n].Flags[6] = int_query("Elite individuals [0]?",0);
								break;
								case	8:	/* Dump Worst */
									Project.Pops[n].Flags[7] = int_query("Individuals to remove [0]?",0);
								break;
								case	9:	/* Init Dumped */
									Project.Pops[n].Flags[8] ^= 1;
								break;
								case	10:	/* Newbies */
									Project.Pops[n].Flags[9] = int_query("Individuals to regenerate [0]?",0);
								break;
								case	11:	/* Erase Best */
									Project.Pops[n].Flags[10] ^= 1;
								break;
								case	12:	/* Make Stats */
									Project.Pops[n].Flags[11] ^= 1;
								break;
								}
							} while(i!=mcount(Flags));
						break;

						case	5: /* Report */
							sprintf(buf,"Main/Pop/Param/Report generation for %s population",Project.Pops[n].Name);
							do {
								for(i=0;i!=6;i++) {
									RFlagVals[i].Val = Project.Pops[n].RFlags[i];
								}
								RFlagVals[7].Val = Project.pass;
								i = menu(buf,RFlagMenu,RFlagVals,RFlagHelp);
								switch(i) {
								case	1:
								case	2:
								case	3:
								case	4:
								case	5:
								case	6:
									Project.Pops[n].RFlags[i-1]^=1;
								break;
								case	7:
									for(i=0;i!=6;i++) {
										Project.Pops[n].RFlags[i]^=1;
									}
								break;
								case	8:
									Project.flags &= ~WIZFLG_MPASS;
									i = int_query("Take average of how many passes [1] ?",1);
									if(i>1) {
										Project.flags |= WIZFLG_MPASS;
									} else {
										i = 1;
									}
									RFlagVals[7].Val = i;
									Project.pass = i;
								break;
								case	9:
									Project.flags ^= WIZFLG_INDXD;
									RFlagVals[8].Val = (Project.flags&WIZFLG_INDXD);
								break;
								}
							} while(i!=mcount(RFlagMenu));
							for(i=0;i!=6;i++) {
								if(Project.Pops[n].RFlags[i]!=0 && Project.Pops[n].Flags[11]==0) {
									Project.Pops[n].Flags[11] = 1;
									strcpy(MOTD,"Auto-enabled statistics.");
									break;
								}
							}
							i=0;
						break;
						case	6:	/* Fitness */
							i = menu("Main/Population/Select fitness function.",FitnessMenu,0,0);
							if(Project.Pops[n].FFile!=0) {
								free(Project.Pops[n].FFile);
							}
							switch(i) {
							case	1:
								PoVals[5].Val = (int)"Empty";
								Project.Pops[n].FFile=0;
							break;
							case	2:
								Project.Pops[n].FFile = str_query("Fitness template file [fitness.t]? :","fitness.t");
								PoVals[5].Val = (int)Project.Pops[n].FFile;
							break;
							default:
								msg("Danger Will Robinson, cosmic storm approaching.");
							}
						break;
						}
					} while(i!=mcount(PoParms));
				} while(Project.NumPops>1);
			} else {
				strcpy(MOTD,"Too few populations.");
				msg("Please set number of populations >= 1. [ENTER]");
			}
			i=2;
		break;

		case	3:	/* Make project */
			sprintf(buf,"Destination directory? [%s]? : ",CURRENT_DIR);
			p = str_query(buf,CURRENT_DIR);
			create_project(p);
			free(p);
		break;

		case	4:	/* Save */
			sprintf(buf2,"%s.spell",Project.Name);
			sprintf(buf,"Save as [%s]? : ",buf2);
			p = str_query(buf,buf2);
			save_template(p);
			free(p);
		break;

		case	5:	/* Load */
			p = str_query("Load project [" DEF_NAME ".spell]? : ",DEF_NAME ".spell");
			load_template(p);
			free(p);
		break;

		case	6: /* Quit */
			if(!bool_query("Really quit " DEFN "? :",NO)) {
				i=0;
			}
		break;
		}	/* switch() */
	} while(i!=mcount(Menu1));
} else {
	printf("Too bad.\n");
}

tixE:;

if(Project.Pops!=NULL) {
	for(i=0;i!=Project.NumPops;i++) {
		if(Project.Pops[i].Name!=NULL) {
			free(Project.Pops[i].Name);
		}
	}
	free(Project.Pops);
}

if(Project.Name!=NULL) {
	free(Project.Name);
}

if(MOTD) {
	free(MOTD);
}

return(0);
}

int menu(char *title,char **items,struct VDisp *vs,char **help)
{
int i,n;
int x=0;
char buf[255];
static int xh=0;

do {
	printf(CLEAR "\n \x1b[4m%s\x1b[0m\n\n",title);
	i=0;
	while(items[i]!=NULL) {
		printf("  %2d) %-24s",(vs!=0 && vs[i].Type==MN_EXT)?0:i+1,items[i]);
		if(vs!=NULL) {
			switch(vs[i].Type) {
			case	MN_IGN:
			break;

			case	MN_EXT:
				x=i;
			break;

			case	MN_INT:
				printf("(%ld)",vs[i].Val);
			break;

			case	MN_STR:
				if(vs[i].Val!=0) {
					printf("(%s)",(char *)vs[i].Val);
				}
			break;

			case	MN_BOL:
				printf("(%s)",(vs[i].Val)?"Yes":"No");
			break;

			default:
				fprintf(stderr,"menu: BUG!\n");
			}
		}
		printf("\n");
		i++;
	}

	if(help!=0) {
		printf("\n   H)elp available.");
	}

	if(xh==1) {
		printf("\n  eX)it help.");
	}

	printf("\n==> ");

	if(MOTD!=NULL) {
		printf("\n\nLast Message: %s\n\x1b[3A\x1b[4C",MOTD);
	}

	fflush(stdout);

	fgets(buf,255,stdin);

	if(xh==1 && buf[0]=='x') {
		return(0);
	}

	if(help!=0 && (buf[0]=='h' || buf[0]=='H')) {
		xh=1;
		do {
			n = menu("Display help on which item?",items,0,0)-1;
			if(n>=0) {
				printf(help[n]);
				msg("\n[ENTER]");
			}
		} while(n!=-1);
		xh=0;
	}

	n = atol(buf);

	if(n==0 && buf[0]=='0' && x!=0) {
		n = x+1;
	}

} while(n<1 || n>i);

printf("\x1b[J");fflush(stdout);

return(n);
}

int msg(char *m)
{
char	buf[255];
fflush(stdin);
printf(m);
fflush(stdout);
fgets(buf,255,stdin);
return((int)buf[0]);
}

int int_query(char *m,int def)
{
int	i;
char	buf[255],*p;
fflush(stdin);
printf(m);
fflush(stdout);
fgets(buf,255,stdin);
i = strtol(buf,&p,0);
if(p==buf) {
	i = def;
}
return(i);
}

char *str_query(char *m,char *def)
{
char	buf[255],*p;
printf(m);
fflush(stdout);
fgets(buf,255,stdin);
if(buf[0]=='\n') {
	if(def!=NULL) {
		strcpy(buf,def);
	} else {
		return(NULL);
	}
}
if(strchr(buf,'\n')!=NULL) {
	strchr(buf,'\n')[0]=0;
}
p = malloc(strlen(buf)+1);
strcpy(p,buf);
return(p);
}

int mcount(char **s)
{
int i;
i = -1;
while(s[++i]!=0);
return(i);
}

int bool_query(char *s,int d)
{
int v;
v = msg(s);
switch(d) {

case	YES:
	if(toupper(v)!=NO) {
		v=1;
	}
break;

case	NO:
	if(toupper(v)!=YES) {
		v=0;
	}
break;

default:
	fprintf(stderr,"bool_query: BUG!\n");
}

return(v);
}

void save_template(char *fname)
{
FILE *fp;
struct stat State;
int	r,i;

r=stat(fname,&State);

if(r==0) {
	if(bool_query("File exists, overwrite? [y/N] : ",NO)) {
		errno=ENOENT;
	} else {
		return;
	}
}

strcpy(MOTD,"Error while saving project template.");

if(errno==ENOENT) {
	fp = fopen(fname,"wb");
	if(fp!=NULL) {
		fprintf(fp,"This file is a product of the Frobozz Magic File Company.\n\n");
		fprintf(fp,"Project: %s\n",Project.Name);
		fprintf(fp,"Populations: %d\n",Project.NumPops);
		fprintf(fp,"CommentLevel: %d\n",Project.CLevel);
		fprintf(fp,"Multisource: %d\n",Project.sep);
		fprintf(fp,"Storyline: %d\n",Project.flags);
		fprintf(fp,"Passcount: %d\n\n",Project.pass);
		for(i=0;i!=Project.NumPops;i++) {
			save_pop(fp,Project.Pops[i]);
		}
		strcpy(MOTD,"Project template saved.");
		fclose(fp);
	} else {
		msg("save_template: General forseen non-fatal error occured. [ENTER]");
	}
} else {
	msg("save_template: General forseen non-fatal error occured. [ENTER]");
}
return;
}

void save_pop(FILE *fp,struct NPop pop)
{
int i;

fprintf(fp,"And now, the %s\n",pop.Name);
fprintf(fp,"\t%d,%d,",pop.Size,pop.Type);
for(i=0;i!=12;i++) {
	fprintf(fp,"%d,",pop.Flags[i]);
}
for(i=0;i!=6;i++) {
	fprintf(fp,"%d,",pop.RFlags[i]);
}
fprintf(fp,"%d,",pop.GData);
fprintf(fp,"\"%s\",",(pop.FFile!=0)?pop.FFile:"");
fprintf(fp,"*\n\n");
}

void load_template(char *fname)
{
FILE *fp;
struct stat State;
int	r,i;
char	buf[255];

r=stat(fname,&State);

if(r==0) {
	fp = fopen(fname,"rb");
	if(fp==NULL) {
		strcpy(MOTD,"Unable to read template.");
		msg("load_template: Irritating error, fopen() failed. [ENTER]");
		return;
	}
	fgets(buf,255,fp);
	if(!strcmp(buf,"This file is a product of the Frobozz Magic File Company.\n")) {

		if(Project.Pops!=NULL) {
			for(i=0;i!=Project.NumPops;i++) {
				if(Project.Pops[i].Name!=NULL) {
					free(Project.Pops[i].Name);
				}
			}
			free(Project.Pops);
		}

		if(Project.Name!=NULL) {
			free(Project.Name);
		}

		while(fgets(buf,255,fp),buf[0]=='\n');

		strchr(buf,'\n')[0]=0;
		Project.Name = malloc(strlen(buf)-8);
		strcpy(Project.Name,&buf[9]);

		while(fgets(buf,255,fp),buf[0]=='\n');
		Project.NumPops = strtol(&buf[13],NULL,0);

		while(fgets(buf,255,fp),buf[0]=='\n');
		Project.CLevel = strtol(&buf[14],NULL,0);

		while(fgets(buf,255,fp),buf[0]=='\n');
		Project.sep = strtol(&buf[13],NULL,0);

		while(fgets(buf,255,fp),buf[0]=='\n');
		Project.flags = strtol(&buf[11],NULL,0);

		while(fgets(buf,255,fp),buf[0]=='\n');
		Project.pass = strtol(&buf[11],NULL,0);

		Project.Pops = malloc(Project.NumPops*sizeof(struct NPop));

		for(i=0;i!=Project.NumPops;i++) {
			load_pop(fp,i);
		}

		PrVals[0].Val = (long)Project.Name;
		PrVals[1].Val = Project.NumPops;
		PrVals[2].Val = (long)CLNames[Project.CLevel];
		PrVals[3].Val = Project.sep;
		PrVals[4].Val = Project.flags&WIZFLG_PLOT;
		PrVals[5].Val = Project.flags&WIZFLG_PSPLOT;
		sprintf(MOTD,"Template for the %s project loaded.",Project.Name);
	} else {
		strcpy(MOTD,"Unrecognized fileformat.");
		msg("Unrecognized fileformat. [ENTER]");
	}
	fclose(fp);
} else {
	strcpy(MOTD,"Unable to examine template.");
	msg("load_template: File inaccessible. [ENTER]");
}
return;

}

void load_pop(FILE *fp,int n)
{
int i;
char buf[255],*p1;

while(fgets(buf,255,fp),strncmp(buf,"And now, the ",12));
strchr(buf,'\n')[0]=0;

Project.Pops[n].Name = malloc(strlen(buf)-11);
strcpy(Project.Pops[n].Name,&buf[13]);

fscanf(fp,"\t%d,%d,",&Project.Pops[n].Size,&Project.Pops[n].Type);

for(i=0;i!=12;i++) {
	fscanf(fp,"%d,",&Project.Pops[n].Flags[i]);
}
for(i=0;i!=6;i++) {
	fscanf(fp,"%d,",&Project.Pops[n].RFlags[i]);
}
fscanf(fp,"%d,",&Project.Pops[n].GData);

if(Project.Pops[n].FFile!=0) {
	free(Project.Pops[n].FFile);
}

fgets(buf,255,fp);
p1 = strchr(buf,'"');
p1++;
strchr(p1,'"')[0]=0;
if(p1[0]!=0) {
	Project.Pops[n].FFile = malloc(strlen(p1)+1);
	strcpy(Project.Pops[n].FFile,p1);
} else {
	Project.Pops[n].FFile = 0;
}

return;
}

void	create_project(char *dstdir)
{
FILE	*fp,*sp,*hp;
char	*buf;
struct NPop *Pops;
struct stat State;
int r,rep;
int i,n;
 
buf = malloc(2048);

Pops = Project.Pops;
strcpy(buf,dstdir);
addpart(buf,Project.Name);
strcat(buf,".c");

r=stat(buf,&State);

if(r==0) {
	if(!bool_query("Project exists, overwrite? [y/N] :",NO)) {
		free(buf);
		return;
	}
}

rep=0;
for(i=0;i!=Project.NumPops;i++) {
	for(n=0;n!=6;n++) {
		rep |= Pops[i].RFlags[n];
	}
}

Project.rep = rep;

fp = fopen(buf,"wb");
if(Project.sep) {
	strcpy(buf,dstdir);
	addpart(buf,Project.Name);
	strcat(buf,"Fitness.c");
	sp = fopen(buf,"wb");
	strcpy(buf,dstdir);
	addpart(buf,Project.Name);
	strcat(buf,".h");
	hp = fopen(buf,"wb");
} else {
	sp = fp;
	hp = fp;
}

if(fp!=NULL && sp!=NULL) {

	switch(Project.CLevel) {
	case	1:
		fprintf(fp,"/*\n *\t%s.c\n *\tCreated by the GAP Conjurer.\n *\n */\n\n",Project.Name);
	break;

	case	2:
	case	3:
		fprintf(fp,"/*\n *\t%s.c\n *\tCreated by the GAP Conjurer.\n *\n *\n * Populations:\n",Project.Name);
		for(i=0;i!=Project.NumPops;i++) {
			fprintf(fp," *\t%s population.\n",Pops[i].Name);
		}
		fprintf(fp," */\n\n");
	break;

	case	4:
		fprintf(fp,"/*\n *\t%s.c\n *\tCreated by the GAP Conjurer.\n *\n *\n * Populations:\n",Project.Name);
		for(i=0;i!=Project.NumPops;i++) {
			fprintf(fp," *\t%s population. (%d individuals initially)\n",Pops[i].Name,Pops[i].Size);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[0],InitNames[Pops[i].Flags[0]]);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[1],SelectNames[Pops[i].Flags[1]]);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[2],CrossoverNames[Pops[i].Flags[2]]);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[3],(Pops[i].Flags[3])?"Yes":"No");
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[4],(Pops[i].Flags[4])?"Yes":"No");
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[5],(Pops[i].Flags[5])?"Yes":"No");
			fprintf(fp," *\t\t %-20s(%d)\n",Flags[6],Pops[i].Flags[6]);
			fprintf(fp," *\t\t %-20s(%d)\n",Flags[7],Pops[i].Flags[7]);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[8],(Pops[i].Flags[8])?"Yes":"No");
			fprintf(fp," *\t\t %-20s(%d)\n",Flags[9],Pops[i].Flags[9]);
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[10],(Pops[i].Flags[10])?"Yes":"No");
			fprintf(fp," *\t\t %-20s(%s)\n",Flags[11],(Pops[i].Flags[11])?"Yes":"No");
			fprintf(fp," *\n");
		}
		fprintf(fp," */\n\n");
	break;

	default:
		;
	}


	if(Project.CLevel>2) {
		fprintf(fp,"/* Includes follow */\n");
	}


	i = 0;
	while(includes[i]!=NULL) {
		fprintf(fp,"#include <%s.h>\n",includes[i++]);
	}

	if(rep!=0) {
		fprintf(fp,"#include \"report.h\"\n");
	}

	if(Project.sep!=0) {
		fprintf(fp,"#include \"%s.h\"\n",Project.Name);
	}

	fprintf(hp,"\n%s",(Project.CLevel>0)?"/* Population defines. */\n\n":"");

	buf[0]=0;
	for(i=0;i!=Project.NumPops;i++) {
		if(Project.CLevel>1) {
			sprintf(buf,"\t/* Initial size of %s population. */",Pops[i].Name);
		}
		fprintf(hp,"#define\t%sSIZE\t%d%s\n",Pops[i].Name,Pops[i].Size,buf);
	}

	fprintf(hp,"\n%s",(Project.CLevel>0)?"/* Population structures. */\n\n":"");

	for(i=0;i!=Project.NumPops;i++) {

		fprintf(hp,"\n/*===== %s =====*/\n\n",Pops[i].Name);

		fprintf(hp,"#%s\tZINIT%d\n",(Pops[i].Flags[0]==1)?"define":"undef",i);
		fprintf(hp,"#%s\tMPCROSS%d\n\n",(Pops[i].Flags[2]==1)?"define":"undef",i);

		switch(Pops[i].Type) {
		case	PTYPE_Bitstring:
			fprintf(hp,"#define\tSIZE%d\t%d%s\n\n",i,Pops[i].GData,(Project.CLevel>1)?"\t/* _BYTE_ length of bitstring. */":"");
		break;

		case	PTYPE_Bitmatrix:
			fprintf(hp,"#define\tWIDTH%d\t%d\n",i,Pops[i].GData>>16);
			fprintf(hp,"#define\tHEIGHT%d\t%d\n",i,Pops[i].GData&0xffff);
			fprintf(hp,"#define\tXBYTES%d\t((WIDTH%d+7)>>3)\n\n",i,i);
		break;

		case	PTYPE_BRVector:
			fprintf(hp,"#define\tVLENGTH%d\t%d\n\nstatic double Constraints%d[VLENGTH%d][2] = {%s\n",i,Pops[i].GData,i,i,(Project.CLevel>0)?" /* Constraint ranges. */":"");
			for(n=0;n<(Pops[i].GData-1);n++) {
				fprintf(hp,"   {-1.0,1.0},%s\n",(Project.CLevel>2)?"\t/* This comment is here just to irritate you. */":"");
			}
			fprintf(hp,"   {-1.0,1.0}\n};\n\n");
		break;

		case	PTYPE_Custom:
		break;

		default:
			fprintf(hp,"/* Error in population type. */\n\n");
		}

		fprintf(hp,"struct %s {\n",Pops[i].Name);
		switch(Pops[i].Type) {
		case	PTYPE_Bitstring:
			fprintf(hp,"   unsigned char Data[SIZE%d];\n",i);
		break;

		case	PTYPE_Bitmatrix:
			fprintf(hp,"   unsigned char matrix[HEIGHT%d][XBYTES%d];\n   int x,y,xb;\n",i,i);
		break;

		case	PTYPE_BRVector:
			fprintf(hp,"   double\tv[%d];\n",DEF_BRVLEN);
		break;

		case	PTYPE_Custom:
			if(Project.CLevel>0) {
				fprintf(hp,"   /* Define custom data for %s here. */\n",Pops[i].Name);
			}
		break;

		default:
			fprintf(hp,"/* Error in population type. */\n");
		}
		fprintf(hp,"};\n\n");
	}

	if(Project.CLevel>0) {
		fprintf(hp,"/* Function prototypes follow. */\n\n");
	}

	if(Project.CLevel>1) {
		fprintf(hp,"/* Fitness functions. */\n\n");
	}

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(hp,"%sdouble %sFitness(struct %s *);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name);
	}

	fprintf(fp,"\n");
	if(Project.CLevel>1) {
		fprintf(hp,"/* Other functions. */\n\n");
	}

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(hp,"%svoid Init%s(struct %s *);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name);
		if(Pops[i].Flags[4]!=0) {
			fprintf(hp,"%svoid Mutate%s(struct %s *);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name);
		}
		fprintf(hp,"%svoid Cross%s(struct %s *,struct %s *);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name,Pops[i].Name);
		fprintf(hp,"%sdouble Compare%s(struct %s *,struct %s *,int);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name,Pops[i].Name);
		fprintf(hp,"%svoid Kill%s(struct %s *);\n",(Project.sep!=0)?"extern ":"",Pops[i].Name,Pops[i].Name);
		fprintf(hp,"\n");
	}

/* Create main() */

	if(Project.CLevel>0) {
		fprintf(fp,"/*=== Main program starts here. ===*/\n\n");
	}

	fprintf(fp,"int main(int cnt,char *arg[])\n{\nint\ti%s;\nint\tGenerations=10;\n",(Project.flags&WIZFLG_MPASS)?",n":"");

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"struct Population *%sPop;\n",Pops[i].Name);
	}

	if(rep!=0) {
		for(i=0;i!=Project.NumPops;i++) {
			for(n=0;n!=6;n++) {
				if(Pops[i].RFlags[n]!=0) {
					fprintf(fp,"struct Report *%sRep;\n",Pops[i].Name);
					break;
				}
			}
		}
	}

	fprintf(fp,"\n");	

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"struct TagItem %sInitTags[] = {\n"\
		"   {POP_Init,(IPTR)Init%s},\n"\
		"   {POP_Destruct,(IPTR)Kill%s},\n"\
		"   {POP_Cache,TRUE},\n"\
		"   {TAG_DONE,0L}\n};\n\n",Pops[i].Name,Pops[i].Name,Pops[i].Name);
	}

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"struct TagItem %sEvolveTags[] = {",Pops[i].Name);
		for(n=0;n!=12;n++) {
			fprintf(fp,"\n   {%s,",FlagTags[n]);
			switch(n) {
			case	0:
				fprintf(fp,"(IPTR)%sFitness},",Pops[i].Name);
			break;
			case	1:
				fprintf(fp,"%s},",SelectDefs[Pops[i].Flags[n]]);
			break;
			case	2:
				fprintf(fp,"(IPTR)Cross%s},",Pops[i].Name);
			break;
			case	3:
				fprintf(fp,"%s},",TF(Pops[i].Flags[n]));
			break;
			case	4:
				if(Pops[i].Flags[n]!=0) {
					fprintf(fp,"(IPTR)Mutate%s},",Pops[i].Name);
				} else {
					fprintf(fp,"NULL},");
				}
			break;
			case	5:
				fprintf(fp,"%s},",TF(Pops[i].Flags[n]));
			break;
			case	6:
				fprintf(fp,"%d},",Pops[i].Flags[n]);
			break;
			case	7:
				fprintf(fp,"%d},",Pops[i].Flags[n]);
			break;
			case	8:
				fprintf(fp,"%s},",TF(Pops[i].Flags[n]));
			break;
			case	9:
				fprintf(fp,"%d},",Pops[i].Flags[n]);
			break;
			case	10:
				fprintf(fp,"%s},",TF(Pops[i].Flags[n]));
			break;
			case	11:
				fprintf(fp,"%s},",TF(Pops[i].Flags[n]));
			break;
			default:
				fprintf(fp,"/* Tag creation error. */\n");
			}
		}
		fprintf(fp,"\n   {TAG_DONE,0L}\n};\n\n");
	}

	if(Project.flags&(WIZFLG_MPASS|WIZFLG_INDXD)) {
		fprintf(fp,"struct TagItem ReportTags[] = {\n");
		if(Project.flags&WIZFLG_MPASS) {
			fprintf(fp,"\t{REP_Generations,0},\n\t{REP_Multipass,TRUE},\n");
		}
		if(Project.flags&WIZFLG_INDXD) {
			fprintf(fp,"\t{REP_Indexed,TRUE},\n");
		}
		fprintf(fp,"\t{TAG_DONE,0L}\n};\n\n");
	}

/*	if(rep!=0 && (Project.flags&(WIZFLG_INDXD|WIZFLG_MPASS))==(WIZFLG_INDXD|WIZFLG_MPASS)) {
		fprintf(fp,"char NameBuf[64];\n\n");
	}*/


	fprintf(fp,"if(cnt>1) {\n   if(strcmp(arg[1],\"-h\")==0 || strcmp(arg[1],\"--help\")==0) {\n"\
		"      fprintf(stderr,\"Useage:\\n\\n%%s <Generations>\\n\\n\",arg[0]);\n      return(0);\n   }\n"\
		"   Generations = atoi(arg[1]);\n}\n\nif(Generations<1) {\n   Generations=10;\n}\n\n");

	fprintf(fp,"InitRand(time(NULL));\n\n");

	if(Project.flags&WIZFLG_MPASS) {
		fprintf(fp,"ReportTags[0].ti_Data = (IPTR)Generations;\n\n");
	}

	if(rep!=0) {
		for(i=0;i!=Project.NumPops;i++) {
			for(n=0;n!=6;n++) {
				if(Pops[i].RFlags[n]!=0) {
					fprintf(fp,"%sRep = MakeReport(\"%s\",%s);\n",Pops[i].Name,Pops[i].Name,(Project.flags&(WIZFLG_MPASS|WIZFLG_INDXD))?"ReportTags":"NULL");
					break;
				}
			}
		}
	}

	fprintf(fp,"\n");

	if(Project.flags&WIZFLG_MPASS) {
		fprintf(fp,"for(n=0;n!=%d;n++) {",Project.pass);
		if(Project.CLevel>2) {
			sprintf(buf,"\t/* Perform %d runs of this GA. */",Project.pass);
		}
		fprintf(fp,"\n\n");
	}

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"%s%sPop = CreatePopulation(%sSIZE,sizeof(struct %s),%sInitTags);\n",(Project.flags&WIZFLG_MPASS)?"\t":"",Pops[i].Name,Pops[i].Name,Pops[i].Name,Pops[i].Name);
	}

	fprintf(fp,"\n%sif(",(Project.flags&WIZFLG_MPASS)?"\t":"");
	for(i=0;i!=(Project.NumPops-1);i++) {
		fprintf(fp,"%sPop!=NULL && ",Pops[i].Name);
	}
	fprintf(fp,"%sPop!=NULL) {\n",Pops[i].Name);

	fprintf(fp,"%s\tfor(i=0;i!=Generations;i++) {\n",(Project.flags&WIZFLG_MPASS)?"\t":"");

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"%s\t\t%sPop = Evolve(%sPop,%sEvolveTags);\n",(Project.flags&WIZFLG_MPASS)?"\t":"",Pops[i].Name,Pops[i].Name,Pops[i].Name);
	}

	if(rep!=0) {
		fprintf(fp,"\n");
		for(i=0;i!=Project.NumPops;i++) {
			buf[0]=0;
			for(n=0;n!=6;n++) {
				if(Pops[i].RFlags[n]!=0) {
					strcat(buf,RepDefs[n]);
					strcat(buf,"|");
				}
			}
			if(buf[0]!=0) {
				buf[strlen(buf)-1]=0;
				fprintf(fp,"%s\t\tDoReport(%sRep,%sPop,%s);\n",(Project.flags&WIZFLG_MPASS)?"\t":"",Pops[i].Name,Pops[i].Name,buf);
			}
		}
	}

	fprintf(fp,"%s\t}\n%s}\n\n",(Project.flags&WIZFLG_MPASS)?"\t":"",(Project.flags&WIZFLG_MPASS)?"\t":"");

	for(i=0;i!=Project.NumPops;i++) {
		fprintf(fp,"%sif(%sPop!=NULL){ DeletePopulation(%sPop); }\n",(Project.flags&WIZFLG_MPASS)?"\t":"",Pops[i].Name,Pops[i].Name);
	}

	if(Project.flags&WIZFLG_MPASS) {
		fprintf(fp,"}\n");
	}

	fprintf(fp,"\n");

	if(rep!=0) {
		for(i=0;i!=Project.NumPops;i++) {
			for(n=0;n!=6;n++) {
				if(Pops[i].RFlags[n]!=0) {
					fprintf(fp,"if(%sRep!=NULL){ EndReport(%sRep); }\n",Pops[i].Name,Pops[i].Name);
					break;
				}
			}
		}
	}

	if(rep!=0) {
		if(Project.flags&WIZFLG_PSPLOT) {
			fprintf(fp,"\nsystem(\"gnuplot MakePS\");\n");
		}
		if(Project.flags&WIZFLG_PLOT) {
			fprintf(fp,"\nsystem(\"gnuplot ShowReport\");\n");
		}
	}

	fprintf(fp,"\nreturn(0);\n}\n\n");

/* == End of main() writing code == */

if(Project.sep!=0) {
	fprintf(sp,"#include <GAP.h>\n#include <math.h>\n#include \"%s.h\"\n\n",Project.Name);
	for(i=0;i!=Project.NumPops;i++) {
		fprintf(sp,"double %sFitness(struct %s *);\n",Pops[i].Name,Pops[i].Name);
	}
	fprintf(sp,"\n");
}

if(Project.CLevel>0) {
	fprintf(sp,"/*=== Fitness functions ===*/\n");
	if(Project.CLevel>2) {
		fprintf(sp,"/* Below here are the functions which define how\n * fit an individual is - commponly known as fitness functions.\n */\n\n");
	}
}

for(i=0;i!=Project.NumPops;i++) {
	if(Pops[i].FFile==0) {
		fprintf(sp,"double %sFitness(struct %s *Polly)\n{\ndouble fitness=0.0;\n",Pops[i].Name,Pops[i].Name);
		if(Project.CLevel>0) {
			fprintf(sp,"/* Write fitness function for %s here. */\n",Pops[i].Name);
		}
		fprintf(sp,"return(fitness);\n}\n\n");
	} else {
		struct stat State;
		if(stat(Pops[i].FFile,&State)==0) {
			char	*tbuf;
			tbuf = malloc(State.st_size+1);
			if(tbuf!=0) {
				FILE *ffp;
				ffp = fopen(Pops[i].FFile,"rb");
				if(ffp!=0) {
					fread(tbuf,State.st_size,1,ffp);
					fclose(ffp);
					tbuf[State.st_size]=0;
					filtdump(sp,tbuf,i);
					free(tbuf);
				} else {
					msg("Unable to read fitness file, skipping... [ENTER]");
				}
			} else {
				msg("Infernal error, virtual store exhausted. malloc() failed. [ENTER]");
			}
		} else {
			msg("Unable to load external fitness function, defaulting to empty function.\n[ENTER]");
			fprintf(sp,"double %sFitness(struct %s *Polly)\n{\ndouble fitness=0.0;\n",Pops[i].Name,Pops[i].Name);
			if(Project.CLevel>0) {
				fprintf(sp,"/* Write fitness function for %s here. */\n",Pops[i].Name);
			}
			fprintf(sp,"return(fitness);\n}\n\n");
		}
	}
}


if(Project.CLevel>0) {
	fprintf(fp,"/*=== Crossover, Mutation etc. functions. ===*/\n\n");
}

/* Functions */

for(i=0;i!=Project.NumPops;i++) {
	switch(Pops[i].Type) {
	case	PTYPE_Bitstring:
		filtdump(fp,Bitstring_c,i);
	break;

	case PTYPE_Bitmatrix:
		filtdump(fp,Bitmatrix_c,i);
	break;

	case PTYPE_BRVector:
		filtdump(fp,BRVector_c,i);
	break;

	case PTYPE_Custom:
		filtdump(fp,Skeleton_c,i);
	break;

	}
}

/* == magic == */

	if(Project.CLevel>0) {
		fprintf(fp,"\n/* vi: set ts=3: */ /* vim magic */\n");
	}

	fclose(fp);
	if(fp!=sp) {
		fclose(sp);
	}
	if(fp!=hp) {
		fclose(hp);
	}


/* Report files. */

if(rep!=0) {
	strcpy(buf,dstdir);
	addpart(buf,"report.h");
	if(file_write(buf)) {
		if((fp=fopen(buf,"wb"))!=NULL) {
			fwrite(report_h,report_h_SIZE,1,fp);
			fclose(fp);
		}
	}

	strcpy(buf,dstdir);
	addpart(buf,"report.c");
	if(file_write(buf)) {
		if((fp=fopen(buf,"wb"))!=NULL) {
			fwrite(report_c,report_c_SIZE,1,fp);
			fclose(fp);
		}	
	}
}


/* Makefile */

strcpy(buf,dstdir);
addpart(buf,"Makefile");
if(file_write(buf)) {
	if((fp=fopen(buf,"wb"))!=NULL) {
		filtdump(fp,mk,0);
		fclose(fp);
	}
}

/* PostScript(tm) generation script */

if(Project.flags&WIZFLG_PSPLOT) {
	strcpy(buf,dstdir);
	addpart(buf,"MakePS");
	if(file_write(buf)) {
		if((fp=fopen(buf,"wb"))!=NULL) {
			fprintf(fp,"\n# PostScript(tm) generation script for GNUPlot.\n# Created by the GAP Conjurer.\n\n");
			fprintf(fp,"set terminal postscript landscape monochrome\n\n");
			for(i=0;i!=Project.NumPops;i++) {
				for(n=0;n!=6;n++) {
					if(Pops[i].RFlags[n]!=0) {
						fprintf(fp,"set output \"%s%s.ps\"\n",Pops[i].Name,RepDefs[n]);
						fprintf(fp,"set title \"%s %s\"\n",Pops[i].Name,RepNames[n]);
						fprintf(fp,"plot \"%s.%s\" with lines\n\n",Pops[i].Name,RepExts[n]);
					}
				}
			}
			fclose(fp);
		}
	}
}

if(Project.flags&WIZFLG_PLOT) {
	strcpy(buf,dstdir);
	addpart(buf,"ShowReport");
	if(file_write(buf)) {
		if((fp=fopen(buf,"wb"))!=NULL) {
			fprintf(fp,"\n# Report display script for GNUPlot.\n# Generated by the GAP Conjurer.\n\n");
			buf[0] = 0;
			for(i=0;i!=Project.NumPops;i++) {
				for(n=0;n!=6;n++) {
					if(Pops[i].RFlags[n]!=0) {
						sprintf(&buf[strlen(buf)],"\t\"%s.%s\" with lines,\\\n",Pops[i].Name,RepExts[n]);
					}
				}
			}
			buf[strlen(buf)-3] = 0;
			fprintf(fp,"plot \\\n%s",buf);
			fprintf(fp,"\npause -1 \"Press enter to continue...\"");
			fclose(fp);
		}
	}
}

	sprintf(MOTD,"Created the %s project.",Project.Name);

} else {
	strcpy(MOTD,"Error creating project.");
	msg("create_project: Unable to open file for writing. [ENTER]");
}

free(buf);

return;
}

char *addpart(char *buf,char *fname)
{
int l;

l = strlen(buf);

#ifdef	AMIGA
if(buf[l-1]==DIR_SEPARATOR || buf[l-1]==':' || buf[0]==0) {
#else
if(buf[l-1]==DIR_SEPARATOR || buf[0]==0) {
#endif
	strcat(buf,fname);
} else {
	buf[l]=DIR_SEPARATOR;
	buf[l+1]=0;
	strcat(buf,fname);
}
return(buf);
}

void filtdump2(FILE *fp,char *data,int indx,int v)
{
int n;
int z;
static int p;

if(fp==NULL) {
	p= -1;
	return;
}

while((z=data[++p])!=0) {
	if(z=='$') {
		z=data[++p];
		switch(z) {
		case	'1':
		case	'2':
		case	'3':
		case	'4':
			n = z-'1';
			filtdump2(fp,data,indx,((Project.CLevel>n)?1:0)&v);
		break;

		case	'N':
			if(v){fprintf(fp,Project.Pops[indx].Name);}
		break;

		case	'I':
			if(v){fprintf(fp,"%d",indx);}
		break;		

		case	'$':
			if(v){fputc('$',fp);}
		break;

		case	'P':
			if(v){fprintf(fp,Project.Name);}
		break;

		case	'U':
			filtdump2(fp,data,indx,((Project.sep)?1:0)&v);
		break;

		case	'R':
			filtdump2(fp,data,indx,((Project.rep)?1:0)&v);
		break;

		default:
			p--;
			return;		
		}
	} else if(v!=0) {
		fputc(z,fp);
	}
}

}


void filtdump(FILE *fp,unsigned char *data,int indx)
{

filtdump2(0,0,0,0);
filtdump2(fp,data,indx,1);

}

int file_write(char *fname)
{
int	r,i=0;
struct stat State;
char	buf[255];

r=stat(fname,&State);

if(r==0) {
	sprintf(buf,"%s exists, overwrite? " DEFN " : ",fname);
	if(bool_query(buf,NO)) {
		i = 1;
	}
} else {
	switch(errno) {

	case	ENOENT:
		i = 1;
	break;

	case	EBUSY:
		msg("File already in use. [ENTER]");
		i = 0;
	break;

	case	EPERM:
		msg("Access denied. [ENTER]");
		i = 0;
	break;

	default:
		sprintf(buf,"Unexpected forseen but unknown error on file \"%s\". [ENTER]",fname);
		msg(buf);
		i = 0;
	}
}

return(i);
}

