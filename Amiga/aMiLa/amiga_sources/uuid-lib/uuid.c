/* genuuid */
/* gcc -o uuid uuid.c -Iinclude
*/

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/uuid.h>
#include <stdio.h>
#include <string.h>

struct UuidBase *UuidBase;
struct UuidIFace *IUuid;

UNUSED char *ver = "\0$VER:uuid 1.1 (21.10.2018)\0";

int main(int argc, char **argv)
{
	ULONG ver = 1;
	ULONG cnt = 1;
	char *name = NULL;
	char *namespace = NULL;
	LONG rarray[] = {0, 0, 0, 0};
	struct RDArgs *args;
	STRPTR template = "-v=VER/K/N,-n=NUM/K/N,UUID=NAMESPACE,NAME";

	enum
	{
		A_VERSION,
		A_COUNT,
		A_NAMESPACE,
		A_NAME
	};
	
	UuidBase = IExec->OpenLibrary("uuid.library", 1L);
	if(UuidBase) {
		IUuid = (struct UuidIFace *)IExec->GetInterface(UuidBase, "main", 1, NULL);
		if (!IUuid) {
			IExec->DropInterface(IUuid);
			printf("uuid (c) 2018 Chris Young <chris@unsatisfactorysoftware.co.uk>\n\nUnable to open uuid.library\n\n");
			return 5;
		}
	} else {
		printf("uuid (c) 2018 Chris Young <chris@unsatisfactorysoftware.co.uk>\n\nUnable to open uuid.library\n\n");
		return 5;
	}

	if(argc != 0) {
		// cli startup

		args = IDOS->ReadArgs(template,rarray,NULL);

		if(args) {
			if(rarray[A_VERSION]) {
				ver = *(ULONG *)rarray[A_VERSION];
			}

			if(rarray[A_COUNT]) {
				cnt = *(ULONG *)rarray[A_COUNT];
			}

			if(rarray[A_NAMESPACE])
				namespace = strdup((char *)rarray[A_NAMESPACE]);

			if(rarray[A_NAME])
				name = strdup((char *)rarray[A_NAME]);

			IDOS->FreeArgs(args);
		} else {
			return 5;
		}
	}


	void *uuid_ns = NULL;
	void *uuid = NULL;
	int i = 0;
	
	for(i = 0; i < cnt; i++) {
	
		if(ver == 5) {
			uuid_ns = IUuid->Uuid(UUID_String, namespace,
							TAG_DONE);
							
	//		uuid_ns = IUuid->Uuid(UUID_Preset, UUID_NS_DNS,
	//						TAG_DONE);
		
			uuid = IUuid->Uuid(UUID_Version, ver,
							UUID_Namespace, uuid_ns,
							UUID_Name, name,
							TAG_DONE);
		} else {
			uuid = IUuid->Uuid(UUID_Version, ver,
							TAG_DONE);
		}
							
		char str[37];

		if(uuid_ns != NULL) {
	//		IUuid->UuidToText(uuid_ns, str);
			IUuid->FreeUuid(uuid_ns);
		}

		if(uuid != NULL) {
			IUuid->UuidToText(uuid, str);

			printf("%s\n", str);
			
			IUuid->FreeUuid(uuid);
		} else {
			printf("uuid (c) 2018 Chris Young <chris@unsatisfactorysoftware.co.uk>\n\nUnable to generate UUID.\n\n-v=VER/K/N must be 1, 4 or 5.\nFor version 5, UUID=NAMESPACE must be specified and be a valid UUID, and NAME must also be provided.\n\n");
			break;
		}
	}

	if(name != NULL) free(name);
	if(namespace != NULL) free(namespace);

	IExec->DropInterface(IUuid);
	IExec->CloseLibrary(UuidBase);

	return 0;
}
