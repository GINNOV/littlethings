/*------------------------------------------------------------------*/
/* parsearg : parse parameters and options in an argv list          */
/*------------------------------------------------------------------*/
/* 03-14-90 originally by Patrick J. Mueller                        */
/* 01-09-91 version 2.0 by Patrick J. Mueller                       */
/* 04-29-91 version 3.0 by Patrick J. Mueller                       */
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/* description:                                                     */
/*------------------------------------------------------------------*/
/* parsearg() classifies argv-style parameters into three           */
/* categories:                                                      */
/*                                                                  */
/*    - boolean  switches                                           */
/*    - variable switches                                           */
/*    - parameters                                                  */
/*                                                                  */
/* Switches are one character markers that are prefixed by the      */
/* switch delimiter (usually - or /, but customizable via parameter */
/* to the function).  A boolean switch has nothing following it:    */
/* multiple boolean switches may be used in the command line        */
/* concatenated together.  A variable switch is followed            */
/* immediately by it's value.  A variable switch may be used as the */
/* last switch in a list of boolean switches (the remainder of the  */
/* string is the value of that variable switch).  A parameter is    */
/* anything that is not a switch.                                   */
/*                                                                  */
/* parsearg() separates the switches from the parameters and resets */
/* the argv array and argc so that they point to parameters only.   */
/*                                                                  */
/* Information on which switches were used is returned in pointers. */
/* Each switch has a pointer associated with it.  The pointer is to */
/* a variable that will be set to the contents of the item.  For    */
/* boolean switches, the pointer is a pointer to an int.  The int   */
/* will be set to 1 if the switch is used in the parameters, else   */
/* it will be set to 0. For variable switches the pointer is a      */
/* pointer to a pointer to a char.  This points to a null           */
/* terminated string which is the value of the switch or parameter. */
/*                                                                  */
/* Switches (but not parameters) may also be specified in an        */
/* environment variable.                                            */
/*                                                                  */
/* You may specify that switches should be handled in a case        */
/* sensitive or case insensitive manner.                            */
/*                                                                  */
/* The prototype for parsearg() is:                                 */
/*------------------------------------------------------------------*/

void parsearg(
   int    *argc,
   char  **argv,
   int     case_sense,
   char   *env_var,
   char   *delimiters,
   char   *format_string,
   ...
   );

/*------------------------------------------------------------------*/
/* parameters:                                                      */
/*------------------------------------------------------------------*/
/*    argc                                                          */
/*    argv                                                          */
/*       are variables in the same format as argc and argv.  The    */
/*       original main() parameters should be passed here (pass the */
/*       address to argc).  Upon return from parsearg(), argc will  */
/*       contain the number of parameters passed in, and argv will  */
/*       point to an array of parameters, in the original argv      */
/*       format.                                                    */
/*                                                                  */
/*    case_sense                                                    */
/*       set to 1 if you want switches handled in a case sensitive  */
/*       manner, set to 0 if you want switches handled in a case    */
/*       insensitive manner.                                        */
/*                                                                  */
/*    env_var                                                       */
/*       is the name of an environment variable.  If the value of   */
/*       this pointer is not NULL and does not point to an empty    */
/*       string, this value will be considered the name of an       */
/*       environment variable.  This environment variable will be   */
/*       retrieved and will be searched for additional switches     */
/*       BEFORE the argv values passed in so that the environment   */
/*       variable values can be overridden by commandline           */
/*       switches.                                                  */
/*                                                                  */
/*    delimiters                                                    */
/*       is a string that contains a list of valid switch delimters */
/*       ("-/" means to use - or / as a switch delimiter).          */
/*                                                                  */
/*    format_string                                                 */
/*       is a string of 'declarations' of switches to use.  Each    */
/*       blank delimited item in the string corresponds to one      */
/*       switch.  The first character of the item is the switch     */
/*       character.  If anything follows the switch character, this */
/*       item is a variable switch, else it is a boolean switch.    */
/*       The stuff following the switch character for a variable    */
/*       switch is ignored.                                         */
/*                                                                  */
/*    ...                                                           */
/*       everything following the format string are pointers to     */
/*       variables corresponding to switches.  The 'declarations'   */
/*       in the format_string should line up 1-1 with the pointer   */
/*       variables, just as in printf().                            */
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/* additional notes:                                                */
/*------------------------------------------------------------------*/
/* If multiple switches are in the argv array, the last one         */
/* in the argv array will be the one used to set the variable.      */
/*------------------------------------------------------------------*/

