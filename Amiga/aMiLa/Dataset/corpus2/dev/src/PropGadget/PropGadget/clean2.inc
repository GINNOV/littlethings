
extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;

void CleanUp(message) 
FAST TEXT *message;
{ 
  puts(message);

  if (GfxBase !=NULL) CloseLibrary((struct Library *)GfxBase);
  if (IntuitionBase!=NULL) CloseLibrary((struct Library *)IntuitionBase);
  exit(TRUE);
}

