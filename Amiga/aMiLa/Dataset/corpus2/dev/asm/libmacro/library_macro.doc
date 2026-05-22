LIBRARY macro
(c) 1995 Rudla Kudla

What is it for

This macro will help you to develop Amiga shared libraries in
assembler. Library sources written using this macro are much more readable and
easy to change. New libraries will also use relative mode for function offsets,
which is very rarely used, also much better (in my opinion) than long absolute
pointers often used. Long pointers are however still usable.

Installation

Copy directory "kudlar/library.i" into your include drawer. (that
drawer with exec, intuition and similar drawers). That's all, you are ready 

Usage

This is very complicated macro and it's usage is little complex (well, nobody
said that developing library is easy thing). First you need to know, how big
your library base will be. It must be at least LIB_SIZE+4 bytes long. Add total
size of your library variables (bases of some other libraries for example) to
this and you know size of your library base.
Now declare library head like this:

	LIBRARY name,version,revision,compilation_date,library_base_size

Example:LIBRARY iffparse,37,231,13.4.1995,iff_SIZEOF

Now you have to declare names of library functions. Do it this way

	LIBRARY FUNCTIONS
	LIBRARY	OpenLib,CloseLib,ExpungeLib,ExtFuncLib

	LIBRARY FunctionName1,FunctionName2,FunctionName3
	LIBRARY FuncName
	LIBRARY AnotherFunction

You MUST write OpenLib,CloseLib,ExpungeLib and ExtFuncLib as first four
functions of your library. They can have different names, but their function
stays same. They are used when library is being openned or closed. See RKM to
or example.library to read more about it. Following functions are specific to
your library. LIBRARY directive can be followed upto 9 function names.
	If your library is bigger than 32 kB, you can put LIBRARY LARGE after
head. This will force library to use long absolute pointers for functions
offsets instead of relative word pointers.

Now follows the code part of library. This is beginning with

	LIBRARY CODE
	
Now you can declare bodies of functions with LIBRARY function_name.
function_name must be equivalent to that listed in initialization part. Label
of this name will be created as entry point to function, while
_LVOfunction_name will be initialized to point on right offset relative to
library base. First function, that you daclare this way must be the one with
name Init. This function has none of those labels. This function is
internally used by system to init library.
	You have to supply body for every function listed in declaration part,
otherwise macro will report an error. Warning will be reported also if you
supply body for function not listed there. (uses PRINTT directive to output
text - works in Trash'mOne V1.6).
	Whole library must be ended with directive
	LIBRARY END

The best way how to begin writing of library is to modify source of my
example.library.

Skeleton of short library:

	LIBRARY iffparse,37,231,13.4.1995,iff_SIZEOF
	LIBRARY FUNCTIONS
	LIBRARY	OpenLib,CloseLib,ExpungeLib,ExtFuncLib
	LIBRARY FunctionName1,FunctionName2,FunctionName3

	LIBRARY CODE
	LIBRARY Init
	;Init code
	LIBRARY OpenLib
	LIBRARY CloseLib
	LIBRARY ExpungeLib
	LIBRARY ExtFuncLib
	
	LIBRARY FunctionName1
	LIBRARY FunctionName2
	LIBRARY FunctionName3
		
	LIBRARY END
	
Skeleton of long library:

	LIBRARY iffparse,39,112,13.6.1995,iff_SIZEOF
	LIBRARY LARGE
	LIBRARY FUNCTIONS
	LIBRARY	OpenLib,CloseLib,ExpungeLib,ExtFuncLib
	LIBRARY FunctionName1,FunctionName2,FunctionName3
	LIBRARY NewFunction
	
	LIBRARY CODE
	LIBRARY Init
	;Init code
	LIBRARY OpenLib
	LIBRARY CloseLib
	LIBRARY ExpungeLib
	LIBRARY ExtFuncLib
	
	LIBRARY FunctionName1
	LIBRARY FunctionName2
	LIBRARY FunctionName3
	LIBRARY NewFunction	
	LIBRARY END
	
Contact and other things

This is freeware. Use it as you wish (but I recommend you to use it for
developing some library :-). Suggestions etc. sent to:

e-mail:  kudlar@risc.upol.cz
www:     http://phoenix.upol.cz/~kudlar/
tel/fax: +42-651-21854
mail:    Rudolf Kudla
         Zerotinova 28/584
         Valasske Mezirici
         75701
         Czech republic
         
I hope, that if you will develop some library using this macro, that you will
send me it.
