//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

#include <exec/libraries.h>

class BSDSocketBaseScope
{
  public:
    BSDSocketBaseScope();
    ~BSDSocketBaseScope();

    Library *get() const;
};
