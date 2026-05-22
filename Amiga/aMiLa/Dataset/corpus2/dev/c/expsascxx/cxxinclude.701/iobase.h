#ifndef __IOBASE_H
#define __IOBASE_H
/* Copyright (c) 1993-1996       by SAS Institute Inc., Cary NC      */

#ifndef _STDDEFH
#include <stddef.h>
#endif

#ifndef _STRING_H
#include <string.h>
#endif


#if defined(__I370__)

#ifndef __IncLio
#include <lcio.h>
#endif

#else

#ifndef _STDIO_H
#include <stdio.h>
#endif
#endif


/* All include's for this file must happen before here. */

#ifdef __I370__
#define __SASCXXLIB_CLASS_DEF_KEYS __alignmem
#define __RENT __rent
#define __NORENT __norent

#else
#define __SASCXXLIB_CLASS_DEF_KEYS 
#define __RENT
#define __NORENT
#endif 

typedef unsigned long _ulong;

class streambuf;
class ostream;
class istream;

typedef long streamoff;

__SASCXXLIB_CLASS_DEF_KEYS struct streampos {

      streampos()
	// Note: _fpos is only initialized on those hosts where it is
	//       convertable with "int".
          {
          _is_offset = 0;
          _offset = 0;
#if !defined(__I370__) && !defined(__iX86__)
	  _fpos = 0;
#endif
          }

      streampos( long _o )
          // Initialize as an offset '_o'.
          //    Zero and EOF are the only valid
          //    initializers for file streampos's.
          {
          _is_offset = 1;
          _offset = _o;
#if !defined(__I370__) && !defined(__iX86__)
	  _fpos = 0;
#endif
          }

      operator long()
          // treat it as an offset, even if it's not.
          {
#if defined(__I370__) || defined(__iX86__)
          return _offset;
#else
          return _offset+_fpos;
#endif
          }

      fpos_t* fpos()
          // Set the streampos to a fpos kind of streampos.
          // Return a pointer to the contained fpos.
          // A typical use of this function is
          //        ::fsetpos( x_file, pos.fpos() );
          //   which sets the
          {
          return &_fpos;
          }

      unsigned short _is_offset;
      long _offset;
      fpos_t _fpos;
    };

#ifndef zapeof
#define zapeof(c) ((unsigned char)(c))
#endif


