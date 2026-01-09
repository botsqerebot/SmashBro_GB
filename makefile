# Game Boy project Makefile

# Define the name of your game (without extension)
GAME_NAME = hello-world

# Tools
RGBASM = rgbasm
RGBLINK = rgblink
RGBFIX = rgbfix

# Directories
SRC_DIR = src
BUILD_DIR = build

# Files
ASM_FILE = $(SRC_DIR)/main.asm
OBJ_FILE = $(BUILD_DIR)/$(GAME_NAME).o
ROM_FILE = $(GAME_NAME).gb
SYM_FILE = $(GAME_NAME).sym
MAP_FILE = $(BUILD_DIR)/$(GAME_NAME).map

# Build the ROM
all: $(ROM_FILE)

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble the source file
$(OBJ_FILE): $(ASM_FILE) | $(BUILD_DIR)
	$(RGBASM) -i $(SRC_DIR)/ -o $(OBJ_FILE) $(ASM_FILE)

# Link the object file into a ROM
$(ROM_FILE): $(OBJ_FILE)
	$(RGBLINK) -n $(SYM_FILE) -m $(MAP_FILE) -o $(ROM_FILE) $(OBJ_FILE)
	$(RGBFIX) -v -p 0xFF $(ROM_FILE)

# Clean build files
clean:
	rm -rf $(BUILD_DIR) $(ROM_FILE) $(SYM_FILE)

# Rebuild everything from scratch
rebuild: clean all

.PHONY: all clean rebuild
