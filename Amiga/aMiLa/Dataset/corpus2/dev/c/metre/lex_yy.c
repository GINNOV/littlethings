#define YYNEWLINE 10
#define INITIAL 0
#define YY_LA_SIZE 35

static unsigned short yy_la_act[] = {
 85, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95,
 34, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95, 34, 95,
 34, 95, 39, 40, 95, 39, 40, 95, 95, 78, 95, 95, 88, 95, 87, 95,
 83, 95, 82, 95, 84, 95, 86, 95, 79, 95, 89, 95, 90, 95, 73, 95,
 80, 95, 68, 95, 69, 95, 70, 95, 71, 95, 72, 95, 74, 95, 75, 95,
 76, 95, 77, 95, 81, 95, 91, 95, 92, 95, 93, 95, 67, 66, 56, 63,
 55, 54, 62, 53, 51, 50, 60, 61, 49, 59, 58, 64, 48, 57, 65, 47,
 45, 43, 46, 43, 43, 43, 43, 43, 41, 39, 40, 39, 40, 39, 40, 39,
 40, 39, 40, 44, 43, 44, 44, 44, 44, 44, 44, 43, 44, 43, 44, 43,
 44, 43, 44, 43, 44, 42, 42, 42, 42, 42, 37, 38, 39, 40, 37, 38,
 39, 40, 37, 38, 39, 40, 37, 38, 39, 40, 37, 38, 39, 40, 35, 36,
 35, 36, 35, 36, 35, 36, 35, 36, 34, 34, 34, 34, 34, 33, 34, 34,
 34, 34, 34, 34, 34, 34, 32, 34, 31, 34, 34, 34, 34, 34, 34, 34,
 34, 30, 34, 34, 29, 34, 34, 34, 34, 34, 34, 28, 34, 34, 34, 34,
 34, 34, 34, 34, 27, 34, 34, 34, 34, 34, 26, 34, 34, 34, 25, 34,
 34, 34, 34, 34, 24, 34, 34, 34, 23, 34, 34, 34, 22, 34, 34, 34,
 34, 34, 34, 21, 34, 34, 34, 34, 34, 20, 34, 34, 34, 19, 34, 17,
 34, 34, 18, 34, 34, 34, 16, 34, 34, 34, 15, 34, 34, 34, 14, 34,
 34, 34, 34, 34, 34, 34, 13, 34, 34, 12, 34, 34, 11, 34, 34, 9,
 34, 34, 34, 34, 10, 34, 34, 34, 34, 34, 8, 34, 34, 34, 34, 34,
 34, 34, 34, 34, 34, 7, 34, 6, 34, 34, 5, 34, 34, 4, 34, 34,
 34, 34, 3, 34, 34, 34, 2, 34, 0, 52, 92, 95, 94, 95, 94, 94,
 1, 94, 94, 1, 94, 1, 94, 1, 94, 1, 94, 1, 94, 1, 94, 94,
 94, 94, 94, 94,
};

static unsigned char yy_look[] = {
 0
};

static short yy_final[] = {
 0, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28,
 30, 32, 34, 37, 40, 41, 43, 44, 46, 48, 50, 52, 54, 56, 58, 60,
 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 91,
 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
 108, 109, 110, 111, 112, 112, 112, 113, 113, 114, 114, 115, 115, 116, 117, 118,
 119, 119, 120, 120, 120, 121, 121, 123, 125, 127, 129, 131, 131, 132, 134, 134,
 135, 136, 137, 138, 138, 139, 139, 141, 143, 145, 147, 147, 149, 149, 150, 151,
 152, 153, 154, 154, 158, 162, 166, 170, 174, 176, 178, 180, 182, 184, 185, 186,
 187, 188, 189, 191, 192, 193, 194, 195, 196, 197, 198, 200, 202, 203, 204, 205,
 206, 207, 208, 209, 211, 212, 214, 215, 216, 217, 218, 219, 221, 222, 223, 224,
 225, 226, 227, 228, 230, 231, 232, 233, 234, 236, 237, 238, 240, 241, 242, 243,
 244, 246, 247, 248, 250, 251, 252, 254, 255, 256, 257, 258, 259, 261, 262, 263,
 264, 265, 267, 268, 269, 271, 273, 274, 276, 277, 278, 280, 281, 282, 284, 285,
 286, 288, 289, 290, 291, 292, 293, 294, 296, 297, 299, 300, 302, 303, 305, 306,
 307, 308, 310, 311, 312, 313, 314, 316, 317, 318, 319, 320, 321, 322, 323, 324,
 325, 327, 329, 330, 332, 333, 335, 336, 337, 338, 340, 341, 342, 344, 345, 346,
 346, 348, 350, 351, 352, 354, 355, 357, 359, 361, 363, 365, 367, 368, 369, 370,
 371, 371, 372
};
typedef unsigned short yy_state_t;
#define	yy_endst 274
#define	yy_nxtmax 1877

static yy_state_t yy_begin[] = {
 0, 255, 0
};

