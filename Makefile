#CC=gcc
#CFLAGS=-m64 -Wall -ansi -pedantic -Os
#LDFLAGS=
RPCGEN = rpcgen

RPCSRC = bootparam_prot.x
RPCGENSRC = bootparam_prot.h bootparam_prot_svc.c bootparam_prot_xdr.c
RPCOBJS = bootparam_prot_svc.o bootparam_prot_xdr.o

all: rarpd bootparamd

bootparamd_main.o: bootparamd_main.c bootparam_prot.h
bootparamd.o: bootparamd.c bootparam_prot.h

rarpd: rarpd.o
	$(CC) $(LDFLAGS) -o $@ $+

bootparamd: bootparamd_main.o bootparamd.o $(RPCOBJS)
	$(CC) $(LDFLAGS) -l rpcsvc -o $@ $+

bootparam_prot.h: $(RPCSRC)
	$(RPCGEN) -C -h -o $@ $+

bootparam_prot_svc.c: $(RPCSRC)
	$(RPCGEN) -C -m -o $@ $+
	@sed -i '' 's/syslog(\([^,]*,[ \t]*\)\([a-z]*\))/syslog(\1"%s", \2)/' $@

bootparam_prot_xdr.c: $(RPCSRC)
	$(RPCGEN) -C -c -o $@ $+

clean:
	@rm -f rarpd.o bootparamd_main.o bootparamd.o $(RPCOBJS) $(RPCGENSRC)

distclean: clean
	@rm -f rarpd bootparamd
