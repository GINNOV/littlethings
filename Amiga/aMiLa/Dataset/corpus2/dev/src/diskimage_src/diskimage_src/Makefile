CC     = vc
RM     = delete
CP     = copy

# Change these as required
OPTIMIZE = -O4 -size
DEBUG =
CFLAGS = $(OPTIMIZE) $(DEBUG) -Iinclude #-DDEBUG

# Flags passed to gcc during linking
LINK = $(OPTIMIZE) $(DEBUG) -Llib

# Name of the "thing" to build
TARGET  = diskimage.device
VERSION = 0

# Additional linker libraries
LIBS = -lvc

# Source code files used in this project
# Add any additional files to this line

SRCS = init.c io.c unit.c main.c scsicmd.c

# -------------------------------------------------------------
# Nothing should need changing below this line

OBJS = $(SRCS:.c=.o)

# Rules for building
$(TARGET): $(OBJS)
	$(CC) -nostdlib $(LINK) -o $@ $^ $(LIBS)

init.o: $(TARGET)_rev.h

.PHONY: install
install: $(TARGET)
	$(CP) $(TARGET) DEVS:

.PHONY: clean
clean:
	$(RM) $(TARGET) $(OBJS)

.PHONY: revision
revision:
	bumprev $(VERSION) $(TARGET)
