Math functions for StormC PPC
=============================


Introduction
------------

This is a PowerPC link lib which replaces some built math functions of the
StormC compiler with the math library from Motorola (libmoto).
It replaces acos, atan, atan2, sqrt, pow, exp, sin and cos with functions
which are 1.5 to 9 times faster than original functions.


Usage
-----

Simply add the lib to your StormC project.


Speed
-----

all values on Cyberstorm PPC 604e/150 060/50, lower values are better

					acos  atan  atan2 sqrt   pow   exp   sin   cos   log  log10   overall
------------------------------------------------------------------------------------
PPC fast         26    36    48    44    52    27    34    34    37    38      376  100%
PPC original     48   104   195   410   203    42   274   272   109   112     1769  376%
68k             135   253   294    90   840   565   362   359   267   313     3478  925%


Special functions
-----------------

There are also two functions which use the fast special instructions of
the 604e.

estinvsqrt calculates the estimate of the reciprocal of the square root of the
operand. The estimate is correct to a precision of one part in 32.

estinv calculates the estimate of the reciprocal of the operand. The estimate
is correct to a precision of one part in 256.

The prototypes for this functions are:

double estinvsqrt(double a);
double estinv(double a);


History
-------

1.0 (07/16/98)    first public release

Problems
--------

Currently errno is not set if the functions are called with invalid parameters.



Have fun!

Andreas Heumann
andreash@diamondmm.com