__SASCXXLIB_CLASS_DEF_KEYS class ios {
    public:
      friend class Iostream_init;

      // State flags
      enum io_state  { goodbit  = 0x00,   // no problems
                       eofbit   = 0x01,   // end of file
                       failbit  = 0x02,   // invalid format (i/o ok)
                       badbit   = 0x04,   // i/o operation failed
                       hardfail = 0x80    // unrecoverable error
                       };

      // Open mode flags
      enum open_mode { in        = 0x01,  // open for input
                       out       = 0x02,  // open for output
                       ate       = 0x04,  // open, seek to eof
                       app       = 0x08,  // open for append
                       trunc     = 0x10,  // truncate if file exists
                       nocreate  = 0x20,  // open fails if file dont exists
                       noreplace = 0x40,  // open fails if file already exists
                       binary    = 0x80   // open binary file
                       };


      // Seek flags
      enum seek_dir  { beg, cur, end };



      // Format flags
      enum {
        skipws     = 0x0001,   // skip whitespace on input

        left       = 0x0002,   // left-adjust output
        right      = 0x0004,   // right-adjust output
        internal   = 0x0008,   // padding after sign or base indicator

        dec        = 0x0010,   // decimal conversion
        oct        = 0x0020,   // octal conversion
        hex        = 0x0040,   // hexidecimal conversion

        showbase   = 0x0080,   // use base indecator on output
        showpoint  = 0x0100,   // force decimal point (for floating output)
        uppercase  = 0x0200,   // use upercase letters during output
        showpos    = 0x0400,   // add + to positive integers

        scientific = 0x0800,   // use 1.2345e2 notation
        fixed      = 0x1000,   // use 123.45   notation

        unitbuf    = 0x2000,   // flush all streams after insertion
        stdio      = 0x4000,   // flush stdout, stderr after insertion
        _firstfree = 0x8000    // first free formatting bit
        };

      __NORENT static const _ulong basefield;      // dec | oct | hex
      __NORENT static const _ulong adjustfield;    // left | right | internal
      __NORENT static const _ulong floatfield;     // scientific | fixed


      // Constructors and destructors
      ios( streambuf* _buf)
          // set up streambuf as the buffer
          {
          init( _buf );
          }

      virtual ~ios() { delete [] x_user; }

      _ulong flags()
          // Return the current format flags
          {
          return x_flags;
          }

      _ulong flags( _ulong _f )
          // Set format flags to 'f', return prev. flags
          {
          _ulong prev = x_flags;
          x_flags = _f;
          return prev;
          }

      _ulong setf(_ulong _field)
         // set flags set in field, return prev. values
         {
         _ulong prev = x_flags & _field;
         x_flags |= _field;
         return prev;
         }

      _ulong unsetf(_ulong _field)
          // clear flags set in field, return prev. values
         {
         _ulong prev = x_flags & _field;
         x_flags &= ~_field;
         return prev;
         }

      _ulong setf(_ulong _setbits, _ulong _field)
          // set flags set in field to values specified in setbits,
          // ret. prev.
         {
         _ulong prev = x_flags & _field;
         x_flags &= ~_field;
         x_flags |= (_setbits & _field);
         return prev;
         }

      int      width()
          // return the value of the width field
          { return x_width; }

      int      width( int _w )
         // set the value of the width field, return prev
         {
         int prev = x_width;
         x_width = (short)_w;
         return prev;
         }

      ostream* tie()
          // return the tie'd ostream
          { return x_tie; }

      ostream* tie( ostream* _s )
          // Tie 's' to this ios
          {
          ostream* prev = x_tie;
          x_tie = _s;
          return prev;
          }


      char fill()
          // return the fill character
          { return x_fill; }

      char fill( char _c )
          // set the fill character, return prev.
          {
          char prev = x_fill;
          x_fill = _c;
          return prev;
          }


      int precision()
          // return the precision value
          { return x_precision; }

      int precision( int _w )
         // set the precision value, return prev.
         {
         int prev = x_precision;
         x_precision = (short)_w;
         return prev;
         }

      // read and set the state
      int rdstate() { return state; }
      int eof()     { return state & eofbit; }
      int fail()    { return state & (failbit | badbit | hardfail); }
      int bad()     { return state & (badbit | hardfail); }
      int good()    { return state == 0; }

      void clear( int _i = 0 ) { state = _i; }

      operator void*()     { return fail() ? 0 : this; }
      int operator!()      { return fail(); }

      streambuf* rdbuf() { return bp; }

      // A no-op in our implementation
      static void sync_with_stdio() {}

      static _ulong bitalloc()
          {
          _ulong temp = nextbit;
          nextbit = nextbit << 1;
          return temp;
          }

      static int xalloc()
          {
          return nextword++;
          }

      long&  iword( int _i ) { return _uword(_i)._l;  }
      void*& pword( int _i ) { return _uword(_i)._vp; }

    protected:
      // Allow initialization by init( streambuf* )
      ios() {};
      void init( streambuf* );



      streambuf* bp;              // The buffer to be manipulated

      int      state;             // the error state

      ostream* x_tie;             // non-NULL if this ios is tied to a stream
      short    x_precision;       // the precision setting
      char     x_fill;            // the fill character
      short    x_width;           // the width setting

      _ulong   x_flags;           // the formatting flags

    private:
      __RENT static _ulong nextbit;      // the next free formatting bit
      __RENT static int nextword;        // the next free formating word

      __SASCXXLIB_CLASS_DEF_KEYS union ios_user_union {
          void* _vp;
          long  _l;
          };

      ios_user_union * x_user;    // the user allocated formatting words
      int nuser;                  // # of userwords actual allocated
                                  //    for this ios.

      ios_user_union& _uword(int i); // return referance to allocated word 'i'

      // Don't allow copying or assigning of ios'
      ios(ios&);
      ios& operator = ( ios& );
      };

/***
*  Manipulators
*    example use: (format 15 in hex then decimal)
*       ostream << hex << 15 << dec << 15;
*
****/
inline ios& dec( ios& _s )
   {
   _s.setf(ios::dec, ios::basefield);
   return _s;
   }

inline ios& hex( ios& _s )
   {
   _s.setf(ios::hex, ios::basefield);
   return _s;
   }

inline ios& oct( ios& _s )
   {
   _s.setf(ios::oct, ios::basefield);
   return _s;
   }




/*****
*
*  class streambuf
*     is the root class for all stream buffers.  Stream buffers
*     act as an interface between where characters can be
*     put and/or fetched.  Classes derived from 'streambuf'
*     specify what happens when a character is put or fetched
*     from the stream buffer. A streambuf is almost never
*     used directly (classes derived from it are used instead),
*     but more often acts a interface specification for derived
*     classes.
*
***/



