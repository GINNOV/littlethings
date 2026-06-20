This code is provided as-is, for instructional purposes only.  You may 
redistribute it or use it as you like, but by doing so you hold the authors
and distributors harmless for any damages it may cause.  This code is 
Copyright (c) 1994-1995 Doug Walker, All Rights Reserved.

Here are two functions that will mount and dismount a volume node in the 
DOS list, assigning all incoming messages to a specific port OTHER THAN the
one in the Task structure.

If you are writing a handler, this gives the following advantages:

   1. No need for mountlist entries or using Mount to mount your file 
      system - use configuration files instead.
   
   2. You can run as a normal process instead of a Task, which means you 
      can use your normal debugger, printf(), stdin, stdout, etc. and the
      user can start your handler from WorkBench or Shell like any other
      program.

I recommend that you use the cback.o startup to detach your handler from
the shell that invoked it.

The following two functions are provided:

   struct DeviceList *Mount(char *name, struct MsgPort *port);

      Mounts a volume with the given name and assigns all incoming DOS 
      packets to the specified MsgPort.

   int DisMount(struct DeviceList *volume);

      Dismounts a volume, given a pointer to its volume node.  Must be a 
      volume that was mounted with Mount().

If you have SAS/C, simply enter this directory in the Shell and type 
"scsetup" followed by "smake" to compile and link the test program.  This 
distribution consists of four files:

   test.c     - Test program.
   mount.h    - Prototypes for Mount() and DisMount().
   mount.c    - Version of Mount() and DisMount() that works on any 
                version of AmigaDOS
   mountv37.c - Version of Mount() and DisMount() for version 37 and up 
                (AmigaDOS 2.0 and above)

When you use smake, it links a program called "test" and one called 
"testv37".  The latter is linked with mountv37.c and will only work on 
AmigaDOS 2.0 and above.

To run the test program, type "test foo".  This will mount a volume node
called "foo".  The test program will print any packets that it receives,
then immediately reject them with an ERROR_ACTION_NOT_KNOWN response.
Packet type 8 is a LOCK packet; if you are running WorkBench, you'll see
one of these come up every so often as WorkBench tries to figure out what
the new volume is.

You can send other packets as well.  Try opening another Shell and doing a
COPY command to foo:

   COPY s:startup-sequence to FOO:

You'll see some new packet types as COPY attempts to open a file in your
FOO: device.  (The copy will fail, of course).  If you are writing a
handler, you should find a copy of PickPacket, written by Doug Walker and
John Toebes.  This testing utility lets you generate and send any packet
type you like, as long as it existed when PickPacket was written (!).
PickPacket is on Fred Fish disk #227.

IMPORTANT NOTE: The test program isn't designed perfectly; it's a 
proof-of-principle, but it does have some multitasking "holes" in it.
Writing a good handler is left as an exercise for the reader 8^)

Happy programming!

   --Doug Walker
