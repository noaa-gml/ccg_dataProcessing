# This makefile creates a library >> odrpack.a << comprised of both the single
# and double precision versions of ODRPACK.  It also runs each of the test
# problems for both versions.  Change S_SOURCE (D_SOURCE) and S_TESTS (D_TESTS)
# as approprite if only the double precision (single precision) version is to
# be installed.

# NB:  This makefile creates a temporary subdirectory, >> ZodrpackZ <<, for
#      splitting and compiling the individual subprograms in each of the
#      release files.  The makefile will fail if such a subdirectory already
#      exists.  The subdirectory is automatically removed upon completion.

#      Note also that some systems need to invoke ranlib, while others do not:
#      if your system lacks ranlib, simply comment out the ranlib invocation
#      below.  Also, compiler names and options, and/or names of data files may 
#      have to be modified for some systems.


.SUFFIXES: .f .o .a .out
F77 = f77       # specify compiler name as appropriate
F77OPT = -u -O  # specify desired compiler options here
LIB = odrpack.a # specify ODRPACK library name
DIR = ZodrpackZ # specify temporary subdirectory name
L =             # specify directory for library files

# Specify what files are to be installed, where
# D_SOURCE = double-precision non-test source files
#          = d_odr.f d_lpkbls.f d_mprec.f
# S_SOURCE = single-precision non-test source files
#          = s_odr.f s_lpkbls.f s_mprec.f
D_SOURCE = d_odr.f d_lpkbls.f d_mprec.f
S_SOURCE = s_odr.f s_lpkbls.f s_mprec.f



# Test installation...

tests: D_TESTS S_TESTS
D_TESTS: d_drive1.out d_drive2.out d_drive3.out d_test.out
S_TESTS: s_drive1.out s_drive2.out s_drive3.out s_test.out


# Create ODRPACK library...

$(LIB): $(D_SOURCE) $(S_SOURCE)
	mkdir $(DIR)
	cd $(DIR) ;\
	  for i in $? ;\
	    do fsplit ../$$i ;\
	       $(F77) -c $(F77OPT) *.f ;\
	       ar ruv ../$@ *.o ;\
	       rm *.f *.o ;\
	    done ;\
	  cd ..
	rm -rf $(DIR)
	ranlib $(LIB)

d_mprec.f: d_mprec0.f
	true  # Obtain d_mprec.f from d_mprec0.f by activating the statements
	false # appropriate to your machine

s_mprec.f: s_mprec0.f
	true  # Obtain s_mprec.f from s_mprec0.f by activating the statements
	false # appropriate to your machine


# Run double-precision test problems...

d_drive1.out: d_drive1.f $(LIB) data1.dat
	cp data1.dat DATA1
	$(F77) d_drive1.f $(LIB) $L; ./a.out
	mv REPORT1 $@; rm -f DATA1 d_drive1.o a.out

d_drive2.out: d_drive2.f $(LIB) data2.dat
	cp data2.dat DATA2
	$(F77) d_drive2.f $(LIB) $L; ./a.out
	mv REPORT2 $@; rm -f DATA2 d_drive2.o a.out

d_drive3.out: d_drive3.f $(LIB) data3.dat
	cp data3.dat DATA3
	$(F77) d_drive3.f $(LIB) $L; ./a.out 
	mv REPORT3 $@; rm -f DATA3 d_drive3.o a.out

d_test.out: d_test.f $(LIB)
	$(F77) d_test.f $(LIB) $L; ./a.out
	mv REPORT $@; cat SUMMARY >> $@; rm -f d_test.o a.out SUMMARY


# Run single-precision test problems...

s_drive1.out: s_drive1.f $(LIB) data1.dat
	cp data1.dat DATA1
	$(F77) s_drive1.f $(LIB) $L; ./a.out
	mv REPORT1 $@; rm -f DATA1 s_drive1.o a.out

s_drive2.out: s_drive2.f $(LIB) data2.dat
	cp data2.dat DATA2
	$(F77) s_drive2.f $(LIB) $L; ./a.out
	mv REPORT2 $@; rm -f DATA2 s_drive2.o a.out

s_drive3.out: s_drive3.f $(LIB) data3.dat
	cp data3.dat DATA3
	$(F77) s_drive3.f $(LIB) $L; ./a.out 
	mv REPORT3 $@; rm -f DATA3 s_drive3.o a.out

s_test.out: s_test.f $(LIB)
	$(F77) s_test.f $(LIB) $L; ./a.out
	mv REPORT $@; cat SUMMARY >> $@; rm -f s_test.o a.out SUMMARY

