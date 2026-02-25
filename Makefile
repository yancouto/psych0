.PHONY: run test typecheck

LOVEC=lovec
LUALS=lua-language-server

-include .env

all: run

run:
	$(LOVEC) src/

test:
	$(LOVEC) src/ --test

typecheck:
	$(LUALS) --check .
