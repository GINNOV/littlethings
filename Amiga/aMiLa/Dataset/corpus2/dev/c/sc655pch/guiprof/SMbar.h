/* support: walker */

#define VBMAXPOS 0xffff  /* Max position of the scroll bar */

struct VBar *VBInit(struct Window *window);
int VBRead(struct VBar *vb);
int VBUpdate(struct VBar *vb, int KnobSize, int KnobPosition);
void VBTerm(struct VBar *vb);
int VBSelected(struct VBar *vb, int gadid);


#define VB_SLIDER  1
#define VB_UP      2
#define VB_DOWN    3
