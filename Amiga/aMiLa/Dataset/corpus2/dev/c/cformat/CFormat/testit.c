 
 main()  {
               #ifdef DEBUG    
printf("Start\n");
                        #endif
Testfun(1,2,3,4);
#ifdef DEBUG
                      printf("End\n");
#endif
  }
 
 Testfun(LONG i,
      int a,
      SHORT b,
      char c)
  { printf("%ld %d %d %c\n",i,a,b,c);
  }
 
  {/*Dies ist ein TEST*/
  }