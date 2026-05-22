/* $Id: Errors.c,v 2.8 1992/08/17 14:35:54 grosch rel $ */

#include "Errors.h"
#include <stdio.h>
#include "System.h"
#include "Sets.h"
#include "Idents.h"


static void yyExit(void)
 {
  Exit(1);
 }


void (*Errors_Exit)(void) = yyExit;


static void WriteHead(short yyErrorClass, tPosition yyPosition)
 {
  WritePosition(stderr,yyPosition);
  fputs(": ",stderr);
  switch (yyErrorClass)
   {
    case xxFatal       : fputs("Fatal       ",stderr);
                         break;
    case xxRestriction : fputs("Restriction ",stderr);
                         break;
    case xxError       : fputs("Error       ",stderr);
                         break;
    case xxWarning     : fputs("Warning     ",stderr);
                         break;
    case xxRepair      : fputs("Repair      ",stderr);
                         break;
    case xxNote        : fputs("Note        ",stderr);
                         break;
    case xxInformation : fputs("Information ",stderr);
                         break;
    default            : fprintf(stderr,"Error class: %d ",yyErrorClass);
   }
 }


static void WriteTail(short yyErrorClass)
 {
  fputc('\n',stderr);
  if (yyErrorClass == xxFatal)
    (*Errors_Exit)();
 }


static void WriteCode(short yyErrorCode)
 {
  switch (yyErrorCode)
   {
    case xxNoText         : break;
    case xxSyntaxError    : fputs("syntax error",stderr);
                            break;
    case xxExpectedTokens : fputs("expected tokens",stderr);
                            break;
    case xxRestartPoint   : fputs("restart point",stderr);
                            break;
    case xxTokenInserted  : fputs("token inserted ",stderr);
                            break;
    default               : fprintf(stderr," error code: %d",yyErrorCode);
   }
 }


static void WriteInfo(short yyInfoClass, char *yyInfo)
 {
  fputs(": ",stderr);
  switch (yyInfoClass)
   {
    case xxInteger   : fprintf(stderr,"%d",*(int *)yyInfo);
                       break;
    case xxShort     : fprintf(stderr,"%d",*(short *)yyInfo);
                       break;
    case xxCharacter : fprintf(stderr,"%c",*yyInfo);
                       break;
    case xxString    : fputs(yyInfo,stderr);
                       break;
    case xxSet       : WriteSet(stderr, (tSet *)yyInfo);
                       break;
    case xxIdent     : WriteIdent(stderr,*(tIdent *)yyInfo);
                       break;
    default          : fprintf(stderr,"info class: %d",yyInfoClass);
   }
 }


void ErrorMessage(short yyErrorCode, short yyErrorClass, tPosition yyPosition)
 {
  WriteHead(yyErrorClass,yyPosition);
  WriteCode(yyErrorCode);
  WriteTail(yyErrorClass);
 }


void ErrorMessageI(short yyErrorCode, short yyErrorClass, tPosition yyPosition, short yyInfoClass, char *yyInfo)
 {
   WriteHead(yyErrorClass,yyPosition);
   WriteCode(yyErrorCode);
   WriteInfo(yyInfoClass,yyInfo);
   WriteTail(yyErrorClass);
 }


void Message(char *yyErrorText, short yyErrorClass, tPosition yyPosition)
 {
  WriteHead(yyErrorClass,yyPosition);
  fputs(yyErrorText,stderr);
  WriteTail(yyErrorClass);
 }


void MessageI(char *yyErrorText, short yyErrorClass, tPosition yyPosition, short yyInfoClass, char *yyInfo)
 {
  WriteHead(yyErrorClass,yyPosition);
  fputs(yyErrorText, stderr);
  WriteInfo(yyInfoClass,yyInfo);
  WriteTail(yyErrorClass);
 }
