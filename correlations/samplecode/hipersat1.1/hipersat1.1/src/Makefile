include ../system/make.common
include ../system/make.$(SYSTEM)

# Files
SOURCES= \
    Sobi.cpp                RingBlock.cpp \
    TypeIdentifier.cpp      SortComponents.cpp \
    average.cpp             center_data.cpp \
    covariance.cpp          eigenstuff.cpp \
    index_array.cpp         sphering_matrix.cpp \
    PartitionedDataset.cpp  NicVector.cpp \
    NicMatrix.cpp           bin_search_tree.cpp  \
    MersenneTwister.cpp     SimpleCLParser.cpp \
    DataReader.cpp          DataWriter.cpp \
    MatrixOperations.cpp    MatrixReader.cpp \
    MatrixWriter.cpp        FastICANew.cpp \
    FastICASettings.cpp     InfomaxNew.cpp \
    InfomaxSettings.cpp     ContrastFunctions.cpp \
    MPIWrapper.cpp          EpochMarkedSimpleBinary.cpp \
    version.cpp             ProgramTools.cpp \
    FilterFactory.cpp       ConvolutionFilter.cpp \
    NICFilter.cpp           FilterOptions.cpp \
    StaticGainFilter.cpp    RangeGenerator.cpp
OBJECTS = $(SOURCES:.cpp=.o)

# directories
OBJDIR = ../obj
SYSOBJDIR = $(OBJDIR)/$(SYSTEM)
BINDIR = ../bin

# target objects
SYSOBJECTS = $(addprefix $(SYSOBJDIR)/,$(OBJECTS))

# Defines
DEFINES = $(LAPACK_DEFINE) $(TAU_DEFINE) $(TAU_DEFS) $(MPI_DEFINE) \
    -DINSTANTIATE_TEMPLATES $(OMP_DEFINE) $(OMP_FLAGS) $(MATRIX_DEFINE)

# Includes
INCLUDE = $(MATRIX_INCLUDE) $(TAU_INCLUDE) $(MPI_INCLUDE)

# Link flags
LINK = $(MATRIX_LIBS) $(MATRIX_LIB_PATH) $(TAU_LIBS) $(MPI_LIBS) \
    $(OMP_LIBS) $(CLIBS)

# The main target. No other targets should appear before this one
all: $(OBJDIR) $(SYSOBJDIR) version.h $(SYSOBJECTS)

$(OBJDIR):
	mkdir $(OBJDIR)

$(SYSOBJDIR):
	mkdir $(SYSOBJDIR)

$(SYSOBJDIR)/%.o: %.cpp %.h
	$(CXX) $(DEFINES) $(INCLUDE) $(CXX_FLAGS) -c $< -o $@

# For releases this rule needs to be removed (since it depends upon svn)
#version.h: $(SOURCES)
#	echo "#ifndef HIPERSAT_VERSION_H" > version.h
#	echo "#define HIPERSAT_VERSION_H" >> version.h;
#	echo -n "#define HIPERSAT_VERSION " >> version.h;
#	svn info | grep Revision | grep -o "[0-9]\+" >> version.h;
#	echo "#include <string>" >> version.h
#	echo "extern char* NIC_COPYRIGHT;" >> version.h;
#	echo "extern int g_hipersatVersion;" >> version.h;
#	echo "std::string hipersatVersionString();" >> version.h;
#	echo "#endif" >> version.h;

tools:
	cd ../tools; make SYSTEM=$(SYSTEM) all

selftests:
	cd ../test; make SYSTEM=$(SYSTEM) selftests

clean:
	$(RM) $(SYSOBJDIR) $(SYSTEM_TOOLS) $(TOOLS)
