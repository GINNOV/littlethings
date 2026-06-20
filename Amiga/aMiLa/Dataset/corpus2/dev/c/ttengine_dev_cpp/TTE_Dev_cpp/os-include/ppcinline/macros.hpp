/*
	This file is copyright by Tomasz Kaczanowski. You can use it for free,
    but you must add info about using this code and info about author. Remember
    also, that if you want to have new versions of this code and other codes
    for AmigaOS-like systems you should motivate author of this code. You
    can send him a small gift or mail or bug report.

    contact:
       kaczus (at) poczta (_) onet (_) pl
       or
       kaczus (at) wp (_) pl
    (_) replaced dot.
*/
#ifndef _INLINE_MACROS_HPP
#define _INLINE_MACROS_HPP

#include <emul/emulregs.h>
#include <emul/emulinterface.h>
#include <proto/exec.h>
//#include <iostream>

extern "C++" {


template<class ret>
inline ret LibTemplate0(long offs,Library *lib)
{
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}


template<class ret,class reg_x>
inline ret LibTemplate1(long offs,reg_x rx,Library *lib,ULONG &REG_X)
{
    REG_X=(ULONG)rx;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}

template<class ret,class reg_x1,class reg_x2>
inline ret LibTemplate2(long offs,reg_x1 rx1,reg_x2 rx2,Library *lib,ULONG &REG_X1,ULONG &REG_X2)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}

template<class ret,class reg_x1,class reg_x2,class reg_x3>
inline ret LibTemplate3(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}



template<class ret,class reg_x1,class reg_x2,class reg_x3,class reg_x4,class reg_x5>
inline ret LibTemplate5(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,reg_x4 rx4,reg_x5 rx5,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3,ULONG &REG_X4,ULONG &REG_X5)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_X4=(ULONG)rx4;
    REG_X5=(ULONG)rx5;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}


template<class ret,class reg_x1,class reg_x2,class reg_x3,class reg_x4>
inline ret LibTemplate4(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,reg_x4 rx4,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3,ULONG &REG_X4)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_X4=(ULONG)rx4;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}
template<class ret,class reg_x1,class reg_x2,class reg_x3,class reg_x4,class reg_x5,class reg_x6>
inline ret LibTemplate6(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,reg_x4 rx4,reg_x5 rx5,reg_x6 rx6,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3,ULONG &REG_X4,ULONG &REG_X5,ULONG &REG_X6)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_X4=(ULONG)rx4;
    REG_X5=(ULONG)rx5;
    REG_X6=(ULONG)rx6;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}

template<class ret,class reg_x1,class reg_x2,class reg_x3,class reg_x4,class reg_x5,class reg_x6,class reg_x7>
inline ret LibTemplate7(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,reg_x4 rx4,reg_x5 rx5,reg_x6 rx6,reg_x7 rx7,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3,ULONG &REG_X4,ULONG &REG_X5,ULONG &REG_X6,ULONG &REG_X7)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_X4=(ULONG)rx4;
    REG_X5=(ULONG)rx5;
    REG_X6=(ULONG)rx6;
    REG_X7=(ULONG)rx7;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}

template<class ret,class reg_x1,class reg_x2,class reg_x3,class reg_x4,class reg_x5,class reg_x6,class reg_x7,class reg_x8>
inline ret LibTemplate8(long offs,reg_x1 rx1,reg_x2 rx2,reg_x3 rx3,reg_x4 rx4,reg_x5 rx5,reg_x6 rx6,reg_x7 rx7,reg_x8 rx8,Library *lib,ULONG &REG_X1,ULONG &REG_X2,ULONG &REG_X3,ULONG &REG_X4,ULONG &REG_X5,ULONG &REG_X6,ULONG &REG_X7,ULONG &REG_X8)
{
    REG_X1=(ULONG)rx1;
    REG_X2=(ULONG)rx2;
    REG_X3=(ULONG)rx3;
    REG_X4=(ULONG)rx4;
    REG_X5=(ULONG)rx5;
    REG_X6=(ULONG)rx6;
    REG_X7=(ULONG)rx7;
    REG_X8=(ULONG)rx8;
    REG_A6=(ULONG)lib;
    return (ret) (*MyEmulHandle->EmulCallDirectOS)(offs);
}


