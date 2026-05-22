#include "page_msg.h"
#include <ace/managers/system.h>
#include <ace/utils/string.h>
#include <comm/comm.h>
#include "../utf8.h"
#include "../defs.h"
#include "../core.h"
#include "../language.h"
#include "../assets.h"
#include "../msg.h"
#include "../game.h"

#define LINES_MAX 100
#define LINES_OCCUPIED_BY_FACE 3

static char *s_pLines[LINES_MAX] = {0};
static const char *s_szTitle;
static UWORD s_uwLineCount;
static UBYTE s_ubCurrPage, s_ubPageCount;
static tFaceId s_eFace;
static tOnClose s_cbOnClose;

static const char * const s_pFaceToPrefix[FACE_ID_COUNT + 1] = {
	[FACE_ID_MIETEK] = "mietek_",
	[FACE_ID_KRYSTYNA] = "krystyna_",
	[FACE_ID_KOMISARZ] = "komisarz_",
	[FACE_ID_URZEDAS] = "urzedas_",
	[FACE_ID_ARCH] = "arch_",
	[FACE_ID_PRISONER] = "prisoner_",
	[FACE_ID_AGENT] = "agent_",
	[FACE_ID_SCIENTIST] = "sci_",
	[FACE_ID_CRYO] = "cryo_",
	[FACE_ID_JAY] = "jay_",
	[FACE_ID_RADIO] = "radio_",
	[FACE_ID_COUNT] = "",
};

static void freeLines(void) {
	while(s_uwLineCount--) {
		memFree(s_pLines[s_uwLineCount], strlen(s_pLines[s_uwLineCount]) + 1);
	}
	s_uwLineCount = 0;
	s_ubCurrPage = 0;
	s_ubPageCount = 0;
}

static void readLines(
	const tCodeRemap *pRemap, const char *szFilePath, UWORD uwMaxLineWidth
) {
	systemUse();
	logBlockBegin(
		"readLines(pRemap: %p, szFilePath: '%s', uwMaxLineWidth: %hu)",
		pRemap, szFilePath, uwMaxLineWidth
	);
	freeLines();

	UWORD uwFileContentsBufferSize;
	UWORD uwTextLength;
	char *szFileContents = remapFile(
		szFilePath, pRemap, &uwFileContentsBufferSize, &uwTextLength
	);
	if(!szFileContents) {
		systemUnuse();
		return;
	}

	// Split text into lines
	UWORD uwPos = 0;
	do {
		UBYTE ubLineLength = commBreakTextToWidth(
			&szFileContents[uwPos], uwMaxLineWidth
		);
		s_pLines[s_uwLineCount] = memAllocFast(ubLineLength + 1);
		memcpy(s_pLines[s_uwLineCount], &szFileContents[uwPos], ubLineLength);
		s_pLines[s_uwLineCount][ubLineLength] = '\0';

		if(s_pLines[s_uwLineCount][ubLineLength - 1] == '\n') {
			s_pLines[s_uwLineCount][ubLineLength - 1] = ' ';
		}

		++s_uwLineCount;
		uwPos += ubLineLength;
	} while(uwPos < uwTextLength);

	if(s_uwLineCount >= LINES_MAX) {
		logWrite("ERR: line count %hu >= LINES MAX %d", s_uwLineCount, LINES_MAX);
	}

	memFree(szFileContents, uwFileContentsBufferSize);
	UBYTE ubLineHeight = commGetLineHeight() - 1;
	UBYTE ubLinesPerPage = COMM_DISPLAY_HEIGHT / ubLineHeight - 1; // skip 1 for  page count
	WORD wLinesInNextPages = s_uwLineCount - (ubLinesPerPage - LINES_OCCUPIED_BY_FACE);
	wLinesInNextPages = MAX(0, wLinesInNextPages);
	s_ubPageCount = 1 + ((UWORD)wLinesInNextPages + ubLinesPerPage - 1) / ubLinesPerPage; // always add first smaller page

	logBlockEnd("readLines()");
	systemUnuse();
}

static void commMsgDrawCurrentPage(void) {
	UBYTE ubLineHeight = commGetLineHeight() - 1; // keep it more concise here
	UBYTE ubLinesPerPage = COMM_DISPLAY_HEIGHT / ubLineHeight - 1;
	UWORD uwLineStart = MAX(0, s_ubCurrPage * ubLinesPerPage - 3);
	commEraseAll();
	UWORD uwLineY = 0;

	if(s_ubCurrPage == 0) {
		if(s_eFace != FACE_ID_COUNT) {
			commDrawFaceAt(s_eFace, 0, 0);
			commDrawTitle(48, 0, g_pMsgs[MSG_PAGE_LIST_MIETEK + s_eFace]);
			if(!stringIsEmpty(s_szTitle)) {
				commDrawText(48, ubLineHeight, s_szTitle, FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT);
			}
		}
		else {
			if(!stringIsEmpty(s_szTitle)) {
				commDrawText(
					(COMM_DISPLAY_WIDTH - fontMeasureText(g_pFont, s_szTitle).uwX) / 2,
					ubLineHeight, s_szTitle, FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT
				);
			}
		}
		uwLineY = LINES_OCCUPIED_BY_FACE * ubLineHeight;
		ubLinesPerPage -= LINES_OCCUPIED_BY_FACE;
	}

	for(
		UWORD i = uwLineStart;
		i < uwLineStart + ubLinesPerPage && i < s_uwLineCount; ++i
	) {
		commDrawText(
			0, uwLineY, s_pLines[i], FONT_COOKIE | FONT_SHADOW,
			COMM_DISPLAY_COLOR_TEXT
		);
		uwLineY += ubLineHeight;
	}
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hhu/%hhu", s_ubCurrPage + 1, s_ubPageCount);
	commDrawText(
		COMM_DISPLAY_WIDTH / 2, COMM_DISPLAY_HEIGHT, gameGetMessageBuffer(),
		FONT_HCENTER | FONT_BOTTOM | FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT_DARK
	);
}

static void pageMsgProcess(void) {
	if(commNavExUse(COMM_NAV_EX_BTN_CLICK) || commNavUse(DIRECTION_DOWN)) {
		if(s_ubCurrPage < s_ubPageCount - 1) {
			++s_ubCurrPage;
			commMsgDrawCurrentPage();
		}
		else {
			if(s_cbOnClose) {
				s_cbOnClose();
			}

			return;
		}
	}

	if(s_ubCurrPage > 0 && commNavUse(DIRECTION_UP)) {
		--s_ubCurrPage;
		commMsgDrawCurrentPage();
	}
}

static void pageMsgDestroy(void) {
	systemUse();
	freeLines();
	systemUnuse();
}

void pageMsgCreate(
	tFaceId eFace, const char *szTitle, const char *szFile, tOnClose cbOnClose
) {
	logBlockBegin(
		"pageMsgCreate(eFace: %d, szTitle: '%s', szfile: '%s', cbOnClose: %p)",
		eFace, szTitle, szFile, cbOnClose
	);
	commRegisterPage(pageMsgProcess, pageMsgDestroy);
	s_eFace = eFace;
	s_szTitle = szTitle;
	s_cbOnClose = cbOnClose;
	s_uwLineCount = 0;
	char szPath[100];
	sprintf(szPath, SUBFILE_PREFIX "txt_%s/%s%s.txt", languageGetPrefix(), s_pFaceToPrefix[eFace],  szFile);
	readLines(g_pRemap, szPath, COMM_DISPLAY_WIDTH);

	s_ubCurrPage = 0;
	commMsgDrawCurrentPage();
	logBlockEnd("pageMsgCreate()");
}
