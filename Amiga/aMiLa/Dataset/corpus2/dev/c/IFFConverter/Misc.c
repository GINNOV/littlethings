/*
**     $VER: Misc.c V0.01 (27-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 27-06-95  Version 0.01     Intial module
**
**  Misc.c contains some miscellanious functions.
**
*/


#include <exec/memory.h>
#include <libraries/gadtools.h>
#include <utility/tagitem.h>

#include "IFFConverter.h"


// Defining protos
ULONG ConvertDecimal(STRPTR);
void  MakeDecimal(LONG, char *, UWORD);
void  UpdateDimensions(ULONG, ...);
BOOL  StringCompare(STRPTR, STRPTR);
UWORD StringLength(char *);

static UBYTE MakeUpper(UBYTE);


/*
**  MakeDecimal(NumberToConvert, ASCII_String, MaxChars)
**
**     Makes from an integer value the same ASCII number.
**
**  pre:  NumberToConvert -> Integer to convert.
**        ASCII_String -> Where to store the ASCII representation.
**        MaxChars -> Maximum number of characters to use.
**  post: None.
**
*/
void MakeDecimal(LONG NumberToConvert, char *ASCII_String, UWORD MaxChars)
{
   int i;
   UBYTE Digit;
   
   for(i=MaxChars-1; i>=0; i--)
   {
      Digit = '0' + (NumberToConvert % 10);
      NumberToConvert /= 10;
      ASCII_String[i] = (char) Digit;
   }
   
   i = 1;
   while(*ASCII_String == '0' && i<MaxChars)
   {
      *ASCII_String++ = ' ';
      i++;
   }
}


/*
**  Result = ConvertDecimal( String )
**
**     Converter an ASCII string to a decimal interger.
**
**  pre:  String - Pointer to an \n terminated ASCII string.
**  post: Result - Function returns a decimal number.
**
*/
ULONG ConvertDecimal(STRPTR String)
{
   ULONG Result = 0;

   while(*String != '\0')
      Result = Result * 10 + (UBYTE)(*String++ - '0');
   
   return( Result );
}


/*
**  Result = ConvertHex( String )
**
**     Converter an ASCII string to a hexadecimal interger.
**
**  pre:  String - Pointer to an \n terminated ASCII string.
**  post: Result - Function returns a hexadecimal number.
**
*/
/*
ULONG ConvertHex(STRPTR String)
{
   ULONG Result = 0;

   while(*String != '\0')
   {
      Hex = MakeUpper( (UBYTE)(*String++ - '0') );
      if( Hex = (UBYTE)(*String++ - '0' < ('A' - '9') )
         Hex -= ('A' - '9');
      Result = Result * 16 + Hex;
   }
   return( Result );
}
*/

/*
**  UpdateDimensions()
**
**     Updates the picture and clip dimention gadgets.
**
**  pre:  None.
**  post: None.
**
*/
void UpdateDimensions(ULONG Gadgets_To_Update, ...)
{
   STRPTR Gad_UpdateText = "1234567";
   ULONG *Gad_To_Update = &Gadgets_To_Update;
   
   register ULONG Gad_enumID;
   register ULONG Gad_Value;
   
   SetTextGadget[1] = (ULONG)Gad_UpdateText;

   while( (Gad_enumID = *Gad_To_Update) != GD_Sentinal )      
   {
      *Gad_To_Update++;
      Gad_Value = *Gad_To_Update++;
      
      if(PanelGadgets[Gad_enumID].MyGadgetType == TEXT_KIND)
      {
         MakeDecimal(Gad_Value, (char *)SetTextGadget[1], 7);
      
         UpdateGadgets(Gad_enumID, &SetTextGadget,
                       TAG_DONE);
      }
      else
      {
         SetIntegerGadget[1] = Gad_Value;
         
         UpdateGadgets(Gad_enumID, &SetIntegerGadget,
                       TAG_DONE);
      }
   }
}


/*
**  Length = StringLength( String )
**
**     Calculate the length of a given string. String should be \0 terminated.
**
**  pre:  String - Pointer to a \0 terminated string.
**  post: Length - Length of \0 terminated string.
**
*/
UWORD StringLength(char *String)
{
   register UWORD i = 0;
   
   while( *String++ != 0 )
      i++;
      
   return(i);
}


/*
**  result = StringCompare( String1, String2 )
**
**     Compare two strings and return TRUE if they match.
**     'StringCompare' is case insencitive.
**
**  pre:  String1, String2 - Pointer to a string to be compaired.
**                           Strings should be \0 terminated.
**  post: result - Function returns TRUE if strings are equal,
**                 FALSE otherwise.
**
*/
BOOL StringCompare(STRPTR String1, STRPTR String2)
{
   while( (*String1 != 0) && (MakeUpper(*String1++) == MakeUpper(*String2++)) );

   if( *String2 == '\0' )
      return(TRUE);
   else
      return(FALSE);
}


/*
**  Upper = MakeUpper( Character )
**
**     Converters a character to upper case.
**
**  pre:  Character - character to be converter to upper case.
**  post: Upper - Chatacter in upper case
**
*/
static UBYTE MakeUpper(UBYTE Character)
{
   if( Character < 'a' || Character > 'z' )
      return(Character);
   return( (UBYTE)(Character - (UBYTE)32) );

}
