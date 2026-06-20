//
// AmigaOS CPP Examples
//
// (c) 2023-2024 TDolphin
//

//
// amisslmaster.library scope
// opens on constructor, closes on destructor
// throws exception if library is already open or on error opening library
//

#include "AmiSSLMasterBaseScope.hpp"

#include <stdexcept>

#include <libraries/amisslmaster.h>
#include <proto/exec.h>

#define AMISSLMASTERNAME "amisslmaster.library"

struct Library *AmiSSLMasterBase = nullptr;

AmiSSLMasterBaseScope::AmiSSLMasterBaseScope()
{
    if (AmiSSLMasterBase != nullptr)
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " " + AMISSLMASTERNAME + " already open!";
        throw std::runtime_error(error);
    }

    if (!(AmiSSLMasterBase = OpenLibrary(AMISSLMASTERNAME, AMISSLMASTER_MIN_VERSION)))
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " failed to open " + AMISSLMASTERNAME + " min version "
            + std::to_string(AMISSLMASTER_MIN_VERSION) + "!";
        throw std::runtime_error(error);
    }
}

AmiSSLMasterBaseScope::~AmiSSLMasterBaseScope()
{
    if (AmiSSLMasterBase != nullptr)
    {
        CloseLibrary(AmiSSLMasterBase);
        AmiSSLMasterBase = nullptr;
    }
}

Library *AmiSSLMasterBaseScope::get() const
{
    return AmiSSLMasterBase;
}
