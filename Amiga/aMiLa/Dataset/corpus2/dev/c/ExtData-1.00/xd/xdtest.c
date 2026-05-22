
#include "xd.h"

int
main(int argc, char **argv)
{
   Xd_Database xd;
   int a = 24, b = 23, h = 180;
   char *name;

   xd_Init();
   if (argc == 1) {
      printf("writing file \"test\"... (call 'xdtest 1' to re-read it)\n");
      xd = xd_Open("test", XD_WRITE, "xdtest");
      xd_DeclareApplication(xd, "xdtestApplication");
      if (xd) {
	 xd_DeclareField(xd, "name", XD_STRING);
	 xd_DeclareField(xd, "age", XD_INTEGER);
	 xd_DeclareField(xd, "height", XD_INTEGER);

	 xd_DeclareSharedString(xd, "info", "General information");

	 xd_AssignField(xd, "name", "Cedric");
	 xd_AssignField(xd, "age", & a);
	 xd_AssignField(xd, "height", & h);
	 xd_WriteRecord(xd);

	 h = 185;
	 xd_AssignField(xd, "name", "Alois");
	 xd_AssignField(xd, "age", & b);
	 xd_AssignField(xd, "height", & h);
	 xd_WriteRecord(xd);
	 
	 xd_Close(xd);
      }
   }
   else {
      char *info;
      printf("reading test...\n");
      xd = xd_Open("test", XD_READ, "xdtest");
      printf("type of this file: '%s'\n", xd_ReadType(xd));
      printf("application of this file: '%s'\n", xd_ReadApplication(xd));
      if (xd) {
	 xd_ReadSharedString(xd, "info", & info);
	 printf("Shared information: '%s'\n", info);
	 xd_ReadSharedString(xd, "info2", & info);
	 while (xd_NextRecord(xd)) {
	    name = "default";
	    a = 42;
	    h = 42;
	    xd_ReadField(xd, "age", XD_INTEGER, & a);
	    xd_ReadField(xd, "name", XD_STRING, & name);
	    xd_ReadField(xd, "height", XD_INTEGER, & h);
	    printf("read name=%s age=%x height=%x\n", name, a, h);
	 }
	 xd_Close(xd);
      }
   }
   xd_Uninit(xd);
   return 0;
}