static yy_state_t yy_next[] = {
 47, 47, 47, 47, 47, 47, 47, 47, 47, 45, 46, 45, 45, 47, 47, 47,
 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47,
 45, 33, 22, 47, 17, 28, 29, 20, 39, 40, 27, 25, 37, 26, 21, 1,
 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 38, 34, 24, 32, 23, 44,
 47, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 41, 47, 42, 30, 17,
 47, 2, 3, 4, 5, 6, 7, 8, 17, 9, 17, 17, 10, 17, 17, 17,
 17, 17, 11, 12, 13, 14, 15, 16, 17, 17, 17, 35, 31, 36, 43, 47,
 48, 49, 50, 52, 54, 55, 56, 58, 61, 62, 63, 64, 66, 65, 67, 74,
 274, 274, 274, 274, 274, 127, 274, 57, 59, 128, 60, 53, 73, 129, 72, 72,
 72, 72, 72, 72, 72, 72, 72, 72, 80, 274, 80, 274, 130, 81, 81, 81,
 81, 81, 81, 81, 81, 81, 81, 131, 132, 134, 135, 133, 136, 137, 138, 139,
 140, 51, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 70, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 68, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69,
 69, 69, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 143, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71,
 71, 71, 274, 274, 144, 274, 93, 93, 93, 93, 93, 93, 93, 93, 93, 93,
 101, 103, 145, 146, 90, 147, 119, 105, 148, 75, 77, 94, 96, 88, 77, 117,
 79, 99, 98, 99, 79, 149, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
 101, 102, 150, 151, 89, 152, 118, 104, 153, 75, 76, 94, 95, 87, 76, 116,
 78, 154, 97, 155, 78, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 160, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 82, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 84, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 82, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 161,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
 85, 85, 85, 85, 85, 92, 162, 86, 86, 86, 86, 86, 86, 86, 86, 86,
 86, 124, 274, 141, 274, 124, 156, 157, 163, 164, 122, 166, 91, 142, 122, 167,
 168, 169, 158, 90, 274, 159, 274, 170, 171, 174, 165, 175, 88, 96, 172, 176,
 177, 123, 178, 98, 179, 123, 180, 181, 182, 183, 121, 184, 91, 186, 121, 103,
 187, 173, 188, 89, 189, 105, 190, 191, 185, 192, 193, 194, 87, 95, 195, 106,
 196, 106, 199, 97, 107, 107, 107, 107, 107, 107, 107, 107, 107, 107, 274, 102,
 274, 108, 200, 108, 201, 104, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109,
 197, 202, 203, 205, 206, 204, 207, 208, 198, 111, 212, 213, 214, 215, 216, 113,
 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115, 115,
 115, 115, 115, 115, 209, 217, 210, 218, 219, 110, 220, 222, 223, 224, 225, 112,
 211, 226, 227, 228, 221, 229, 119, 230, 114, 231, 234, 235, 236, 237, 238, 117,
 232, 239, 240, 241, 242, 243, 244, 233, 120, 120, 120, 120, 120, 120, 120, 120,
 120, 120, 245, 246, 247, 248, 118, 249, 114, 120, 120, 120, 120, 120, 120, 116,
 250, 251, 125, 252, 274, 253, 274, 274, 274, 274, 274, 274, 274, 274, 126, 126,
 126, 126, 126, 126, 126, 126, 126, 126, 254, 120, 120, 120, 120, 120, 120, 125,
 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125,
 125, 125, 125, 125, 125, 125, 125, 125, 125, 274, 274, 274, 274, 125, 274, 125,
 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125,
 125, 125, 125, 125, 125, 125, 125, 125, 125, 256, 274, 256, 256, 274, 274, 274,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 256, 274, 274, 257, 261, 261, 261, 261, 261, 261, 261, 261, 261, 258, 274, 261,
 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 258, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 261, 261,
 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 259, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 272, 274, 272, 272, 274, 274, 274, 274, 274, 264, 274,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 261, 272, 274, 274, 273,
 274, 274, 274, 274, 274, 264, 274, 274, 274, 274, 274, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 265,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 274, 274, 274, 274, 274, 274, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 263, 261, 264, 264, 264, 264, 264, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 263, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 262, 262, 262,
 262, 262, 262, 262, 262, 262, 262, 264, 264, 264, 264, 264, 264, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,
 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 274, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 267,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 264, 271, 274,
 274, 274, 274, 274, 274, 274, 274, 261, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 264, 271, 274, 274, 274, 274, 274, 274, 274, 274, 261, 274,
 274, 261, 274, 274, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 261, 261,
 261, 261, 261, 261, 261, 261, 261, 261, 261, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 261, 274, 274, 274, 261, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 271, 274, 274, 274, 274, 274, 274, 274, 274, 261, 274, 274, 274, 274,
 274, 261, 274, 274, 274, 274, 274, 268, 274, 271, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 274, 274, 274, 274, 261, 261, 261, 261, 261, 261, 261,
 261, 261, 261, 274, 261, 274, 269, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 270, 274, 274, 274, 274, 274, 274, 261, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 274, 261,
};

static yy_state_t yy_check[] = {
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 24, 62, 23, 23, 65, 73,
 80, 99, 80, 99, 106, 16, 106, 26, 26, 127, 25, 29, 21, 128, 21, 21,
 21, 21, 21, 21, 21, 21, 21, 21, 75, 108, 75, 108, 129, 75, 75, 75,
 75, 75, 75, 75, 75, 75, 75, 15, 131, 133, 134, 131, 135, 136, 137, 132,
 14, 31, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 22, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 142, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68,
 68, 68, 72, 81, 143, 81, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
 93, 93, 144, 145, 90, 146, 119, 93, 141, 72, 72, 92, 92, 90, 81, 119,
 72, 94, 92, 94, 81, 148, 94, 94, 94, 94, 94, 94, 94, 94, 94, 94,
 93, 93, 13, 150, 90, 151, 119, 93, 152, 72, 72, 92, 92, 90, 81, 119,
 72, 153, 92, 154, 81, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 159, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 20, 20, 20, 20, 20, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83,
 83, 83, 83, 83, 83, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 160,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82,
 82, 82, 82, 82, 82, 19, 161, 19, 19, 19, 19, 19, 19, 19, 19, 19,
 19, 120, 100, 140, 100, 124, 12, 12, 162, 158, 120, 165, 19, 140, 124, 166,
 167, 164, 12, 19, 107, 12, 107, 169, 170, 173, 158, 174, 19, 100, 157, 175,
 172, 120, 177, 100, 178, 124, 156, 180, 181, 11, 120, 183, 19, 185, 124, 107,
 186, 157, 187, 19, 184, 107, 189, 190, 183, 191, 192, 10, 19, 100, 194, 101,
 195, 101, 198, 100, 101, 101, 101, 101, 101, 101, 101, 101, 101, 101, 109, 107,
 109, 91, 8, 91, 200, 107, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
 9, 201, 7, 204, 203, 7, 206, 207, 9, 109, 211, 212, 213, 214, 210, 109,
 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 115, 115, 115, 115, 115, 115,
 115, 115, 115, 115, 6, 216, 6, 209, 218, 109, 5, 221, 222, 223, 224, 109,
 6, 220, 226, 227, 5, 228, 115, 229, 18, 4, 233, 234, 234, 236, 237, 115,
 4, 238, 239, 235, 232, 242, 231, 4, 114, 114, 114, 114, 114, 114, 114, 114,
 114, 114, 244, 3, 246, 247, 115, 248, 18, 114, 114, 114, 114, 114, 114, 115,
 2, 250, 17, 251, ~0, 1, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 1, 114, 114, 114, 114, 114, 114, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, ~0, ~0, ~0, ~0, 17, ~0, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 255, ~0, 255, 255, ~0, ~0, ~0,
 ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 255, ~0, ~0, 255, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, ~0, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257, 257,
 257, 257, 257, 257, 261, 256, ~0, 256, 256, ~0, ~0, ~0, ~0, ~0, 264, ~0,
 ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, 261, 256, ~0, ~0, 256,
 ~0, ~0, ~0, ~0, ~0, 264, ~0, ~0, ~0, ~0, ~0, 261, 261, 261, 261, 261,
 261, 261, 261, 261, 261, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 263,
 ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, 263, 263, 263,
 263, 263, 263, 263, 263, 263, 263, ~0, ~0, ~0, ~0, ~0, ~0, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 261, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260,
 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 260, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, ~0, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265,
 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 265, 267, 271, ~0,
 ~0, ~0, ~0, ~0, ~0, ~0, ~0, 259, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 ~0, ~0, ~0, ~0, 267, 271, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, 259, ~0,
 ~0, 268, ~0, ~0, 267, 267, 267, 267, 267, 267, 267, 267, 267, 267, 259, 259,
 259, 259, 259, 259, 259, 259, 259, 259, 268, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 ~0, ~0, ~0, ~0, 269, ~0, ~0, ~0, 268, 268, 268, 268, 268, 268, 268, 268,
 268, 268, 270, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, 269, ~0, ~0, ~0, ~0,
 ~0, 271, ~0, ~0, ~0, ~0, ~0, 259, ~0, 270, 259, 269, 269, 269, 269, 269,
 269, 269, 269, 269, 269, ~0, ~0, ~0, ~0, 270, 270, 270, 270, 270, 270, 270,
 270, 270, 270, ~0, 268, ~0, 268, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 269, ~0, ~0, ~0, ~0, ~0, ~0, 269, ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0,
 ~0, ~0, ~0, ~0, ~0, 270,
};

