#define EDGE 366
long tightroutine(struct Window *window,struct Gadget *gadget, long x);
long attackroutine(struct Window *window,struct Gadget *gadget, long x);
long multiroutine(struct Window *window,struct Gadget *gadget, long x);
long chanroutine(struct Window *window,struct Gadget *gadget, long x);
long finetuneroutine(struct Window *window,struct Gadget *gadget,long x);
long lengthroutine(struct Window *window,struct Gadget *gadget,long x);
void setgadgettext(struct Window *window,short id,char *text);
long pitchbendroutine(struct Window *window,struct Gadget *gadget, long x);
ULONG looproutine(struct Window *window,struct Gadget *gadget, ULONG x);


extern struct Functions *functions;

long tightroutine(struct Window *window,struct Gadget *gadget, long x)

{
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld   ",x);
    Text(rp,text,4);
    return(x);
}

long attackroutine(struct Window *window,struct Gadget *gadget, long x)

{
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld   ",x);
    Text(rp,text,4);
    return(x);
}

long chanroutine(struct Window *window,struct Gadget *gadget, long x)

{
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld   ",x+1);
    Text(rp,text,4);
    return(x);
}

long multiroutine(struct Window *window,struct Gadget *gadget, long x)

{
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld   ",x);
    Text(rp,text,4);
    return(x);
}


long panroutine(struct Window *window ,struct Gadget *gadget, long x)
{
    long y;
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    y=x;
    x -= 64;

    if (x == 0) sprintf(text,"CENTER      ");

   else {
          if (x > 0){
                     sprintf(text,"R%ld      ",x);
                    }
    else {
           x = (-x);
           sprintf(text,"L%ld      ",x);
         }
       }
   x=y;
   Text(rp,text,6);
   return(x);
}

long finetuneroutine(struct Window *window,struct Gadget *gadget,long x)

{
    long y;
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    y=x;
           x -=30;
        if (x > 0){
                    sprintf(text,"+%ld      ",x);
                  }
        else {
              sprintf(text,"%ld      ",x);
             }
    x=y;
    Text(rp,text,6);
    return(x);
}


long lengthroutine(struct Window *window,struct Gadget *gadget,long x)

{
    long y;
    char text[20];
    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);

               if (x==0) sprintf(text,"FULL    ");
             else {
                    y=x;
                    x =(21-x);
                    sprintf(text,"%ld      ",x);
                     x=y;
                  }
    Text(rp,text,6);
    return(x);
}

long pitchbendroutine(struct Window *window,struct Gadget *gadget, long x)

{
long y;

    char text[20];
    struct RastPort *rp = window->RPort;
   y=12-x;

    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld   ",y);
    Text(rp,text,4);
    return(x);
}


void setgadgettext(struct Window *window,short id,char *text)
{
    struct Gadget *gadget = (struct Gadget *) (*functions->GetGadget)(window,id);
    if (gadget) {
        gadget->GadgetText->IText = text;
        (functions->DrawEmbossed)(window,id);
    }
}

ULONG looproutine(struct Window *window,struct Gadget *gadget, ULONG x)

{
char text[20];


    struct RastPort *rp = window->RPort;
    Move(rp,EDGE,gadget->TopEdge + 7);
    SetAPen(rp,1);
    SetBPen(rp,0);
    SetDrMd(rp,JAM2);
    sprintf(text,"%ld      ",x);


    Text(rp,text,7);
    return(long)(x);
}

