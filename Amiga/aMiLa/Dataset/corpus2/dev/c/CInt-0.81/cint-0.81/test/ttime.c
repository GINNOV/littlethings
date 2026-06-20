struct tm
{
    int tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday,
	tm_yday, tm_isdst;
};

long tt1, tt2;
struct tm tm;
int t, n;

tt1 = time (&tt2);
// tt1 = time ((long *)0);

printf ("tt1=%d\ntt2=%d\n", tt1, tt2);

localtime (&tt1, &tm);

printf ("struct tm tm = { tm_sec=%d, tm_min=%d, tm_hour=%d, tm_mday=%d,\n"
	"tm_mon=%d, tm_year=%d, tm_wday=%d, tm_yday=%d, tm_isdst=%d };\n",
	    tm.tm_sec, tm.tm_min, tm.tm_hour, tm.tm_mday,
	    tm.tm_mon, tm.tm_year, tm.tm_wday, tm.tm_yday, tm.tm_isdst);

printf ("%d:%02d:%02d %d.%d.%d\n",
	tm.tm_hour, tm.tm_min, tm.tm_sec, tm.tm_mday, tm.tm_mon+1,
	1900+tm.tm_year);

n = 100000;

time (&tt1);

for (t=0; t<n; t++);

time (&tt2);

t = tt2 - tt1;

printf ("t=%d\n", t);
printf ("%d Durchläufe benötigen %d:%02d:%02d\n",
	n, t/3600, (t%3600)/60, t%60);
