//////////////////////////////////////////////////////////////////////////////
// Button Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    AFWindow win;
    AFRastPort rp(&win);
    AFReqTools rt;
    AFRect rect(10,10,410,310);

    win.Create(&theApp,&rect,"AFrame RastPort Example");
    rp.FromWindow(&win);

    rt.EZRequest("Drawing a Box","Ok");
    rect.SetRect(10,10,30,30);
    rp.SetAPen(2);
    rp.Rect(&rect);

    rt.EZRequest("Drawing a filled Box","Ok");
    rect.SetRect(32,10,52,30);
    rp.SetAPen(3);
    rp.RectFill(&rect);

    rt.EZRequest("Drawing Text","Ok");
    rp.SetAPen(4);
    rp.TextOut(10,40,(char*)"AFrame is God like",18);

    rt.EZRequest("Drawing an Ellipse","Ok");
    rect.SetRect(100,100,150,150);
    rp.SetAPen(5);
    rp.DrawEllipse(&rect);

    rt.EZRequest("Clearing with another pen","Ok");
    rp.SetAPen(6);
    rp.Clear();

    theApp.RunApp();
}
