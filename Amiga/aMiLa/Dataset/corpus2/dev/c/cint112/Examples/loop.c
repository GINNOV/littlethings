/* Nested loop example. */
main()
{
  int i, j, k;
  for(i = 0; i < 5; i = i + 1) {
    for(j = 0; j < 3; j = j + 1) { 
      for(k = 3; k ; k = k - 1) {
        print(i);
        print(j);
        print(k);
        puts("");
      }
    }
  }
  puts("done");    
}