__SASCXXLIB_CLASS_DEF_KEYS class streambuf {
    public:
      // The constructor should be protected but are not for
      // compatibility with older versions of streams.  Instead
      // use a particular base class.
      streambuf();
               // Create a streambuf with no specific buffer.

      streambuf( char* p, int l );

      virtual ~streambuf()
          {
          if ( alloc )
              delete [] x_base;
          }


      int  in_avail()
          // The number of characters currently in the get buffer
          // (that have been read from the source but not fetched).
          { return x_egptr - x_gptr; }

      int  out_waiting()
          // The number of characters currently in the put buffer
          // (that have not yet been sent to the sink).
          { return x_pptr - x_pbase; }


      int  sbumpc()
          // Move the get pointer forward one character.
          // Return the moved over character.
          {
          return ( in_avail() != 0 || underflow() != EOF )
                ? (unsigned char) (*x_gptr++)
                : EOF;
          }

      int  sgetc()
          // Return the character at the get pointer.
          // Don't move the get pointer.
          {
          return ( in_avail() != 0 )
               ? (unsigned char) (*x_gptr)
               : underflow();
          }

      int  sgetn( char* s, int n )
          // Fill 's' with 'n' characters (if possible).
          // Return the number of gotten characters.
          {
          if ( n <= ( x_egptr - x_gptr ) )
              {
              memcpy( s, x_gptr, n );
              gbump( n );
              return n;
              }
          else
              return xsgetn( s, n );
          }


      int  snextc()
          // Move the get pointer forward one character.
          // Return the character at the new position.
          {
          if ( sbumpc() == EOF )
              return EOF;
          else
              return sgetc();
          }



      void stossc() { sbumpc(); }
               // Move the get pointer forward one character.


      int  sputbackc( char c )
          // Move the get pointer back one character.
          {
          return ( x_eback < x_gptr )
                     ? (unsigned char) (*--x_gptr = c)
                     : pbackfail(c);
          }

      int  sputc( int c )
          // Put 'c' in the position after the put pointer
          // then move the put pointer past that character.
          // Return 'c', or if error return EOF.
          {
          return ( x_pptr >= x_epptr )
              ? overflow( c )
              : (unsigned char) (*x_pptr++ = (char)c);
          }

      int  sputn( const char* s, int n )
          // Put 'n' characters after the put pointer.
          // Move put pointer past them.
          // Return number of character successfully put.
          {
          if ( n <= ( x_epptr - x_pptr ) )
              {
              memcpy( x_pptr, s, n );
              pbump( n );
              return n;
              }
          else
              return xsputn( s, n );
          }


      virtual int sync()
          // Send any characters in the put buffer to the sink.
          // Send any characters in the get area back to the source.
          // Return 0 if successful, EOF if failure.
          // The default version fails if in_avail or out_waiting
          {
          return ( in_avail() == 0 && out_waiting() == 0 )
              ? 0 : EOF;
          }


      virtual streampos seekoff( streamoff,
                                 ios::seek_dir,
                                 int = ios::in|ios::out )
          // Set the get and/or put pointers to a new position.
          // Return the new position or EOF if error.
          {
          return EOF;
          }

      virtual streampos seekpos( streampos _p,
                                 int _m = ios::in|ios::out )
          // Set the get and/or put pointers to a new position.
          // Return the new position or EOF if error.
          {
          return seekoff( streamoff(_p), ios::beg, _m );
          }


      virtual streambuf* setbuf( char*, size_t );
               // Offer a buffer area to be used for the get and/or put areas.

   protected:
      // The functions in this section are for use by classes derived from
      // streambuf to implement a particular kind of stream buffer.
      //
      // Conceptually a stream buffer consists of two optional areas:
      //     a get area - characters waiting to be fetched by the user
      //     a put area - characters put by the user.




      // The following functions return pointers to the get and put
      // areas for the stream buffer.  They may be null indicating
      // that there is not (or not currently) a get or put area.

      char* pbase()
          // First character position in the put area.
          { return x_pbase; }

      char* pptr()
          // Character position where the next put character will go to.
          { return x_pptr; }

      char* epptr()
          // Character position after the last position in the put area.
          { return x_epptr; }

      char* eback()
          // First character position in the get area.
          { return x_eback; }

      char* gptr()
          // Character position from which the next fetched character
          // will come from.
          { return x_gptr; }

      char* egptr()
          // Character position after the last position in the put area.
          { return x_egptr; }

      void setp(char* p, char* ep);
          // Sets pbase() and pptr() to 'p' and epptr() to 'ep'.
          // Required: p <= ep
          // They may both be NULL.

      void  setg(char* eb,char* g, char* eg);
          // Sets eback() to 'eb'.
          // Sets gptr() to 'g'.
          // Sets egptr() to 'eg'.
          // Required: (eb <= g) and (g <= eg)
          // They may all be NULL.



      // The following functions provide for a place to store an array
      // that can be used for the get and/or put areas.  This array
      // is called the reserve area.  Stream buffers are not required
      // to use these functions.


      char* base()
          // The beginning of a character array (buffer).
          { return x_base; }

      char* ebuf()
          // The end of the same array.
          { return x_base + x_blen; }

      int   blen()
          // ebuf() - base().
          { return x_blen; }




      void setb(char* b, char* eb, int a = 0 );
          // Set base() to 'b'.
          // Set ebuf() to 'eb'.
          // If 'a' is not zero then
          // the reserve area will be deleted by a call to
          // operator delete() the next time setb() is called
          // or when this streambuf is destroyed.

      int allocate()
          // Allocate a reserve area if needed:
          //     if base() is NULL and unbuffered() is 0 then
          //        return doallocate();
          //     otherwise
          //        return 0;
          //
          // This function is commonly needed by derived classes
          // in their overflow() and underflow() functions
          // (and maybe in other functions).  It is provided
          // here for convenience.
          {
          if ( x_base == 0 && x_unbuf == 0 )
              return doallocate() == EOF ? EOF : 1;
          else
              return 0;
          }


      int   unbuffered() { return x_unbuf; }
      void  unbuffered( int unb ) { x_unbuf = (char)unb; }
          // These two functions respectively test and set the flag
          // used by allocate().


      // The following functions are used to specialize a stream buffer.
      //
      // Usualy a class derived from streambuf will override at least
      // overflow() and underflow(), although it may override all or
      // none of them.

      virtual int overflow( int c = EOF );
          // Called when the put area is full (or non-existent),
          // although it may be called at other times.
          // It should return EOF only to indicate errors.
          //
          // The purpose of this function is to send characters
          // to the ultimate sink for this stream buffer.
          //
          // Commonly this function will add 'c' to the end of the
          // put area if there is room; otherwise it will consume any
          // characters in the put area as well as 'c', and reset
          // the put area using setp().
          //
          // The default (streambuf) version of this function:
          //     First calls allocate(), if it returns EOF then
          //         streambuf::overflow() returns EOF.
          //     if 'c' == EOF then
          //         returns UCHAR_MAX
          //     otherwise
          //         'c' is added to the put area if there is room for it
          //         and returns 'c'

      virtual int underflow();
          // Called when the get area is empty (or non-existent),
          // although it may be called at other times.
          // It should return EOF to indicate errors or end of input,
          // otherwise it should
          //    1) insure that the get area contains at least one character
          //    2) return the first character in that area.
          //
          // The purpose of this function is to provide characters
          // from the ultimate source of this stream buffer.
          //
          // Commonly this function:
          //     if in_avail() == 0
          //         fill the get area with new characters
          //         and reset the get area using setg().
          //     always return *gptr().
          //
          // The default (streambuf) version of this function
          // just returns EOF.
          //

      virtual int xsputn(const char* s,int n);
          // This function is called by sputn() if there is not
          // enough room in the put area for 'n' characters.  It
          // may also be called at other times.  It should return
          // a value within 0 to 'n'-1 to indicate errors; 'n' otherwise.
          //
          // The intention is the same as overflow().
          //
          // The default (streambuf) version of this function calls
          // streambuf::sputc() for each character in 's'.

      virtual int xsgetn(char*  s,int n);
          // This function is called by sgetn() if there are not
          // 'n' characters in the get area.  It may also be called at
          // other times.  It should return a value within 0 to 'n'-1
          // to indicate errors or end of input; 'n' otherwise.
          //
          // The intention is the same as underflow().
          //
          // The default (streambuf) version of this function calls
          // streambuf::sbumpc() for each character in 's'.


      virtual int pbackfail( int c ) { return EOF; }
          // Called by sputbackc() when eback() == gptr(). It may also
          // be called at other times.
          //
          // It should reset the get area pointers so that gptr() is
          // moved back one character, and so that gptr() points to 'c'.
          // It may move the get area to accomplish this.
          // It may assume 'c' is the same as the character before the
          // get pointer.
          //
          // To indicate errors (including inability to do putback) this
          // function should return EOF.
          //
          // The default (streambuf) version of this function returns EOF.

      virtual int doallocate();
          // Called by allocate() if base() == NULL and unbuffered() == 0.
          // It may also be called at other times.
          // It should either set up a reserve area using setb() and
          // return 0 or return EOF.
          //
          // The intention is that this function set up the reserve
          // area (the base() and ebuf() pointers) for use by overflow()
          // and/or underflow().  It is not required that it do this.
          //
          // The default (streambuf) version of this function attempts
          // to allocate a buffer using operator new().  If this fails
          // this function returns EOF.



      // The following functions are provided for more convienient
      // manipulation to stream buffers by classes derived from streambuf.

      void  pbump( int n ) { x_pptr += n; }
      void  gbump( int n ) { x_gptr += n; }
          // These functions move pptr() and gptr() respectively.
          // 'n' may be any integer.  These functions do no bounds
          // checking.

      static const char* _modestr( int mode );
          // convert a combination of open_mode bits to a
          //   mode string for fopen or afopen.

    private:
      char* x_base;

      char* x_pbase;
      char* x_pptr;
      char* x_epptr;

      char* x_eback;
      char* x_gptr;
      char* x_egptr;

      long  x_blen;

      char  alloc;
      char  x_unbuf;
    };



