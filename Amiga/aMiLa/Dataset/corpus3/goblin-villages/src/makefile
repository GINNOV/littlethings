CC = vc

ACE_DIR = ACE:
GAME_DIR =
TMP_DIR = tmp/

GAME_FILES = $(wildcard $(SOURCE)*.c $(SOURCE)gamestates/menu/*.c $(SOURCE)gamestates/arcade/*.c)
GAME_OBJS = $(addprefix $(TMP_DIR), $(notdir $(GAME_FILES:.c=.o)))
ACE_OBJS = $(wildcard $(ACE_DIR)$(TMP_DIR)*.o)

core: ace game

ace:
	make -C $(ACE_DIR)
	cp $(ACE_DIR)$(TMP_DIR)*.o $(TMP_DIR)

game: $(GAME_OBJS)
	$(CC) $(CC_FLAGS) -o /$@ $^ $(ACE_OBJS)

$(TMP_DIR)%.o: $(GAME_DIR)%.c
	$(CC) -I$(GAME_DIR) $(CC_FLAGS) -c -o $@ $<
	
$(TMP_DIR)%.o: $(GAME_DIR)gamestates/menu/%.c
	$(CC) -I$(GAME_DIR) $(CC_FLAGS) -c -o $@ $<

$(TMP_DIR)%.o: $(GAME_DIR)gamestates/arcade/%.c
	$(CC) -I$(GAME_DIR) $(CC_FLAGS) -c -o $@ $<
		
all: clear core

clear:
	rm -f $(ACE_DIR)$(TMP_DIR)*.o
	rm -f $(TMP_DIR)*.o