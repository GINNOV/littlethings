/*
 * megadrive.h
 *
 *  Created on: 21 sept 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : megadrive.h
 *      Purpose  : Megadrive (Genesis) rom definitions
 *      Copyright: (C)2015-2016 Nicolas Bastien
 */

#ifndef MEGADRIVE_H_
#define MEGADRIVE_H_

#define SMD_BUFFER_SIZE 16384
#define SMD_MID_SIZE 8192

#define NEXT_IN_CYCLE(i) (i < SMD_MID_SIZE ? i * 2 : (i - SMD_MID_SIZE) * 2 + 1)

int BelongToPreviousCycle(int);
void SMD16kBufferInsituTransposition(uint8_t *);

#endif /* MEGADRIVE_H_ */
