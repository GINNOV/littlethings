//////////////////////////////////////////////////////////////////////////////
// border.cpp
//
// Jeffry A Worth
// March 2, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/border.hpp"

AFBorder::AFBorder() //AFRect rect, bevel type,WORD pShine, WORD pShadow)
{
	//SetBorder(rect,type,pShine,pShadow);
}

void
AFBorder::SetBorder(AFRect rect,WORD pShine, WORD pShadow)
{
	WORD w,h;

 	w=rect.Width()-1;
  	h=rect.Height()-1;
  	xyShine[0]=xyShine[2]=xyShine[3]=xyShine[5]=xyShadow[5]=0;
  	xyShine[1]=xyShadow[1]=xyShadow[3]=h;
  	xyShine[4]=xyShadow[2]=xyShadow[4]=w;
  	xyShadow[0]=1;
	shineBorder.LeftEdge=shadowBorder.LeftEdge=rect.TopLeft()->m_x;
	shineBorder.TopEdge=shadowBorder.TopEdge=rect.TopLeft()->m_y;
	shineBorder.XY=shineData();
	shadowBorder.XY=shadowData();
	shineBorder.NextBorder=&shadowBorder;
	shadowBorder.NextBorder=NULL;
	shineBorder.FrontPen=pShine;
	shadowBorder.FrontPen=pShadow;
}

WORD *
AFBorder::shineData()
{
	return xyShine;
}

WORD *
AFBorder::shadowData()
{
	return xyShadow;
}

LPBorder
AFBorder::border()
{
	return NULL; //&shineBorder;
}
