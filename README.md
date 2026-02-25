# Psych0

Coming... one day.

## How to use

We're using Love2D 11.5, coded in plain Lua with [LuaLS](https://github.com/LuaLS/lua-language-server) annotations for type checking. No build step is required — just run Love2D directly on the `src/` directory.

To run: `lovec src/` (or `make run`)

## How to typecheck

Install the [lua-language-server](https://github.com/LuaLS/lua-language-server) and run:
`lua-language-server --check src/` (or `make typecheck`)

The `.luarc.json` at the project root configures the workspace. For IDE support, install the LuaLS extension in VS Code.

For love2d type definitions, install the [LuaCATS/love2d](https://github.com/LuaCATS/love2d) library and add it to `Lua.workspace.library` in `.vscode/settings.json`.

## How to test

Run `lovec src/ --test` (or `make test`).
