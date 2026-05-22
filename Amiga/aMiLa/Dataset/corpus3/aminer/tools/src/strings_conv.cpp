#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <fstream>

#include "../../src/msg.h"
#include "../../deps/ACE/tools/src/common/endian.h"
#include "lang_dom.h"
#include "string_array.h"
#include "utf8_remap.h"
#include "json.h"
#include "jsmn.h"

const tCodeRemap g_pRemap[] = {
	{323, 145}, // "Ń"
	{377, 144}, // "Ź"
	{260, 143}, // "Ą"
	{346, 142}, // "Ś"
	{280, 141}, // "Ę"
	{262, 140}, // "Ć"
	{321, 139}, // "Ł"
	{211, 138}, // "Ó"
	{379, 137}, // "Ż"
	{324, 136}, // "ń"
	{378, 135}, // "ź"
	{261, 134}, // "ą"
	{347, 133}, // "ś"
	{281, 132}, // "ę"
	{263, 131}, // "ć"
	{322, 130}, // "ł"
	{243, 129}, // "ó"
	{380, 128}, // "ż"
	{169, 169}, // "©"
	{0, 0} // Terminator
};

char **g_pMsgs;

int main(int lArgCount, const char *pArgs[]) {

	if(lArgCount != 3) {
		printf("Usage: %s infile.json outfile.str", pArgs[0]);
		return EXIT_FAILURE;
	}

	auto InPath = pArgs[1];
	tJson *pJson = jsonCreate(InPath);
	if(pJson == nullptr) {
		std::printf("ERR: %s not found\n", InPath);
		return EXIT_FAILURE;
	}

	g_pMsgs = stringArrayCreateFromDomElements(pJson, g_pRemap, g_pLangDom);
	jsonDestroy(pJson);

	std::ofstream FileOut;
	FileOut.open(pArgs[2], std::ios::binary);
	if(!FileOut.good()) {
		printf("ERR: Can't file output file at '%s'", pArgs[2]);
		return EXIT_FAILURE;
	}

	std::uint16_t uwCountBe = nEndian::toBig16(tMsg::MSG_COUNT);
	FileOut.write(reinterpret_cast<const char*>(&uwCountBe), sizeof(uwCountBe));
	for(auto i = 0; i < tMsg::MSG_COUNT; ++i) {
		std::uint16_t uwLength = strlen(g_pMsgs[i]);
		if(uwLength > 255) {
			std::printf("ERR: msg %d length %hu is too long: '%s'", i, uwLength, g_pMsgs[i]);
			return EXIT_FAILURE;
		}
		std::uint8_t ubLength = std::uint8_t(uwLength);
		FileOut.write(reinterpret_cast<const char*>(&ubLength), sizeof(ubLength));
		FileOut.write(g_pMsgs[i], ubLength);
	}
	FileOut.close();
	stringArrayDestroy(g_pMsgs);

	printf("All done!\n");
	return EXIT_SUCCESS;
}
