
struct ConInfo
	{
	ulong Use_The_Tags_To_Set_Attributes;
	};

extern struct ConInfo * __stdargs InitCon  (struct Window * Win,ulong FirstTag, ...);
extern struct ConInfo * __regargs InitConA (struct Window * Win,struct TagItem * TagList);
extern void __regargs CloseCon  (struct ConInfo * ConInfo);
extern void __regargs RedrawCon (struct ConInfo * ConInfo);
extern void __regargs ModifyConA (struct ConInfo * ConInfo,struct TagItem * TagList);
extern void __stdargs ModifyCon  (struct ConInfo * ConInfo,ulong FirstTag, ...);
extern void __regargs HandleCon  (struct ConInfo * ConInfo,uword RawKey,uword Qualifier);
extern void __regargs GetCon (struct ConInfo * ConInfo,char *into);
extern void __regargs AddCon (struct ConInfo * ConInfo,char *from);
extern void __regargs ClearConCursor (struct ConInfo * ConInfo);
extern void __regargs ShowConCursor (struct ConInfo * ConInfo);

//Tags:															<read from>
#define CON_APen				(TAG_USER+1) //RP
#define CON_BPen				(TAG_USER+2) //RP
#define CON_DrMd				(TAG_USER+3) //RP
#define CON_TxHeight		(TAG_USER+4) //RP
#define CON_TxUp				(TAG_USER+5) //RP
#define CON_CursorColor	(TAG_USER+6)
#define CON_CursorType	(TAG_USER+7) // non-0 for line-cursor
#define CON_MinX				(TAG_USER+8) //Win
#define CON_MinY				(TAG_USER+9) //Win
#define CON_MaxX				(TAG_USER+10)//Win
#define CON_MaxY				(TAG_USER+11)//Win

//for InitCon only
#define CON_NumLines		(TAG_USER+20)
#define CON_BufLen			(TAG_USER+21)

//for ModifyCon only
#define CON_ReadWin			(TAG_USER+30)
#define CON_ReadRP			(TAG_USER+31)

