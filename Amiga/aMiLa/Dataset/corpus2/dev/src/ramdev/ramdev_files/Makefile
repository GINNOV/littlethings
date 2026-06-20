
CC     = $(CROSS_COMPILE)vc
AS     = $(CROSS_COMPILE)as
LD     = $(CROSS_COMPILE)ld
RANLIB = $(CROSS_COMPILE)ranlib
RM     = delete
CP     = copy

# Change these as required
OPTIMIZE = -O4
DEBUG =
CFLAGS = $(OPTIMIZE) $(DEBUG) -I. -Iinclude

# Flags passed to gcc during linking
LINK =

# Name of the "thing" to build
TARGET  = ramdev.device
VERSION = 51

# Additional linker libraries
LIBS =

# Source code files used in this project
# Add any additional files to this line

SRCS = init.c dev_unit.c dev_io.c dev_io_cmd.c dev_task.c

# -------------------------------------------------------------
# Nothing should need changing below this line

OBJS = $(SRCS:.c=.o)

# Rules for building
$(TARGET): $(OBJS)
	$(CC) -nostdlib $(LINK) -o $(TARGET) $(OBJS) $(LIBS)

.PHONY: install
install: $(TARGET) $(DT_DESC)
	$(CP) $(TARGET) SYS:Devs/

.PHONY: clean
clean:
	$(RM) $(TARGET) $(OBJS)

.PHONY: revision
revision:
	bumprev $(VERSION) $(TARGET)

