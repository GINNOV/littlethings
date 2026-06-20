#include "amiga.h"
#include <string.h>
#include <stdio.h>

char *mktemp(char *name)
{
  int l;
  char *change = name + strlen(name) - 6;
  char letter = 'a';
  char id[9], *end_id;

  chkabort();
  _sprintf(id, "%lx", _us);
  l = strlen(id);
  end_id = l > 5 ? id + l - 5 : id;
  _sprintf(change, "a%s", end_id);

  while (letter <= 'z')
    {
      *change = letter;
      if (access(name, 0)) return name;
      letter++;
    }
  name[0] = '\0';
  return name;
}
