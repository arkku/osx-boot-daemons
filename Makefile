RPCGEN = rpcgen

RPCSRC = bootparam_prot.x
RPCGENSRC = bootparam_prot.h bootparam_prot_svc.c bootparam_prot_xdr.c
RPCOBJS = bootparam_prot_svc.o bootparam_prot_xdr.o

all: rarpd bootparam_prot.h bootparamd

rarpd: rarpd.o
	$(CC) $(LDFLAGS) -o $@ $+

bootparamd: bootparamd_main.o bootparamd.o my-daemon.o $(RPCOBJS)
	$(CC) $(LDFLAGS) -l rpcsvc -o $@ $+

bootparam_main.o: bootparam_main.c bootparam_prot.h
bootparamd.o: bootparamd.c bootparam_prot.h

bootparam_prot.h: bootparam_prot.x
	$(RPCGEN) -C -h -o $@ $+

bootparam_prot_svc.c: $(RPCSRC)
	$(RPCGEN) -C -m -o $@ $+

bootparam_prot_xdr.c: $(RPCSRC)
	$(RPCGEN) -C -c -o $@ $+

clean:
	@rm -f rarpd.o bootparamd_main.o bootparamd.o my-daemon.o $(RPCOBJS) $(RPCGENSRC)

distclean: clean
	@rm -f rarpd bootparamd
