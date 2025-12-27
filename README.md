# Psych0

Coming... one day.

## How to use

We're using Love2D 11.5, but coding in Luau instead of Lua for the types and some other small improvements. To do that, we use Kaledis to transform Luau into Lua.

To build, run `kaledis build` and it will create a `.build/final.love` file that can simply be run with Love2D. We're using a custom version of kaledis (https://github.com/yancouto/kaledis) to allow custom polyfill options (since we just care about the types, and there is a bug in the default polyfill).

We use `luasty` to format the code.

We use some HUMP libraries to help out, but we modified them so they have Luau types.

## How to typecheck

Install the Luau LSP in your IDE, add the `love.d.luau` as custom type definitions (this adds LOVE and all its functions).
For the levels, instead add `level_script.d.luau` as custom type definitions.

To run in terminal, add `luau-lsp` to your PATH, and then run:
`luau-lsp analyze --defs love.d.luau src/` to typecheck the main code, and
`luau-lsp analyze --defs level_script.d.luau levels/` to typecheck the levels.

## How to test

After using kaledis to build, run `lovec .build --test` to test.
