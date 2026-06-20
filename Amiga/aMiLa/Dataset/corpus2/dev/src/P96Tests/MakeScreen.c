#include <graphics/view.h>
#include <intuition/screens.h>
#include <intuition/intuitionbase.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/exec.h>

int main(void)
{
  struct IntuitionBase *IntuitionBase;
  
  if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",40)) {
    struct Screen *sc = IntuitionBase->FirstScreen;
    if (sc) {
      sc->ViewPort.DxOffset++; /* force a mode snoop */
      MakeScreen(sc);
      sc->ViewPort.DxOffset--;
      MakeScreen(sc);
      if (sc = sc->NextScreen) {
	sc->ViewPort.DxOffset++; /* force a mode snoop */
	MakeScreen(sc);
	sc->ViewPort.DxOffset--;
	MakeScreen(sc);
      }
    }
    CloseLibrary((struct Library *)IntuitionBase);
  }
  return 0;
}