static yy_state_t yy_default[] = {
 274, 274, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 274, 19, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
 274, 274, 274, 274, 274, 22, 274, 22, 21, 274, 274, 274, 274, 274, 274, 274,
 75, 75, 274, 274, 274, 83, 19, 90, 90, 90, 274, 274, 274, 92, 274, 274,
 274, 274, 274, 94, 94, 274, 274, 274, 274, 274, 101, 101, 91, 91, 274, 274,
 274, 274, 274, 19, 119, 119, 119, 274, 114, 124, 124, 124, 274, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 274, 274, 0,
 274, 274, 257, 257, 274, 257, 260, 260, 260, 274, 265, 260, 257, 257, 257, 257,
 256, 257,
};

static short yy_base[] = {
 0, 1067, 987, 977, 968, 949, 936, 902, 883, 906, 860, 852, 814, 377, 82, 72,
 45, 1070, 976, 855, 517, 110, 194, 79, 77, 93, 90, 73, 72, 94, 70, 69,
 68, 67, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878,
 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 1878, 78, 1878,
 1878, 81, 1878, 1878, 322, 1878, 1878, 1878, 404, 97, 1878, 125, 1878, 1878, 1878, 1878,
 101, 408, 773, 645, 1878, 1878, 1878, 1878, 1878, 1878, 392, 950, 406, 395, 438, 1878,
 1878, 1878, 1878, 102, 871, 932, 1878, 1878, 1878, 1878, 105, 889, 126, 947, 1878, 1878,
 1878, 1878, 1032, 986, 1878, 1878, 1878, 394, 837, 1878, 1878, 1878, 841, 1878, 1878, 48,
 49, 71, 1878, 79, 91, 88, 70, 83, 81, 89, 1878, 1878, 810, 361, 227, 349,
 356, 366, 369, 1878, 375, 1878, 387, 400, 404, 412, 413, 1878, 839, 839, 824, 451,
 667, 803, 816, 1878, 813, 806, 828, 812, 1878, 830, 837, 1878, 834, 836, 828, 841,
 1878, 845, 848, 1878, 837, 836, 1878, 852, 859, 840, 846, 852, 1878, 851, 851, 868,
 856, 1878, 864, 873, 1878, 1878, 862, 1878, 880, 898, 1878, 901, 897, 1878, 917, 899,
 1878, 932, 905, 902, 918, 906, 911, 1878, 936, 1878, 947, 1878, 955, 934, 954, 945,
 953, 1878, 961, 942, 953, 947, 1878, 963, 979, 956, 952, 959, 964, 960, 956, 973,
 1878, 1878, 963, 1878, 989, 1878, 991, 996, 988, 1878, 989, 996, 1878, 1878, 1878, 1184,
 1340, 1220, 1878, 1694, 1437, 1339, 1878, 1373, 1349, 1565, 1878, 1684, 1720, 1755, 1769, 1685,
 1878, 1878, 1878
};


#line 1 "c:\mks/etc/yylex.c"
/*
 * Copyright 1988, 1990 by Mortice Kern Systems Inc.
 * All rights reserved.
 */
#include <stdio.h>
/*
 * Define gettext() to an appropriate function for internationalized messages
 * or custom processing.
 */
#ifndef I18N
#define gettext(s)	(s)
#endif
/*
 * Include string.h to get definition of memmove() and size_t.
 * If you do not have string.h or it does not declare memmove
 * or size_t, you will have to declare them here.
 */
#include <string.h>
/* Uncomment next line if memmove() is not declared in string.h */
/*extern char * memmove();*/
/* Uncomment next line if size_t is not available in stdio.h or string.h */
/*typedef unsigned size_t;*/
/* Drop this when LATTICE provides memmove */
#ifdef LATTICE
#define memmove	memcopy
#endif

/*
 * YY_STATIC determines the scope of variables and functions
 * declared by the lex scanner. It must be set with a -DYY_STATIC
 * option to the compiler (it cannot be defined in the lex program).
 */
#ifdef	YY_STATIC
/* define all variables as static to allow more than one lex scanner */
#define	YY_DECL	static
#else
/* define all variables as global to allow other modules to access them */
#define	YY_DECL	
#endif

#ifdef __STDC__
#define	YY_ARGS(_args_)	_args_
#else
#define	YY_ARGS(_args_)	()
#endif

/*
 * the following can be redefined by the user.
 */
#define	ECHO		fputs(yytext, yyout)
#define	yygetc()	getc(yyin) 	/* yylex input source */
#define	output(c)	putc((c), yyout) /* yylex sink for unmatched chars */
#define	YY_FATAL(msg)	{ fprintf(stderr, "yylex: %s\n", msg); exit(1); }
#define	YY_INTERACTIVE	1		/* save micro-seconds if 0 */
#define	YYLMAX		100		/* token and pushback buffer size */

/*
 * the following must not be redefined.
 */
#define	yy_tbuf	yytext		/* token string */

#define	BEGIN		yy_start =
#define	REJECT		goto yy_reject
#define	NLSTATE		(yy_lastc = YYNEWLINE)
#define	YY_INIT		(yy_start = 0, yyleng = yy_end = 0, yy_lastc = YYNEWLINE)
#define	yymore()	goto yy_more
#define	yyless(n)	if ((n) < 0 || (n) > yy_end) ; \
			else { YY_SCANNER; yyleng = (n); YY_USER; }

YY_DECL	int	input	YY_ARGS((void));
YY_DECL	int	unput	YY_ARGS((int c));

/* functions defined in libl.lib */
extern	int	yywrap	YY_ARGS((void));
extern	void	yyerror	YY_ARGS((char *fmt, ...));
extern	void	yycomment	YY_ARGS((char *term));
extern	int	yymapch	YY_ARGS((int delim, int escape));

#line 8 "scan.l"

/*************************************************************
   Copyright (c) 1993,1994 by Paul Long  All rights reserved.
**************************************************************/

/*************************************************************
   scan.l - This source file contains the lex specification
            for Metre's Standard C lexer.  It also contains
            lexical functions that can be called from the
            rules() function and replacement functions for
            lex's yywrap() and MKS lex's yygetc().
**************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "ytab.h"
#include "metreint.h"


/*
   Decide which lex is being used based on whether YY_INIT and YY_INPUT are
   defined.  It is my belief that the 4 combinations of whether these two
   manifest constants are defined coincidentally indicates which lex is being
   used.  I know that this method works with MKS and AT&T lex; from reading
   John Levine's book, "lex & yacc," I also believe that it works with flex
   and pclex.  Note: Berkeley is considered same as AT&T lex, and Posix is not
   considered at all.
*/
#ifdef YY_INIT
#ifdef YY_INPUT
#define MTR_PCLEX
#else
#define MTR_MKSLEX
#endif
#else
#ifdef YY_INPUT
#define MTR_FLEX
#else
#define MTR_ATTLEX
#endif
#endif

/*
   Redefine size of miniscule yytext[].  Should have no affect on other lex's.
*/
#define MTR_YYTEXT_SIZE 500
/*
   Redefine for MKS and AT&T lex.  I don't explicitly test for MTR_MKSLEX or
   MTR_ATTLEX because YYLMAX should only be defined for them.
*/
#ifdef YYLMAX
#if YYLMAX < MTR_YYTEXT_SIZE
#undef YYLMAX
#define YYLMAX MTR_YYTEXT_SIZE
#endif
#endif
/*
   Redefine for pclex.  I don't explicitly test for MTR_PCLEX because F_BUFSIZ
   should only be defined for it.
*/
#ifdef F_BUFSIZ
#if F_BUFSIZ < MTR_YYTEXT_SIZE
#undef F_BUFSIZ
#define F_BUFSIZ MTR_YYTEXT_SIZE
#endif
#endif

