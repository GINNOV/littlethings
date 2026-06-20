struct PPCDispatchMsg {
    long (*func)(long r3, long r4, long r5, long r6, long r7, long r8,
                 long r9, long r10);
    long r3;
    long r4;
    long r5;
    long r6;
    long r7;
    long r8;
    long r9;
    long r10;
};

struct StartupData {
    void *MsgPort;
};



long DispatchFunction(void);
long CallPPCFunction(void *, ...);
