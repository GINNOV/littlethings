Portable Object Compiler (c) 1997,98,99,2000,01,02,03,04.  All Rights Reserved.


GETTING HELP
------------

For help and reporting bugs : send email to objc-users@lists.sourceforge.net
(to subscribe : send email to objc-users-request@lists.sourceforge.net)

INSTALL
-------

Read the Install.txt file.

IMPORTANT : if this is a first-time installation, you have to start by installing the bootstrap package; do not install this package until you have installed the bootstrap package.

For every release, there is an objc-x.y.z.tar.gz package and an objc-x.y.z-bootstrap.tar.gz package.

LICENSE
-------

Read the License.txt file (the "GNU Library General Public License").

The license file explains the difference between,

 (a) "software using the Portable Object Compiler", and 
 (b) "software based upon the Portable Object Compiler".


LATEST VERSION
--------------

The latest bootstrap compilers and sources of the Portable Object Compiler
are available at:

	http://sunsite.unc.edu/pub/Linux/devel/lang/objc

Or from my home page at:

	http://users.pandora.be/stes/

WHAT'S INCLUDED
---------------

The "objc" distribution consists of the following parts :

	0. "VICI", interactive Objective-C debugger and interpreter

	1. "objc", the actual compiler

	Consists of driver script ("objc") and binary ("objc1").
	"objc1" is a precompiler for C.
	The binary "postlink" is used
	for preparing tables for runtime initialization.

	2. "objcrt", the Objective C Runtime Library for "objc"

	This is a modern, portable, "all C" Objective C runtime
	There's absolutely no assembly language needed, nor is there
	a dependency on stack layout, register allocation conventions etc.

	Most other runtimes, were derived from pre-"all C"-Stepstone 
	runtimes, so this is an important point of difference.

	3. "objpak", the "Object Pak" Objective C Collection Classes

	Simple, powerful set of classes.  Very portable.
	Can be used to develop with different compilers, then
	port with 'objc'.  Compatible with ICpak101, the collection class
	library described in Brad Cox book, and used by existing
	Objective-C packages that were developed with Stepstone objc.

	4. "cakit", the "Computer Algebra Kit" Objective C classes

	Small, concise, interface to a large set of classes for
	polynomial computing and arbitrary precision integer arithmetic.

	5. Source of compiler and "oclib", a set of Objective C classes for
        parsing C (and the Objective C extensions to C)
  
"objc" and "vici" are written in Objective C itself.  It's all
written in portable Objective C : any Objective C compiler
should be able to compile the "objc" compiler.  From time to time,
we try a configure with other Objective-C compilers, to ensure that our
sources are still compatible with e.g. Stepstone Objective C compiler.

NOT included is a C compiler : in order to be able to use "objc", you will
need to elsewhere find a compatible C compiler.  This should be no problem
since one of our goals - see below - is to make "objc" work with as many C
compilers as possible.  On UNIX systems, the (free) "gcc" compiler is a
possibility (not needed, but possible).  Another possibility, is to use
the (free) "lcc" compiler or the "tcc" TDF compiler system.


NICE FEATURES
-------------

	1.Easy to install or to modify.

	2.Works on many systems with the native cc, debugger, profiler etc.
	(Unix, Windows, Macintosh, Beos, OpenVMS etc. see Platforms.txt file)

	2a. Option for reference counted memory management (-refcnt).
	This uses the native malloc(), free() etc. but the compiler generates
	statements for keeping track of references.
	(Tested on a few platforms, such as IRIX 5.2 with the SGI malloc).

	3.Built-in possibility of tracing Objective C messages. (OBJCRTMSG)

	4.Straightforward "C" messenger; "inline cache" messenger.
	Forwarding C messenger (to support -doesNotUnderstand:).
	
	5.All classes get a +initialize message at start-up, rather than
	'each class receives a +initialize before it receives its first
	message'.

	6.Some support for translating Objective-C to Smalltalk (-st80 option)

	7.Automatic archiver.  Compiler generates code for classes to save
	and load objects to and from disk (for all instance variables of
	type "id").

	8.Option for Garbage Collection (using Boehm gc package).  Tested
	on some UNIXes and WIN32.   Option for reference counted memory
	management (doesn't require Boehm).

	9.Exception handling scheme (using Objective-C Blocks) that allows
	to specify a default handler to be executed.

	10.Supports dynamically loading Objective-C modules on Windows,
	FreeBSD, HP-UX, Linux, IRIX, Digital Unix etc.

	11.Has a switch for double indirection for Object identifiers (id as
	a handle instead of a pointer). (-become: method)

	12.Supports forwarding messages (-doesNotUnderstand: method)

        13.Support for Embedded SQL in Objective-C (Informix only for now)  

	14.Great system for experimentation with your own additions/extensions
	to Objective C !


WANT TO HELP?
-------------

If you like "objc", feel free to send e-mail to, "stes@pandora.be".
I'm especially interested in bug-fixes, of course.  And in ports
to machines that I don't have access to (e.g. CP/M, Atari).

