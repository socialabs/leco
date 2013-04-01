COFFEE = ./node_modules/.bin/coffee

SRC = $(wildcard src/*.coffee)
DST = $(SRC:src/%.coffee=lib/%.js)


all: compile


compile: $(DST)

test: compile
	node_modules/.bin/nodeunit test

lib/%.js: src/%.coffee
	@mkdir -p $(@D)
	$(COFFEE) -bpc $< > $@
