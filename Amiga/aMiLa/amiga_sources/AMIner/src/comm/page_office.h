/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _COMM_PAGE_OFFICE_H_
#define _COMM_PAGE_OFFICE_H_

#include <comm/comm.h>
#include <comm/gs_shop.h>

#define PAGE_OFFICE_SUBPAGES_PER_PERSON 10

void pageOfficeReset(void);

void pageOfficeSave(tFile *pFile);

UBYTE pageOfficeLoad(tFile *pFile);

void pageOfficeResetSelection(void);

void pageOfficeShow(void);

void pageOfficeUnlockPerson(tFaceId ePerson);

void pageOfficeLockPerson(tFaceId ePerson);

UBYTE pageOfficeHasPerson(tFaceId ePerson);

void pageOfficeLockPersonSubpage(tFaceId ePerson, tCommShopPage eSubpage);

UBYTE pageOfficeTryUnlockPersonSubpage(tFaceId ePerson, tCommShopPage eSubpage);

const tCommShopPage *officeGetPagesForFace(tFaceId eFace);

#endif // _COMM_PAGE_OFFICE_H_
