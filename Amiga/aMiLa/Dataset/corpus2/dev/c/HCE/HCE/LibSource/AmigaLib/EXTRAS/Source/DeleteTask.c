#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/memory.h>

void DeleteTask (tc)
struct Task *tc;
{
    RemTask(tc);
}
