
The code:
---------------------------------------------------------------------------

/*
    true if midi data was received.
    false if no midi data was received.

    other_signals contain the signal mask for received signals.
*/
ULONG ReceiveMidiData(ULONG *other_signals)
{
    struct IOExtSer *ioextser = si->serialio;
    register ULONG serialmask = (1L << si->msgport->mp_SigBit);
    register ULONG bits;
    ULONG buffered;
    ULONG i;

    data_ready = 0;

    while (1)
    {
        GetStamp(&timestamp);

        ioextser->IOSer.io_Command = SDCMD_QUERY;
        ioextser->IOSer.io_Flags   = IOF_QUICK;
        BeginIO((struct IORequest *)ioextser);

        if(!(ioextser->IOSer.io_Flags & IOF_QUICK))
        {
            bits = Wait(*other_signals | serialmask);

            GetStamp(&timestamp);

            if (bits & serialmask)
            {
                WaitIO((struct IORequest *)ioextser);
            }
            else
            {
                AbortIO((struct IORequest *)ioextser);
                WaitIO((struct IORequest *)ioextser);
                *other_signals = bits & (~serialmask);
                return(data_ready);
            }
        }

        if ((buffered = ioextser->IOSer.io_Actual) == 0)
        {
            if (data_ready)
            {
                *other_signals = 0L;
                return data_ready;
            }

            GetStamp(&timestamp);

            ioextser->IOSer.io_Command = CMD_READ;
            ioextser->IOSer.io_Length  = 1;
            ioextser->IOSer.io_Data    = (APTR)serialbuffer;
            SendIO((struct IORequest *)ioextser);

            bits = Wait(*other_signals | serialmask);

            GetStamp(&timestamp);

            if (bits & serialmask)
            {
                WaitIO((struct IORequest *)ioextser);
                pb_byte = serialbuffer[0];
                (*ProcessByte)();
            }
            else
            {
                AbortIO((struct IORequest *)ioextser);
                WaitIO((struct IORequest *)ioextser);
                *other_signals = bits & (~serialmask);
                return(data_ready);
            }
        }
        else // bytes in queue
        {
            ioextser->IOSer.io_Command = CMD_READ;
            ioextser->IOSer.io_Flags   = IOF_QUICK;
            ioextser->IOSer.io_Length  =
buffered>serialbuffersize?serialbuffersize:buffered;
            ioextser->IOSer.io_Data    = (APTR)serialbuffer;
            BeginIO((struct IORequest *)ioextser);

            if(!(ioextser->IOSer.io_Flags & IOF_QUICK))
            {
                bits = Wait(*other_signals | serialmask);
    
                GetStamp(&timestamp);
    
                if (bits & serialmask)
                {
                    WaitIO((struct IORequest *)ioextser);
                }
                else
                {
                    AbortIO((struct IORequest *)ioextser);
                    WaitIO((struct IORequest *)ioextser);
                    *other_signals = bits & (~serialmask);
                    return(data_ready);
                }
            }

            for(i=0;i<ioextser->IOSer.io_Actual;i++)
            {
                pb_byte = serialbuffer[i];
                (*ProcessByte)();
            }
        }
    }
}

---------------------------------------------------------------------------

