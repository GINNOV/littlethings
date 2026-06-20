#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <workbench/startup.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>


void prtnum(double num,int mode);
double getnum(char *buff,int mode);

char format[100] = "%16.16e\n";

void main()
{
   char linebuff[80];
   char *buff;
   int mode = 0,noprint;   /* 0 = x, 1 = decimal, 2 = binary */
   double result;
   double result2,result3, result4;
   long input;
   
   input = Input();
   if (input == NULL) return;

result = result2 = result3 = result4 = 0.0;      

 while(1)
 {
looptop:
   memset(linebuff,'\0',79);
   if (Read(input, linebuff, 79) == 0 || *linebuff == 'q')
   {
      return;
   }
   buff = linebuff;
   while(*buff)
   {
      noprint = 0;
      while(*buff == ' ') buff++;
      switch(toupper(*buff))
      {
         case 0: 
            break;
         case 'i':
         case 'I':
            result = 1/ result;
            break;
         case '!':
            result = -result;
            break;          
         case '|':
            result = (double)((long)result2|(long)result);
            result2 = result3;
            result3 = result4;
            break;          
         case '&':
            result = (double)((long)result2&(long)result);
            result2 = result3;
            result3 = result4;
            break;          
         case '/':
            result = result2/result;
            result2 = result3;
            result3 = result4;
            break;          
         case '*':
            result = result2*result;
            result2 = result3;
            result3 = result4;
            break;          
         case '-':
            result = result2- result;
            result2 = result3;
            result3 = result4;
            break;          
         case '+':
            result = result2+result;
            result2 = result3;
            result3 = result4;
            break;
         case 'S':
            prtnum(result4,mode);
            prtnum(result3,mode);
            prtnum(result2,mode);
            break;
         case 'M':
            buff++;
            switch(toupper(*buff))
            {
	       case 'F':
	          strcpy(format, buff+1);
		  buff += strlen(buff);
		  break;
               case 'P':
                  mode = 3;
                  break;
               case 'X':   
               case 'H':
                  mode = 0;
                  break;
               case 'D':
                  mode = 1;
                  break;
               case 'B':
                  mode = 2;
                  break;
            }
            break;
         case '?':
            printf("MH  - hex mode\n");
            printf("MD  - decimal mode\n");
            printf("MB  - binary mode\n");
            printf("MP  - Hex pattern of double\n");
            printf("MF  - Specify decimal output format\n");
            printf("S   - print stack\n");
            printf("+   - Addition\n");
            printf("-   - Subtraction\n");
            printf("*   - Multiplication\n");
            printf("/   - Division\n");
            printf("&   - Bitwise AND\n");
            printf("|   - Bitwise OR\n");
            printf("!   - Negation\n");
            printf("i   - Inverse (1/x)\n"); 
            break;
         
         default:
            result4 = result3;
            result3 = result2;
            result2 = result;
            if (strlen(buff)>1)
               result = getnum(buff,mode);
            noprint = 1;
      }
      if (!noprint) prtnum(result, mode);
      while(*buff != ' ' && *buff != '\0') buff++;
   }
 }   
}

double getnum(buff, mode)
char *buff;
int mode;
{
   unsigned long ret;
   char *p;
   double ret2;
   unsigned long *d = (long *)&ret2;
   char buff2[256];
   
   switch(mode)
   {
      case 0:
         stch_l(buff, (long *)&ret);
         ret2 = ret;
         break;
      case 1:
         sscanf(buff, "%le",&ret2);
         break;
      case 2:
         p = buff;
         ret = 0;
         while(*p == '0' || *p == '1')
         {
            ret = (ret << 1) + (*p - '0'); 
            p++;
         }
         ret2 = ret;
         break;      
      case 3:
         strcpy(buff2,buff);
         buff2[8] = 0;
         stch_l(buff2, (long *)d);
         strcpy(buff2,buff);
         ret = 8;
         while (buff[ret] && buff[ret]== ' ')
         {
            buff[ret] = 'z';
            ret++;
         }
         stch_l(&buff[ret], (long *)(d+1));
         break;

   }
   return ret2;
}

void prtnum(num, mode)
double num;
int mode;
{
   char buff[33];
   int i;
   unsigned long num2;
   unsigned long *l;
   
   buff[32] = 0;
   switch(mode)
   {
      case 0:
         if (num > 0)
           printf("%x\n",(unsigned long)num);
         else
           printf("%x\n",(long)num);
         break;
      case 1:
         printf(format,num);
         break;
      case 2:
         num2 = num;
         for (i = 31; i >= 0; i--)
         {
            if (num2 & (1<<i)) buff[31 - i] = '1';
            else buff[31 - i] = '0';
         }
         printf("%s\n",buff);
         break;      
      case 3:
         l = (long *)&num;
         printf("%x %x\n",*l,*(l+1));
         break;
   }
}

