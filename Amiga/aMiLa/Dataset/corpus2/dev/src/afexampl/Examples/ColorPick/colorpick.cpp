//////////////////////////////////////////////////////////////////////////////
// colorpick.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/colorpick.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFCPBox::AFCPBox()
{
  m_pcolorpick = NULL;
}

AFCPBox::~AFCPBox()
{
  DestroyObject();
}

void
AFCPBox::Create
	(AFWindow* pwindow, AFRect *rect, ULONG id, UBYTE penColor, UBYTE Outline, AFColorPick *colorpick)
{
  m_pcolorpick=colorpick;
  m_penColor=penColor;
  AFBox::Create(pwindow,rect,id,penColor,Outline);
}

void
AFCPBox::OnGadgetUp(LPIntuiMessage imess)
{
  m_pcolorpick->m_Color = m_penColor;
}

AFColorPick::AFColorPick()
	:m_Color(0)
{
}

AFColorPick::~AFColorPick()
{
}

void
AFColorPick::DestroyObject()
{
	// First Destroy any Boxes that were created
	m_boxes.cleanAndDestroy();
	
	// Call the default DestroyObject to destroy this gadget
	AFPanel::DestroyObject();
}

void
AFColorPick::OnGadgetUp(LPIntuiMessage imess)
{
	// Select the color somehow
}

void
AFColorPick::Create
	(AFWindow* pwindow, AFRect *rect, ULONG id, bevel beveltype, int numColors, int numColumns, UBYTE Color)
{
  int x,y,rows,bwidth,bheight;
  AFCPBox *box;
  AFRect brect;

	x=0;

	if(numColumns==1)
		rows = numColors;
	else
		rows = (numColors+numColumns-1) / numColumns;

	bwidth = (rect->Width()-2) / numColumns;
	bheight = (rect->Height()-2) / rows;

	for(y=0; (y*numColumns+x) < numColors;y++) {
		for(x=0;x<numColumns;x++) {

			m_boxes.append(box = new AFCPBox());

			brect.SetRect(rect->TopLeft()->m_x+1+bwidth*x, rect->TopLeft()->m_y+1+bheight*y,
				rect->TopLeft()->m_x+1+bwidth*x+bwidth-1, rect->TopLeft()->m_y+1+bheight*y+bheight-1);
			box->Create(pwindow,&brect,id,y*numColumns+x,BOX_SOLID,this);

		}
		x=0;
	}

	// Create the panel gadget
	AFPanel::Create((char*)"", pwindow, rect, id, AFPanel::bevelUp);
}
