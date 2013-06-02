include ../system/make.common
include ../system/make.$(SYSTEM)

BINDIR = bin
SOURCEDIR = src

SELFTESTS =  \
    TestFastICA \
    TestEigenstuff \
    TestSphering \
    TestCovariance \
    TestReadWrite \
    TestMersenneTwister \
    TestMatrixOperations \
    TestCenterData


SELFTESTS_NAME = $(addsuffix -$(SYSTEM),$(SELFTESTS))
SELFTESTS_BIN = $(addprefix $(BINDIR)/,$(SELFTESTS_NAME))
SELFTESTS_CPP = $(addsuffix .cpp,$(SELFTESTS))
SOURCE = $(addprefix $(SOURCEDIR)/,$(SELFTESTS_CPP))

OBJECTS = ../obj/$(SYSTEM)/*.o

PTESTS = \
    ptest1 \
    ptest2 \
    ptest3 \
    ptest4 \
    ptest5 \
    ptest6 \
    ptest7


tmp:
	mkdir tmp

clean:
	rm -rf tmp $(BINDIR)

ptests: tmp mpisetup $(PTESTS) mpishutdown

selftests: $(BINDIR) $(SELFTESTS_BIN)

test:
	echo $(SOURCE) $(SELFTESTS_BIN)

$(BINDIR):
	mkdir $(BINDIR)
	
mpisetup:
	$(MPI_SETUP)

mpishutdown:
	$(MPI_SHUTDOWN)

ALL_CXX_FLAGS = $(LAPACK_DEFINE) $(TAU_DEFINE) $(TAU_DEFS) $(MPI_DEFINE) \
    -DINSTANTIATE_TEMPLATES $(OMP_DEFINE) $(OMP_FLAGS) $(MATRIX_DEFINE) \
    $(MATRIX_INCLUDE) $(TAU_INCLUDE) $(MPI_INCLUDE) \
    $(MATRIX_LIBS) $(MATRIX_LIB_PATH) $(TAU_LIBS) $(MPI_LIBS) $(OMP_LIBS) \
    $(CLIBS) $(CXX_FLAGS) $(OBJECTS) -I../src

$(BINDIR)/TestCenterData-$(SYSTEM): $(SOURCEDIR)/TestCenterData.cpp
	$(CXX) $(ALL_CXX_FLAGS) $< -o $@
	./$@ -io testData/testData.original.big.scf -ic testData/testData.centered.big.scf -c 34 -s 76001

$(BINDIR)/TestEigenstuff-$(SYSTEM): $(SOURCEDIR)/TestEigenstuff.cpp
	$(CXX) $< $(ALL_CXX_FLAGS)  -o $@ 
	./$@ -icov testData/testData.covariance.big.scf -ivec testData/testData.eigenvectors.big.scf -ival testData/testData.eigenvalues.big.scf -c 34
	
$(BINDIR)/TestCovariance-$(SYSTEM): $(SOURCEDIR)/TestCovariance.cpp
	$(CXX) $< $(ALL_CXX_FLAGS) -o $@
	$(MPI_SETUP)
	$(MPI_RUN) "`pwd`/$@" -io testData/testData.original.big.scf -ic testData/testData.covariance.big.scf -c 34 -s 76001
	$(MPI_SHUTDOWN)

$(BINDIR)/TestSphering-$(SYSTEM): $(SOURCEDIR)/TestSphering.cpp
	$(CXX) $< $(ALL_CXX_FLAGS) -o $@
	./$@ -icen testData/testData.centered.big.scf -icov testData/testData.covariance.big.scf -isph testData/testData.fastICASphering.big.scf -c 34 -s 76001
	./$@ -icen testData/testData.centered.big.scf -icov testData/testData.covariance.big.scf -isph testData/testData.infomaxSphering.big.scf -infomax -c 34 -s 76001

$(BINDIR)/TestFastICA-$(SYSTEM): $(SOURCEDIR)/TestFastICA.cpp
	$(CXX) $< $(ALL_CXX_FLAGS) -o $@
	./$@ -icen testData/testData.whitenedData.big.scf -isph testData/testData.fastICASphering.big.scf -c 34 -s 76001 -tol 0.0001 -maxIter 1000 -contrast cubic -init user -initFile testData/testData.initialGuess.big.scf -mixingMatrix testData/testData.mixingMatrix.big.scf -maxRetries 5
	
$(BINDIR)/%-$(SYSTEM): $(SOURCEDIR)/%.cpp
	$(CXX) $(ALL_CXX_FLAGS) $< -o $@
	./$@

ptest1:
	time $(MPI_RUN) "`pwd`/../bin/hipersat" FastICA_Prewhitened_cubic.form
	sleep 1
	@diff results/FastICA_Prewhitened_cubic_correct_ascii.wgt \
          tmp/FastICA_Prewhitened_cubic_ascii.wgt &> \
          tmp/FastICA_Prewhitened_cubic_diff.txt || \
          echo "ptest1 failed. Differences in tmp/FastICA_Prewhitened_cubic_diff.txt"

ptest2:
	time $(MPI_RUN) "`pwd`/../bin/hipersat" FastICA_Prewhitened_tanh.form
	sleep 1
	@diff results/FastICA_Prewhitened_tanh_correct_ascii.wgt \
          tmp/FastICA_Prewhitened_tanh_ascii.wgt &> \
          tmp/FastICA_Prewhitened_tanh_diff.txt || \
          echo "ptest2 failed. Differences in tmp/FastICA_Prewhitened_tanh_diff.txt"
          
ptest3:
	time $(MPI_RUN) "`pwd`/../bin/hipersat" FastICA_Unwhitened_cubic.form
	sleep 1
	@diff results/FastICA_Unwhitened_cubic_correct_ascii.wgt \
          tmp/FastICA_Unwhitened_cubic_ascii.wgt &> \
          tmp/FastICA_Unwhitened_cubic_diff.txt || \
          echo "ptest3 failed. Differences in tmp/FastICA_Unwhitened_cubic_diff.txt"

ptest4:
	time $(MPI_RUN) "`pwd`/../bin/hipersat" FastICA_Unwhitened_tanh.form
	sleep 1
	@diff results/FastICA_Unwhitened_tanh_correct_ascii.wgt \
          tmp/FastICA_Unwhitened_tanh_ascii.wgt &> \
          tmp/FastICA_Unwhitened_tanh_diff.txt || \
          echo "ptest4 failed. Differences in tmp/FastICA_Unwhitened_tanh_diff.txt"

ptest7:
	time $(MPI_RUN) "`pwd`/../bin/hipersat" FastICA_Prewhitened_tanh_rand.form
	sleep 1
	@diff results/FastICA_Prewhitened_tanh_rand_correct_ascii.wgt \
          tmp/FastICA_Prewhitened_tanh_rand_ascii.wgt &> \
          tmp/FastICA_Prewhitened_tanh_diff_rand.txt || \
          echo "ptest7 failed. Differences in tmp/FastICA_Prewhitened_tanh_diff_rand.txt"

ptest5:
	time `pwd`/../bin/hipersat Infomax_Prewhitened.form
	sleep 1
	@diff \
	    results/Infomax_Prewhitened_correct_ascii.wgt \
	    tmp/Infomax_Prewhitened_ascii.wgt &> \
	    tmp/Infomax_Prewhitened_diff.txt || \
	    echo "####### Test5 failed. See differences in: tmp/Infomax_Prewhitened_diff.txt"
	
ptest6:
	time `pwd`/../bin/hipersat Infomax_Unwhitened.form
	sleep 1
	@diff \
	    results/Infomax_Unwhitened_correct_ascii.wgt \
	    tmp/Infomax_Unwhitened_ascii.wgt &> \
	    tmp/Infomax_Unwhitened_diff.txt || \
	    echo "####### Test6 failed. See differences in: tmp/Infomax_Unwhitened_diff.txt"

