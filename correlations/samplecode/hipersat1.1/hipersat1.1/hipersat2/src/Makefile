# project variables
ROOTDIR = .
#     the name of the platform that you are on
SYSTEM = mac
SOURCESUFFIX = cpp
MKDIR = mkdir
COMPILER = g++
RM = rm -rf

# files to build
FILES = NicMatrix StreamReader StreamWriter DataFormat BlasLapack SignalOperations LuaInterface
SOURCES = $(addsuffix .$(SOURCESUFFIX),$(FILES))
OBJECTS = $(addsuffix .o,$(FILES))
LIBRARY = hipersat.so

# directories
OBJDIR = $(ROOTDIR)/obj
SYSOBJDIR = $(OBJDIR)/$(SYSTEM)
BINDIR = $(ROOTDIR)/bin
LIBDIR = $(ROOTDIR)/lib
SYSLIBDIR = $(LIBDIR)/$(SYSTEM)

# target objects
SYSOBJECTS = $(addprefix $(SYSOBJDIR)/,$(OBJECTS))

# define macros
DEFINE =

# include paths
INCLUDE = -I/Users/hoge/usr/include -I/System/Library/Frameworks/vecLib.framework/Headers

# link flags
LINK = -bundle -L/Users/hoge/usr/lib -llua -framework Accelerate -framework vecLib

# the main target. No other targets should appear before this one    
all: $(SYSOBJDIR) $(SYSLIBDIR) $(SYSOBJECTS) $(LIBRARY)
    
# rules to make the target directories
$(OBJDIR):
	$(MKDIR) $(OBJDIR)
    
$(SYSOBJDIR): $(OBJDIR)
	$(MKDIR) $(SYSOBJDIR)
    
$(BINDIR):
	$(MKDIR) $(BINDIR)

$(LIBDIR):
	$(MKDIR) $(LIBDIR)
	
$(SYSLIBDIR): $(LIBDIR)
	$(MKDIR) $(SYSLIBDIR)
    
# build rule for the object files
$(SYSOBJDIR)/%.o: %.$(SOURCESUFFIX)
	$(COMPILER) $(DEFINES) $(INCLUDE) $(FLAGS) -c $< -o $@
	
# build rule for the library
$(LIBRARY): $(SYSOBJECTS)
	$(COMPILER) $(SYSOBJECTS) $(LINK) -o $@
    
# remove object and target files
clean:
	$(RM) $(SYSOBJDIR) $(SYSLIBDIR) $(BINDIR)
