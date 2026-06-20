//
// AmigaOS CPP Examples
//
// (c) 2023-2024 TDolphin
//

#include <exec/libraries.h>

class AmiSSLMasterBaseScope
{
  public:
    AmiSSLMasterBaseScope();
    ~AmiSSLMasterBaseScope();

    Library *get() const;
};