/*
   Prior to version 2.4, flex defined a yywrap() macro.  Undefine it just in
   case, because I define a yywrap() function.  This shouldn't affect the other
   lex's.
*/
#ifdef yywrap
#undef yywrap
#endif


#if READ_LINE

/*
   I provide a function to replace MKS' yygetc() macro, so undefine the macro.
   Should have no affect on other lex's.  That's why I don't explicitly test
   for MTR_MKSLEX.
*/
#ifdef yygetc
#undef yygetc
#endif

/*
   AT&T lex uses stdio.h's getc() to read in characters in its input() macro.
   Assuming that getc() is a macro in stdio.h, redefine it to call my
   yygetc() macro.
*/
#ifdef MTR_ATTLEX
#ifdef getc
#undef getc
#endif
#define getc(x)   yygetc()
#endif

/*
   The following directives hopefully make Metre compatible with flex and
   pclex.  I don't have either, so I can't test this.  From reading John
   Levine's book, "lex & yacc," flex/pclex expects the YY_INPUT() macro to
   read a block of data.  If flex/pclex is used, it will use my definition.
   If flex/pclex is not used, MKS and AT&T lex will use it indirectly because
   yygetc() and getc(), respectively, also use the macro.

   This diagram shows the dependencies and how Metre achieves compatibility
   with the three lex's.

      getc()                     <-- AT&T lex uses
         yygetc()                <-- MKS lex uses
            YY_INPUT()           <-- flex/pclex uses
               my_yyinput()
*/
#ifdef YY_INPUT
#undef YY_INPUT
#endif
#define YY_INPUT(b, r, ms) (r = my_yyinput(b, ms))

/* Size of input buffer.  Must be as large as the largest expected line. */
#define INPUT_LINE_MAX_LEN    2048

#endif      /* #if READ_LINE */


/* Define how to restart lexer based on which lex is being used. */
#if defined(MTR_MKSLEX) || defined(MTR_PCLEX)
#define MTR_YY_INIT  YY_INIT
#elif defined(MTR_FLEX)
#define MTR_YY_INIT  yyrestart(yyin)
#elif defined(MTR_ATTLEX)
#define MTR_YY_INIT  yy_init()
#else
#error Unsupported version of lex
#endif


/* External variables. */

/*
   Whether to interleave the input with the output.  Set according to the
   copy-input option character from the command line.
*/
BOOLEAN display_input;

#if defined(MTR_MKSLEX) || defined(MTR_ATTLEX)
/* Do nothing--the lex takes care of it. */
#define INCR_YYLINENO
#else
/*
   I know that MKS and AT&T lex support yylineno.  Don't know about the
   others.  Here's one for them.  I use the technique described in
   John Levine's book, "lex & yacc," of simply incrementing a line counter
   whenever a newline is encountered in the input stream.  However, this is not
   as accurate as how MKS and AT&T lex do it.  They increment the line counter
   when the input() macro encounters a newline and decrement it when it is
   pushed back via the unput() macro.  This overcomes the problem of
   incrementing the line counter prematurely during look-ahead.  I took the
   easy way out for lex's other than MKS or AT&T--I didn't want to provide my
   own input() and output() macros for them.  You could modify them, though.
*/
int yylineno;
#define INCR_YYLINENO   (++yylineno)
#endif


/* Function prototypes for static functions. */
#if READ_LINE
static int yygetc(void);
static int my_yyinput(char *, int);
#endif
static void count(void);
static void comment(void);
static void fire_keyword(void);
static void fire_identifier(void);
static void found_nonstandard(void);
static BOOLEAN identifier_defined(char *);
static int check_type(void);
static unsigned extract_line_number(char *);
static char *extract_file_name(char *);
#ifdef MTR_ATTLEX
static void yy_init(void);
#endif

/* Static variables. */

#if READ_LINE
/*
   I read the input line into here then feed the lexer one character at a time
   from that.  This is so that I have the entire line available in case I
   need to print the line along with an error message.
*/
static char input_line[INPUT_LINE_MAX_LEN];
#endif

/* An input line is one of these three types. */
static enum { BLANK_LINE, COMMENT_LINE, CODE_LINE } line_type = BLANK_LINE;

/* Whether a tab or space character was found at the beginning of a line. */
static BOOLEAN found_tab;
static BOOLEAN found_space;

/*
   Pointer to current keyword or identifier as passed to rules if such a token
   is encountered.
*/
static char *current_keyword;
static char *current_identifier;

#line 79 "c:\mks/etc/yylex.c"


#ifdef	YY_DEBUG
#undef	YY_DEBUG
#define	YY_DEBUG(fmt, a1, a2)	fprintf(stderr, fmt, a1, a2)
#else
#define	YY_DEBUG(fmt, a1, a2)
#endif

/*
 * The declaration for the lex scanner can be changed by
 * redefining YYLEX or YYDECL. This must be done if you have
 * more than one scanner in a program.
 */
#ifndef	YYLEX
#define	YYLEX yylex			/* name of lex scanner */
#endif

#ifndef YYDECL
#define	YYDECL	int YYLEX YY_ARGS((void))	/* declaration for lex scanner */
#endif

/* stdin and stdout may not neccessarily be constants */
YY_DECL	FILE   *yyin = NULL;
YY_DECL	FILE   *yyout = NULL;
YY_DECL	int	yylineno = 1;		/* line number */
YY_DECL	int	yyleng = 0;		/* yytext token length */

/*
 * yy_tbuf is an alias for yytext.
 * yy_sbuf[0:yyleng-1] contains the states corresponding to yy_tbuf.
 * yy_tbuf[0:yyleng-1] contains the current token.
 * yy_tbuf[yyleng:yy_end-1] contains pushed-back characters.
 * When the user action routine is active,
 * yy_save contains yy_tbuf[yyleng], which is set to '\0'.
 * Things are different when YY_PRESERVE is defined. 
 */

YY_DECL	unsigned char yy_tbuf [YYLMAX+1]; /* text buffer (really yytext) */
static	yy_state_t yy_sbuf [YYLMAX+1];	/* state buffer */

static	int	yy_end = 0;		/* end of pushback */
static	int	yy_start = 0;		/* start state */
static	int	yy_lastc = YYNEWLINE;	/* previous char */

#ifndef YY_PRESERVE	/* the efficient default push-back scheme */

static	unsigned char yy_save;	/* saved yytext[yyleng] */

#define	YY_USER	{ /* set up yytext for user */ \
		yy_save = yytext[yyleng]; \
		yytext[yyleng] = 0; \
	}
#define	YY_SCANNER { /* set up yytext for scanner */ \
		yytext[yyleng] = yy_save; \
	}

#else		/* not-so efficient push-back for yytext mungers */

static	unsigned char yy_save [YYLMAX];
static	unsigned char *yy_push = yy_save+YYLMAX;

#define	YY_USER { \
		size_t n = yy_end - yyleng; \
		yy_push = yy_save+YYLMAX - n; \
		if (n > 0) \
			memmove(yy_push, yytext+yyleng, n); \
		yytext[yyleng] = 0; \
	}
#define	YY_SCANNER { \
		size_t n = yy_save+YYLMAX - yy_push; \
		if (n > 0) \
			memmove(yytext+yyleng, yy_push, n); \
		yy_end = yyleng + n; \
	}

