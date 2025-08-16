# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **UnLua**, a highly optimized Lua scripting solution for Unreal Engine by Tencent. UnLua allows direct access to all UE reflection system types (UCLASS, UPROPERTY, UFUNCTION, USTRUCT, UENUM) from Lua without glue code, and enables overriding Blueprint events, replication notifications, animation notifications, and input events.

**Current Engine Version:** Unreal Engine 5.6  
**Supported Platforms:** Windows, Android, iOS, Linux, OSX  
**Supported Engine Versions:** UE 4.17.x - UE 5.x

## Architecture

### Core Components

- **UnLua Plugin** (`Plugins/UnLua/`): Main runtime plugin containing three modules:
  - `UnLua`: Core runtime module with Lua integration
  - `UnLuaEditor`: Editor extensions for Lua template generation and IntelliSense
  - `UnLuaDefaultParamCollector`: Program module for collecting UFUNCTION default parameters

- **UnLuaTestSuite Plugin** (`Plugins/UnLuaTestSuite/`): Comprehensive test suite with spec-based tests and regression tests

- **UnLuaExtensions Plugin** (`Plugins/UnLuaExtensions/`): Extension examples including:
  - `LuaSocket`: Socket library integration
  - `LuaRapidjson`: JSON processing library
  - `LuaProtobuf`: Protocol buffer support

- **TPSProject**: Example third-person shooter project demonstrating UnLua integration

### Lua Script Organization

All Lua scripts are located in `Content/Script/` with the following structure:
- `Content/Script/Tutorials/`: Tutorial examples (01-13 covering core features)
- `Content/Script/Tests/`: Test scripts including benchmarks, bindings, and regression tests
- Blueprint-specific Lua files follow naming convention: `<BlueprintName>_C.lua`

### Key Integration Points

- **Static Binding**: Blueprints implement `UnLuaInterface` and return Lua module path in `GetModuleName`
- **Dynamic Binding**: Runtime binding without Blueprint modifications
- **Template Generation**: UnLua toolbar in Blueprint editor provides "Create Lua Template" functionality
- **Console Commands**: Runtime debugging with `lua.do`, `lua.dofile`, `lua.gc` commands

## Development Commands

### Building
```bash
# Generate Visual Studio project files
# Right-click TPSProject.uproject -> "Generate Visual Studio project files"
# Open TPSProject.uproject in UE Editor to build

# For command line builds (requires UE installed):
# UnrealBuildTool TPSProject Win64 Development -Project="TPSProject.uproject"
```

### Testing
```bash
# Run automated tests via UE Editor's Automation Tool:
# 1. Open UE Editor with TPSProject.uproject
# 2. Window -> Developer Tools -> Automation
# 3. Search for "UnLua" to run all UnLua-related tests
# 4. Categories available:
#    - "UnLua.Spec" for specification tests
#    - "UnLua.Issue" for regression tests  
#    - "UnLua.Benchmark" for performance tests

# Run specific test by searching for issue number:
# Example: Search "Issue276" to run specific regression test
```

### IntelliSense Generation
```bash
# Generate Lua IntelliSense files for IDEs:
# 1. In UE Editor: UnLua Toolbar -> "Generate IntelliSense"
# 2. Generated files appear in: Plugins/UnLua/Intermediate/IntelliSense/Script/
# 3. Use these files with VSCode Lua Booster or other Lua language servers
```

### Console Commands (In-Game/PIE)
- `lua.do <code>`: Execute Lua code in default environment
- `lua.dofile <module path>`: Execute specified Lua file  
- `lua.gc`: Force garbage collection
- `lua.mem`: Display memory usage statistics
- `lua.debug`: Toggle debug mode on/off

### Project Configuration
```bash
# Key configuration files:
# - Config/DefaultUnLuaEditor.ini: Plugin settings and build options
# - Plugins/UnLua/Config/LuaTemplates/: Default Lua templates for different UE classes
# - Content/Script/: All Lua implementation files

# Hot reload settings in DefaultUnLuaEditor.ini:
# HotReloadMode=Manual|Auto|Never
```

### Editor Workflow
1. Create Blueprint and implement `UnLuaInterface`
2. Return Lua file path in `GetModuleName` (relative to `Content/Script/`)
3. Use UnLua toolbar "Create Lua Template" to generate boilerplate
4. Edit generated `.lua` file in `Content/Script/`

