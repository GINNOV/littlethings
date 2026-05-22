#
# Copyright (C) 1989  Mike Meyer
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

CFLAGS = -Asr -O

OBJS = main.o treewalk.o filter.o magic.o

treewalk: $(OBJS)
	cc $(CFLAGS) -o treewalk $(OBJS)

# Test version of the treewalk routine.
treetest: treewalk.c treewalk.h
	cc -g -DTEST treewalk.c -o treetest

# willfit command based on treewalkk
willfit: willfit.o treewalk.o lib:s-expand.o
	cc $(CFLAGS) -o willfit lib:s-expand.o willfit.o treewalk.o

willfit.o main.o treewalk.o: treewalk.h

clean:
	rm $(OBJS) treewalk du.o
