.PHONY: run test

all: run

run:
	kaledis build
	lovec .build/

test:
	kaledis build
	lovec .build/ --test

typecheck:
	luau-lsp analyze --defs love.d.luau src/
	luau-lsp analyze --defs level_script.d.luau levels/
