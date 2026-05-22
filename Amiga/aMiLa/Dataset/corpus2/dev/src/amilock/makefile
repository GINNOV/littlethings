SOURCE  = source/
HEADER  = headers/
BIN  	= bin/

GHEAD	= $(HEADER)Global.h $(HEADER)deamon.h
GLIB	= $(SOURCE)TalkTo.o $(SOURCE)Error.o

all: bin/Deamon bin/Login bin/logout bin/Kill bin/WhoAmI

bin/Deamon: $(SOURCE)deamon.o $(GLIB)
	slink with withdeamon

bin/Login:  $(SOURCE)login.o $(GLIB) $(SOURCE)inputhandler.o
	slink with withlogin

bin/logout: $(SOURCE)logout.o $(GLIB)
	slink with withlogout

bin/Kill: $(SOURCE)kill.o $(GLIB)
	slink with withkill

bin/WhoAmI: $(SOURCE)WhoAmI.o $(GLIB)
	slink with withwhoami

$(SOURCE)inputhandler.o: $(SOURCE)inputhandler.a
	asm $(SOURCE)inputhandler.a

$(SOURCE)error.o: $(SOURCE)error.c $(HEADER)error_proto.h
	sc $(SOURCE)error.c

$(SOURCE)WhoAmi.o: $(SOURCE)WhoAmI.c
	sc $(SOURCE)WhoAmi.c

$(SOURCE)kill.o: $(SOURCE)kill.c $(GHEAD) $(HEADER)deamon_proto.h
	sc $(SOURCE)kill.c

$(SOURCE)deamon.o: $(SOURCE)deamon.c $(GHEAD) $(HEADER)deamon_proto.h
	sc $(SOURCE)deamon.c

$(SOURCE)logout.o: $(SOURCE)logout.c $(GHEAD) $(HEADER)talkto_proto.h
	sc $(SOURCE)logout.c

$(SOURCE)login.o: $(SOURCE)login.c $(GHEAD) $(HEADER)talkto_proto.h $(HEADER)login.h
	sc $(SOURCE)login.c

$(SOURCE)talkto.o: $(SOURCE)talkto.c $(HEADER)deamon.h $(GHEAD)
	sc $(SOURCE)talkto.c