/*

class istream

   is the root base for those classes that only do input.
   It includes all the basic extraction functions on basic
   C++ types, as well as a number of unformatted input
   functions, as well as functions that allow moving the file
   position pointer.

*/

__SASCXXLIB_CLASS_DEF_KEYS class istream : virtual public ios {
    public:
      istream( streambuf* _b ) : ios( _b ) {}
          // Initializes an istream and associates a streambuf
          // with it.

      virtual ~istream() {}
          // Clean up the istream.


    public:
      int  ipfx( int need = 0 );
          // Input prefix function:
          //     This function does those things that happen
          //     before each formatted operation:
          //     1) If istream's error state is non-zero
          //            then return 0 immediately.
          //     2) If necessary, flush the ios (if any) tied to
          //            this istream.  It is necessary if 'need'
          //            is zero or if there are less than 'need'
          //            characters available for input.
          //     3) If ios::skipws is set and 'need' is 0 then
          //            skip any leading white space in input
          //            (return 0 if error occurs during this skipping).
          //     4) Return 1.

      void isfx() {}


      // The following functions named operator >> are called
      // extraction operators.  They are formmatted input functions.
      //
      // They each call ipfx(0), and do nothing else if it returns 0.
      // They then extract leading characters from the input streambuf
      // according to the type of their argument and formatting flags
      // in the ios.  They all always return the istream.  Errors are
      // indicated by setting the error flags in ios.
      //
      // ios::failbit means that the characters in the input stream
      //     did not match the expected input format.
      // ios::badbit means that an error occured during extraction
      //     of charaters from the streambuf.





      istream&  operator>>( unsigned char* _c ) { return *this >> (char*)_c; }
      istream&  operator>>( signed char* _c )   { return *this >> (char*)_c; }
      istream&  operator>>( char* );
          // Extract characters up to the next white space character.
          // The terminating whitespace character is not extracted.
          // If width() is non-zero extract no more than width() - 1
          // characters, and reset width() to zero.
          // Add a terminating null character (this is done even if
          // an error happens during extraction).



      istream&  operator>>( char& );
      istream&  operator>>( unsigned char& );
      istream&  operator>>( signed char& );
          // Extract a single character, and store it in the argument.


      istream&  operator>>(short&);
      istream&  operator>>(unsigned short&);

      istream&  operator>>(int&);
      istream&  operator>>(unsigned int&);

      istream&  operator>>(long&);
      istream&  operator>>(unsigned long&);
          // There may be a leading sign character (+ or -).
          // If any of ios::dec, ios::oct, or ios::hex is set
          //    characters will be extracted and converted
          //    according to which bit is set.
          // If none of the above bits is set, then these functions
          //    expect one of the following formats:
          //       0xhhh
          //       0Xhhh
          //       0ooo
          //        ddd
          //  Extraction stops when it reaches a non-allowable-digit.
          // An allowable-digit is 0-7 for octal conversion, 0-9 for decimal
          // conversion, and 0-9 and a-f and A-F for hexadecimal conversion.
          //
          // ios::failbit will be set if no digits are found.


      istream&  operator>>( float& );
      istream&  operator>>( double& );
      istream&  operator>>( long double& );
          // Expects a C++ style floating point number.
          // ios::failbit will be set if there are no digits to
          // extract, or if the format is not correct.

      istream&  operator>>( streambuf* );
          // All characters are extracted from the istream and inserted
          // into the streambuf.  Extraction stops when an EOF is
          // found in the istream.


      // The following two functions are syntatically like extractors
      // but are not.

      istream&  operator>>(istream& (*f)(istream&)) { return (*f)(*this); }
      istream&  operator>>(ios& (*f)(ios&)) { (*f)(*this); return *this; }
          // These two functions are for support of simple
          // manipulators.  The parameter functions are called with
          // the stream or ios as arguments.  It is expected
          // that the functions will manipulate the stream in
          // some way.



      // gcount - 

      int       gcount() { return x_gcount; }
          // Returns the number of characters extracted by the last
          // unformatted extraction function.  Formatted extraction
          // functions may change the value of this function in
          // unexpected ways.



      // The following functions are the unformatted input functions.
      // They each call ipfx(1) first, and do nothing else if it
      // returns zero.  If non-zero, gcount will contain the number
      // of extracted characters.  These functions complete by 
      // calling isfx().

      istream&  get(          char* c, int len, char delim='\n');
          // Extract up to 'len'-1 characters.
          // Extraction stops when it reaches a 'delim' character (delim
          // is not extracted), when EOF is reached, or when 'len'-1
          // characters have been found.  Store a terminating null
          // character in the array.  ios::failbit is set only if
          // EOF is reached before any characters are extracted.

      istream&  get( unsigned char* c, int len, char delim='\n')
          { return get((char*)c, len, delim ); }

      istream&  get(   signed char* c, int len, char delim='\n')
          { return get((char*)c, len, delim ); }

      istream&  getline(          char* b, int len, char delim='\n');
          // Same as get except that the terminating 'delim' character
          // (if found) IS extracted.  A terminating null character is
          // always stored in the array.

      istream&  getline( unsigned char* b, int len, char delim='\n')
          { return getline((char*)b, len, delim); }

      istream&  getline(   signed char* b, int len, char delim='\n')
          { return getline((char*)b, len, delim); }

      istream&  get( streambuf& sb, char delim ='\n');
          // Extract characters up to the next 'delim' character or
          // EOF, and insert them into 'sb'.  'delim' is not extracted
          // or inserted.  ios::failbit is set if an error occurs while
          // inserting into 'sb'.

      istream&  get(  signed char& c);
      istream&  get(unsigned char& c);
      istream&  get(char& c);
          // Extract a single character.
          // ios::failbit is set if istream is already at EOF.


      int       get();
          // Extract a single character and return it.
          // EOF is returned if istream is already at EOF.
          // ios::failbit is never set.

      istream&  ignore( int n=1, int delim = EOF );
          // Extract up to the next 'n' characters, or up through the
          // next 'delim' character (when delim != EOF).
          // ios::failbit is set if EOF is reached before all
          // characters are extracted.

      istream&  read(unsigned char* s, int n) { return read((char*)s, n ); }
      istream&  read(  signed char* s, int n) { return read((char*)s, n ); }
      istream&  read(         char* s, int n);
          // Extract the next 'n' characters and store them
          // into the array pointed to by 's'.
          // ios::failbit is set if EOF is reached before 'n' characters
          // are extracted.

      int       peek();
          // Returns EOF if ipfx(1) returns 0 or if stream is at EOF.
          // Otherwise returns next character in stream without
          // extracting it.

      istream&  putback(char c)
          // Do nothing if error state is not good.
          // Move the get pointer of the streambuf back one character.
          // 'c' must be the character before the get pointer before
          // this function is called ('c' must be the character
          // being backed up over).  ios::badbit will be set if
          // the streambuf cannot move the get pointer back.
          {
          if ( good() )
              if ( rdbuf()->sputbackc(c) == EOF )
                  clear( ios::badbit | rdstate() );
          return *this;
          }

      int       sync() { return rdbuf()->sync(); }
          // Calls sync() on the associated streambuf.
          // Returns whatever the streambuf call returns.

      istream&  seekg( streampos p )
          // Move the get pointer of the associated streambuf.
          // 'p' is a value returned by a previous tellg().
          {
          if ( rdbuf()->seekpos( p, ios::in ) == EOF )
              clear( ios::badbit | rdstate() );
          else
              clear(~ios::eofbit & rdstate());
          return *this;
          }

      istream&  seekg(streamoff o, ios::seek_dir d)
          // Move the get pointer of the associated streambuf.
          // 'o' and 'd' are explained in streambuf::seekoff().
          {
          if ( rdbuf()->seekoff(o, d, ios::in) == EOF )
              clear( ios::badbit | rdstate() );
          else
              clear(~ios::eofbit & rdstate());
          return *this;
          }

      streampos tellg()
          // Return the current streampos of the get pointer of
          // the associated streambuf.
          {
          return rdbuf()->seekoff( 0, ios::cur, ios::in );
          }


    protected:

      istream() : ios() {}
          // Initialize istream.  Call the defualt constructor for
          // the ios.  To be used by constructors for classes derived
          // from this one.  Don't use the public constructor, which
          // is only for use when istream is not used as a base.
          // Initialize the streambuf pointer by directly calling
          // ios::ios(streambuf*) in the mem-initializer list of
          // your constructors, or by calling ios::init(streambuf*)
          // from within your constructors.


    private:
      int x_gcount;
      __RENT static char _buffer[100];
      int _fillbufi(int& base);
      int _fillbuff();
    };


