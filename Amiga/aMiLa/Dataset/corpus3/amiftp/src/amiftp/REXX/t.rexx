/* */

portname="AMIFTP"

options results
address value portname

parse arg filepath

/*say filepath*/
filename=delstr(filepath, 1, index(filepath, "/"));
filename=left(filename, length(filename)-1);
/*say filename*/
GET filename