## Testing Structure

The project uses UE's Automation Testing framework with three main approaches:

1. **Spec Tests** (`Plugins/UnLuaTestSuite/Source/UnLuaTestSuite/Private/Specs/`):
   - Feature-based tests using `BEGIN_DEFINE_SPEC`/`END_DEFINE_SPEC`
   - Test individual API components (LuaLib_Array, LuaLib_Delegate, etc.)
   - Math types (FVector, FQuat, FRotator, FTransform, FColor, etc.)
   - Search "UnLua.Spec" in automation window to run

2. **Regression Tests** (`Plugins/UnLuaTestSuite/Source/UnLuaTestSuite/Private/Tests/`):
   - Issue-specific tests named by GitHub issue numbers (Issue276-Issue668)
   - Both C++ test classes in `Tests/` and corresponding Lua scripts in `Content/Script/Tests/Regression/`
   - Search "UnLua.Issue" or specific issue number in automation window


## Module Dependencies

For game development, you need these core components:
- **Main project** (`TPSProject`): Your game project using UnLua
- **UnLua Plugin** (`Plugins/UnLua/`): Essential - provides Lua-Blueprint integration
- **UnLuaTestSuite** (`Plugins/UnLuaTestSuite/`): Optional - for testing your Lua scripts
- **UnLuaExtensions** (`Plugins/UnLuaExtensions/`): Optional - additional Lua libraries:
  - LuaSocket: Network communication
  - LuaRapidjson: JSON processing  
  - LuaProtobuf: Protocol buffer support


## Important File Patterns

- `*.Build.cs`: Unreal Build Tool configuration files
- `*.uplugin`: Plugin descriptor files
- `*.spec.cpp`: Automation test specifications
- `*_C.lua`: Blueprint-bound Lua implementation files
- `Content/Script/Tutorials/*.lua`: Feature demonstration scripts

## Localization

The project includes comprehensive localization support:
- `Content/Localization/UnLua/`: Main localization assets
- `Plugins/UnLua/Content/Localization/UnLua/`: Plugin-specific localization
- Supports Chinese (zh-Hans) and English

## Performance Considerations

UnLua is highly optimized for:
- **UFUNCTION invocation**: Persistent parameter caching and optimized parameter passing
- **Container access**: TArray, TSet, TMap without Lua table conversion, same memory layout as engine
- **Structure operations**: Efficient creation, access, and garbage collection  
- **Static export**: Custom export system for frequently used classes, functions, and enums
- **Memory management**: Minimized allocations and optimized garbage collection cycles


## Plugin-Specific Documentation

Each plugin has its own detailed CLAUDE.md file with specialized information:

- **`Plugins/UnLua/CLAUDE.md`**: Core plugin details
  - Detailed C++ module structure and architecture
  - Advanced configuration options and build settings
  - Plugin development workflows and extension points
  
- **`Plugins/UnLuaTestSuite/CLAUDE.md`**: Testing framework details
  - Comprehensive testing workflows and best practices
  - Adding new test cases and automation setup
  - Performance benchmarking and regression testing details
  
- **`Plugins/UnLuaExtensions/CLAUDE.md`**: Extension plugins information
  - LuaSocket, LuaRapidjson, LuaProtobuf usage details
  - Integration examples and extension development

**When to use plugin-specific documentation:**
- For deep technical implementation details
- When extending or modifying plugin functionality  
- For advanced testing and debugging workflows
- When working with specific extension libraries

## Development Workflow for Code Changes

### Adding New Lua Library Functions
1. Add C++ implementation in `Plugins/UnLua/Source/UnLua/Private/BaseLib/LuaLib_*.cpp`
2. Register function in corresponding module initialization
3. Add spec test in `Plugins/UnLuaTestSuite/Source/UnLuaTestSuite/Private/Specs/LuaLib_*.spec.cpp`
4. Update IntelliSense generation if needed

### Fixing Reported Issues  
1. Create regression test in `Plugins/UnLuaTestSuite/Source/UnLuaTestSuite/Private/Tests/Issue[Number]Test.cpp`
2. Add corresponding Lua test script in `Content/Script/Tests/Regression/Issue[Number]/`
3. Implement fix in appropriate UnLua module
4. Verify test passes in automation window