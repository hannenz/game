TARGETS := game
PRG := game.prg

.PRECIOUS: %.d64

all: game.prg

%.o: %.s
	ca65 --target c64 -o $@ $<

game.prg: game.o reloader.o
	ld65 -o $@ --config game.cfg --start-addr 0x7ff $^

game.d64: game.prg
	c1541 -format foo,id d64 $@ -write $<

# game: game.d64
# 	x64 $<

clean:
	rm -f $(TARGETS) *.prg *.o *.d64

# $(PRG): 	game.s reloader.s
# 	cl65 --config game.cfg --target c64 --start-addr 0x7ff -o $(PRG) $^


