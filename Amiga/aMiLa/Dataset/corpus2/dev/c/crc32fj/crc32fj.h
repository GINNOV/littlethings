/* crc32fj.h */

/* Written and copyright 1999 by Finn Yannick Jacobs.
 * No rights were reserved to this, so feel free to do
 * with it, what you want or desire :)
 */

/* when you use chksum_crc32{Filehandle|Block}(), then make
 * sure, you have created the crcTab[] before by chksum_crc32GenTab() !!
 * your crcTab[] _must_ be initialized like this :
 *
 * unsigned long crcTab[256];
 * :
 * chksum_crc32GenTab();
 * :
 *
 * Oh, something to it, make sure, that your crc for the result
 * of the functions _is_ 'unsigned long', otherwise the result-crc's
 * are wrong.
 */


void chksum_crc32GenTab();
unsigned long chksum_crc32Filehandle( FILE *filehandle );
unsigned long chksum_crc32Block( unsigned char *block, unsigned int length );


/* end of crc32fj.h */
