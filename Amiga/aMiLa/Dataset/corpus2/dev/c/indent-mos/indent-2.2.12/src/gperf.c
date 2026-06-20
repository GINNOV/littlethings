/* ANSI-C code produced by gperf version 3.1 */
/* Command-line: gperf -D -c -l -p -t -T -g -j1 -o -K rwd -L ANSI-C -N is_reserved indent.gperf  */
/* Computed positions: -k'1,$' */

#if !((' ' == 32) && ('!' == 33) && ('"' == 34) && ('#' == 35) \
      && ('%' == 37) && ('&' == 38) && ('\'' == 39) && ('(' == 40) \
      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \
      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \
      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \
      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \
      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \
      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \
      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \
      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \
      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \
      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \
      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \
      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \
      && ('Z' == 90) && ('[' == 91) && ('\\' == 92) && (']' == 93) \
      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \
      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \
      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \
      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \
      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \
      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \
      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \
      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))
/* The character set is not based on ISO-646.  */
#error "gperf generated tables don't work with this execution character set. Please report a bug to <bug-gperf@gnu.org>."
#endif


#define TOTAL_KEYWORDS 45
#define MIN_WORD_LENGTH 2
#define MAX_WORD_LENGTH 10
#define MIN_HASH_VALUE 3
#define MAX_HASH_VALUE 49
/* maximum key range = 47, duplicates = 0 */

#if defined(__GNUC__) && !defined(__clang__)
__inline
#else
#ifdef __cplusplus
inline
#endif
#endif
static unsigned int
hash (register const char *str, register size_t len)
{
  static unsigned char asso_values[] =
    {
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 18, 50,  7, 25,  6,
      17,  9,  2, 18, 39,  0, 50, 13, 13, 27,
       6, 19, 50, 50,  5,  0,  0, 23,  8, 25,
      18, 21, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50
    };
  return len + asso_values[(unsigned char)str[len - 1]] + asso_values[(unsigned char)str[0]];
}

templ_ty *
is_reserved (register const char *str, register size_t len)
{
  static unsigned char lengthtable[] =
    {
       3,  2,  5,  6,  5,  6,  7,  3,  5,  6,  8,  7,  4,  7,
       6,  8,  4,  8,  6,  4,  6,  7,  8,  8,  6,  8,  4,  9,
       7,  6,  9,  5,  4,  5,  6,  2,  5,  4,  4,  4,  5,  8,
       6,  8, 10
    };
  static templ_ty wordlist[] =
    {
#line 10 "indent.gperf"
      {"int", rw_decl,},
#line 32 "indent.gperf"
      {"if", rw_sp_paren,},
#line 16 "indent.gperf"
      {"short", rw_decl,},
#line 6 "indent.gperf"
      {"struct", rw_struct_like,},
#line 13 "indent.gperf"
      {"float", rw_decl,},
#line 37 "indent.gperf"
      {"sizeof", rw_sizeof,},
#line 17 "indent.gperf"
      {"typedef", rw_decl,},
#line 34 "indent.gperf"
      {"for", rw_sp_paren,},
#line 12 "indent.gperf"
      {"const", rw_decl,},
#line 21 "indent.gperf"
      {"static", rw_decl,},
#line 22 "indent.gperf"
      {"restrict", rw_decl,},
#line 38 "indent.gperf"
      {"alignas", rw_sizeof,},
#line 11 "indent.gperf"
      {"char", rw_decl,},
#line 40 "indent.gperf"
      {"alignof", rw_sizeof,},
#line 31 "indent.gperf"
      {"return", rw_return,},
#line 20 "indent.gperf"
      {"register", rw_decl,},
#line 4 "indent.gperf"
      {"case", rw_case,},
#line 26 "indent.gperf"
      {"noreturn", rw_decl,},
#line 24 "indent.gperf"
      {"extern", rw_decl,},
#line 35 "indent.gperf"
      {"else", rw_sp_else,},
#line 19 "indent.gperf"
      {"signed", rw_decl,},
#line 9 "indent.gperf"
      {"default", rw_case,},
#line 28 "indent.gperf"
      {"volatile", rw_decl,},
#line 39 "indent.gperf"
      {"_Alignas", rw_sizeof,},
#line 29 "indent.gperf"
      {"va_dcl", rw_decl,},
#line 41 "indent.gperf"
      {"_Alignof", rw_sizeof,},
#line 25 "indent.gperf"
      {"void", rw_decl,},
#line 46 "indent.gperf"
      {"imaginary", rw_decl,},
#line 44 "indent.gperf"
      {"complex", rw_decl,},
#line 14 "indent.gperf"
      {"double", rw_decl,},
#line 27 "indent.gperf"
      {"_Noreturn", rw_decl,},
#line 7 "indent.gperf"
      {"union", rw_struct_like,},
#line 15 "indent.gperf"
      {"long", rw_decl,},
#line 43 "indent.gperf"
      {"_Bool", rw_decl,},
#line 23 "indent.gperf"
      {"global", rw_decl,},
#line 36 "indent.gperf"
      {"do", rw_sp_nparen,},
#line 33 "indent.gperf"
      {"while", rw_sp_paren,},
#line 8 "indent.gperf"
      {"enum", rw_enum,},
#line 30 "indent.gperf"
      {"goto", rw_break,},
#line 42 "indent.gperf"
      {"bool", rw_decl,},
#line 5 "indent.gperf"
      {"break", rw_break,},
#line 45 "indent.gperf"
      {"_Complex", rw_decl,},
#line 3 "indent.gperf"
      {"switch", rw_switch,},
#line 18 "indent.gperf"
      {"unsigned", rw_decl,},
#line 47 "indent.gperf"
      {"_Imaginary", rw_decl,}
    };

  static signed char lookup[] =
    {
      -1, -1, -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10,
      11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
      25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
      39, 40, 41, 42, -1, -1, 43, 44
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register unsigned int key = hash (str, len);

      if (key <= MAX_HASH_VALUE)
        {
          register int idx = lookup[key];

          if (idx >= 0)
            {
              if (len == lengthtable[idx])
                {
                  register const char *s = wordlist[idx].rwd;

                  if (*str == *s && !memcmp (str + 1, s + 1, len - 1))
                    return &wordlist[idx];
                }
            }
        }
    }
  return 0;
}
