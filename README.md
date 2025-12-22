# Psych0

Coming... one day.

## How to use

We're using Love2D 11.5, but coding in Luau instead of Lua for the types and some other small improvements. To do that, we use Kaledis to transform Luau into Lua.

To build, run `kaledis build` and it will create a `.build/final.love` file that can simply be run with Love2D. We're using a custom version of kaledis (https://github.com/yancouto/kaledis) to allow custom polyfill options (since we just care about the types, and there is a bug in the default polyfill).

We use luasty to format the code.

We use some HUMP libraries to help out, but we modified them so they have Luau types.
