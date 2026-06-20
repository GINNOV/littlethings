#define BITNESS 32

enum {
   vmwTtimes, vmwTdiv, vmwTmod, vmwTplus, vmwTminus, 
   vmwTeql, vmwTneq, vmwTlss, vmwTleq, vmwTgtr, vmwTgeq, 
   vmwTperiod, vmwTcomma, 
   vmwTrparen, vmwTrbrak, vmwTrbrace, vmwTlparen, vmwTlbrak, vmwTlbrace,
   vmwTbecomes, vmwTnumber, vmwTident, vmwTsemicolon, vmwTelse, vmwTif, 
   vmwTwhile, vmwTstruct,
   vmwTconst, vmwTvoid, vmwTeof,  
   vmwTplusplus, vmwTplusequal,
   vmwTminusminus, vmwTminusequal,
   vmwTtimesequal, vmwTmodequal, vmwTdivequal,
   vmwTbitand, vmwTbooland, vmwTbitandequal,
   vmwTbitor, vmwTboolor, vmwTbitorequal,
   vmwTbitxor, vmwTbitxorequal,
   vmwTbitnot,vmwTbitnotequal,vmwTboolnot,
   vmwTquestion,vmwTsinglequote,vmwTstring,
   vmwTcase,vmwTchar,vmwTdefault,vmwTdouble,vmwTdo,
   vmwTfloat,vmwTfor,vmwTgoto,vmwTint,
   vmwTlong,vmwTregister,vmwTreturn,vmwTswitch,vmwTunsigned,
   vmwTlshift,vmwTlshiftequal,
   vmwTrshift,vmwTrshiftequal,
   vmwTenum, vmwTshort,
   vmwTarrow, vmwTsizeof,
};

/* architectures */
enum {vmwPPC, vmwAlpha, vmwIa32, vmwUnknown};
   


/* class & mode */
enum {CSGVar, CSGConst, CSGFld, CSGTyp, CSGProc, CSGSProc, CSGReg, CSGJmp, CSGInstr, 
     CSGPtr, CSGPhi, CSGString};

/* location */

enum {Before, After, End, BeforeLastBranch};
   

/* form */
enum {CSGInt, CSGLong, CSGBoolean, CSGArray, CSGStruct,
      CSGChar, CSGShort, CSGVoid};

enum {blockDefault, blockIf, blockThen, blockElse, blockIfJoin,
      blockWhileHead, blockWhileBody, blockWhileJoin, blockProc,
      blockReturnProc};
   

enum {
   vmwNop,
   
   vmwNeg, vmwAdd, vmwSub, vmwMul, vmwDiv, vmwMod, vmwAdda, vmwLshift, 
   vmwRshift, vmwAnd, vmwOr, vmwXor, vmwNot, vmwBoolnot,
           
   vmwLoad, 
     
   vmwStore,
     
   vmwMove, vmwParam, 
   
   vmwBeq, vmwBneq, vmwBlt, vmwBle, vmwBgt, vmwBge,

   vmwBsr, vmwBr, vmwRet, vmwEarlyRet,
     
   vmwRead, vmwWrite, vmwWrl,

   vmwPhi,
     
   vmwHCF
};


