#include "PROJ:CGLE/gle.h"

/***** Version ******/

#define WINDOWTITLE		"AB3DTrainer v3.01"
#define VERSIONSTRING	"$VER: "				\
						WINDOWTITLE				\
						" (" __DATE__ " "  __TIME__ ") © 1997 John Girvin"


/***** Prefs ******/

typedef struct PREFS
{
	UBYTE NoGUI;
	UBYTE InfAmmo;
	UBYTE InfEnergy;
	UBYTE UseHack;
	UBYTE Control;
};


/***** Gadget ID's ******/

#define	GAD_ENERGY			1
#define	LAB_ENERGY			2
#define	GAD_AMMO			3
#define	LAB_AMMO			4
#define	GAD_HACK			5
#define	LAB_HACK			6
#define	GAD_CONTROL			7
#define	LAB_CONTROL			8
#define	GAD_PLAY			9
#define	GAD_CANCEL			10

#define GAD_BLANK1			11
#define GAD_BLANK2			12


/***** Prototypes ******/

BOOL CreateControlPanel (void);

/***** Externs ******/

extern struct Library *GadToolsBase;
extern struct Library *DOSBase;