istream& ws(istream&);
    // This function skips any leading white space in the associated
    // streambuf.




/*

class ostream

   is the root base for those classes that only do output.
   It includes all the basic insertion operators on basic
   C++ types, as well as a number of unformatted output
   operators and operators that allow moving the file position
   pointer.

*/


__SASCXXLIB_CLASS_DEF_KEYS class ostream : virtual public ios {
    public:
      ostream(streambuf* _b ) : ios( _b ) {}
      virtual ~ostream() {}

    public:
      /* The prefix and suffix functions:
         Certain operations are defined to happen either
         before or after formatted output through a ostream.
         The prefix operations are done by "ostream::opfx",
         and the suffix operations by "ostream::osfx".
      */


      int  opfx();
          /*
             Do prefix operations, return 0 if error.

             This function does the prefix operations for an ostream.
             In particular it does the following:
                  1) If the error state is not good
                         it returns immediately, doing nothing else.
                  2) If this stream is tied (see tie) to another
                         the other is flushed (see flush).
                  Returns 0 if error state is not good.
                          1 otherwise.

             By convention this function is called before
             any formatted output operation on a stream.  If it returns
             0 (meaning error state in stream) the output operation is
             not done.  Each of of the built-in inserters follows this
             convention.  Use- written formatted output functions
             should also follow this convention by calling this function
             and cheking the return code before doing any unformatted
             output.  User-written functions that do no unformatted
             output calls may also call opfx, but need not since
             all formatted output functions should already be calling
             opfx.

          */


      void osfx();
          /*
          Do posfix operations on stream.

          If ios::unitbuf is set
              flush this ostream.
          If ios::stdio is set
               flush stdout and stderr.

          This function should be called at the end of any
          formatted output function that does unformatted
          output on the ostream.  It need not be called
          if the last output operation on the ostream was
          formatted.
          */


      /*
      The following functions named "operator <<" are called
      inserters (because they insert values into the output stream).

      All inserters are formatted output operations and
      as such follow the formatted output conventions
      mentioned above.

      All of the inserters do the following.  First they
      call opfx(), and if it returns an error they do nothing
      else.  They then choose a representation for their argument
      based on the type and value of the argument, and based on the
      formatting flags set in the stream.  The rules for choosing
      a representation are presented below for each function.

      The representation is always a sequence of characters of
      some length.  Once the representation is choosen the
      it will be placed within a field that is at least ios.width()
      characters wide.  If ios.width() is zero the field will be as
      wide as the representation.  The position of the representation
      within the field is determined by the following format flags:
          ios::right
              The representation will be to the far right of
              the field (leading padding will be used).
          ios::left
              The representation will be to the far left of the
              field (trailing padding will be used).
          ios::internal
              The sign and base indicators will be to the far
              left of the field, and the digits will be on the
              far right (internal padding will be used).

      The rest of the field will be filled by characters whose
      value is ios.fill().

      Once the representation is chosen and the field padded
      to be at least ios.width() characters wide, ios.width()
      is reset to zero, and osfx() is called.

      All inserters indicate errors by setting state flags
      in the ostream.  They each always return a reference
      to the ostream.

      */

      ostream&  operator<<( signed char _c )   { return *this << (char)_c; }
      ostream&  operator<<( unsigned char _c ) { return *this << (char)_c; }
      ostream&  operator<<( char );
          // This representation is the value of the charater
          // treated as char's.


      ostream&  operator<<( const unsigned char* _c )
          { return *this << (const char*)_c; }

      ostream&  operator<<( const signed char* _c )
          { return *this << (const char*)_c; }

      ostream&  operator<<( const char* );
          /*
          The representation is the sequence of pointed-to
          characters treated as plain chars, up to but not
          including a '\0' character.
          */

      ostream&  operator<<( short _i )
          { return *this << (long)_i; }
      ostream&  operator<<( unsigned short _i )
          { return *this << (unsigned long)_i; }

      ostream&  operator<<( int _i)
          { return *this << (long)_i; }
      ostream&  operator<<( unsigned int _i )
          { return *this << (unsigned long)_i; }

      ostream&  operator<<( long );
      ostream&  operator<<( unsigned long );
          /*
          The representation is a sequence of digits representing
          the value of the argument.   If the value is negative
          there will be a leading '-'.  Formatting flags within
          the ostream affect the representation as follows:

          ios::showpos
             if set and the value is positive, there will be
             a leading '+'.

          ios::dec ios::oct ios::hex
             determine the base used for the representation.

          ios::showbase
             if set the base of the representation will be indicated
             in the representation as follows:
                decimal - no change to the representations.
                octal - there will be a leading zero in the
                    digits of the representation.  If the value
                    is zero there will be only one zero digit.
                hexadecimal - there will be a leading "0x" in
                    the digits of the representation.  If
                    ios::uppercase is set, a leading "0X" is
                    used instead.

             If the sign indication ('+' or '-') exists it is
             before the base indication.
          */


      ostream&  operator<<( float _f );
      ostream&  operator<<( double );
      ostream&  operator<<( long double );
          /*
          The representation is a sequence of characters representing
          a floating point value in one of two formats.

          Fixed notation is "sddd.ddd" where the digits are decimal
          and 's' is optional ('+' or '-').
          The number of digits after the '.' is determined by
          ios.precision(), 6 is the default.  The decimal point
          is shown only if digits follow it.

          Scientific notation is "sd.dddesdd" where digits are decimal
          and 's' is optional ('+' or '-').  Their is always one
          digit before the decimal point.  The number of digits after
          the point is determined by ios.precision(), the default is 6.
          The value of the digits after the 'e' is called the exponent.

          The representation is affected by the following ios format
          flags:

          ios::fixed or ios::scientific
              determines the overall representation.  If neither
              is set then the overall format is scientific if
              the exponent would be less then -4 or greater than the
              precision.  Fixed is chosen otherwise.

          ios::showpoint
              if set the decimal point is always be shown followed by
              at least one digit.
              If it is NOT set and if all digits after the decimal
              point would be zero, they and the decimal point are
              dropped.

           ios::uppercase
               if set then the 'e' in scientific notation will be 'E'
               instead.

           ios::showpos
               If set then a leading '+' will be output for positive
               values.
           */

      ostream&  operator<<( void* );
          /*
          The value of the pointer is converted to an unsigned long
          and then represented as if ios::hex and ios::showbase
          were set.
          */

      ostream&  operator<<(streambuf*);
          /*
          If the stream state is good, all the characters in
          the argument are fetched from it, and inserted into
          the output stream.  No padding is done.
          */




      /*
      These two functions are for support of simple
      manipulators.  The parameter functions are called with
      the stream or ios as arguments.  It is expected
      that the functions will manipulate the stream in
      some way.
      */

      ostream&  operator<< (ostream& (*f)(ostream&))
          { return (*f)( *this ); }

      ostream&  operator<< (ios& (*f)(ios&) )
          { (*f)( *this ); return *this; }


      /*
      The following functions are for support of unformatted
      output to a stream.  Because they are unformatted operations
      they do not call opfx() and osfx().

      All inserters indicate errors by setting state flags
      in the ostream.  They each always return a reference
      to the ostream.

      */



      ostream& put( char _c )
          // Inserts its argument into the stream.
          {
          if ( good() )
              if ( rdbuf()->sputc( (unsigned char) _c ) == EOF )
                  clear( ios::badbit | rdstate() );
          return *this;
          }

      ostream&  write( const signed char* _s, int _n )
          { return write( (const char*)_s, _n ); }

      ostream&  write( const unsigned char* _s, int _n )
          { return write( (const char*)_s, _n ); }

      ostream&  write( const char* _s, int _n )
         // Inserts 'n' characters starting at 's' into the stream.
         // The characters are treated as plain chars independent
         // of their actual type.
         {
         if ( good() )
             if ( rdbuf()->sputn( _s, _n ) != _n )
                 clear( ios::badbit | rdstate() );
         return *this;
         }


      ostream&  flush()
          {
          if ( rdbuf()->sync() == EOF )
              clear( ios::badbit | rdstate() );
          return *this;
          }

      streampos tellp()
         // Returns the stream's current put pointer position.
         { return rdbuf()->seekoff( 0, ios::cur, ios::out ); }

      ostream&  seekp( streampos _p, ios::seek_dir = ios::beg )
         // Repositions the stream's put pointer.
         // See streambuf::seekpos.
        {
        if ( rdbuf()->seekpos( _p, ios::out ) == EOF )
            clear( ios::badbit | rdstate() );
        return *this;
        }

      ostream&  seekp( streamoff _o, ios::seek_dir _d )
         // Repositions the stream's put pointer.
         // See streambuf::seekoff
        {
        if ( rdbuf()->seekoff( _o, _d, ios::out ) == EOF )
            clear( ios::badbit | rdstate() );
        return *this;
        }


    protected:

      ostream() : ios() {}

    private:

      void _output_integer( int, unsigned long, int = 0 );

    };


