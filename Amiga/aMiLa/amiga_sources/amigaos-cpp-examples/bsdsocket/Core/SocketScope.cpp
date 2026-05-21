//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

//
// bsdsocket.libraray/socket scope
// create an endpoint for communication on, closes socket on destructor
// throws exception on error
//

#include "SocketScope.hpp"

#include <stdexcept>

#include <proto/bsdsocket.h>

SocketScope::SocketScope(const long domain, const long type, const long protocol)
{
    mSocket = socket(domain, type, protocol);
    if (mSocket == -1)
    {
        std::string error = (std::string) __PRETTY_FUNCTION__ + " failed to create socket (domain: " + std::to_string(domain)
            + ", type:" + std::to_string(type) + " protocol: " + std::to_string(protocol) + ")!";
        throw std::runtime_error(error);
    }
}

SocketScope::~SocketScope()
{
    if (mSocket != -1)
        CloseSocket(mSocket);
}
