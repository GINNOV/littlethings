abort()
{
	extern long Output(), Write();

	Write( Output(), "^C\n", 4L);
	exit( 3 );
}
