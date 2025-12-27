### Project Guidelines

#### Build and Configuration

This project uses **Love2D 11.5** with **Luau** instead of standard Lua. The build process involves transpiling Luau to Lua using **Kaledis**.

1.  **Kaledis**: Use a custom version of Kaledis (available at [https://github.com/yancouto/kaledis](https://github.com/yancouto/kaledis)) to support custom polyfill options and fix specific bugs.
2.  **Building**: Run the following command to build the project:
    ```powershell
    kaledis build
    ```
    This creates a `.build/` directory containing the transpiled Lua code and a `final.love` file.
3.  **Configuration**: Key settings are located in `kaledis.toml`. Ensure `love_path` is correctly set to your Love2D installation directory (e.g., `C:\Program Files\LOVE`).

#### Testing Information

The project includes a basic testing suite that verifies level scripts can be executed by the interpreter.

1.  **Running Tests**:
    Tests must be run against the built Lua code.
    ```powershell
    kaledis build
    lovec .build --test
    ```
    The `--test` flag is intercepted in `src/main.luau`, which then runs `Tests.runAllLevels()`.

2.  **Adding New Tests**:
    Tests are implemented as level scripts in the `levels/` directory.
    -   Create a new `.luau` file in `levels/`.
    -   Use the `API` global provided by the interpreter (defined in `src/interpreter/init.luau`).
    -   Example (`levels/junie_test.luau`):
        ```luau
        API.SetDefaultIndicatorDuration(2.0)
        API.Wait(0.5)
        API.Spawn.Single {
            enemy = Enemy.Simple,
            pos = Vec2(400, 300),
            speed = {5, 5},
            radius = 20
        }
        API.WaitUntilNoEnemies()
        ```
    -   Run the build and test commands again to verify.

#### Additional Development Information

1.  **Code Style**:
    The project uses **StyLua** for code formatting. Configuration is in `stylua.toml`.
    -   **Syntax**: Luau
    -   **Indentation**: Tabs
    -   **Column Width**: 120
    -   **Quote Style**: AutoPreferDouble

2.  **Typechecking**:
    Typechecking is performed using `luau-lsp`.
    -   To typecheck the core source code:
        ```powershell
        luau-lsp analyze --defs love.d.luau src/
        ```
    -   To typecheck level scripts:
        ```powershell
        luau-lsp analyze --defs level_script.d.luau levels/
        ```

3.  **Libraries**:
    -   Uses modified **HUMP** libraries with Luau types (located in `src/libs/`).
    -   **Sandbox**: A custom sandbox implementation for running level scripts safely is in `src/libs/sandbox.luau`.
