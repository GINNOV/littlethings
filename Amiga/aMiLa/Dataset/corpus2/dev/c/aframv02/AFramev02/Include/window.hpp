//////////////////////////////////////////////////////////////////////////////
// window.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __WINDOW_HPP__
#define __WINDOW_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/aframe.hpp"
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/screen.hpp"
#include "aframe:include/string.hpp"
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <clib/icon_protos.h>
#include <clib/wb_protos.h>

//////////////////////////////////////////////////////////////////////////////
// Structures

struct WindowRange {
  ULONG minWidth;
  ULONG minHeight;
  ULONG maxWidth;
  ULONG maxHeight;
};
typedef struct WindowRange * LPWindowRange;

//////////////////////////////////////////////////////////////////////////////
// Window Class

class AFWindow : public AFObject
{
	public:
		AFWindow();
		~AFWindow();

		// Methods
		virtual BOOL Create(AFAmigaApp* app, AFRect* rect);
		virtual BOOL Create(AFAmigaApp* app, AFRect* rect, char* szTitle);
		virtual BOOL Create(AFScreen* screen, AFRect* rect);
		virtual BOOL Create(AFScreen* screen, AFRect* rect, char* szTitle);  
		virtual BOOL Create(AFWindow* window, AFRect* rect);
		virtual BOOL Create(AFWindow* window, AFRect* rect, char* szTitle);
		virtual LPIntuiMessage GetMsg();
        virtual LPAppMessage GetAppMsg(LPMsgPort mport);
		virtual void ReplyMsg(LPIntuiMessage imess);
		virtual void ExecuteMsg(LPIntuiMessage imess);
		virtual void ExecuteAppMsg(LPAppMessage amess);
		virtual void DestroyWindow();
		virtual void DestroyObject();
		BOOL isValid();
		virtual void SetWindowRange(LPWindowRange wrange);
		virtual BOOL ValidPoint(AFPoint* point);
		virtual void AdjustPoint(AFPoint* point);
		virtual ULONG WindowIDCMP() { return STD_WINDOW_IDCMP; };
		virtual ULONG WindowFlags() { return STD_WINDOW_FLAGS; };
		virtual void GetDisplayRect(AFRect* rect);

		virtual void OnCreate() { return; };

		// --- IDCMP Classes
		virtual void OnSizeVerify(LPIntuiMessage imess) { return; };
		virtual void OnNewSize(LPIntuiMessage imess);
		virtual void OnRefreshWindow(LPIntuiMessage imess) { return; };
		virtual void OnMouseButtons(LPIntuiMessage imess) { return; };
		virtual void OnMouseMove(LPIntuiMessage imess) { return; };
		virtual void OnGadgetDown(LPIntuiMessage imess);
		virtual void OnGadgetUp(LPIntuiMessage imess);
		virtual void OnReqSet(LPIntuiMessage imess) { return; };
		virtual void OnMenuPick(LPIntuiMessage imess) { return; };
		virtual void OnCloseWindow(LPIntuiMessage imess);
		virtual void OnRawKey(LPIntuiMessage imess) { return; };
		virtual void OnReqVerify(LPIntuiMessage imess) { return; };
		virtual void OnReqClear(LPIntuiMessage imess) { return; };
		virtual void OnMenuVerify(LPIntuiMessage imess) { return; };
		virtual void OnNewPrefs(LPIntuiMessage imess) { return; };
		virtual void OnDiskInserted(LPIntuiMessage imess) { return; };
		virtual void OnDiskRemoved(LPIntuiMessage imess) { return; };
		virtual void OnWBenchMessage(LPIntuiMessage imess) { return; };
		virtual void OnActiveWindow(LPIntuiMessage imess) { return; };
		virtual void OnInActiveWindow(LPIntuiMessage imess) { return; };
		virtual void OnDeltaMove(LPIntuiMessage imess) { return; };
		virtual void OnVanillaKey(LPIntuiMessage imess) { return; };
		virtual void OnIntuiTicks(LPIntuiMessage imess) { return; };
		virtual void OnIDCMPUpdate(LPIntuiMessage imess) { return; };
		virtual void OnMenuHelp(LPIntuiMessage imess) { return; };
		virtual void OnChangeWindow(LPIntuiMessage imess) { return; };
		virtual void OnGadgetHelp(LPIntuiMessage imess);
		virtual void OnFutureIDCMP(LPIntuiMessage imess) { return; };
        virtual void OnFutureIDCMP(LPAppMessage amess) { return; };
        virtual void OnAppIcon(LPAppMessage amess) { return; };
        virtual void OnAppMenu(LPAppMessage amess) { return; };
        virtual void OnAppWindow(LPAppMessage amess) { return; };

		// Intuition functions
		virtual void SetWindowTitles(UBYTE* lpszWindowTitle, UBYTE* lpszScreenTitle);
		virtual void SizeWindow(WORD deltax, WORD deltay);
		virtual void WindowToBack();
		virtual void WindowToFront();
		virtual void ZipWindow();
		virtual void RefreshGadgets();
		virtual void Clear(UBYTE pen);
		virtual void SetStatusPanel(AFObject* edit);
		void HelpControl(ULONG flags);
		BOOL AppendGadget(AFObject* gadget);
		void RemoveGadget(AFObject* gadget, BOOL deleteobject);
		AFObject* GadgetFromID(ULONG id);

		// Properties
		AFAmigaApp *m_papp;
		AFScreen *m_pscreen;
		struct Window * m_pWindow;
		AFNode *m_pgadgets;
		AFPtrDlist m_gadgets; // Gadget List
		char *m_sztitle;
		TEXTATTR m_textattr;
		AFObject *m_statusObject;
		AFString m_statusText;
		AFString m_dragStatusText;
		AFString m_closeStatusText;
		AFString m_depthStatusText;
		AFString m_zoomStatusText;
		AFString m_sizeStatusText;
};

//////////////////////////////////////////////////////////////////////////////
#endif //__WINDOW_HPP__
