include ../system/make.common
include ../system/make.$(SYSTEM)

# set up tool file names
DOTSYSTEM = .$(SYSTEM)
BINTOOLS = $(addprefix $(BINDIR)/,$(TOOLS))
SYSTOOLS = $(addsuffix $(DOTSYSTEM),$(BINTOOLS))

# directories
OBJDIR = ../obj
SYSOBJDIR = $(OBJDIR)/$(SYSTEM)
BINDIR = ../bin

# Defines
DEFINES = $(LAPACK_DEFINE) $(TAU_DEFINE) $(TAU_DEFS) $(MPI_DEFINE) \
    -DINSTANTIATE_TEMPLATES $(OMP_DEFINE) $(OMP_FLAGS) $(MATRIX_DEFINE)

# Includes
INCLUDE = $(MATRIX_INCLUDE) $(TAU_INCLUDE) $(MPI_INCLUDE)

# Link flags
LINK = $(MATRIX_LIBS) $(MATRIX_LIB_PATH) $(TAU_LIBS) $(MPI_LIBS) \
    $(OMP_LIBS) $(CLIBS)

# The main target. No other targets should appear before this one
all: $(BINDIR) $(SYSTOOLS) $(BINTOOLS)

$(BINDIR):
	mkdir $(BINDIR)

$(BINDIR)/%.$(SYSTEM): %.cpp %.h $(SYSOBJDIR)/*
	$(CXX) $(DEFINES) $(INCLUDE) -I../src $(CXX_FLAGS) $(SYSOBJDIR)/* $(LINK) $< -o $@

$(BINDIR)/%: $(BINDIR)/%.$(SYSTEM)
	cp $< $@

clean:
	$(RM) $(BINTOOLS) $(SYSTOOLS)
