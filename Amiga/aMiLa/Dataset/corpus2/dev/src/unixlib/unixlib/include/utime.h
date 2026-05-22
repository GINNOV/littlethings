struct utimbuf { time_t actime, modtime; };

int utime(char *path, struct utimbuf *times);
