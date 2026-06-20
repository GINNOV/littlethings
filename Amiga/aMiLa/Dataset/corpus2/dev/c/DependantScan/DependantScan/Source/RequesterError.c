#define DEF_REQUESTERERROR_C

#if defined AMIGA                                              /* if we are being compiled for AmigaOS */
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>
#include <stdarg.h>

#include "RequesterError.h"
#include "LocaleSupport.h"

static struct Window *ErrorRequesterWindow = NULL;             /* default screen for error requesters to show up on */
static struct LOCALE_SUPPORT_CATALOG *ErrorCatalog = NULL;     /* the language catalog currently in effect */
static int ErrorRequesterTitle = -1;                           /* how we will title error requesters */
static int ErrorGadgetText = -1;                               /* description of the gadget(s) on the error requesters */

/*
   void requester_error_set_defaults(
      struct Window *window,                                   the screen to display error requesters on
      struct LOCALE_SUPPORT_CATALOG *catalog,                  the catalog open by the program
      int title,                                               the title of error requesters (-1 = no title)
      int gadget_text)                                         the text to be used for the gadget(s) on the requesters (-1 = no text)

   * Description
      This function optionally sets up the title of error requesters and/or the array of strings to be used for error messages.
*/
void requester_error_set_defaults(
   struct Window *window,                                      /* the screen to display error requesters on */
   struct LOCALE_SUPPORT_CATALOG *catalog,                     /* the catalog open by the program */
   int title,                                                  /* the title of error requesters (-1 = no title) */
   int gadget_text)                                            /* the text to be used for the gadget(s) on the requesters (-1 = no text) */
{
   if (window)                                                 /* if we should set a default screen for our error requesters */
      ErrorRequesterWindow = window;                           /* put error requests on the same screen as this window */

   if (catalog)                                                /* if a language catalog was supplied */
      ErrorCatalog = catalog;                                  /* remember it */

   if (title != -1)                                            /* if we should change the name for the error requesters */
      ErrorRequesterTitle = title;                             /* use this for the name of the error requesters */

   if (gadget_text != -1)                                      /* if we should change the default gadget text */
      ErrorGadgetText = gadget_text;                           /* use this for the default gadget text */
}

/*
   int vrequester_error(
      struct Window *window,                                   if non-NULL, show the requester window on the same screen as this window
      int title,                                               if not -1, use this for the title
      int error_text,                                          use this for the error text
      int gadget_text,                                         if not -1, use this for to define the available gadget(s)
      va_list arg_ptr)                                         printf() style arguments for the error text and gadget text

   * Description
      This function will display the specified error in a requester optionally entitled 'title' and wait for the user to choose something.

      NOTE: Turn off all "Verify Messages" before using this routine. Use ModifyIDCMP() to turn off all messages such as MENUVERIFY before
      calling this function. Neglecting to do so can cause situations where Intuition is waiting for the return of a message that the
      application cannot receive because it's input is shut off while the requester created by this function is up.

   This function requires that the intuition.library be open.

   * Return Value
      0 = the rightmost gadget was selected
      > 1 = a leftmost gadget was selected (the number of the gadget is returned)
*/
int vrequester_error(
   struct Window *window,                                      /* if non-NULL, show the requester window on the same screen as this window */
   int title,                                                  /* if not -1, use this for the title */
   int error_text,                                             /* use this for the error text */
   int gadget_text,                                            /* if not -1, use this for to define the available gadget(s) */
   va_list arg_ptr)                                            /* printf() style arguments for the error text and gadget text */
{
   struct EasyStruct *easy_struct = AllocVec(sizeof(*easy_struct),0);                           /* the structure used to handle the requester */
   int retval = 0;                                             /* default to the cancel gadget */

   if (title == -1)                                            /* if no title was supplied */
      title = ErrorRequesterTitle;                             /* use the default */

   if (gadget_text == -1)                                      /* if no gadget was supplied */
      gadget_text = ErrorGadgetText;                           /* use default */

   if (easy_struct)                                            /* if we could get enough memory */
   {
      easy_struct->es_StructSize = sizeof(*easy_struct);       /* let intuition know which structure we are using */
      easy_struct->es_Flags = 0;                               /* not yet used */
      easy_struct->es_Title = locale_support_string(ErrorCatalog, title);                       /* use appropriate title */
      easy_struct->es_TextFormat = locale_support_string(ErrorCatalog,error_text);              /* fetch specified error text */
      easy_struct->es_GadgetFormat = locale_support_string(ErrorCatalog,gadget_text);           /* use the appropriate gadget text */

      retval = EasyRequestArgs(window ? window : ErrorRequesterWindow, easy_struct, NULL, arg_ptr);

      FreeVec(easy_struct);                                    /* don't need this memory anymore */
   }

   return (retval);                                            /* 0 = righmost (cancel), other = gadget number */
}

/*
   int requester_error(
      struct Window *window,                                   if non-NULL, show the requester window on the same screen as this window
      int title,                                               if not -1, use this for the title
      int error_text,                                          use this for the error text
      int gadget_text,                                         if not -1, use this for to define the available gadget(s)
      ...)                                                     printf() style arguments for the error text and gadget text

   * Description
      This funciton acts exactly like vrequester_error() except that it takes it's arguments individually.

   * Return Value
      see vrequester_error()
*/
int requester_error(
   struct Window *window,                                      /* if non-NULL, show the requester window on the same screen as this window */
   int title,                                                  /* if not -1, use this for the title */
   int error_text,                                             /* use this for the error text */
   int gadget_text,                                            /* if not -1, use this for to define the available gadget(s) */
   ...)                                                        /* printf() style arguments for the error text and gadget text */
{
   va_list arg_ptr;                                            /* for dealing with variable arguments */

   va_start(arg_ptr,gadget_text);                              /* setup the variable argument stuff */

   return (vrequester_error(window,title,error_text,gadget_text,arg_ptr));                      /* call the va_arg version of this function */
}

/*
   int quick_requester_error(
      int error_text,                                          index into the errory text array
      ...)                                                     printf() style arguments for the error text and gadget text

   * Description
      This function works exactly like requester_error() except that the values previously setup by a call to requester_error_set_defaults() will be used instead of having to pass them on the stack.

   * Return Value
      see requester_error()
*/
int quick_requester_error(
   int error_text,                                             /* index into the errory text array */
   ...)                                                        /* printf() style arguments for the error text and gadget text */
{
   va_list arg_ptr;                                            /* for dealing with variable arguments */

   va_start(arg_ptr,error_text);                               /* setup the variable argument stuff */

   return (vrequester_error(NULL,-1,error_text,-1,arg_ptr));   /* call the va_arg version of this function */
}
#endif
