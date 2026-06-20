
#include "freedb.h"

/***********************************************************************/

struct FREEDBS_TrackInfo emptyTrack;

/***********************************************************************/

APTR SAVEDS ASM
FreeDBAllocObjectA(REG(d0) ULONG type,REG(a0) struct TagItem * attrs)
{
    register struct FREEDBS_Object  *obj;
    register APTR                   pool;
    register ULONG                  flags, size;

    pool  = NULL;
    flags = 0;

    switch (type)
    {
        case FREEDBV_AllocObject_DiscInfoTOC:
            if (!(pool = CreatePool(MEMF_PUBLIC|MEMF_CLEAR,1024,256))) return NULL;
            size = sizeof(struct FREEDBS_DiscInfo)+sizeof(struct FREEDBS_TOC);
            break;

        case FREEDBV_AllocObject_DiscInfo:
            if (!(pool = CreatePool(MEMF_PUBLIC|MEMF_CLEAR,1024,256))) return NULL;
            size = sizeof(struct FREEDBS_DiscInfo);
            break;

        case FREEDBV_AllocObject_TOC:
            size = sizeof(struct FREEDBS_TOC);
            break;

        default:
            return NULL;
            break;
    }

    if (!(obj = pool ? AllocVecPooled(pool,size+sizeof(struct FREEDBS_Object)) :
                       allocArbitratePooled(size+sizeof(struct FREEDBS_Object))))
    {
        if (pool) DeletePool(pool);
        return NULL;
    }

    obj->pool  = pool;
    obj->type  = type;
    obj->size  = size;
    obj->flags = flags;

    return &obj->mem;
}

/***********************************************************************/

void SAVEDS ASM
FreeDBClearObject(REG(a0) APTR m)
{
    register struct FREEDBS_Object  *obj = FREEDBM_OBJ(m);
    register ULONG                  size = obj->size;

    switch (obj->type)
    {
        case FREEDBV_AllocObject_DiscInfo:
        case FREEDBV_AllocObject_DiscInfoTOC:
        {
            register struct FREEDBS_DiscInfo    *di = (struct FREEDBS_DiscInfo *)m;
            register APTR                   pool = obj->pool;
            register int                    i;

            if (di->header) FreeVecPooled(pool,di->header);
            if (di->extd) FreeVecPooled(pool,di->extd);

            for (i = 0; i<FREEDBV_MAXTRACKS; i++)
            {
                if (di->tracks[i] && di->tracks[i]!=&emptyTrack)
                {
                    if (di->tracks[i]->extd) FreeVecPooled(pool,di->tracks[i]->extd);
                    FreeVecPooled(pool,di->tracks[i]);
                }
            }

            memset(di,0,size);

            break;
        }

        case FREEDBV_AllocObject_TOC:
            memset(m,0,size);
            break;

        default:
            break;
    }
}

/***********************************************************************/

void SAVEDS ASM
FreeDBFreeObject(REG(a0) APTR m)
{
    register struct FREEDBS_Object  *obj = FREEDBM_OBJ(m);
    register APTR                   pool = obj->pool;

    if (pool) DeletePool(pool);
    else
    {
        switch (obj->type)
        {
            case FREEDBV_AllocObject_TOC:
                freeArbitratePooled(obj,obj->size+sizeof(struct FREEDBS_Object));
                break;

            default:
                break;
        }
    }
}

/***********************************************************************/
