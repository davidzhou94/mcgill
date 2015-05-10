CFLAGS = -g -c -Wall 

LDFLAGS = 

SOURCES= malloc_test.c malloc_api.h malloc_api.c

OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=malloc_test

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	gcc $(OBJECTS) $(LDFLAGS) -o $@

.c.o:
	gcc $(CFLAGS) $< -o $@

clean:
	rm -rf *.o *~ 
	rm $(EXECUTABLE)