#endif

/*
 * The actual lex scanner (usually yylex(void)).
 */
YYDECL {

#line 161 "c:\mks/etc/yylex.c"

	register int c, i, yyst, yybase;
	int yyfmin, yyfmax;		/* yy_la_act indices of final states */
	int yyoldi, yyoleng;		/* base i, yyleng before look-ahead */

	if (yyin == NULL)		/* for silly compilers (yes, I know)*/
		yyin = stdin;
	if (yyout == NULL)
		yyout = stdout;
	i = yyleng;
	YY_SCANNER;

  yy_again:
	yyleng = i;
	/* determine previous char. */
	if (i > 0)
		yy_lastc = yytext[i-1];
	/* scan previously accepted token adjusting yylineno */
	while (i > 0)
		if (yytext[--i] == YYNEWLINE)
			yylineno++;
	/* adjust pushback */
	yy_end -= yyleng;
	memmove(yytext, yytext+yyleng, (size_t) yy_end);
	i = 0;

  yy_contin:
	yyoldi = i;

	/* run the state machine until it jams */
	for (yy_sbuf[i] = yyst = yy_begin[yy_start + (yy_lastc == YYNEWLINE)];
	     !(yyst == yy_endst || YY_INTERACTIVE && yy_base[yyst] > yy_nxtmax && yy_default[yyst] == yy_endst);
	     yy_sbuf[++i] = yyst) {
		YY_DEBUG(gettext("<state %d, i = %d>\n"), yyst, i);
		if (i >= YYLMAX)
			YY_FATAL(gettext("Token buffer overflow"));

		/* get input char */
		if (i < yy_end)
			c = yy_tbuf[i];		/* get pushback char */
		else if ((c = yygetc()) != EOF) {
			yy_end = i+1;
			yy_tbuf[i] = c = (unsigned char) c;
		} else /* c == EOF */ {
			if (i == yyoldi)	/* no token */
				if (yywrap())
					return 0;
				else
					goto yy_again;
			else
				break;
		}
		YY_DEBUG(gettext("<input %d = 0x%02x>\n"), c, c);

		/* look up next state */
		while ((yybase = yy_base[yyst]+c) > yy_nxtmax || yy_check[yybase] != yyst) {
			if (yyst == yy_endst)
				goto yy_jammed;
			yyst = yy_default[yyst];
		}
		yyst = yy_next[yybase];
	  yy_jammed: ;
	}
	YY_DEBUG(gettext("<stopped %d, i = %d>\n"), yyst, i);
	if (yyst != yy_endst)
		++i;

  yy_search:
	/* search backward for a final state */
	while (--i > yyoldi) {
		yyst = yy_sbuf[i];
		if ((yyfmin = yy_final[yyst]) < (yyfmax = yy_final[yyst+1]))
			goto yy_found;	/* found final state(s) */
	}
	/* no match, default action */
	i = yyoldi + 1;
	output(yy_tbuf[yyoldi]);
	goto yy_again;

  yy_found:
	YY_DEBUG(gettext("<final state %d, i = %d>\n"), yyst, i);
	yyoleng = i;		/* save length for REJECT */
	
	/* pushback look-ahead RHS */
	if ((c = (int)(yy_la_act[yyfmin]>>9) - 1) >= 0) { /* trailing context? */
		unsigned char *bv = yy_look + c*YY_LA_SIZE;
		static unsigned char bits [8] = {
			1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7
		};
		while (1) {
			if (--i < yyoldi) {	/* no / */
				i = yyoleng;
				break;
			}
			yyst = yy_sbuf[i];
			if (bv[(unsigned)yyst/8] & bits[(unsigned)yyst%8])
				break;
		}
	}

	/* perform action */
	yyleng = i;
	YY_USER;
	switch (yy_la_act[yyfmin] & 0777) {
	case 0:
#line 222 "scan.l"
	{ comment();   /* Read in rest of comment. */ }
	break;
	case 1:
#line 223 "scan.l"
	{
                           char *temp_file_name;

                           count();

                           /* Don't know why had to subtract 1. Oh well. */
                           yylineno = extract_line_number(yytext) - 1;

                           /* Use new file name if present. */
                           temp_file_name = extract_file_name(yytext);
                           if (temp_file_name != NULL)
                              input_file_orig_name = temp_file_name;
                        }
	break;
	case 2:
#line 237 "scan.l"
	{  /*
                              For this and the following keywords, do
                              some lexical accounting, fire the keyword
                              trigger in case a rule uses a keyword as a
                              trigger, then return token to parser.
                           */
                           count(); fire_keyword(); return(TK_AUTO); }
	break;
	case 3:
#line 244 "scan.l"
	{ count(); fire_keyword(); return(TK_BREAK); }
	break;
	case 4:
#line 245 "scan.l"
	{ count(); fire_keyword(); return(TK_CASE); }
	break;
	case 5:
#line 246 "scan.l"
	{ count(); fire_keyword(); return(TK_CHAR); }
	break;
	case 6:
#line 247 "scan.l"
	{ count(); fire_keyword(); return(TK_CONST); }
	break;
	case 7:
#line 248 "scan.l"
	{ count(); fire_keyword(); return(TK_CONTINUE); }
	break;
	case 8:
#line 249 "scan.l"
	{ count(); fire_keyword(); return(TK_DEFAULT); }
	break;
	case 9:
#line 250 "scan.l"
	{ count(); fire_keyword(); return(TK_DO); }
	break;
	case 10:
#line 251 "scan.l"
	{ count(); fire_keyword(); return(TK_DOUBLE); }
	break;
	case 11:
#line 252 "scan.l"
	{ count(); fire_keyword(); return(TK_ELSE); }
	break;
	case 12:
#line 253 "scan.l"
	{ count(); fire_keyword(); return(TK_ENUM); }
	break;
	case 13:
#line 254 "scan.l"
	{ count(); fire_keyword(); return(TK_EXTERN); }
	break;
	case 14:
#line 255 "scan.l"
	{ count(); fire_keyword(); return(TK_FLOAT); }
	break;
	case 15:
#line 256 "scan.l"
	{ count(); fire_keyword(); return(TK_FOR); }
	break;
	case 16:
#line 257 "scan.l"
	{ count(); fire_keyword(); return(TK_GOTO); }
	break;
	case 17:
#line 258 "scan.l"
	{ count(); fire_keyword(); return(TK_IF); }
	break;
	case 18:
#line 259 "scan.l"
	{ count(); fire_keyword(); return(TK_INT); }
	break;
	case 19:
#line 260 "scan.l"
	{ count(); fire_keyword(); return(TK_LONG); }
	break;
	case 20:
#line 261 "scan.l"
	{ count(); fire_keyword(); return(TK_REGISTER); }
	break;
	case 21:
#line 262 "scan.l"
	{ count(); fire_keyword(); return(TK_RETURN); }
	break;
	case 22:
#line 263 "scan.l"
	{ count(); fire_keyword(); return(TK_SHORT); }
	break;
	case 23:
#line 264 "scan.l"
	{ count(); fire_keyword(); return(TK_SIGNED); }
	break;
	case 24:
#line 265 "scan.l"
	{ count(); fire_keyword(); return(TK_SIZEOF); }
	break;
	case 25:
#line 266 "scan.l"
	{ count(); fire_keyword(); return(TK_STATIC); }
	break;
	case 26:
#line 267 "scan.l"
	{ count(); fire_keyword(); return(TK_STRUCT); }
	break;
	case 27:
#line 268 "scan.l"
	{ count(); fire_keyword(); return(TK_SWITCH); }
	break;
	case 28:
#line 269 "scan.l"
	{ count(); fire_keyword(); return(TK_TYPEDEF); }
	break;
	case 29:
#line 270 "scan.l"
	{ count(); fire_keyword(); return(TK_UNION); }
	break;
	case 30:
#line 271 "scan.l"
	{ count(); fire_keyword(); return(TK_UNSIGNED); }
	break;
	case 31:
#line 272 "scan.l"
	{ count(); fire_keyword(); return(TK_VOID); }
	break;
	case 32:
#line 273 "scan.l"
	{ count(); fire_keyword(); return(TK_VOLATILE); }
	break;
	case 33:
#line 274 "scan.l"
	{ count(); fire_keyword(); return(TK_WHILE); }
	break;
	case 34:
#line 276 "scan.l"
	{
                           /*
                              If a replacement was provided on the
                              command line for this identifier, rescan
                              input which will now have the replacement
                              characters.  Otherwise, do some lexical
                              accounting, fire the identifier trigger in
                              case a rule uses an identifier in a
                              trigger, then return token to parser (this
                              is either an identifier or a typedef type
                              name).
                           */
                           if (!identifier_defined(yytext))
                           {
                              count();
                              fire_identifier();
                              return(check_type());
                           }
                        }
	break;
	case 35:
#line 296 "scan.l"
	{  /*
                              For this and the following constants and
                              string literals, do some lexical
                              accounting and return token to parser.
                           */
                           count(); return(TK_CONSTANT); }
	break;
	case 36:
#line 302 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 37:
#line 303 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 38:
#line 304 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 39:
#line 305 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 40:
#line 306 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 41:
#line 307 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 42:
#line 308 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 43:
#line 309 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 44:
#line 310 "scan.l"
	{ count(); return(TK_CONSTANT); }
	break;
	case 45:
#line 311 "scan.l"
	{ count(); return(TK_STRING_LITERAL); }
	break;
	case 46:
#line 313 "scan.l"
	{  /*
                              For this and the following operators, do
                              some lexical accounting and return token
                              to parser.
                           */
                           count(); return(TK_ELIPSIS); }
	break;
	case 47:
#line 319 "scan.l"
	{ count(); return(TK_RIGHT_ASSIGN); }
	break;
	case 48:
#line 320 "scan.l"
	{ count(); return(TK_LEFT_ASSIGN); }
	break;
	case 49:
#line 321 "scan.l"
	{ count(); return(TK_ADD_ASSIGN); }
	break;
	case 50:
#line 322 "scan.l"
	{ count(); return(TK_SUB_ASSIGN); }
	break;
	case 51:
#line 323 "scan.l"
	{ count(); return(TK_MUL_ASSIGN); }
	break;
	case 52:
#line 324 "scan.l"
	{ count(); return(TK_DIV_ASSIGN); }
	break;
	case 53:
#line 325 "scan.l"
	{ count(); return(TK_MOD_ASSIGN); }
	break;
	case 54:
#line 326 "scan.l"
	{ count(); return(TK_AND_ASSIGN); }
	break;
	case 55:
#line 327 "scan.l"
	{ count(); return(TK_XOR_ASSIGN); }
	break;
	case 56:
#line 328 "scan.l"
	{ count(); return(TK_OR_ASSIGN); }
	break;
	case 57:
#line 329 "scan.l"
	{ count(); return(TK_RIGHT_OP); }
	break;
	case 58:
#line 330 "scan.l"
	{ count(); return(TK_LEFT_OP); }
	break;
	case 59:
#line 331 "scan.l"
	{ count(); return(TK_INC_OP); }
	break;
	case 60:
#line 332 "scan.l"
	{ count(); return(TK_DEC_OP); }
	break;
	case 61:
#line 333 "scan.l"
	{ count(); return(TK_PTR_OP); }
	break;
	case 62:
#line 334 "scan.l"
	{ count(); return(TK_AND_OP); }
	break;
	case 63:
#line 335 "scan.l"
	{ count(); return(TK_OR_OP); }
	break;
	case 64:
#line 336 "scan.l"
	{ count(); return(TK_LE_OP); }
	break;
	case 65:
#line 337 "scan.l"
	{ count(); return(TK_GE_OP); }
	break;
	case 66:
#line 338 "scan.l"
	{ count(); return(TK_EQ_OP); }
	break;
	case 67:
#line 339 "scan.l"
	{ count(); return(TK_NE_OP); }
	break;
	case 68:
#line 340 "scan.l"
	{ count(); return(';'); }
	break;
	case 69:
#line 341 "scan.l"
	{ count(); return('{'); }
	break;
	case 70:
#line 342 "scan.l"
	{ count(); return('}'); }
	break;
	case 71:
#line 343 "scan.l"
	{ count(); return(','); }
	break;
	case 72:
#line 344 "scan.l"
	{ count(); return(':'); }
	break;
	case 73:
#line 345 "scan.l"
	{ count(); return('='); }
	break;
	case 74:
#line 346 "scan.l"
	{ count(); return('('); }
	break;
	case 75:
#line 347 "scan.l"
	{ count(); return(')'); }
	break;
	case 76:
#line 348 "scan.l"
	{ count(); return('['); }
	break;
	case 77:
#line 349 "scan.l"
	{ count(); return(']'); }
	break;
	case 78:
#line 350 "scan.l"
	{ count(); return('.'); }
	break;
	case 79:
#line 351 "scan.l"
	{ count(); return('&'); }
	break;
	case 80:
#line 352 "scan.l"
	{ count(); return('!'); }
	break;
	case 81:
#line 353 "scan.l"
	{ count(); return('~'); }
	break;
	case 82:
#line 354 "scan.l"
	{ count(); return('-'); }
	break;
	case 83:
#line 355 "scan.l"
	{ count(); return('+'); }
	break;
	case 84:
#line 356 "scan.l"
	{ count(); return('*'); }
	break;
	case 85:
#line 357 "scan.l"
	{ count(); return('/'); }
	break;
	case 86:
#line 358 "scan.l"
	{ count(); return('%'); }
	break;
	case 87:
#line 359 "scan.l"
	{ count(); return('<'); }
	break;
	case 88:
#line 360 "scan.l"
	{ count(); return('>'); }
	break;
	case 89:
#line 361 "scan.l"
	{ count(); return('^'); }
	break;
	case 90:
#line 362 "scan.l"
	{ count(); return('|'); }
	break;
	case 91:
#line 363 "scan.l"
	{ count(); return('?'); }
	break;
	case 92:
#line 365 "scan.l"
	{  /* Absorb whitespace character. */
                           count(); }
	break;
	case 93:
#line 367 "scan.l"
	{ INCR_YYLINENO; count(); }
	break;
	case 94:
#line 369 "scan.l"
	{  /* Ignore preprocessor directives. */
                           count(); }
	break;
	case 95:
#line 372 "scan.l"
	{  /* Trap any non-standard characters. */
                           count(); found_nonstandard(); }
	break;

#line 265 "c:\mks/etc/yylex.c"

	}
	YY_SCANNER;
	i = yyleng;
	goto yy_again;			/* action fell though */

  yy_reject:
	YY_SCANNER;
	i = yyoleng;			/* restore original yytext */
	if (++yyfmin < yyfmax)
		goto yy_found;		/* another final state, same length */
	else
		goto yy_search;		/* try shorter yytext */

  yy_more:
	YY_SCANNER;
	i = yyleng;
	if (i > 0)
		yy_lastc = yytext[i-1];
	goto yy_contin;
}

