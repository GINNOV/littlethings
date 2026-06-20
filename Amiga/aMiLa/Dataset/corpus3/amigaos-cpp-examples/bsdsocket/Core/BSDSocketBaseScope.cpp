//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

//
// bsdsocket.libraray scope
// opens on constructor, closes on destructor
// throws exception if library is already open or on error opening library
//

#include "BSDSocketBaseScope.hpp"

#include <stdexcept>

#include <clib/socket_protos.h>
#include <proto/exec.h>

struct Library *SocketBase = nullptr;

BSDSocketBaseScope::BSDSocketBaseScope()
{
    if (SocketBase != nullptr)
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " " + SOCKETNAME + " already open!";
        throw std::runtime_error(error);
    }

    if (!(SocketBase = OpenLibrary(SOCKETNAME, 4)))
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " failed to open " + SOCKETNAME;
        throw std::runtime_error(error);
    }
}

BSDSocketBaseScope::~BSDSocketBaseScope()
{
    if (SocketBase != nullptr)
    {
        CloseLibrary(SocketBase);
        SocketBase = nullptr;
    }
}

Library *BSDSocketBaseScope::get() const
{
    return SocketBase;
}
