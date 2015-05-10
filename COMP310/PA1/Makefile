CFLAGS = -g -c -Wall `pkg-config fuse --cflags --libs`

LDFLAGS = `pkg-config fuse --cflags --libs`

SOURCES= disk_emu.c disk_emu.h sfs_test.c sfs_api.c sfs_api.h sfs_util.h

OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=sfs

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	gcc $(OBJECTS) $(LDFLAGS) -o $@

.c.o:
	gcc $(CFLAGS) $< -o $@

clean:
	rm -rf *.o *~ 
	rm $(EXECUTABLE)
