all: rarpd

rarpd: rarpd.o
	$(CC) $(LDFLAGS) -o $@ $+

clean:
	rm -f rarpd.o
