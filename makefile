BC=fbc
INPUTLIST=main.bas extern/*.o
OPTIONS=-x radio -v
DEBUGFLAGS=-e -ex -exx

all: radio
	
radio:
	$(BC) $(OPTIONS) $(INPUTLIST)
	
debug:
	$(BC) $(OPTIONS) $(DEBUGFLAGS) $(INPUTLIST)
	
clean:
	rm radio