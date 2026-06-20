/*
**
**
**
**
*/

#define BUT_Text		(TAG_USER + 1)
#define BUT_Color		(TAG_USER + 2)
#define BUT_BackColor	(TAG_USER + 3)
#define BUT_TextFont	(TAG_USER + 4)
#define BUT_Image		(TAG_USER + 5)
#define BUT_SelectImage	(TAG_USER + 6)
#define BUT_Drawer		(TAG_USER + 7)


#define PRO_Min			(TAG_USER + 9)
#define PRO_Max			(TAG_USER + 10)
#define PRO_Current		(TAG_USER + 11)
#define PRO_ShowPercent (TAG_USER + 12)
#define PRO_TextFont	(TAG_USER + 4)


Class *initButtonGadgetClass(struct Library *IBase, struct Library *UBase, struct Library *GBase);
BOOL freeButtonGadgetClass ( Class *cl );

Class *initProgressGadgetClass(struct Library *IBase, struct Library *UBase, struct Library *GBase);
BOOL freeProgressGadgetClass ( Class *cl );
