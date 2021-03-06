LIBNAME=	librsaref
SRC=		rsaref.c
OBJ=		rsaref.o
HEADER=		rsaref.h

CC=		gcc
PIC=		-fPIC
CFLAGS=		-g -I../../../include $(PIC) -DENGINE_DYNAMIC_SUPPORT
AR=		ar r
RANLIB=		ranlib

LIB=		$(LIBNAME).a
SHLIB=		$(LIBNAME).so

all:
		@echo 'Please choose a system to build on:'
		@echo ''
		@echo 'tru64:    Tru64 Unix, Digital Unix, Digital OSF/1'
		@echo 'solaris:  Solaris'
		@echo 'irix:     IRIX'
		@echo 'hpux32:   32-bit HP/UX'
		@echo 'hpux64:   64-bit HP/UX'
		@echo 'aix:      AIX'
		@echo 'gnu:      Generic GNU-based system (gcc and GNU ld)'
		@echo ''

FORCE.install:
install:	FORCE.install
		cd install; \
			make -f unix/makefile CFLAGS='-fPIC -I. -DPROTOTYPES=1 -O -c' RSAREFLIB=librsaref.a librsaref.a

FORCE.update:
update:		FORCE.update
		perl ../../../util/mkerr.pl -conf rsaref.ec \
			-nostatic -staticloader -write rsaref.c

darwin:		install $(SHLIB).darwin
cygwin:		install $(SHLIB).cygwin
gnu:		install $(SHLIB).gnu
alpha-osf1:	install $(SHLIB).alpha-osf1
tru64:		install $(SHLIB).tru64
solaris:	install $(SHLIB).solaris
irix:		install $(SHLIB).irix
hpux32:		install $(SHLIB).hpux32
hpux64:		install $(SHLIB).hpux64
aix:		install $(SHLIB).aix
reliantunix:	install $(SHLIB).reliantunix

$(LIB):		$(OBJ)
		$(AR) $(LIB) $(OBJ)
		- $(RANLIB) $(LIB)

LINK_SO=	\
  ld -r -o $(LIBNAME).o $$ALLSYMSFLAGS $(LIB) install/librsaref.a && \
  (nm -Pg $(LIBNAME).o | grep ' [BDT] ' | cut -f1 -d' ' > $(LIBNAME).exp; \
   $$SHAREDCMD $$SHAREDFLAGS -o $(SHLIB) $(LIBNAME).o -L ../../.. -lcrypto -lc)

$(SHLIB).darwin:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-all_load' \
		SHAREDFLAGS='-dynamiclib -install_name $(SHLIB)' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).darwin
$(SHLIB).cygwin:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='--whole-archive' \
		SHAREDFLAGS='-shared -Wl,-Bsymbolic -Wl,--out-implib,$(LIBNAME).dll.a' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).cygwin
$(SHLIB).gnu:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='--whole-archive' \
		SHAREDFLAGS='-shared -Wl,-soname=$(SHLIB)' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).gnu
$(SHLIB).tru64:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-all' \
		SHAREDFLAGS='-shared' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).tru64
$(SHLIB).solaris:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-z allextract' \
		SHAREDFLAGS='-G -h $(SHLIB)' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).solaris
$(SHLIB).irix:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-all' \
		SHAREDFLAGS='-shared -Wl,-soname,$(SHLIB)' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).irix
$(SHLIB).hpux32:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-Fl' \
		SHAREDFLAGS='+vnocompatwarnings -b -z +s +h $(SHLIB)' \
		SHAREDCMD='/usr/ccs/bin/ld'; \
		$(LINK_SO)
		touch $(SHLIB).hpux32
$(SHLIB).hpux64:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='+forceload' \
		SHAREDFLAGS='-b -z +h $(SHLIB)' \
		SHAREDCMD='/usr/ccs/bin/ld'; \
		$(LINK_SO)
		touch $(SHLIB).hpux64
$(SHLIB).aix:	$(LIB) install/librsaref.a
		ALLSYMSFLAGS='-bnogc' \
		SHAREDFLAGS='-G -bE:$(LIBNAME).exp -bM:SRE' \
		SHAREDCMD='$(CC)'; \
		$(LINK_SO)
		touch $(SHLIB).aix

depend:
		sed -e '/^# DO NOT DELETE.*/,$$d' < Makefile > Makefile.tmp
		echo '# DO NOT DELETE THIS LINE -- make depend depends on it.' >> Makefile.tmp
		gcc -M $(CFLAGS) $(SRC) >> Makefile.tmp
		perl ../../../util/clean-depend.pl < Makefile.tmp > Makefile.new
		rm -f Makefile.tmp Makefile
		mv Makefile.new Makefile

clean:
		rm -f install/*.o install/*.a
		rm -f *.o *.a *.so *.exp *.gnu

# DO NOT DELETE THIS LINE -- make depend depends on it.

rsaref.o: ../../../crypto/asn1/asn1.h ../../../crypto/bio/bio.h
rsaref.o: ../../../crypto/bn/bn.h ../../../crypto/crypto.h
rsaref.o: ../../../crypto/dh/dh.h ../../../crypto/dsa/dsa.h
rsaref.o: ../../../e_os2.h ../../../crypto/engine/engine.h
rsaref.o: ../../../crypto/err/err.h ../../../crypto/lhash/lhash.h
rsaref.o: ../../../crypto/conf/conf.h
rsaref.o: ../../../crypto/opensslv.h
rsaref.o: ../../../crypto/ossl_typ.h ../../../crypto/rand/rand.h
rsaref.o: ../../../crypto/rsa/rsa.h ../../../crypto/stack/safestack.h
rsaref.o: ../../../crypto/stack/stack.h ../../../crypto/symhacks.h
rsaref.o: ../../../crypto/ui/ui.h rsaref.c rsaref_err.c rsaref_err.h
rsaref.o: source/des.h source/global.h source/md2.h source/md5.h source/rsa.h
rsaref.o: source/rsaref.h