// The manipulators
//  example:
//     cout << flush;
//     cout << endl;
//

inline ostream& flush( ostream& _o )
    // Calls o.flush().
    {
    _o.flush();
    return _o;
    }

inline ostream& endl( ostream& _o )
    // Inserts a '\n' character into ostream.
    {
    _o << '\n' << flush;
    return _o;
    }

inline ostream& ends( ostream& _o )
    // Inserts a '\0' character into ostream.
    {
    _o << '\0';
    return _o;
    }





/*

class iostream
    is both an istream and an ostream, and includes all the
    operations of both subclasses.

    It adds only constructors of its own.
*/

__SASCXXLIB_CLASS_DEF_KEYS class iostream : public ostream, public istream {

    public:
      iostream( streambuf* _b ) : ios(_b), istream(), ostream() {}
      virtual ~iostream() {}

    protected:
      iostream() : istream(), ostream() {}
    };


__SASCXXLIB_CLASS_DEF_KEYS class istream_withassign : public istream
    {
    public:
      istream_withassign() : ios( 0 ) {}
      istream_withassign( streambuf* _b ) : ios( _b ) {}
      istream_withassign( istream& _i ) : ios( _i.rdbuf() ) {}
      virtual ~istream_withassign() {}
      istream_withassign& operator = ( streambuf* _b )
          { init( _b ); return *this; }
      istream_withassign& operator = ( istream& _i )
          { init( _i.rdbuf() ); return *this; }
      istream_withassign& operator = ( istream_withassign& _i )
          { init( _i.rdbuf() ); return *this; }

    };

