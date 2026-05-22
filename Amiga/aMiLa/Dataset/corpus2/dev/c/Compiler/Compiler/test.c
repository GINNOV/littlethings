main ()
{
	register int a;
	auto int b;

	a = 0;
	b = 1;
	subr (a);
}

subr (a)
int a;
{
	a *= 2;
	return (a);
}
