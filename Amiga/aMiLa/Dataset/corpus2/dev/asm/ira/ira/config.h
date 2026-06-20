/*
 * config.h
 *
 *  Created on: 8 may 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : config.h
 *      Purpose  : Headers for config file
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2024 Frank Wille, (C)2014-2016 Nicolas Bastien
 */

#ifndef CONFIG_H_
#define CONFIG_H_

void CheckEquateName(char *, uint16_t);
void CNFAreaToCodeArea(ira_t *);
void CreateConfig(ira_t *);
uint32_t GetAddress(char *, uint16_t);
char *GetFullLine(char *, FILE *);
void InsertBanner(ira_t *, uint32_t, char *);
void InsertComment(ira_t *, uint32_t, char *);
void InsertEquate(ira_t *, char *, uint32_t, int);
void InsertExtsym(ira_t *, char *, uint32_t);
void InsertCNFArea(ira_t *, uint32_t, uint32_t);
void InsertJmpTabArea(ira_t *, int, uint32_t, uint32_t, uint32_t);
void InsertNoBaseArea(ira_t *, uint32_t, uint32_t);
void InsertNoPointersArea(ira_t *, uint32_t, uint32_t);
void InsertTextArea(ira_t *, uint32_t, uint32_t);
void PreparseConfig(ira_t *);
void ReadConfig(ira_t *);

#endif /* CONFIG_H_ */
