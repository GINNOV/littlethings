
int t;

for (t=0; t<=10000; t++)
{
    printf ("t = %5d\r", t);
    flush_stdout ();
}

for ( ; t>=0; t--)
{
    printf ("t = %5d\r", t);
    flush_stdout ();
}

printf ("\n");
