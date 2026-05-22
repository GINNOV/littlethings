
#ifndef BROWSE_H
#define BROWSE_H

__geta4 void BrowserMain(void);

void StopBrowser(void);
void StartBrowser(char * szMessageDirArg);
BOOL BrowserIsRunning(void);
void StopPlayer (struct MsgPort * ReplyPort);      

#endif
