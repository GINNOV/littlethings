/*
 * init.h
 *
 *  Created on: 8 may 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : init.h
 *      Purpose  : Headers for IRA initialization subroutines
 *      Copyright: (C)2014-2016 Nicolas Bastien
 */

#ifndef INIT_H_
#define INIT_H_

#define ASM_EXT ".asm"
#define BIN_EXT ".bin"
#define CONFIG_EXT ".cnf"
#define LABEL_EXT ".label"

void CheckCPU(ira_t *);
char *ExtendFileName(char *, char *);
void Init(ira_t *, int, char **);
void ReadOptions(ira_t *, int, char **, int *, uint16_t *);
ira_t *Start(void);

#endif /* INIT_H_ */
