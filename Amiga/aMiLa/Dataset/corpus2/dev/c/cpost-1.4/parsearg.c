/*------------------------------------------------------------------*/
/* parsearg : parse parameters and options in an argv list          */
/*            see parsearg.h for a description                      */
/*------------------------------------------------------------------*/
/* 03-13-90 originally by Patrick J. Mueller                        */
/* 01-09-91 version 2.0 by Patrick J. Mueller                       */
/* 04-29-91 version 3.0 by Patrick J. Mueller                       */
/*------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

/*------------------------------------------------------------------*/
/* typedefs                                                         */
/*------------------------------------------------------------------*/
typedef enum
   {
   Boolean_Switch,
   Variable_Switch
   } Item_Type;

typedef struct Cmdline_Item
   {
   Item_Type             type;
   int                   position;
   char                  sw_char;
   void                 *variable;
   struct Cmdline_Item  *next;
   } Cmdline_Item;

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*------------------------------------------------------------------*/
/*               L O C A L   F U N C T I O N S                      */
/*------------------------------------------------------------------*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------*/
/* Search the Cmdline_Item list for a particular switch.  Look for  */
/* the option with a particular switch character (Boolean and       */
/* Variable are treated as the same)                                */
/*------------------------------------------------------------------*/

static Cmdline_Item *get_item(
   Cmdline_Item *head,
   char          sw_char,
   int           case_sense
   )

   {
   Cmdline_Item *next;

   /*---------------------------------------------------------------*/
   /* traverse the linked list ...                                  */
   /*---------------------------------------------------------------*/
   next = head;
   while (next != NULL)
      {
      /*------------------------------------------------------------*/
      /* for case sensitive switches, just compare chars            */
      /*------------------------------------------------------------*/
      if (case_sense)
         {
         if (next->sw_char == sw_char)
            return(next);
         }

      /*------------------------------------------------------------*/
      /* otherwise, toupper the chars and compare                   */
      /*------------------------------------------------------------*/
      else
         {
         if (toupper(sw_char) == toupper(next->sw_char))
            return(next);
         }

      /*------------------------------------------------------------*/
      /* no matches so traverse to next item                        */
      /*------------------------------------------------------------*/
      next = next->next;
      }

   /*---------------------------------------------------------------*/
   /* no matches at all!                                            */
   /*---------------------------------------------------------------*/
   return(NULL);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*------------------------------------------------------------------*/
/*               M A I N     F U N C T I O N                        */
/*------------------------------------------------------------------*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------*/
/* the main function                                                */
/*------------------------------------------------------------------*/
void parsearg(
   int    *argc,
   char  **argv,
   int     case_sense,
   char   *env_var,
   char   *delimiters,
   char   *format_string,
   ...
   )

   {
   char         *tok;
   Cmdline_Item *item_head;
   Cmdline_Item *item_tail;
   Cmdline_Item *item;
   va_list       arg_marker;
   int           i;
   int           parms;
   int          *ptr_int;
   char        **ptr_ptr_char;
   char          sw_char;
   char         *env_value;
   int           envc;
   char         *envv;
   char         *temp;

   /*---------------------------------------------------------------*/
   /* sanity checks                                                 */
   /*---------------------------------------------------------------*/
   if ((NULL == format_string)  ||
       (NULL == argv)           ||
       (0    == *argc))
      return;

   /*---------------------------------------------------------------*/
   /* make a copy of the format string since we will be strtok()ing */
   /* through it                                                    */
   /*---------------------------------------------------------------*/
   temp = malloc(1+strlen(format_string));
   if (NULL == temp)
      {
      puts("Error allocating memory in parsearg()");
      return;
      }

   strcpy(temp,format_string);
   format_string = temp;

   /*---------------------------------------------------------------*/
   /* get environment variable value                                */
   /*---------------------------------------------------------------*/
   env_value = NULL;

   if (NULL != env_var)
      if ('\0' != *env_var)
         {

         /*---------------------------------------------------------*/
         /* get value and copy if we found something                */
         /*---------------------------------------------------------*/
         env_value = getenv(env_var);

         if (NULL != env_value)
            {
            temp = malloc(1+strlen(env_value));
            if (NULL == temp)
               {
               puts("Error allocating memory in parsearg()");
               return;
               }

            strcpy(temp,env_value);
            env_value = temp;
            }
         }

   /*---------------------------------------------------------------*/
   /* build option list                                             */
   /*---------------------------------------------------------------*/
   item_head = item_tail = NULL;
   va_start(arg_marker,format_string);

   /*---------------------------------------------------------------*/
   /* parse the format_string with strtok                           */
   /*---------------------------------------------------------------*/
   tok = strtok(format_string," ");

   while (NULL != tok)
      {
      /*------------------------------------------------------------*/
      /* allocate area for a new Item                               */
      /*------------------------------------------------------------*/
      item = (Cmdline_Item *) malloc(sizeof(Cmdline_Item));
      if (NULL == item)
         {
         puts("Error allocating memory in parsearg()");
         return;
         }

      /*------------------------------------------------------------*/
      /* start assigning values to it                               */
      /*------------------------------------------------------------*/
      item->next    = NULL;
      item->sw_char = *tok++;

      /*---------------------------------------------------------*/
      /* is it a boolean switch?                                 */
      /*---------------------------------------------------------*/
      if ('\0' == *tok)
         item->type = Boolean_Switch;

      /*---------------------------------------------------------*/
      /* must be a variable switch                               */
      /*---------------------------------------------------------*/
      else
         item->type = Variable_Switch;

      /*------------------------------------------------------------*/
      /* now get the variable pointer                               */
      /*------------------------------------------------------------*/
      item->variable = va_arg(arg_marker,void *);

      /*------------------------------------------------------------*/
      /* initialize boolean switches to 0                           */
      /*------------------------------------------------------------*/
      if (Boolean_Switch == item->type)
         {
         ptr_int  = item->variable;
         *ptr_int = 0;
         }

      /*------------------------------------------------------------*/
      /* and variable switches to NULL                              */
      /*------------------------------------------------------------*/
      else
         {
         ptr_ptr_char  = item->variable;
         *ptr_ptr_char = NULL;
         }

      /*------------------------------------------------------------*/
      /* now insert into list (at end)                              */
      /*------------------------------------------------------------*/
      if (NULL == item_head)
         item_head = item_tail = item;

      else
         {
         item_tail->next = item;
         item_tail       = item;
         }

      /*------------------------------------------------------------*/
      /* get next item in format_string                             */
      /*------------------------------------------------------------*/
      tok = strtok(NULL," ");
      }

   /*---------------------------------------------------------------*/
   /* now we've set up the format_string.  time to step through the */
   /* args to set the switches on and off and to scanf through      */
   /* variable switches and parameters                              */
   /*---------------------------------------------------------------*/

   /*---------------------------------------------------------------*/
   /* assign argc to parms and initialize argc to 0                 */
   /*---------------------------------------------------------------*/
   parms = *argc;
   *argc = 0;

   /*---------------------------------------------------------------*/
   /* We want to check the environment variables first.  Try to get */
   /* the first item with strtok (if we had anything to begin with. */
   /* If we have anything, set envv to the value and set env to 1.  */
   /*---------------------------------------------------------------*/
   envc = 0;
   envv = NULL;

   if (NULL != env_value)
      {
      envv = strtok(env_value," ");
      if (NULL != envv)
         envc = 1;
      }

   /*---------------------------------------------------------------*/
   /* now loop through the environment variables and arguments      */
   /* setting the appropriate value in the CmdLine_Item list.       */
   /*---------------------------------------------------------------*/
   for (i = 0; i < envc + parms; i++)
      {
      if (NULL != envv)
         tok = envv;

      else
         tok = argv[i-envc];

      /*------------------------------------------------------------*/
      /* if it's a parameter, assign it to next argv pointer        */
      /*------------------------------------------------------------*/
      if (('\0' == *tok) || (NULL == strchr(delimiters,*tok)))
         {

         /*---------------------------------------------------------*/
         /* we don't want to handle environment values though       */
         /*---------------------------------------------------------*/
         if (NULL == envv)
            {
            argv[*argc] = tok;
            (*argc)++;
            }
         }

      /*------------------------------------------------------------*/
      /* otherwise it's a switch                                    */
      /*------------------------------------------------------------*/
      else
         {
         tok++;

parse_switches:
         sw_char = *tok++;

         /*---------------------------------------------------------*/
         /* is it a switch?                                         */
         /*---------------------------------------------------------*/
         item = get_item(item_head,sw_char,case_sense);

         if (NULL != item)
            {
            /*------------------------------------------------------*/
            /* it's a switch, but is it variable or boolean?        */
            /*------------------------------------------------------*/
            if (Variable_Switch == item->type)
               {
               ptr_ptr_char  = item->variable;
               *ptr_ptr_char = tok;
               }

            else
               {
               ptr_int  = item->variable;
               *ptr_int = 1;

               /*---------------------------------------------------*/
               /* handle multiple switches concatenated             */
               /*---------------------------------------------------*/
               if ('\0' != *tok)
                  goto parse_switches;
               }
            }

         }

      /*------------------------------------------------------------*/
      /* now get the next environment value if we need to           */
      /*------------------------------------------------------------*/
      if (NULL != envv)
         {
         envv = strtok(NULL," ");
         if (NULL != envv)
            envc++;
         }

      }

   /*---------------------------------------------------------------*/
   /* now release all the memory we used                            */
   /*---------------------------------------------------------------*/
   item = item_head;
   while (NULL != item)
      {
      item_head = item->next;
      free(item);
      item = item_head;
      }

   free(format_string);

   /*---------------------------------------------------------------*/
   /* don't release this memory as we may have set pointers into it */
   /* I guess if we wanted to be >real< tricky we could somehow     */
   /* return pointers into the original string ... nah!!!           */
   /*---------------------------------------------------------------*/
#if defined(SHOOT_YOURSELF_IN_THE_FOOT)
   if (NULL != env_value)
      free(env_value);
#endif

   return;
   }

