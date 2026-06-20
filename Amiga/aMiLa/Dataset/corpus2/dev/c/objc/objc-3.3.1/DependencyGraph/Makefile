
OBJC=objc -g
OBJS=Graph.o Node.o mGraph.o

.SUFFIXES:.m

.m.o: 
	$(OBJC) -c $*.m -o $*.o

dg : $(OBJS) ; $(OBJC) $(OBJS) -o dg
wc : ; wc *.m
clean: ; rm -f *.o dg

