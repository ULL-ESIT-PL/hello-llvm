# GitHub Codespaces DevContainer for LLVM Learning

This [devcontainer](/.devcontainer/devcontainer.json) is configured for the **LLVM Learning Tutorial** for the *Procesadores de Lenguajes* course. It uses the script [setup.sh](/.devcontainer/setup.sh) to install LLVM and related tools in a GitHub Codespaces environment. Use it as a template for your own LLVM projects.

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
   bash scripts/llvm-health-check.sh
   ```

3. **First End-to-End Run (factorial)**:
   ```bash
   cd /workspaces/hello-llvm
   clang --target=x86_64-pc-linux-gnu examples/factorial-main.ll examples/factorial.ll -o tmp/f
   ./tmp/f
   ```
   Expected output:
   ```text
   120
   ```

   Note: these `.ll` files were generated on macOS, so in Linux/Codespaces you should keep the explicit `--target=x86_64-pc-linux-gnu` to avoid linker errors.

4. **Run Examples**:
   ```bash
   cd examples
   clang -S factorial.c -emit-llvm -o factorial.ll
   cat factorial.ll
   ```

5. **Optional: connect via SSH from your local terminal**:
   ```bash
   gh codespace list
   gh codespace ssh -c <codespace-name>
   ```
   This project keeps SSH disabled by default to reduce startup time. If you need it, enable it by setting `ENABLE_SSHD=1` in [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) under `containerEnv`, then rebuild/create the Codespace.

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
- SSH keys are not mounted by default in Codespaces. Use GitHub authentication or Codespaces secrets when needed.
- SSH server installation is optional (`ENABLE_SSHD=1`) to avoid extra setup time in classroom scenarios.

## Troubleshooting

- If Codespaces fails while creating the container with a mount error mentioning `/.ssh`, remove custom `mounts` entries from [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json).
