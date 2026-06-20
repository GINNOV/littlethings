/*
 *  user_strings_morphos.cpp - MorphOS specific localizable strings
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *                  2005 Ilkka Lehtoranta
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "sysdeps.h"
#include "user_strings.h"


// Platform-specific string definitions
const user_string_def platform_strings[] = {
	// Common strings that have a platform-specific variant
	{STR_VOLUME_IS_MOUNTED_WARN, "The volume '%s' is mounted under MorphOS. Basilisk II will try to unmount it."},
	{STR_EXTFS_CTRL, "MorphOS Root"},
	{STR_EXTFS_NAME, "MorphOS Directory Tree"},
	{STR_EXTFS_VOLUME_NAME, "MorphOS"},

	// Purely platform-specific strings
	{STR_NO_TIMER_DEV_ERR, "Cannot open timer.device."},

	{STR_NOT_ETHERNET_WARN, "The selected network device is not an Ethernet device. Networking will be disabled."},
	{STR_NO_MULTICAST_WARN, "Your Ethernet card does not support multicast and is not usable with AppleTalk. Please report this to the manufacturer of the card."},
	{STR_NOT_ENOUGH_MEM_WARN, "Could not get %lu MBytes of memory.\nShould I use the largest Block (%lu MBytes) instead ?"},

	{STR_SCSI_DEVICES_CTRL, "Virtual SCSI Devices"},

	{-1, NULL}	// End marker
};


/*
 *  Fetch pointer to string, given the string number
 */

const char *GetString(int num)
{
	// First search for platform-specific string
	int i = 0;
	while (platform_strings[i].num >= 0) {
		if (platform_strings[i].num == num)
			return platform_strings[i].str;
		i++;
	}

	// Not found, search for common string
	i = 0;
	while (common_strings[i].num >= 0) {
		if (common_strings[i].num == num)
			return common_strings[i].str;
		i++;
	}
	return NULL;
}
