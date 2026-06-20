/* Assigments as operations. */
main()
{
  int a, b;
  a = b = 10;
  print(a); print(b);
  while(a=a-1) {
    print(a);
    do {
       print(b); 
    }while((b=b-1) > -10); 
  }
}
