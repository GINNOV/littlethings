.PHONY:clean
.PHONY:all
LDFLAGS=$(shell sdl-config --libs)
all:spline bezier hemite
spline:spline.o matrix.o midpoint_line.o
bezier:bezier.o matrix.o midpoint_line.o
hemite:hemite.o matrix.o midpoint_line.o
clean:
	@ rm -f hemite hemite.o matrix.o midpoint_line.o bezier.o bezier \
spline.o spline
