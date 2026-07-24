# Compiler and flags
FPC     = fpc
FFLAGS  = -O2
TARGET  = pasfetch
SRC     = pasfetch.pas
PREFIX ?= /usr/local

# Binary compiler
all: $(TARGET)

$(TARGET): $(SRC)
	$(FPC) $(FFLAGS) $(SRC)

# Install on the system
install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/$(TARGET)

# Clean the binaries
clean:
	rm -f $(TARGET) *.o *.ppu

# remove from the system
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(TARGET)

.PHONY: all clean install uninstall
