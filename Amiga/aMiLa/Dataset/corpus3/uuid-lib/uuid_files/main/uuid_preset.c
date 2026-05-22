/* Predefined UUIDs */

#include <proto/exec.h>
#include <stdlib.h>

#include <libraries/uuid.h>
#include "uuid_preset.h"

bool uuid_preset(uuid_t *uuid, int preset)
{
/* pre-defined UUIDs from rfc4122 */

   /* Name string is a fully-qualified domain name */
   uuid_t NameSpace_DNS = { /* 6ba7b810-9dad-11d1-80b4-00c04fd430c8 */
       0x6ba7b810,
       0x9dad,
       0x11d1,
       0x80, 0xb4, {0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8}
   };

   /* Name string is a URL */
   uuid_t NameSpace_URL = { /* 6ba7b811-9dad-11d1-80b4-00c04fd430c8 */
       0x6ba7b811,
       0x9dad,
       0x11d1,
       0x80, 0xb4, {0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8}
   };

   /* Name string is an ISO OID */
   uuid_t NameSpace_OID = { /* 6ba7b812-9dad-11d1-80b4-00c04fd430c8 */
       0x6ba7b812,
       0x9dad,
       0x11d1,
       0x80, 0xb4, {0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8}
   };

   /* Name string is an X.500 DN (in DER or a text output format) */
   uuid_t NameSpace_X500 = { /* 6ba7b814-9dad-11d1-80b4-00c04fd430c8 */
       0x6ba7b814,
       0x9dad,
       0x11d1,
       0x80, 0xb4, {0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8}
   };

   /* NULL */
   uuid_t uuid_null = { /* 00000000-0000-0000-0000-000000000000 */
       0x00000000,
       0x0000,
       0x0000,
       0x00, 0x00, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
   };
   
	switch(preset) {
		case UUID_NULL:
			memcpy(uuid, &uuid_null, sizeof(uuid_t));
		break;
		
		case UUID_NS_DNS:
			memcpy(uuid, &NameSpace_DNS, sizeof(uuid_t));
		break;

		case UUID_NS_URL:
			memcpy(uuid, &NameSpace_URL, sizeof(uuid_t));
		break;

		case UUID_NS_OID:
			memcpy(uuid, &NameSpace_OID, sizeof(uuid_t));
		break;

		case UUID_NS_X500:
			memcpy(uuid, &NameSpace_X500, sizeof(uuid_t));
		break;
	
		default:
			return false;
		break;
	}
	
	return true;
}
