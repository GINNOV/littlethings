/*
 * HCC chip memory demonstration program by TetiSoft
 *
 * This is not an example of good programming style
 */

/*
 * Modified slightly by Jason Petty for HCE. (15/6/94)
 * Changes marked VANSOFT.
 */

void *IntuitionBase;

/* Moved 'chip' keyword to start of line. VANSOFT. */

chip unsigned short pointer[] = /* NOTICE THE WORD 'chip'
     * If you don't use it, the pointer will be
     * invisible on Amigas with non-chip memory
     */
{
 0x0000,0x0000,
 0xffff,0xffff,
 0x8001,0x8001,
 0x8001,0x8001,
 0x8001,0x8001,
 0x8001,0x8001,
 0x8001,0x8001,
 0x8001,0x8001,
 0xffff,0xffff,
 0x0000,0x0000
};

struct NewWindow {
 short left,top;
 short width,height;
 char detailpen, blockpen;
 long idcmpflags;
 long flags;
 void *gadget;
 void *checkmark;
 char *title;
 void *screen;
 void *bitmap;
 short minw,minh;
 short maxw,maxh;
 short type
} NewWindow =
{
 0,11,
 400,50,
 2,1,
 0,
 0x1000,
 0,
 0,
 "Chip memory demonstration for HCC/HCE",  /* Changed, VANSOFT. */
 0,
 0,
 0,0,
 0,0,
 1
};

main()
{
 void *Window, *OpenWindow(), *OpenLibrary();

 IntuitionBase=OpenLibrary("intuition.library",33);
 if (IntuitionBase==0) exit(20);

 Window=OpenWindow(&NewWindow);
 if (Window==0) {
  CloseLibrary(IntuitionBase);
  exit(20);
 }

 SetPointer(Window, pointer, 8, 8, 0, 0);
 Delay(10*50);
 ClearPointer(Window);
 CloseWindow(Window);
 CloseLibrary(IntuitionBase);
}
