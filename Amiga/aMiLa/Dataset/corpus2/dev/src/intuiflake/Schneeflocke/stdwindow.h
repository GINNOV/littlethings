/* stdwindow.h */

void open_libs(void)
	{
		IntuitionBase = (struct IntuitionBase *)
		                OpenLibrary("intuition.library",0L);
		if (IntuitionBase == NULL) Exit(FALSE);

		GfxBase = (struct GfxBase *)
		          OpenLibrary("graphics.library",0L);
		if (GfxBase == NULL)
			{
				CloseLibrary(IntuitionBase); /* Int.-Lib zu */
				Exit(FALSE);                 /* Abbruch     */
		   }
	}
	struct window *open_window (short x, short y,
										 short w, short h,
										 char *name,
										 ULONG flags,
										 ULONG i_flags,
										 struct Gadget *gadget )
		{
			struct NewWindow nw;

		nw.LeftEdge = x;    /* linke Kante des Fensters */
		nw.TopEdge = y;     /* obere Kante des Fensters */
		nw.Width = w;       /* Breite des Fensters      */
		nw.Height = h;      /* Höhe des Fensters        */
		nw.DetailPen = -1;
		nw.BlockPen  = -1;
		nw.Title = (UBYTE *) name;    /* Fenster-Titel  */
		nw.Flags = flags;             /* Welche Gadgets */
		nw.IDCMPFlags = i_flags;      /* Welche IDCMP's */
		nw.Screen = NULL;
		nw.Type = WBENCHSCREEN;
		nw.FirstGadget = gadget;
		nw.CheckMark = NULL;
		nw.BitMap =  0;
		nw.MinWidth =  -1; nw.MinHeight = -1;
		nw.MaxWidth =  -1; nw.MaxHeight = -1;

		return( (struct window *) OpenWindow(&nw) );

		}

		void close_all(void)
			{
				CloseWindow(Window);
				CloseLibrary(GfxBase);
				CloseLibrary(IntuitionBase);
				Exit(TRUE);
			}