/*
 * user callable input/unput functions.
 */

/* get input char with pushback */
YY_DECL int
input()
{
	int c;
#ifndef YY_PRESERVE
	if (yy_end > yyleng) {
		yy_end--;
		memmove(yytext+yyleng, yytext+yyleng+1,
			(size_t) (yy_end-yyleng));
		c = yy_save;
		YY_USER;
#else
	if (yy_push < yy_save+YYLMAX) {
		c = *yy_push++;
#endif
	} else
		c = yygetc();
	yy_lastc = c;
	if (c == YYNEWLINE)
		yylineno++;
	return c;
}

/* pushback char */
YY_DECL int
unput(c)
	int c;
{
#ifndef YY_PRESERVE
	if (yy_end >= YYLMAX)
		YY_FATAL(gettext("Push-back buffer overflow"));
	if (yy_end > yyleng) {
		yytext[yyleng] = yy_save;
		memmove(yytext+yyleng+1, yytext+yyleng,
			(size_t) (yy_end-yyleng));
		yytext[yyleng] = 0;
	}
	yy_end++;
	yy_save = c;
#else
	if (yy_push <= yy_save)
		YY_FATAL(gettext("Push-back buffer overflow"));
	*--yy_push = c;
#endif
	if (c == YYNEWLINE)
		yylineno--;
	return c;
}

#line 376 "scan.l"

/*
   If a replacement string was specified on command line, substitute for
   this lexeme.  Return whether this identifier had a replacement string.
*/
static BOOLEAN identifier_defined(char *id)
{
   unsigned i;

   /* Look through command-line arguments for the define option character. */
   for (i = 1; i < cmd_line_argc; ++i)
      if (strchr(OPT_INTRO_CHARS, cmd_line_argv[i][0]) != NULL &&
            toupper(cmd_line_argv[i][1]) == DEFINE_OPT_CHAR)
      {
         char *repl_str;

         /* Look for equal sign after identifier. */
         repl_str = (char *)strchr(&cmd_line_argv[i][2], '=');

         /*
            If equal sign found and this is a define for this
            identifier, substitute replacement string for this lexeme.
         */
         if (repl_str != NULL && strncmp(&cmd_line_argv[i][2], id,
                                       repl_str - &cmd_line_argv[i][2]) == 0)
         {
            unsigned len;
            char *p;

            /*
               unput replacement string so that lex will scan it in as
               if it occurred in the input stream instead of the
               original identifier.  NOTE: If empty replacement string,
               the affect is that the identifier is ignored.
            */
            for (len = strlen(&repl_str[1]), p = &repl_str[len]; len > 0;
                                                                     --len, --p)
               unput(*p);

            /*
               Leave outer loop because define option character found
               and processed.
            */
            break;
         }
      }

   return i < cmd_line_argc;
}

/* Initialize lexer. */
void init_lex(void)
{
   /*
      Restart lex itself.  Note: I don't believe that this is absolutely
      necessary for this lexer.  The lexer is not left in an unusual state
      after each file, e.g., characters left in the push-back buffer or the
      lexer being in a state other than INITIAL.  It is explicitly restarted
      here just because "it's the right thing to do."  If this macro reference
      expands to something that is not compatible with your lexer, although I
      tried to make it portable, just remove it.
   */
   MTR_YY_INIT;

   /* Reset line_type for first line.  Start off assuming blank line. */
   line_type = BLANK_LINE;

   yylineno = 1;
   found_tab = FALSE;
   found_space = FALSE;
   current_keyword = "";
   current_identifier = "";
}

#ifdef MTR_ATTLEX
/* Function that restarts AT&T lexers. */
static void yy_init(void)
{
   extern int yyprevious;

   NLSTATE;
   yysptr = yysbuf;
   BEGIN INITIAL;

/* I don't think these absolutely need to be reset. */
#if 0
   extern int *yyfnd;
   yyleng = 0;
   yytchar = 0;
   yymorfg = 0;
   yyestate = 0;
   yyfnd = 0;
#endif
}
#endif

/* Fire the keyword trigger. */
static void fire_keyword(void)
{
   current_keyword = yytext;
   rules();
   current_keyword = "";
}

/* Fire the identifier trigger. */
static void fire_identifier(void)
{
   current_identifier = yytext;
   rules();
   current_identifier = "";
}


#if READ_LINE

/* Pointer to next character in input_line[]. */
static char *next_char_p;

/*
   Replacement for the out-of-the-box yygetc().  This function provides
   access to the entire input line, even the characters that have not
   yet been scanned in.
*/
static int yygetc(void)
{
   static char last_char = EOF;   /* Force subsequent getting of first line.*/
   char next_char;
   int characters_read;

   switch (last_char)
   {
   case '\n':        /* Time to get another line of input? */
   case EOF:
      YY_INPUT(input_line, characters_read, INPUT_LINE_MAX_LEN);
      if (characters_read == 0)
      {
         next_char = EOF;           /* Indicate that couldn't get another line*/
         next_char_p = input_line;  /* Set to something. */
      }
      else
      {
         next_char_p = input_line;
         next_char = *next_char_p++;   /* Get first character from input line. */
      }
      break;

   default:                         /* Get next character from input line. */
      next_char = *next_char_p++;
   }

   last_char = next_char;

   return next_char;
}

/* Read next line from input file, returning number of characters read. */
static int my_yyinput(char *buf, int max_size)
{
   int characters_read;

   if (fgets(buf, max_size, yyin) == NULL)
      buf[0] = '\0';
   else
      /* This is where the input line is printed if display_print is TRUE. */
      if (display_input)
         fputs(buf, out_fp);

   return strlen(buf);
}

#endif      /* #if READ_LINE */

/*
   Called by yacc at the end of a source file.  If there are more files to
   process, open them and continue, else stop.
*/
yywrap()
{
   int ret_val;

   /* Provide module information then fire the end-of-module trigger. */
   int_mod.decisions = mod_decisions;
   int_mod.functions = mod_functions;
   int_mod.lines.total = yylineno - 1;
   int_mod.end = TRUE;
   fire_mod();
   int_mod.end = FALSE;
   ZERO(int_mod);

   /* See whether there is another input file to process. */
   if (next_cmd_line_file < cmd_line_argc &&
         (input_file = get_next_input_file(&next_cmd_line_file)) != NULL)
      if (freopen(input_file, "r", yyin) != NULL)
      {
         /* Reinitialize yacc and lex. */
         init_yacc();
         init_lex();

         /*
            See whether to use the original file name as provided on the
            command line rather than the file name that was provided.  This
            is in case the output of the preprocessor is the input file and
            there are no line directives, but we'd like to use the name of
            the input to the preprocessor.
         */
         input_file_orig_name =
               get_next_input_file_orig_name(&next_cmd_line_file_orig_n);
         if (input_file_orig_name == NULL)
            input_file_orig_name = input_file;

         /* Fire the beginning-of-module trigger. */
         ZERO(int_mod);
         int_mod.begin = TRUE;
         fire_mod();
         int_mod.begin = FALSE;

         /* Tell yacc to continue. */
         ret_val = 0;
      }
      else
      {
         warn(W_CANNOT_OPEN_FILE, input_file);

         /* Fire the end-of-project trigger. */
         int_prj.end = TRUE;
         fire_prj();
         int_prj.end = FALSE;
         ZERO(int_prj);

         /* Tell yacc to stop. */
         ret_val = 1;
      }
   else
   {
      /* Fire the end-of-project trigger. */
      int_prj.end = TRUE;
      fire_prj();
      int_prj.end = FALSE;
      ZERO(int_prj);

#ifdef DEBUG_TYPEDEF
      /* Used for debugging typedef processing. */
      typedef_symbol_table_dump();
#endif

      /* Tell yacc to stop. */
      ret_val = 1;
   }

   return ret_val;
}

/*
   The beginning of a comment has been detected.  Handle until the entire
   comment has been consumed, then give control back over to lex.
*/
static void comment(void)
{
   char c;

   /* If this was just a blank line, it now becomes a comment line. */
   if (line_type == BLANK_LINE)
      line_type = COMMENT_LINE;

   /* Loop until input exhausted or end-of-comment reached. */
   for ( ; (c = input()) != '\0'; )
      if (c == '*')                    /* Could be end-of-comment. */
      {
         char c1;

         if ((c1 = input()) == '/')
            break;                     /* Is end-of-comment. */
         else
            unput(c1);                 /* False alarm.  Not end-of-comment. */
      }
      else if (c == '\n')
      {
         INCR_YYLINENO;

         /* Provide line information then fire the end-of-line trigger. */
         int_lin.number = yylineno;
         int_lin.is_comment = TRUE;
         int_lin.end = TRUE;
         fire_lin();
         ZERO(int_lin);

         /* Reset these BOOLEANs for the next line. */
         found_tab = FALSE;
         found_space = FALSE;

         /* Increment the number-of-comment-lines counter. */
         ++int_mod.lines.com;
      }
}

/*
   Count various things associated with input tokens.  All input, except
   for comments and preprocessor lines pass through here.
*/
static void count(void)
{
   int i;

   for (i = 0; yytext[i] != '\0'; i++)
      switch (yytext[i])
      {
      case '\n':
         /* Provide line information then fire the end-of-line trigger. */
         switch (line_type)
         {
         case BLANK_LINE:
            int_lin.is_white = TRUE;
            ++int_mod.lines.white;
            break;

         case COMMENT_LINE:
            int_lin.is_comment = TRUE;
            ++int_mod.lines.com;
            break;

         case CODE_LINE:
            int_lin.is_exec = TRUE;
            ++int_mod.lines.exec;
            break;

         default:
            fatal(E_LINE_TYPE);
         }
         /* Reset line_type for next line.  Start off assuming blank line. */
         line_type = BLANK_LINE;

         int_lin.number = yylineno;
         int_lin.end = TRUE;
         fire_lin();
         ZERO(int_lin);

         /* Reset these BOOLEANs for the next line. */
         found_tab = FALSE;
         found_space = FALSE;
         break;

      /*
         The next two cases are trying to figure out whether spaces and tabs
         are both being used for indention on the same line--a little pet peeve
         of mine.
      */
      case '\t':
         if (line_type == BLANK_LINE && found_space)
            int_lin.is_mixed_indent = TRUE;
         found_tab = TRUE;
         break;

      case ' ':
         if (line_type == BLANK_LINE && found_tab)
            int_lin.is_mixed_indent = TRUE;
         found_space = TRUE;
         break;

      default:
         /*
            If not one of the above, special characters, there must be code on
            this line.
         */
         if (isgraph(yytext[i]))
            line_type = CODE_LINE;
      }
}

/*
   Return whether the token in yytext[] is just an identifier or is a
   previously typedef'd name.
*/
static int check_type(void)
{
   int type;

   /*
      looking_for_tag is set to TRUE only when the parser is looking for a
      struct, union, or enum tag.  Since tags are in a separate name space,
      the current lexeme can never be a typedef type name and are therefore
      always an identifier.
   */
   if (looking_for_tag)
      type = TK_IDENTIFIER;
   else
      /*
         If lexeme was previously defined as a typedef type name, return
         token for type name, else return token for identifier.  Note that
         the parser puts identifiers in the typedef symbol table, not the
         lexer.
      */
      type = typedef_symbol_table_find(yytext) ? TK_TYPE_NAME : TK_IDENTIFIER;

   return type;
}

/* Return whether the specified keyword is the current keyword. */
BOOLEAN keyword(char *name)
{
   return strcmp(current_keyword, name) == 0;
}

/* Return whether the specified identifier is the current identifier. */
BOOLEAN identifier(char *name)
{
   return strcmp(current_identifier, name) == 0;
}

/* Return pointer to current input token (lexeme). */
char *token(void)
{
   return yytext;
}

/* Return pointer to input buffer which contains current line. */
char *line(void)
{
#if READ_LINE
   return input_line;
#else
   return "";
#endif
}

/*
   Return string with marker character indicating current position of parser.
   Note that this line always ends with a newline character.
*/
char *marker(void)
{
#if READ_LINE
   static char marker_str[INPUT_LINE_MAX_LEN];
   char *dst_p, *src_p;

   /* Replace all graphic characters in input buffer with space character. */
   for (dst_p = marker_str, src_p = input_line;
         src_p < next_char_p && *src_p != '\0' &&
         /* Leave room for marker character, newline, and '\0'. */
         dst_p < marker_str + sizeof marker_str - 2;
         ++dst_p, ++src_p)
      *dst_p = isgraph(*src_p) ? ' ' : *src_p;

   if (dst_p == marker_str)
      strcpy(dst_p, "\n");       /* Nothing scanned in yet, so can't mark. */
   else
      strcpy(&dst_p[-1], "-\n"); /* Terminate line with marker character. */

   return marker_str;
#else
   return "";
#endif      /* #if READ_LINE */
}

/* Fire the lex trigger with nonstandard set to TRUE. */
static void found_nonstandard(void)
{
   int_lex.nonstandard = yytext[0];
   fire_lex();
   ZERO(int_lex);
}

/* Extract and return the line number out of the #line directive. */
static unsigned extract_line_number(char *string)
{
   return (unsigned)strtol(&string[strcspn(string, "0123456789")], NULL, 10);
}

/*
   Extract and return the file name out of the #line directive. If not present,
   return NULL.
*/
static char *extract_file_name(char *string)
{
   char *start_of_file_name;

   /* File name is enclosed in quotes. Return NULL if no first quote. */
   start_of_file_name = strchr(string, '"');
   if (start_of_file_name != NULL)
   {
      char *end_of_file_name;

      ++start_of_file_name;      /* Skip past first quote. */

      /* If no trailing quote, return NULL. */
      end_of_file_name = strchr(start_of_file_name, '"');
      if (end_of_file_name == NULL)
         start_of_file_name = NULL;
      else
      {
         size_t file_name_length;
         static char return_buffer[MTR_YYTEXT_SIZE];

         file_name_length = end_of_file_name - start_of_file_name;

         /* Copy file name between quotes. */
         strncpy(return_buffer, start_of_file_name, file_name_length);
         return_buffer[file_name_length] = '\0';

         /* Buffer is static, so it's still viable after returning. */
         start_of_file_name = return_buffer;
      }
   }

   return start_of_file_name;
}
