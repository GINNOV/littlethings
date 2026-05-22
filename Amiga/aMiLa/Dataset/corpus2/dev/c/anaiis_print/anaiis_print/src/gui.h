


struct Window *wopen(Tag, ...) ;
void wclose(struct Window *) ;

void wsetpencils(UWORD *) ;
void Button_SetImage(struct Gadget *,
struct Image *, struct Image *, struct Image *,
struct Image *, struct Image *, struct Image *,
UWORD *) ;

void DrawRect(struct RastPort *, LONG, LONG, LONG, LONG) ;
 
