#include <proto/exec.h>
#include <proto/intuition.h>

void waitclose(struct Window *w)
{
  int done = FALSE;

  while (! done) {
    struct IntuiMessage *msg;
    Wait(1L << w->UserPort->mp_SigBit);
    while ((msg = (struct IntuiMessage *)GetMsg(w->UserPort))) {                                       /* Did the user hit the */
      if (msg->Class == CLOSEWINDOW)
        done = TRUE;
      ReplyMsg((struct Message *)msg);
    }
  }
}

int getkey(struct Window *w)
{
  struct IntuiMessage *msg;
  int k = 0;

  while ((msg = (struct IntuiMessage *)GetMsg(w->UserPort))) {                                       /* Did the user hit the */
    if (msg->Class == IDCMP_VANILLAKEY)
      k = msg->Code;
    ReplyMsg((struct Message *)msg);
  }

  return k;
}

int handlekey(struct Window *w)
{
  int k;

  if ((k = getkey(w)))
  {
    if (k == ' ')
    {
      while (1)
      {
        k = getkey(w);
        if (k == ' ')
          return 1;
        else if (k == 'q' || k == 'Q')
          return 0;
      }
    }
    else if (k == 'q' || k == 'Q')
      return 0;
  }

  return 1;
}
