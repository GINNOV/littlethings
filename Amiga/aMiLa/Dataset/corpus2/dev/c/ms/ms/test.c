
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include "ms.h"

#define LL long long

const char *vers = "\0$VER: test 1.0 (07.05.2020) ms test program";
const char *copy = "Copyright (c) 2012 TJ Holowaychuk <tj@vision-media.ca>\n"
                   "Copyright (c) 2003-2016 Devon H. O'Dell <devon.odell@gmail.com>\n"
                   "Copyright (c) 1992, 1993 The Regents of the University of California\n"
                   "Copyright (c) 2011 The FreeBSD Foundation";

void equal(char *a, char *b)
{
  if (strcmp(a, b))
  {
    printf("expected: %s\n", a);
    printf("actual: %s\n", b);
    free(b);
    exit(1);
  }
  free(b);
}

void test_string_to_microseconds()
{
  assert(string_to_microseconds("") == -1);
  assert(string_to_microseconds("s") == -1);
  assert(string_to_microseconds("hey") == -1);
  assert(string_to_microseconds("5000") == 5000);
  assert(string_to_microseconds("1ms") == 1000);
  assert(string_to_microseconds("5ms") == 5000);
  assert(string_to_microseconds("1s") == 1000000);
  assert(string_to_microseconds("5s") == 5000000);
  assert(string_to_microseconds("1m") == 60000000);
  assert(string_to_microseconds("1h") == 3600000000);
  assert(string_to_microseconds("2d") == 2 * 24 * 3600000000);
}

void test_string_to_milliseconds()
{
  assert(string_to_milliseconds("") == -1);
  assert(string_to_milliseconds("s") == -1);
  assert(string_to_milliseconds("hey") == -1);
  assert(string_to_milliseconds("5000") == 5000);
  assert(string_to_milliseconds("1ms") == 1);
  assert(string_to_milliseconds("5ms") == 5);
  assert(string_to_milliseconds("1s") == 1000);
  assert(string_to_milliseconds("5s") == 5000);
  assert(string_to_milliseconds("1m") == 60 * 1000);
  assert(string_to_milliseconds("1h") == 60 * 60 * 1000);
  assert(string_to_milliseconds("1d") == 24 * 60 * 60 * 1000);
}

void test_string_to_seconds()
{
  assert(string_to_seconds("") == -1);
  assert(string_to_seconds("s") == -1);
  assert(string_to_seconds("hey") == -1);
  assert(string_to_seconds("5000") == 5);
  assert(string_to_seconds("1ms") == 0);
  assert(string_to_seconds("5ms") == 0);
  assert(string_to_seconds("1s") == 1);
  assert(string_to_seconds("5s") == 5);
  assert(string_to_seconds("1m") == 60);
  assert(string_to_seconds("1h") == 60 * 60);
  assert(string_to_seconds("1d") == 24 * 60 * 60);
}

void test_milliseconds_to_string()
{
  equal("500ms", milliseconds_to_string(500));
  equal("5s", milliseconds_to_string(5000));
  equal("2s", milliseconds_to_string(2500));
  equal("1m", milliseconds_to_string(60 * 1000));
  equal("5m", milliseconds_to_string(5 * 60 * 1000));
  equal("1h", milliseconds_to_string(60 * 60 * 1000));
  equal("2d", milliseconds_to_string(2 * 24 * 60 * 60 * 1000));
  equal("2w", milliseconds_to_string(15 * 24 * 60 * 60 * 1000));
  equal("3y", milliseconds_to_string((LL)3 * 52 * 7 * 24 * 60 * 60 * 1000));
}

void test_milliseconds_to_long_string()
{
  equal("less than one second", milliseconds_to_long_string(500));
  equal("5 seconds", milliseconds_to_long_string(5000));
  equal("2 seconds", milliseconds_to_long_string(2500));
  equal("1 minute", milliseconds_to_long_string(60 * 1000));
  equal("5 minutes", milliseconds_to_long_string(5 * 60 * 1000));
  equal("1 hour", milliseconds_to_long_string(60 * 60 * 1000));
  equal("2 days", milliseconds_to_long_string(2 * 24 * 60 * 60 * 1000));
  equal("2 weeks", milliseconds_to_long_string(15 * 24 * 60 * 60 * 1000));
  equal("1 year", milliseconds_to_long_string((LL)52 * 7 * 24 * 60 * 60 * 1000));
  equal("3 years", milliseconds_to_long_string((LL)3 * 52 * 7 * 24 * 60 * 60 * 1000));
}

int main()
{
  test_string_to_microseconds();
  test_string_to_milliseconds();
  test_string_to_seconds();
  test_milliseconds_to_string();
  test_milliseconds_to_long_string();
  printf("\n  \e[32m\u2713 \e[90mok\e[0m\n\n");
  return 0;
}
