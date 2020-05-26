# Makefile

# The directory in which source files are stored.
SOURCE = src

# The name of the output file to generate.
TARGET = pgm9_2

# The intermediate directory for compiled object files.
BUILD = build

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS = $(patsubst $(SOURCE)/%.asm,$(BUILD)/%.o,$(wildcard $(SOURCE)/*.asm))

# Rule to make everything.
all: $(TARGET)

 
# Rule to make the elf file.
$(TARGET): scriptLink.ld $(OBJECTS)
	ld  -o $(BUILD)/$(TARGET) $(OBJECTS) -T scriptLink.ld  -e main --strip-all --print-map >map1.txt
 
# Rule to make the object files.
$(BUILD)/%.o: $(SOURCE)/%.asm
	nasm  -f elf $< -o $@   
 
