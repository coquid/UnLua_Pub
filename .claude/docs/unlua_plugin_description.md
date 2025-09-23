# UnLua Plugin Description

## UnLua Plugin Architecture

### Core Components
- **UnLua Plugin** (`Plugins/UnLua/`): Main runtime plugin containing three modules: 
  - **@Plugins/UnLua/CLAUDE.md 참고.**
  - `UnLua`: Core runtime module with Lua integration
  - `UnLuaEditor`: Editor extensions for Lua template generation and IntelliSense
  - `UnLuaDefaultParamCollector`: Program module for collecting UFUNCTION default parameters

- **UnLuaTestSuite Plugin** (`Plugins/UnLuaTestSuite/`): Comprehensive test suite with spec-based tests and regression tests : 
  - **@Plugins/UnLuaTestSuite/CLAUDE.md 참고.**

- **UnLuaExtensions Plugin** (`Plugins/UnLuaExtensions/`): Extension examples including: 
  - **@Plugins/UnLuaExtensions/CLAUDE.md 참고.**
  - `LuaSocket`: Socket library integration
  - `LuaRapidjson`: JSON processing library
  - `LuaProtobuf`: Protocol buffer support

### Lua Script Organization

All Lua scripts are located in `Content/Script/` with the following structure:
- `Content/Script/Tutorials/`: Tutorial examples (01-13 covering core features)
- `Content/Script/Tests/`: Test scripts including benchmarks, bindings, and regression tests

### Key Integration Points

- **Static Binding**: Blueprints implement `UnLuaInterface` and return Lua module path in `GetModuleName`
- **Dynamic Binding**: Runtime binding without Blueprint modifications
- **Template Generation**: UnLua toolbar in Blueprint editor provides "Create Lua Template" functionality
- **Console Commands**: Runtime debugging with `lua.do`, `lua.dofile`, `lua.gc` commands

### Console Commands (In-Game/PIE)
- `lua.do <code>`: Execute Lua code in default environment
- `lua.dofile <module path>`: Execute specified Lua file
- `lua.gc`: Force garbage collection
- `lua.mem`: Display memory usage statistics
- `lua.debug`: Toggle debug mode on/off