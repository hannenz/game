PRG:=game.prg

$(PRG): 	game.s reloader.s
	@echo $<
	cl65 --target none --start-addr 0x7ff -o $(PRG) $^