__SASCXXLIB_CLASS_DEF_KEYS class ostream_withassign : public ostream
    {
    public:
      ostream_withassign() : ios( 0 ) {}
      ostream_withassign( streambuf* _b ) : ios( _b) {}
      ostream_withassign( ostream& _o ) : ios( _o.rdbuf() ) {}
      virtual ~ostream_withassign() {}
      ostream_withassign& operator=( streambuf* _b )
          { init( _b ); return *this; }
      ostream_withassign& operator=( ostream& _o )
          { init( _o.rdbuf() ); return *this; }
      ostream_withassign& operator=( ostream_withassign& _o )
          { init( _o.rdbuf() ); return *this; }
    };

__SASCXXLIB_CLASS_DEF_KEYS class iostream_withassign : public iostream
    {
    public:
      iostream_withassign() : ios( 0 ) {}
      iostream_withassign( streambuf* _b ) : ios( _b ) {}
      iostream_withassign( ios& _s ) : ios( _s.rdbuf() ) {}
      virtual ~iostream_withassign() {}
      iostream_withassign& operator=( streambuf* _b )
          { init( _b ); return *this; }
      iostream_withassign& operator=( ios& _s )
          { init( _s.rdbuf() ); return *this; }
      iostream_withassign& operator=( iostream_withassign& _s )
          { init( _s.rdbuf() ); return *this; }
    };

#undef __SASCXXLIB_CLASS_DEF_KEYS
#endif
