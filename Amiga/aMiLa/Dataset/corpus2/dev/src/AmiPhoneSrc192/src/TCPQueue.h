#ifndef TCPQUEUE_H
#define TCPQUEUE_H

/* Setup/shutdown queue data */
BOOL SetupTCPQueue(int nQNum, BOOL BSetup);

/* Copy given buffer and store it in our queue */
BOOL QueueTCPData(int nQNum, UBYTE * pubData, ULONG ulLen);

/* Send as much data as we can */
int ReduceTCPQueue(int nQNum, LONG sSocket);

/* Returns current length of queue */
int TCPQueueLength(int nQNum);
int TCPQueueBytes(int nQNum);

/* Dumps all the data out of the queue */
void FlushTCPQueue(int nQNum);

/* Attempts to send or queues data */
int AttemptTCPSend(LONG sSendSocket, int nQNum, UBYTE * data, ULONG ulDataLen);

#endif 
