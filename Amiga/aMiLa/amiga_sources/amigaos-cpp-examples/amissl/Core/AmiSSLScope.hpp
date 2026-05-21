//
// AmigaOS CPP Examples
//
// (c) 2023-2024 TDolphin
//

#include "../../bsdsocket/Core/BSDSocketBaseScope.hpp"
#include "AmiSSLMasterBaseScope.hpp"

#include <openssl/types.h>

class AmiSSLScope
{
    BSDSocketBaseScope mBSDSocketBaseScope;
    AmiSSLMasterBaseScope mAmiSSLMasterBaseScope;

    SSL_CTX *mpSSLContext;

  public:
    AmiSSLScope();
    ~AmiSSLScope();

    Library *get() const;

    SSL_CTX *SSLContext() const
    {
        return mpSSLContext;
    }
};