template<class tret, class argtype>
class TFloatingArgs
{
    protected:
    virtual tret Func(argtype *)=NULL;
    public:
    tret operator()(argtype tag1,...)
    {
        va_list va;
        ULONG i;
        argtype *array;
        ULONG Count;
        va_start(va,tag1);
        Count=0;
        i=tag1;
        tret ret;
        while((i&&(i!=TAG_DONE))||(Count&1))
        {
             if ((i==TAG_MORE)&&((Count&1)==0))
             {
             	Count+=va_arg(va,argtype)+1;
                i=0;
             }
             else
             {
             	i=va_arg(va,ULONG);
             	Count++;
             }
        }
        va_end(va);
        array=new argtype[Count+2];
        array[0]=tag1;
        array[Count+1]=TAG_DONE;
           va_start(va,tag1);
           for (i=1;i<=Count;i++)
           {
           	array[i]=va_arg(va,argtype);
           }
           va_end(va);
    	   ret=Func(array);
           delete []array;
        return ret;
    }

};

template<class tret, class arg1,class argtype>
class TFloatingArgs1
{
    protected:
    virtual tret Func(arg1,argtype *)=NULL;
    public:
    tret operator()(arg1 ar1,argtype tag1,...)
    {
        va_list va;
        ULONG i;
        argtype *array;
        ULONG Count;
        va_start(va,tag1);
        Count=0;
        i=tag1;
        tret ret;
        while((i&&(i!=TAG_DONE))||(Count&1))
        {
             if ((i==TAG_MORE)&&((Count&1)==0))
             {
             	Count+=va_arg(va,argtype)+1;
                i=0;
             }
             else
             {
             	i=va_arg(va,ULONG);
             	Count++;
             }
        }
        va_end(va);
        
        array=new argtype[Count+2];
        array[0]=tag1;
        array[Count+1]=TAG_DONE;

           va_start(va,tag1);
           for (i=1;i<=Count;i++)
           {
           	array[i]=va_arg(va,argtype);
           }
           va_end(va);
    	   ret=Func(ar1,array);
           delete []array;

        return ret;
    }

};

template<class tret, class arg1, class arg2, class argtype>
class TFloatingArgs2
{
    protected:
    virtual tret Func(arg1,arg2,argtype *)=NULL;
    public:
    tret operator()(arg1 ar1,arg2 ar2,argtype tag1,...)
    {
        va_list va;
        ULONG i;
        argtype *array;
        ULONG Count;
        va_start(va,tag1);
        Count=0;
        i=tag1;
        tret ret;
        while((i&&(i!=TAG_DONE))||(Count&1))
        {
             if ((i==TAG_MORE)&&((Count&1)==0))
             {
             	Count+=va_arg(va,argtype)+1;
                i=0;
             }
             else
             {
             	i=va_arg(va,ULONG);
             	Count++;
             }
        }
        va_end(va);

        array=new argtype[Count+2];
        array[0]=tag1;
        array[Count+1]=TAG_DONE;

           va_start(va,tag1);
           for (i=1;i<=Count;i++)
           {
           	array[i]=va_arg(va,argtype);
           }
           va_end(va);
    	   ret=Func(ar1,ar2, array);
           delete []array;

        return ret;
    }

};

template<class tret, class arg1, class arg2, class arg3, class argtype>
class TFloatingArgs3
{
    protected:
    virtual tret Func(arg1,arg2,arg3, argtype *)=NULL;
    public:
    tret operator()(arg1 ar1,arg2 ar2, arg3 ar3, argtype tag1,...)
    {
        va_list va;
        ULONG i;
        argtype *array;
        ULONG Count;
        va_start(va,tag1);
        Count=0;
        i=tag1;
        tret ret;
        while((i&&(i!=TAG_DONE))||(Count&1))
        {
             if ((i==TAG_MORE)&&((Count&1)==0))
             {
             	Count+=va_arg(va,argtype)+1;
                i=0;
             }
             else
             {
             	i=va_arg(va,ULONG);
             	Count++;
             }
        }
        va_end(va);

        array=new argtype[Count+2];
        array[0]=tag1;
        array[Count+1]=TAG_DONE;

           va_start(va,tag1);
           for (i=1;i<=Count;i++)
           {
           	array[i]=va_arg(va,argtype);
           }
           va_end(va);
    	   ret=Func(ar1,ar2, array);
           delete []array;

        return ret;
    }

};

}
#endif
