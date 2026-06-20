/*
 *	C++ scanner for GoldED
 *
 * by Gega in 1997
 */

#include <exec/types.h>


#define isName(x)	(((x)>=48&&(x)<58)||((x)>=64&&(x)<=90)||((x)>=97&&(x)<=122)||(x)==95||(x)==126)
#define isOper(x)	(!isName(x)&&(x)>32&&(x)<=126)


ULONG __asm ScanHandlerCpp(	register __d0 ULONG len,
				register __a0 char **text,
				register __a1 ULONG *line)
{
const char *version = "$VER: C++ 1.0 (23.09.97)";
const char *opstr = "operator";
const int oplen=8;
const char *clstr = "class";
const int cllen=5;

if(len) {
	int i;
	ULONG ret;

	// kezdõ space-k
	for(i=0;**text==' '&&i<len;i++,(*text)++);	// spc

	// class ??	
	if(**text=='c') {		// lehet, hogy class
		char *cls;
		int h;

		for(h=i,cls=*text;h<len&&clstr[h-i]==*cls;h++,cls++) {}
		if(h-i==cllen) {
			// class !
			for(;h<len&&*cls==' ';cls++,h++);	// spc
			for(;h<len&&isName(*cls);cls++,h++);	// a neve
			ret=(ULONG)h-i;
			for(;h<len&&*cls!=';';cls++,h++);	// ; ?
			if(*cls==';') return(FALSE);	// elõdeklaráció
			return(ret);
			}
		}
	for(i=0;i<len&&**text>=' '&&**text<='~'&&**text!=':';i++,(*text)++);
	if(i>len-1) return(FALSE);
	if(**text==':'&&*((*text)+1)==':') {
		// external method ( ... :: ...)
		char *brace=(*text)+2;		// :: után (zárójelhez)
		int j,h;

		// vissza a classnév elejére:
		for(j=i-1,(*text)--;**text==' '&&j>0;j--,(*text)--);	// spc
		if(j==0) return(FALSE);
		for(;isName(**text)&&--j>=0;(*text)--);			// név
		if(j>0||!isName(**text)) (*text)++;

		// a :: utáni space-k átlépése
		for(i+=2;*brace==' '&&i<len;i++,brace++);	// spc

		// a metódus 'operator' ?
		for(h=i;h<len&&*(brace+h-i)==opstr[h-i]&&h-i<oplen;h++);
		if(h-i!=oplen) {	// normál metódus
			// keressük a nyitó zárójelet
			for(;isName(*brace)&&i<len;i++,brace++);	// név
			h=i-1;
			for(;*brace==' '&&i<len;i++,brace++);		// spc
			if(i==len) return(FALSE);
			if(*brace!='(') return(FALSE);	// nincs nyitó zárójel
			ret=((ULONG)h-j);
			}
		else {			// operator
			brace+=oplen;
			h++;
			if(!isOper(*brace)) return(FALSE); // hibás operator
			if(*++brace!='(') {
				if(isOper(*brace)) brace++,h++;
				for(;*brace==' '&&h<len;h++,brace++);	// spc
				if(h==len) return(FALSE);
				if(*brace!='(') return(FALSE);
				ret=((ULONG)h-1-j);
				}
			else ret=((ULONG)h-j-1);
			}
		// van a végén pontosvesszõ? (ha van, hívás)
		for(;h<len&&*brace!=')';h++,brace++);		// záró )
		if(*brace!=')') return(FALSE);			// nincs
		for(;h<len&&*brace!=';';h++,brace++);		// van ; ?
		if(*brace==';') return(FALSE);			// van
		return(ret);
		}
	else return(FALSE);
	}
return(FALSE);
}
