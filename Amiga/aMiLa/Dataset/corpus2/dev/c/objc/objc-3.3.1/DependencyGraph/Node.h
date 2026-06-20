
/* Node in graph of named nodes */

#include "objpak.h"

@interface Graphnode : String
  { BOOL isDefined; BOOL isMarked; id references; }
  
- addReference:anotherNode;
- mark;
- define;
- (BOOL)isMarked;
- (BOOL)isDefined;

@end

