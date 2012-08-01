# project name (generate executable with this name)
TARGET      = c64_emu
TEST_RUNNER = test_runner

# remove helper
rm       = rm -f

CXX      = g++
# compiling flags here
CXXFLAGS = -Wall `cppunit-config --cflags`

LINKER   = g++ -o
# linking flags here
LFLAGS   = `cppunit-config --libs`

DIR_SOURCE       := src
DIR_INCLUDE      := include
DIR_TEST         := test
DIR_TEST_INCLUDE := $(DIR_TEST)/include
DIR_BUILD        := build
DIR_BIN          := $(DIR_BUILD)/bin
DIR_OBJECTS      := $(DIR_BUILD)/output
DIR_TEST_OBJECTS := $(DIR_BUILD)/test

BUILD_SOURCES  := $(wildcard $(DIR_SOURCE)/*.cpp)
BUILD_INCLUDES := $(wildcard $(DIR_INCLUDE)/*.hpp)
BUILD_OBJECTS  := $(BUILD_SOURCES:$(DIR_SOURCE)/%.cpp=$(DIR_OBJECTS)/%.o)

TEST_SOURCES   := $(wildcard $(DIR_TEST)/*.cpp)
TEST_INCLUDES  := $(wildcard $(DIR_TEST_INCLUDE)/*.hpp)
TEST_OBJECTS   := $(TEST_SOURCES:$(DIR_TEST)/%.cpp=$(DIR_TEST_OBJECTS)/%.o)

# Sources compile & linking
$(DIR_BIN)/$(TARGET): $(BUILD_OBJECTS)
	@mkdir -p $(DIR_OBJECTS)
	@mkdir -p $(DIR_BIN)
	@$(LINKER) $@ $(LFLAGS) $(BUILD_OBJECTS)
	@echo "Linking BUILD complete!"

$(BUILD_OBJECTS): $(DIR_OBJECTS)/%.o : $(DIR_SOURCE)/%.cpp
	@mkdir -p $(DIR_OBJECTS)
	@$(CXX) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

# Test compile & linking
$(DIR_BUILD)/$(TEST_RUNNER): $(TEST_OBJECTS) $(BUILD_OBJECTS)
	@mkdir -p $(DIR_TEST_OBJECTS)
	@mkdir -p $(DIR_OBJECTS)
	@mkdir -p $(DIR_BIN)
	@$(LINKER) $@ $(LFLAGS) $(TEST_OBJECTS) \
		$(filter-out $(DIR_OBJECTS)/main.o, $(BUILD_OBJECTS))
	@echo "Linking TEST complete!"
 
$(TEST_OBJECTS): $(DIR_TEST_OBJECTS)/%.o : $(DIR_TEST)/%.cpp
	@mkdir -p $(DIR_TEST_OBJECTS)
	@$(CXX) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

test: $(BUILD_OBJECTS) $(DIR_BUILD)/$(TEST_RUNNER)
	@echo Running test suite ...
	@./$(DIR_BUILD)/$(TEST_RUNNER)

run: $(DIR_BIN)/$(TARGET)
	@echo Running $(DIR_BIN)/$(TARGET) ...
	@./$(DIR_BIN)/$(TARGET)

.PHONEY: clean
clean:
	@$(rm) $(BUILD_OBJECTS)
	@$(rm) $(TEST_OBJECTS)
	@$(rm) $(DIR_BUILD)/$(TEST_RUNNER)
	@echo "Cleanup complete!"

.PHONEY: remove
remove: clean
	@$(rm) $(DIR_BIN)/$(TARGET)
	@echo "Executable removed!"
