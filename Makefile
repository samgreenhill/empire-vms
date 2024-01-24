#
#    Copyright (C) 1987, 1988 Chuck Simmons
#
# See the file COPYING, distributed with empire, for restriction
# and warranty information.

VERS=1.13

# Use -g to compile the program for debugging.
#DEBUG = -g -DDEBUG
DEBUG = -O2

CC = gcc

# Use -p to profile the program.
#PROFILE = -p -DPROFILE
PROFILE =

LIBS = -lncurses

# You shouldn't have to modify anything below this line.

# There's a dynamic format in the object-display routines; suppress the warning
CFLAGS = $(DEBUG) $(PROFILE) -Wall -Wno-format-security -fcommon -I${INC_DIR}

INC_DIR = include
SRC_DIR = src
BUILD_DIR = build

FILES = \
	${SRC_DIR}/attack.c \
	${SRC_DIR}/compmove.c \
	${SRC_DIR}/data.c \
	${SRC_DIR}/display.c \
	${SRC_DIR}/edit.c \
	${SRC_DIR}/empire.c \
	${SRC_DIR}/game.c \
	${SRC_DIR}/main.c \
	${SRC_DIR}/map.c \
	${SRC_DIR}/math.c \
	${SRC_DIR}/object.c \
	${SRC_DIR}/term.c \
	${SRC_DIR}/usermove.c \
	${SRC_DIR}/util.c

HEADERS = ${INC_DIR}/empire.h ${INC_DIR}/extern.h

OFILES = \
	$(BUILD_DIR)/attack.o \
	$(BUILD_DIR)/compmove.o \
	$(BUILD_DIR)/data.o \
	$(BUILD_DIR)/display.o \
	$(BUILD_DIR)/edit.o \
	$(BUILD_DIR)/empire.o \
	$(BUILD_DIR)/game.o \
	$(BUILD_DIR)/main.o \
	$(BUILD_DIR)/map.o \
	$(BUILD_DIR)/math.o \
	$(BUILD_DIR)/object.o \
	$(BUILD_DIR)/term.o \
	$(BUILD_DIR)/usermove.o \
	$(BUILD_DIR)/util.o

all: $(BUILD_DIR) vms-empire

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

vms-empire: $(OFILES)
	$(CC) $(PROFILE) -o $(BUILD_DIR)/vms-empire $(OFILES) $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -c -o $@ $<

empire.6: vms-empire.xml
	xmlto man vms-empire.xml

vms-empire.html: vms-empire.xml
	xmlto html-nochunks vms-empire.xml

TAGS: $(HEADERS) $(FILES)
	etags $(HEADERS) $(FILES)

lint: $(FILES)
	lint -u -D$(SYS) $(FILES) -lcurses

# cppcheck should run clean
cppcheck:
	cppcheck --inline-suppr --suppress=unusedStructMember --suppress=unusedFunction  --template gcc --enable=all --force -I ${INC_DIR} ${SRC_DIR}/*.[c]

install: empire.6 uninstall
	install -m 0755 -d $(DESTDIR)/usr/bin
	install -m 0755 -d $(DESTDIR)/usr/share/man/man6
	install -m 0755 -d $(DESTDIR)/usr/share/applications/
	install -m 0755 -d $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/
	install -m 0755 -d $(DESTDIR)/usr/share/appdata
	install -m 0755 vms-empire $(DESTDIR)/usr/bin/
	install -m 0644 empire.6 $(DESTDIR)/usr/share/man/man6/vms-empire.6
	install -m 0644 vms-empire.desktop $(DESTDIR)/usr/share/applications/
	install -m 0644 vms-empire.png $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/
	install -m 0644 vms-empire.xml $(DESTDIR)/usr/share/appdata/

uninstall:
	rm -f /usr/bin/vms-empire /usr/share/man/man6/vms-empire.6
	rm -f /usr/share/applications/vms-empire.desktop
	rm -f /usr/share/icons/hicolor/48x48/apps/vms-empire.png
	rm -f /usr/share/appdata/vms-empire.xml

clean:
	rm -rf build
	rm -f *.o TAGS vms-empire
	rm -f *.6 *.html

clobber: clean
	rm -f vms-empire vms-empire-*.tar*

SOURCES = README HACKING NEWS control empire.6 vms-empire.xml COPYING Makefile BUGS AUTHORS $(FILES) $(HEADERS) vms-empire.png vms-empire.desktop

vms-empire-$(VERS).tar.gz: $(SOURCES)
	@ls $(SOURCES) | sed s:^:vms-empire-$(VERS)/: >MANIFEST
	@(cd ..; ln -s vms-empire vms-empire-$(VERS))
	(cd ..; tar -czf vms-empire/vms-empire-$(VERS).tar.gz `cat vms-empire/MANIFEST`)
	@(cd ..; rm vms-empire-$(VERS))

dist: vms-empire-$(VERS).tar.gz

release: vms-empire-$(VERS).tar.gz vms-empire.html
	shipper version=$(VERS) | sh -e -x
