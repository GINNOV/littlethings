
#include <stdio.h>
#include <clib/asl_protos.h>
#ifdef REGARGS
#   include <pragmas/asl_pragmas.h>
#endif

APTR AllocAslRequest (ULONG type,struct TagItem * ptags)
{
    APTR ret;

    if ( (ret = AllocAslRequest (type,ptags)) != NULL)
	CHECK_ADD_RN1(RTL_ASL,RTLRT_AslRequest,type)

    return (ret);
} /* AllocAslRequest */



APTR AllocAslRequestTAGS (ULONG type, ...)
{
    APTR ret;

    if ( (ret = AllocAslRequestTAGS (type,...)) )
	CHECK_ADD_RN1(RTL_ASL,RTLRT_AslRequest,type)

    return (ret);
} /* AllocAslRequestTAGS */



struct FileRequester * AllocFileRequest (ULONG type)
{
    struct FileRequester * ret;

    if ( (ret = AllocFileRequest (type)) )
	CHECK_ADD_RN1(RTL_ASL,RTLRT_AslRequest,-)

    return (ret);
} /* AllocFileRequest */








