# GitHub Codespaces DevContainer for LLVM Learning

This devcontainer is configured for the **LLVM Learning Tutorial** for the *Procesadores de Lenguajes* course.

## What's Included

- **Base Image**: Ubuntu 22.04 with C++ development tools
- **LLVM**: Version 17 with:
  - `clang` and `clang++` compilers
  - `lld` linker
  - `llvm-config` utilities
  - Development headers and tools
- **Node.js**: Version 20 (for LLVM JavaScript bindings if needed)
- **VS Code Extensions**:
  - C/C++ Tools
  - CMake Tools
  - Clang-D language server
  - Makefile Tools

## Quick Start

1. **Open in Codespaces**:
   - Click "Code" → "Codespaces" → "Create codespace on main"
   - Wait ~3-5 minutes for setup to complete (LLVM installation takes time)

2. **Verify Installation**:
   ```bash
   llvm-config --version
   clang --version
   ```

3. **Run Examples**:
   ```bash
   cd examples
   clang -S factorial.c -emit-llvm -o factorial.ll
   cat factorial.ll
   ```

## Available Scripts

- `llvm-version.sh` — Switch between LLVM versions 14 and 21 (Homebrew on macOS)
  - In Codespaces, use direct `clang` command or install additional versions with apt

## Building from Source

To compile C to LLVM IR:
```bash
clang -S -emit-llvm yourfile.c -o yourfile.ll
```

To compile C to assembly:
```bash
clang -S yourfile.c -o yourfile.s
```

## Notes

- The container pre-installs LLVM 17 by default
- All apt cache is cleaned after installation to minimize container size
- SSH keys are automatically mounted if available on your local machine
