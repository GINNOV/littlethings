/* This is the modified sl-aztec.c file which I call "manx.c".  It includes *
 * most (but probably not all) standard library, Aztec C68K, and Amiga      *
 * specific functions.  DOS 1.2 functions are missing.  Some of the return  * 
 * types may be incorrect.  Please correct any errors you find, add any     * 
 * of the missing functions, and let me know of any changes so I can be     *
 * current also. Bixmail to althoff.                                        *
 *									    * 
 * Modified 7/2/86 by althoff						    *
 *									    *
 ****************************************************************************/ 
typedef struct { 
char *_bp;
char *_bend;
char *_buff;
char _flags;
char _unit;
char _bytbuf;
short _buflen;
char *_tmpname;
} FILE;
extern FILE Cbuffs[];
FILE *fopen();
long ftell();
typedef void *UNIV;
typedef char *STRING;
typedef FILE *STREAM;/*lint -e715 *//*lint -e530 *//*lint -e533 */
/*lint -library *//*lint +fvr */
long lseek();
long fseek();
int fwrite();
int close();
int creat();
STRING strcpy();
STRING strcat();
int putc();
int aputc();
int unlink();
int write();/*lint +fva 
*/
int fprintf() {}
int printf() {}
int sprintf() {}
int scanf() {}
int fscanf() {}
int sscanf() {}/*lint -fvr *//*lint -fva */
s_y_s_t_e_m()
{
int argc;
STRING *argv;
main( argc, argv );
}
FILE Cbuffs[];
void flsh_(f,n) STREAM f; int n; { }
long cList;
char ctp_[];
int agetc(f) STREAM f; {}
int aputc( c, f) int c; STREAM f; {}
double atof(s) STRING s; { }
int atoi(s) STRING s; { }
long atol(s) STRING s; { }
UNIV calloc( n, m ) unsigned n,m; { }
int close(fd) int fd; { }
int creat( fname, mode ) STRING fname; int mode; { }
void exit(n) int n; { }
int getc(f) STREAM f; {}
int getchar();
STRING gets( buf) UNIV buf; { }
int getw(stream) FILE *stream;{}
int putc( c, f) int c; STREAM f; {}
double fabs(x) double x; { }
void fclose(f) STREAM f; {}
STRING fgets( buf, len, f ) STRING buf; int len; STREAM f; { }
STREAM fopen( name, mode ) STRING name, mode; { }
void fputs( s, f) STRING s; STREAM f; {}
int fread( p, sz, n, f ) UNIV p; int sz, n; STREAM f; {}
STREAM freopen(name,mode,fp) STRING name, mode; STREAM fp; { }
void free(p) UNIV p; {}
long fseek( f, off, type) STREAM f; long off; int type; { }
long ftell( f ) STREAM f; { }
int fwrite( p, sz, n, f) UNIV p; int sz, n; STREAM f; { }

long lseek( fd, off, base ) int fd, base; long off; { }
UNIV malloc(n) unsigned n; { }
void movmem( p, q, n) UNIV p, q; unsigned n; { }
int open( name, mode ) STRING name; int mode; { }
void puts( s ) STRING s; {}
int read( fd, buf, count ) int fd, count; UNIV buf; { }
UNIV realloc( p, size ) UNIV p; unsigned size; { }
STRING strcat( s1, s2 ) STRING s1, s2; { }
int strcmp( s1, s2 ) STRING s1, s2; { }
STRING strcpy( s1, s2 ) STRING s1, s2; { }
int strlen( s ) STRING s; { }
STRING strncat( s1, s2, n ) STRING s1, s2; int n; { }
int strncmp( s1, s2, n ) STRING s1, s2; int n; { }
STRING strncpy( s1, s2, n ) STRING s1, s2; int n; { }
int tolower(c) char c; { }
int toupper(c) char c; { }
int unlink( nm ) STRING nm; { }
void ungetc(c,stream) FILE *stream;{ }
int write( fd, buf, count) int fd, count; UNIV buf; { }


