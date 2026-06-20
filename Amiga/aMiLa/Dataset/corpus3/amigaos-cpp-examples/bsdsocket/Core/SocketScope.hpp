//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

#include <exec/libraries.h>

class SocketScope
{
    long mSocket;

  public:
    SocketScope(const long domain, const long type, const long protocol);
    ~SocketScope();

    long get() const
    {
        return mSocket;
    }
};
