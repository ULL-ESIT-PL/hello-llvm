
### Quick install on the main platforms

These are the easiest package-manager based options for a working LLVM/Clang toolchain.

#### macOS (Homebrew)

```bash
brew update
brew install llvm
echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc   # Apple Silicon
# echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc     # Intel Macs
source ~/.zshrc
llvm-config --version
```

#### Linux

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y llvm clang lld
llvm-config --version
```

Fedora:

```bash
sudo dnf install -y llvm clang lld
llvm-config --version
```

Arch Linux:

```bash
sudo pacman -S llvm clang lld
llvm-config --version
```

#### Windows

Option 1 (easiest): `winget`

```powershell
winget install LLVM.LLVM
clang --version
```

Option 2: `choco`

```powershell
choco install llvm -y
clang --version
```

If `clang` is not recognized after installation, reopen the terminal or add LLVM's `bin` folder to `PATH`.



See also the LLVM section
[Getting Started with the LLVM System¶](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm)
