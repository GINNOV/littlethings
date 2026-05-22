//
// AmigaOS CPP Examples
//
// (c) 2023-2024 TDolphin
//

//
// AmiSSL scope (amisslmaster.library & amissl & bsdsocket etc)
// opens & init on constructor, create ssl context, closes on destructor
// throws exception if library is already open or on error opening library
//

#include "AmiSSLScope.hpp"

#include <stdexcept>

#include <libraries/amisslmaster.h>
#include <proto/amissl.h>
#include <proto/amisslmaster.h>
#include <proto/exec.h>

struct Library *AmiSSLBase = nullptr, *AmiSSLExtBase = nullptr;

AmiSSLScope::AmiSSLScope()
{
    if (AmiSSLBase != nullptr)
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " AmiSSL already open!";
        throw std::runtime_error(error);
    }

    if (OpenAmiSSLTags(AMISSL_CURRENT_VERSION, AmiSSL_UsesOpenSSLStructs, FALSE, AmiSSL_GetAmiSSLBase, (unsigned long)&AmiSSLBase,
                       AmiSSL_GetAmiSSLExtBase, (unsigned long)&AmiSSLExtBase, AmiSSL_SocketBase, (unsigned long)mBSDSocketBaseScope.get(),
                       AmiSSL_ErrNoPtr, (unsigned long)&errno, TAG_DONE)
        != 0)
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " failed to open and initialize AmiSSL version "
            + std::to_string(AMISSL_CURRENT_VERSION) + "!";
        throw std::runtime_error(error);
    }

    if (!(mpSSLContext = SSL_CTX_new(TLS_client_method())))
    {
        CloseAmiSSL();
        AmiSSLBase = nullptr;
        throw std::runtime_error("Couldn't create SSL context!");
    }
}

AmiSSLScope::~AmiSSLScope()
{
    if (mpSSLContext != nullptr)
    {
        SSL_CTX_free(mpSSLContext);
        mpSSLContext = nullptr;
    }

    if (AmiSSLBase != nullptr)
    {
        CloseAmiSSL();
        AmiSSLBase = nullptr;
    }
}

Library *AmiSSLScope::get() const
{
    return AmiSSLBase;
}
