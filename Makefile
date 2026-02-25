.PHONY: run test typecheck

all: run

run:
	lovec src/

test:
	lovec src/ --test

typecheck:
	lua-language-server --check src/
