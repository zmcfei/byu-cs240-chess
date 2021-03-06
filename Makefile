CC = g++
GTKMM = gtkmm-2.4
SIGC = sigc++-2.0
LIBGLADE = libglademm-2.4

FLAGS = -Wall -g -Iinc -Ilib/inc

#Add the next line to the FLAGS variable to turn of debugging messages to the Message area of the GUI
#-DLOG_LEVEL_HIDE_MASK="(G_LOG_LEVEL_DEBUG)"


#CFLAGS are the -I values needed to compile files using the GTKMM, SIGC, and LIBGLADE libraries
CFLAGS = `pkg-config $(GTKMM) $(SIGC) $(LIBGLADE) --cflags`  -Iimages/ 
#LIBS are the paths to the static libraries for GTKMM, SIGC, and LIBGLADE needed for linking
LIBS = `pkg-config $(GTKMM) $(SIGC) $(LIBGLADE) --libs` -lboost_regex-mt

#LIB_FLAGS D_LOG_DOMAIN is used by g_log in the ChessGui library to seperate logging messages from the library
# from logging messages from the students code
#IMPORTANT: You must add a compiler option here for the library to be dynamic
LIB_FLAGS = -DG_LOG_DOMAIN=\"ChessGui\" -fPIC


#change this to a dynamic library name
LIBRARY= lib/libcs240.so
EXE_NAME = bin/chess



SOURCES = $(foreach file, $(shell ls src/*.cpp), $(basename $(notdir $(file))))
OBJ_FILES = $(foreach file, $(SOURCES), obj/$(file).o)

LIBSOURCES = $(foreach file, $(shell ls lib/src/*.cpp), $(basename $(notdir $(file))))
LIB_OBJ_FILES = $(foreach file, $(LIBSOURCES), lib/obj/$(file).o)

.PHONY: run clean bin lib memtest

run: $(EXE_NAME)
	./$(EXE_NAME)

test:
	@echo "Just play the game. That's test enough."

all: clean bin

tgz: tar
tar: clean
	@tar -czf ../chess.tgz inc/ lib/ Makefile bin/ obj/ src/ images/ cs240chess.glade

submit: tar
	../submit_cs.rb Chess chess.tgz

clean: 
	-rm -f $(EXE_NAME)
	-rm -f $(OBJ_FILES)
	-rm -f src/*~ inc/*~
	-rm -f $(LIBRARY) $(LIB_OBJ_FILES)
	-rm -f lib/src/*~ lib/inc/*~
	-rm -f *.mk
		
	

bin: $(EXE_NAME)


lib: $(LIBRARY) 

	
memtest: $(EXE_NAME)
	valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --suppressions=chess.supp $(EXE_NAME)

	
$(EXE_NAME): $(OBJ_FILES)  $(LIBRARY)
	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) -o $(EXE_NAME) $(OBJ_FILES) $(LIBRARY) 
	

#obj/main.o: src/main.cpp lib/inc/ChessGuiImages.h inc/Chess.h
#	$(CC) -c $(FLAGS) $(CFLAGS) -o obj/main.o src/main.cpp
#obj/Chess.o: src/Chess.cpp inc/Chess.h lib/inc/SelectDialog.h lib/inc/ChessGuiDefines.h lib/inc/ChessGui.h
#	$(CC) -c $(FLAGS) $(CFLAGS) -o obj/Chess.o src/Chess.cpp







#This is currently a STATIC library, you must change it to a DYNAMIC library
#You must also add a compiler option to the variable LIB_FLAGS in order for the library to be dynamic
$(LIBRARY): $(LIB_OBJ_FILES) 
	$(CC) -shared $(FLAGS) $(CFLAGS) -o $(LIBRARY) $(LIB_OBJ_FILES)
	#ar r $(LIBRARY) $(LIB_OBJ_FILES)









########DO NOT DELETE###########################################################################################3
#Below is some Makefile Magic to compile the libraries, you do not need to
#understand or alter it.  If you would like to, look up the Make manual online, it's very comprehensive	

lib/obj/%.o : lib/src/%.cpp lib/inc/Inline.h
	$(CC) $(FLAGS) $(LIB_FLAGS) $(CFLAGS) -c -o $@ $< 

  #The following is part of what lets us include Images within the binary. It currently only loads the default
  #"Image not found" icon that we use

INLINE_IMAGES = $(shell ls lib/img/* )
INLINE_IMAGE_PAIRS =$(foreach file, $(INLINE_IMAGES), $(basename $(notdir $(file)) $(file).* ))	
lib/inc/Inline.h: $(INLINE_IMAGES)
	@echo "Updating Images"
	gdk-pixbuf-csource --raw --build-list $(INLINE_IMAGE_PAIRS) > lib/inc/Inline.h

  #generates the dependencies of the library
library.mk: $(shell ls lib/src/*.cpp) $(shell ls lib/inc/*.h)
	@-rm -f library.mk
	@-echo "#library.mk is a makefile generated using the compiler to determine dependencies\n" >>library.mk
	@for f in $(LIBSOURCES) ; do $(CC) -MM -MT lib/obj/$$f.o -I lib/inc/ -I images lib/src/$$f.cpp >> library.mk; done

include library.mk


CHESSSOURCES = $(foreach file, $(shell ls src/*.cpp), $(basename $(notdir $(file))))
obj/%.o : src/%.cpp inc/%.h
	$(CC) $(FLAGS) $(LIB_FLAGS) $(CFLAGS) -c -o $@ $< 

  #generates the dependencies of my chess
chess.mk: $(shell ls src/*.cpp) $(shell ls inc/*.h)
	@-rm -f chess.mk
	@-echo "#chess.mk is a makefile generated using the compiler to determine dependencies\n" >>chess.mk
	@for f in $(CHESSSOURCES) ; do $(CC) -MM -MT obj/$$f.o -I inc/ -I lib/inc -I images src/$$f.cpp >> chess.mk; done

include chess.mk

