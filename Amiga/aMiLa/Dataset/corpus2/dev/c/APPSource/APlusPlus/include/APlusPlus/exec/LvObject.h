#ifndef APP_LvObject_H
#define APP_LvObject_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/LvObject.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#ifdef __SASC
#include <amiproc/amiproc.h>                 // by Doug Walker and Steve Krueger
#include <APlusPlus/environment/APPObject.h>
#include <APlusPlus/environment/TypeInfo.h>


/******************************************************************************
      » class LivingObject «  virtual base class

   Each Living object runs on its own task and has its main procedure which 
   can be overwritten easily in derived classes. Within this main procedure 
   all kinds of objects may be created, also objects that have static data 
   since each living object gets its own near data section. The object starts 
   its 'life' with the first call to 'activate()' and ceases from existence 
   with the end of its 'main' procedure. The destructor will not return until
   the object terminates.
   
   Any access to the object should be done via semaphores or inter-process 
   communications.

   This class takes advantage of the AmiProc package by Doug Walker and 
   Steve Krueger that allows creating several child tasks with their personal 
   copy of the near data section. THEREFORE IT ONLY WORKS COMPILED WITH SAS/C®.
   AMIPROC Copyright (c) 1994 Steve Krueger and Doug Walker

 ****************************************************************************************/

class LivingObject : public APPObject
{
   public:
      LivingObject();
      // create object on its own task. Start it with activate()
      virtual ~LivingObject();
      // terminate the LivingObject (waits for self termination)

      BOOL activate();     // bring the object task to life
      BOOL isLiving();     // check for life signs (not implemented yet)

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      virtual int main()=0;   // overwrite to make your own object main loop

   private:
      struct AmiProcMsg *ap_msg;
      static int func(void *);

};
#endif   // #ifdef __SASC
#endif