long AbleICR(mask) long mask;{}
void AbortIO(ioRequest) struct IORequest *ioRequest;{}
void AddAnimOb(anOb,anKey,rPort) struct AnimOb *anOb, **anKey;
struct RastPort *rPort;{}
void AddBob(bob,rPort) struct Bob*bob; struct RastPort *rPort; {}
void AddDevice(device) struct Device *device;{}
void AddFont(textFont) struct TextFont *textFont;{}
short AddFreeList(free,mem,len) struct FreeList *free;char *mem;long len;{}
short AddGadget(pntr,gadget,position) struct Window *pntr;struct Gadget *gadget;
long position;{}
void AddHead(list,node) struct List *list; struct Node *node;{}
struct Interrupt * AddICRVector(iCRBit, interrupt) long iCRBit;
struct Interrupt *interrupt;{}
void AddIntServer(intNum,interrupt) long intNum;struct Interrupt *interrupt;{}
void AddLibrary(library) struct Library *library;{}
void AddPort(port) struct MsgPort *port;{}
void AddResource(resource) struct MiscResource *resource;{}
void AddTail(list,node) struct List *list;struct Node *node;{}
void AddTask(task,initialPC,finalPC) struct Task *task;long initialPC,finalPC;{}
void AddTime(dest,source) struct TimeVal *dest, *source;{}
void AddVSprite(vs,rPort)
struct VSprite *vs; struct RastPort *rPort;{}
long Alert(alertNum,parameters) long alertNum,parameters;{}
void * AllocAbs(bytSiz,location) long bytSiz; char *location;{}
long AllocCList(cLPool) long cLPool;{}
struct MemList * AllocEntry(memList) struct MemList *memList;{}
void * AllocMem(byteSize,requirements) long byteSize,requirements;{}
long AllocPotBits(bits) long bits;{}
void AllocRaster(width,height) long width,height;{}
char * AllocRemember(rememberKey, size, flags) struct Remember *rememberKey;
long size, flags;{}
long AllocSignal(signalNum) long signalNum;{}
long AllocTrap(trapNum) long trapNum;{}
struct WBObject * AllocWBObject();
void * Allocate(freeList,byteSize)struct List *freeList;long byteSize;{}
void AlohaWorkBench(wbPort) struct MsgPort *wbPort;{}
void AndRectRegion(region, rectangle)
struct Region *region; struct Rectangle *rectangle;{}
void Animate(key,rPort) struct AnimOb **key; struct RastPort *rPort;{}
short AreaDraw(rp,x,y) struct RastPort *rp; long x,y;{}
void AreaEnd(rp) struct RastPort *rp;{}
short AreaMove(rp,x,y) struct RastPort *rp; long x,y;{}
void AskFont(rp,textAttr)struct RastPort *rp; struct TextAttr *textAttr;{}
long AskSoftStyle(rp) struct RastPort *rp;{}
short AutoRequest(window,body,positive,negative,posFlags,negFlags,width,height)
struct Window *window; struct IntuiText *body,*positive,*negative;
long posFlags,negFlags,width,height;{}
long AvailFonts(buffer,bufBytes,types)char *buffer;long bufBytes,types;{}
long AvailMem(requirements) long requirements;{}
void BeginIO(ioRequest) struct IORequest *ioRequest;{}
void BeginRefresh(window) struct Window *window;{}
void BeginUpdate(l) struct Layer *l;{}
void BehindLayer(li,l) struct LayerInfo *li;struct Layer *l;{}
long BltBitMap(srcBM,srcX,srcY,dstBM,dstX,dstY,sizX,sizY,minTerm,mask,tempA)
struct BitMap *srcBM,*dstBM;long srcX,srcY,dstX,dstY,sizX,sizY,minTerm;{}
long BltBitMapRastPort(srcBitMap,srcX,srcY,dstBitMap,dstX,dstY,sizX,sizY,
minTerm)
struct BitMap *srcBitMap,*dstBitMap;long srcX,srcY,dstX,dstY,sizX,sizY,
minTerm;{}
void BltClear(memBlock,byteCount,flags) char *memBlock;long byteCount,flags;{}
void BltPattern(rp,buf,x1,y1,maxX,maxY,byteCnt)struct RastPort *rp;char *buf;
long x1,y1,maxX,maxY,byteCnt;{}
void BltTemplate(src,srcX,srcMod,dstRastPort,dstX,dstY,sizX,sizY)
char *src;struct RastPort *dstRastPort;
long srcX,srcMod,dstX,dstY,sizX,sizY;{}
struct Window * BuildSysRequest(wind,body,positive,negative,flags,width,height)
struct Window *wind;struct IntuiText *body,*positive, *negative;
long flags,width,height;{}
char * BumpRevision(newbuf,oldname) char *newbuf,*oldname;{}
void CBump(c) struct UCopList *c;{}
void CDInputHandler(events,consoleDevice) struct Events *events;
struct Device *consoleDevice;{}
void Cmove(c,a,v) struct UCopList *c; long *a,v;{}
void CWait(c,v,h) struct UCopList *c; long v,h;{}
void Cause(interrupt) struct Interrupt *interrupt;{}
void ChangeSprite(vp,s,newdata) struct ViewPort *vp;struct SimpleSprite *s;
struct spriteimage *newdata;{}
struct IORequest* CheckIO(ioRequest) struct IORequest *ioRequest;{}
short ClearDMRequest(window) struct Window *window;{}
void ClearEOL(rp) struct RastPort *rp;{}
void ClearMenuStrip(window) struct Window *window;{}
void ClearPointer(window) struct Window *window;{}
void ClearRegion(region) struct Region *region;{}
void ClearScreen(rp) struct RastPort *rp;{}
void ClipBlit(src,srcX,srcY,dst,dstX,dstY,xSize,ySize,mode)
struct RastPort *src,*dst;long srcX,srcY,dstX,dstY,xSize,ySize,mode;{}
void Close(file) struct fileHandle *file;{}
void CloseDevice(ioRequest) struct IORequest *ioRequest;{}
void CloseFont(font) struct Font *font;{}
void CloseLibrary(library) struct Library *library;{}
void CloseScreen(screen) struct Screen *screen;{}
void CloseWindow(window) struct Window *window;{}
void CloseWorkBench();
short CmpTime(dest,source) struct TimeVal *dest,*source;{}
long concatCList(sourceCList,destCList) long sourceCList,destCList;{}
long CopyCList(cList) long cList;{}
void CopySBitMap(layer) struct Layer *layer;{}
void CreateBehindLayer(li,bm,x0,y0,x1,y1,flags) struct LayerInfo *li;
struct BitMap *bm; long x0,y0,x1,y1,flags;{}
struct Lock * CreateDir(name) char *name;{}
struct MsgPort* CreatePort(name,pri) char *name; long pri;{}
struct Process * CreateProc(name,pri,segment,stackSize) char *name;
struct Segment *segment; long pri,stackSize;{}
struct IOStdReq * CreateStdIO(mp) struct MsgPort *mp;{}
struct Task * CreateTask(name,pri,start_pc,stksiz) char *name;
long pri,start_pc,stksiz;{}
void CreateUpfrontLayer(li,bm,x0,y0,x1,y1,flags) struct LayerInfo *li;
struct BitMap *bm; long x0,y0,x1,y1,flags;{}
struct Lock * CurrentDir(lock) struct Lock *lock;{}
void CurrentTime(seconds,micros) unsigned long *seconds, *micros;{}
long * DateStamp(v) long *v;{}
void Deallocate(freeList,memoryBlock,byteSize) struct List *freeList;
char *memoryBlock; long byteSize;{}
void Debug();
void Delay(timeout) long timeout;{}
short DeleteFile(name) char *name;{}
void DeleteLayer(li,l)struct LayerInfo *li;struct Layer *l;{}
void DeletePort(port) struct MsgPort *port;{}
void DeleteStdIO(iop) struct IOStdReq *iop;{}
void DeleteTask(tp) struct Task *tp;{}
struct Process * DeviceProc(name) char *name;{}
void Disable();
void DisownBlitter();
void DisplayAlert(alertNumber,string,height)long alertNumber;
char *string; long height;{}
void DisplayBeep(screen) struct Screen *screen;{}
void DisposeRegion(region) struct Region *region;{}
void DoCollision(rPort) struct RastPort *rPort;{}
long DoIO(ioRequest) struct IORequest *ioRequest;{}
short DoubleClick(startSeconds,startMicros,currentSeconds,currentMicros)
unsigned long startSeconds,startMicros,currentSeconds,currentMicros;{}
void Draw(rp,x,y) struct RastPort *rp; long x,y;{}
void DrawBorder(rp,b,leftOffset,topOffset) struct RastPort *rp;
struct Border *b; long leftOffset, topOffset;{}
void DrawGList(rPort,vPort)struct RastPort *rPort;struct ViewPort *vPort;{}
void DrawImage(rp,image,leftOffset,topOffset)struct RastPort *rp;
struct Image *image; long leftOffset,topOffset;{}
struct Lock * DupLock(lock) struct Lock *lock;{}
void Enable();
void EndRefresh(window,complete) struct Window *window; long complete;{}
void EndUpdate(l,flag) struct Layer *l; long flag;{}
void Enqueue(list,node) struct List *list;struct Node *node;{}
short ExNext(lock,fileInfoBlock) struct Lock *lock;
struct FileInfoBlock *fileInfoBlock;{}
short Examine(lock,fileInfoBlock)struct Lock *lock;
struct FileInfoBlock *fileInfoBlock;{}
short Execute(commandString,input,output) char *commandString;
struct FileHandle *input, *output;{}
void Exit(returnCode) long returnCode;{}
struct Node * FindName(list,name) struct List *list;char *name;{}
struct MsgPort * FindPort(name) char *name;{}
struct Task* FindTask(name) char *name;{}
char * FindToolType(toolTypeArray,typeName)char **toolTypeArray,*typeName;{}
void Flood(rp,mode,x,y) struct RastPort *rp; long mode,x,y;{}
void FlushCList(cList) long cList;{}
void Forbid();
void FreeCList(cList) long cList;{}
void FreeCPrList(cprList) struct CprList *cprList;{}
void FreeDiskObject(diskobj) struct DiskObject *diskobj;{}
void FreeEntry(memList) struct MemList *memList;{}
void FreeGBuffers(anOb,rPort,db)struct AnimOB *anOb;
struct RastPort *rPort; long db;{}
void FreeMem(memoryBlock,sizeBytes) char *memoryBlock; long sizeBytes;{}
void FreePotBits(allocated) long allocated;{}
void FreeRaster(p,width,height) char *p;long width,height;{}
void FreeRemember(key,reallyForget) struct Remember *key;long reallyForget;{}
void FreeSignal(signalNum) long signalNum;{}
void FreeSprite(pick) long pick;{}
void FreeSysRequest(wind) struct Window *wind;{}
void FreeTrap(trapNum) long trapNum;{}
void FreeVPortCopLists(viewPort) struct ViewPort *viewPort;{}
void FreeWBObject(obj) struct WBObject *obj;{}
long GetCC();
long GetCLBuf(cList,buffer,maxlength) long cList;char *buffer;long maxlength;{}
short GetCLChar(cList) long cList;{}
short GetCLWord(cList) long cList;{}
struct ColorMap * GetColorMap(entries) long entries;{}
struct Preferences * GetDefPrefs(prefBuffer,size) char *prefBuffer;long size;{}
struct DiskObject * GetDiskObject(name) char *name;{}
void GetGBuffers(anOb,rPort,db) struct AnimOb *anOb;
struct RastPort *rPort; long db;{}
short GetIcon(name,icon,free) char *name;struct DiskObject *icon;
struct FreeList *free;{}
struct Message* GetMsg(port) struct MsgPort *port;{}
struct Preferences* GetPrefs(buffer,size)struct Preferences *buffer;long size;{}
short GetSprite(sprite,pick) struct SimpleSprite *sprite; long pick;{}
struct WBObject * GetWBObject(name) char *name;{}
long IncrCLMark(cList) long cList;{}
short Info(lock,info_Data) struct Lock *lock;struct Info_Data *info_Data;{}
void InitArea(areaInfo,buffer,maxVectors) struct AreaInfo *areaInfo;
char *buffer; long maxVectors;{}
void InitBitMap(bm,depth,width,height) struct BitMap *bm;
long depth,width, height;{}
long InitCLPool(cLPool,size) struct cLPool *cLPool; long size;{}
void InitCode(startClass,version) long startClass, version;{}
void InitGMasks(anOb) struct AnimOb *anOb;{}
void InitGels(head,tail,gInfo)struct VSprite *head,*tail;
struct GelsInfo *gInfo;{}
void InitMasks(vs) struct VSprite *vs;{}
void InitRastPort(rp) struct RastPort *rp;{}
void InitRequester(req) struct Requester *req;{}
void InitResident(resident,segList) long resident, segList;{}
void InitStruct(initTable,memory,size) short *initTable;
char *memory; long size;{}
void InitTmpRas(tmpRas,buffer,size)struct TmpRas *tmpRas;
char *buffer; long size;{}
void InitVPort(vp) struct ViewPort *vp;{}
void InitView(view) struct View *view;{}
struct FileHandle * Input();
void Insert(list,node,listNode) struct List *list;
struct Node *node, *listNode;{}
long IntuiTextLength(iText) struct IntuiText *iText;{}
struct InputEvent* Intuition(inputEvent) struct InputEvent *inputEvent;{}
long IoErr();
short IsInteractive(file) struct FileHandle *file;{}
struct MenuItem* ItemAddress(menuStrip,menuNumber) struct Menu *menuStrip;
long menuNumber;{}
void LoadRGB4(vp,colorMap,count) struct ViewPort *vp;
struct ColorMap *colorMap; long count;{}
struct Segment * LoadSeg(name) char *name;{}
void LoadView(view) struct View *view;{}
struct Lock * Lock(name,accessMode) char *name; long accessMode;{}
void LockLayer(li,l) struct LayerInfo *li; struct Layer *l;{}
void LockLayerInfo(li) struct LayerInfo *li;{}
void LockLayerRom(layer) struct Layer *layer;{}
void LockLayers(li) struct LayerInfo *li;{}
struct Library * MakeLibrary(vectors,structure,libInit,dataSize,segList)
void(*vectors[])(),(*libInit)(); short *structure;
long dataSize; struct MemList *segList;{}
void MakeScreen(screen) struct Screen *screen;{}
void MakeVPort(view,viewPort) struct View *view;struct ViewPort *viewPort;{}
long MarkClist(cList,offset) long cList; long offset;{}
long MatchToolValue(typeString,value) char *typeString, *value;{}
void ModifyIDCMP(wind,IDCMPFlags)struct Window *wind;long IDCMPFlags;{}
void ModifyProp(gad,wind,req,flags,horizPot,vertPot,horizBody,verBody)
struct Gadget *gad; struct Window *wind; struct Requester *req;
long flags, horizPot, vertPot, horizBody, verBody;{}
void Move(rp,x,y) struct RastPort *rp; long x,y;{}
void MoveLayer(li,l,dx,dy) struct LayerInfo *li;struct Layer *l;long dx,dy;{}
void MoveScreen(screen,deltaX,deltaY)struct Screen *screen;long deltaX,deltaY;{}
void MoveSprite(vp,sprite,x,y) struct ViewPort *vp;
struct SimpleSprite *sprite; long x,y;{}
void MoveWindow(wind,deltaX,deltaY) struct Window *wind;long deltaX,deltaY;{}
void MrgCop(view) struct View *view;{}
void NewList(list) struct List *list;{}
struct Region * NewRegion();
void NotRegion(rgn) struct Region *rgn;{}
void OffGadget(gad,wind,req) struct Gadget *gad;struct Window *wind;
struct Requester *req;{}
void OffMenu(wind,menuNumber) struct Window *wind; long menuNumber;{}
void OnGadget(gad,wind,req) struct Gadget *gad;struct Window *wind;
struct Requester *req;{}
void OnMenu(wind,menuNumber) struct Window *wind; long menuNumber;{}
struct FileHandle * Open(name,accessMode) char *name; long accessMode;{}
long OpenDevice(name,unitNumber,ioRequest,flags) char *name;
struct IORequest *ioRequest;
long unitNumber,flags;{}
struct Font * OpenDiskFont(textAttr) struct TextAttr *textAttr;{}
struct Font * OpenFont(textAttr) struct TextAttr *textAttr;{}
void OpenIntuition();
struct Library * OpenLibrary(libName, version) char *libName;long version;{}
struct MiscResource * OpenResource(resName) char *resName;{}
struct Screen* OpenScreen(newScreen) struct NewScreen *newScreen;{}
struct Window* OpenWindow(newWindow) struct NewWindow *newWindow;{}
short OpenWorkbench();
void OrRectRegion(region,rectangle) struct Region *region;
struct Rectangle *rectangle;{}
struct FileHandle * Output();
void OwnBlitter();
struct Lock * ParentDir(lock) struct Lock *lock;{}
short PeekCLMark(cList) long cList;{}
void Permit();
void PolyDraw(rp,count,array) struct RastPort *rp; long count,array[][];{}
void PrintText(rp,iText,leftEdge,topEdge) struct RastPort *rp;
struct IntuiText *iText; long leftEdge,topEdge;{}
long PutCLBuf(cList,buffer,length)char *buffer;long length,cList;{}
long PutCLChar(cList,byte) long cList,byte;{}
long PutCLWord(cList,word) long cList,word;{}
short PutDiskObject(name,diskobj) char *name;struct DiskObject *diskobj;{}
short PutIcon(name,icon) char *name; struct DiskObject *icon;{}
void PutMsg(port,message) struct MsgPort *port; struct Message *message;{}
short PutWBObject(name,object) char *name;struct WBObject *object;{}
void QBSBlit(bsp) struct Blit *bsp;{}
void QBlit(bp) struct Blit *bp;{}
short RawKeyConvert(events,buffer,length,keyMap) struct InputEvent *events;
char *buffer; long length; struct KeyMap *keyMap;{}
long Read(file,buffer,length) struct FileHandle *file;char *buffer;
long length;{}
short ReadPixel(rp,x,y) struct RastPort *rp; long x,y;{}
void RectFill(rp,xMin,yMin,xMax,yMax) struct RastPort *rp;
long xMin,yMin,xMax,yMax;{}
void RefreshGadgets(gad,wind,req) struct Gadgets *gad; struct Window *wind;
struct Requester *req;{}
void RemDevice(device) struct Device *device;{}
void RemFont(textFont) struct TextFont *textFont;{}
void RemHead(list) struct List *list;{}
void RemBob(bob,rPort,vPort) struct Bob *bob; struct RastPort *rPort;
struct ViewPort *vPort;{}
void RemICRVector(iCRBit,interrupt)long iCRBit;struct Interrupt *interrupt;{}
void RemIntServer(intNum,interrupt)long intNum;struct Interrupt *interrupt;{}
long RemLibrary(library) struct Library *library;{}
void RemPort(port) struct MsgPort *port;{}
void RemResource(resource) struct MiscResource *resource;{}
struct Node * RemTail(list) struct List *list;{}
void RemTask(task) struct Task *task;{}
void RemVSprite(vs) struct VSprite *vs;{}
void RemakeDisplay();
void Remove(list,node) struct List *list; struct Node *node;{}
unsigned short RemoveGadget(wind,gad) struct Window *wind;struct Gadget *gad;{}
short Rename(oldName,newName)char *oldName, *newName;{}
void ReplyMsg(message) struct Message *message;{}
void ReportMouse(wind,boolean) struct Window *wind;long boolean;{}
short Request(req,wind) struct Requester *req; struct Window *wind;{}
void RethinkDisplay();
void ScreenToBack(screen) struct Screen *screen;{}
void ScreenToFront(screen) struct Screen *screen;{}
void ScrollLayer(li,l,dx,dy)struct LayerInfo *li;struct Layer *l;long dx,dy;{}
void ScrollRaster(rp,dx,dy,xMin,yMin,xMax,yMax) struct RastPort *rp;
long dx,dy,xMin,yMin,xMax,yMax;{}
void ScrollVPort(vp) struct ViewPort *vp;{}
long Seek(file,position,mode) struct FileHandle *file;long position,mode;{}
void SendIO(ioRequest) struct IORequest *ioRequest;{}
void SetAPen(rp,pen) struct RastPort *rp; long pen;{}
void SetBPen(rp,pen) struct RastPort *rp; long pen;{}
void SetCollision(num,routine,gInfo)long num,(*routine)();
struct GelsInfo *gInfo;{}
short SetComment(name,comment)char *name,*comment;{}
short SetDMRequest(wind,DMRequester)struct Window *wind;
struct Requester *DMRequester;{}
void SetDrMd(rp,mode) struct RastPort *rp; long mode;{}
long SetExcept(newSignals,signalMask)long newSignals,signalMask;{}
long SetFont(rp,font) struct RastPort *rp; struct TextFont *font;{}
long SetFunction(library,funcOffset,funcEntry)struct Library *library;
long funcOffset; void (*funcEntry)();{}
long SetICR(mask) long mask;{}
struct Interrupt * SetIntVector(intNumber,interrupt)long intNumber;
struct Indterrupt *interrupt;{}
void SetMenuStrip(wind,menu) struct Window *wind; struct Menu *menu;{}
void SetPointer(wind,sp,height,width,xOffset, yOffset)
struct Window *wind; struct Sprite *sp;
long height,width, xOffset, yOffset;{}
void SetPrefs(p,size,realThing)struct Preferences *p;long size,realThing;{}
short SetProtection(name,mask) char *name; long mask;{}
void SetRGB4(vp,n,r,g,b)struct ViewPort *vp;long n,r,g,b;{}
void SetRast(rp,pen) struct RastPort *rp; long pen;{}
long SetSR(newSR,mask) long newSR, mask;{}
long SetSignal(newSignals,signalMask)long newSignals,signalMask;{}
long SetSoftStyle(rp,style,enable)struct RastPort *rp;long style,enable;{}
short SetTaskPri(task,priority)struct Task *task; long priority;{}
void SetWindowTitles(wind,windowTitle,screenTitle) struct Window *wind;
char *windowTitle, *screenTitle;{}
void ShowTitle(screen, showIt) struct Screen *screen; long showIt;{}
void Signal(task,signals) struct Task *task; long signals;{}
long SizeCList(cList) long cList;{}
void SizeLayer(li,l,dx,dy) struct LayerInfo *li;struct Layer *l;long dx,dy;{}
void SizeWindow(wind,deltaX,deltaY)struct Window *wind;long deltaX,deltaY;{}
void SortGList(rPort) struct RastPort *rPort;{}
long SplitCList(cList) long cList;{}
long SubCList(cList,index,length) long cList,index, length;{}
void SubTime(dest,source) struct TimeVal *dest, *source;{}
void SumLibrary(library) struct Library *library;{}
long SuperState();
void SwapBitsRastPortClipRect(li)struct LayerInfo *li;{}
void SyncSBitMap(layer) struct Layer *layer;{}
long Text(rp,string,count) struct RastPort *rp; char *string; long count;{}
long TextLength(rp,string,count) struct RastPort *rp;
char *string; long count;{}
long Translate(instring,inlen,outbuf,outlen) char *instring, *outbuf;
long inlen, outlen;{}
long UnGetCLChar(cList,byte) long cList,byte;{}
long UnGetCLWord(cList,word) long cList,word;{}
void UnLoadSeg(segment) struct Segment *segment;{}
void UnLock(lock) struct Lock *lock;{}
short UnPutCLChar(cList) long cList;{}
short UnPutCLWord(cList) long cList;{}
void UnlockLayer(l) struct Layer *l;{}
void UnlockLayerInfo(li) struct LayerInfo *li;{}
void UnlockLayerRom(layer) struct LayerInfo *layer;{}
void UnlockLayers(li) struct LayerInfo *li;{}
void UpfrontLayer(li,l) struct LayerInfo *li;struct Layer *l;{}
void UserState(sysStack) long sysStack;{}
short VBeamPos();
struct View* ViewAddress();
struct View* ViewPortAddress(wind) struct Window *wind;{}
short WBenchToBack();
short WBenchToFront();
long Wait(signalSet) long signalSet;{}
void WaitBOVP(viewPort) struct ViewPort *viewPort;{}
void WaitBlit();
short WaitForChar(file,timeout)struct FileHandle *file;long timeout;{}
long WaitIO(ioRequest) struct IORequest *ioRequest;{}
struct Message* WaitPort(port) struct MsgPort *port;{}
void WaitTOF();
struct Layer * WhichLayer(li,x,y)struct LayerInfo *li;long x,y;{}
short WindowLimits(wind,minWidth,minHeight,maxWidth,maxHeight)
struct Window *wind; long minWidth,minHeight,maxWidth,maxHeight;{}
void WindowToBack(wind) struct Window *wind;{}
void WindowToFront(wind) struct Window *wind;{}
long Write(file,buffer,length) struct FileHandle *file; char *buffer;
long length;{}
void WritePixel(rp,x,y)struct RastPort *rp;long x,y;{}
void WritePotgo(word,mask) long word,mask;{}
void XorRectRegion(region,rectangle)struct Region *region;
struct Rectangle *rectangle;{}/*lint -restore */
/*lint -e715 -e533 */
int access(filename, mode) char *filename; int mode;{}
void assert(expr) int expr; {}
void *sbrk(size) unsigned int size; {}/*lint -e??? */
void execl(name,arg0,arg1,arg2,...,argn,) char *name,*arg0,*arg1,*arg2,...;{}
void execlp(name,arg0,arg1,arg2,...,argn,) char *nam,*arg0,*arg1,*arg2,...;{}
int fexecl(name,arg0,arg1,arg2,...,argn,) char *name,*arg0,*arg1,*arg2,...,;{}
/*lint -restore */
/*lint -e715 -e533 */
void execv(name,argv) char *name,*argv[];{}
void execvp(name,argv) char *name,*argv[];{}
int fexecv(name,argv) char *name, *argv[]; {}
char *getenv(name) char *name; {}
char *mktemp(template) char *template; {}
int perror(s) char *s;{}
char *scdir(pat) char *pat;{}
void scr_beep();
void scr_bs();
void scr_tab();
void scr_lf();
void scr_cursup();
void scr_cursrt();
void scr_cr();
void scr_clear();
void scr_home();
void scr_eol();
void scr_linsert();
void scr_ldelete();
void scr_cinsert();
void scr_cdelete();
void scr_curs(lin,col) int lin, col; {}
long time(tloc) long *tloc;{} 
char *ctime(clock) long *clock;{}
struct tm *localtime(clock) long *clock;{}
struct tm *gmtime(clock) long *clock;{}
char *asctime(t) struct tm *t; {}
FILE *tmpfile();
char *tmpnam(s) char *s; {}/*lint -restore */
