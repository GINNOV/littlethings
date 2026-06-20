#include "input.h"

/* Globals */

/* Functions */
void inputOpen() {
	mouseOpen();
	joyOpen();
}

void inputProcess() {
	ULONG ulWindowSignal;
	ULONG ulSignals;
	struct IntuiMessage *pMsg;

	ulWindowSignal = 1L << g_sWindowManager.pWindow->UserPort->mp_SigBit;
	ulSignals = SetSignal(0L, 0L);

	if (ulSignals & ulWindowSignal) {
		while (pMsg = (struct IntuiMessage *) GetMsg(g_sWindowManager.pWindow->UserPort)) {
			ReplyMsg((struct Message *) pMsg);

			switch (pMsg->Class) {
				case IDCMP_RAWKEY:
					if (pMsg->Code & IECODE_UP_PREFIX) {
						pMsg->Code -= IECODE_UP_PREFIX;
						
						keySetState(pMsg->Code, KEY_NACTIVE);
					}
					else if (!keyCheck(pMsg->Code)) {
						keySetState(pMsg->Code, KEY_ACTIVE);
					}
					break;
				case IDCMP_MOUSEBUTTONS:
					if (pMsg->Code & IECODE_UP_PREFIX) {
						pMsg->Code -= IECODE_UP_PREFIX;
						
						mouseSetState(pMsg->Code, MOUSE_NACTIVE);
					}
					else if (!mouseCheck(pMsg->Code)) {
						mouseSetState(pMsg->Code, MOUSE_ACTIVE);
					}
					break;
			}
		}
	}

	joyProcess();
}

void inputClose() {
	mouseClose();
	joyClose();
}