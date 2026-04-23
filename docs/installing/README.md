
# Quick install on the main platforms

These are the easiest package-manager based options for a working LLVM/Clang toolchain.

## macOS (Homebrew)

```bash
brew update
brew install llvm
echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc   # Apple Silicon
# echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc     # Intel Macs
source ~/.zshrc
llvm-config --version
```

### Managing several LLVM versions 

See the script at [llvm-version.sh](/llvm-version.sh). It helps me to switch between different LLVM versions installed via Homebrew. You can use it as a template to create your own version manager for LLVM.

## Linux

### Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y llvm clang lld
llvm-config --version
```

### ULL iaas virtual machines

When using the ULL iaas environment:

```
usuario@ubuntu:~/pl/llvm$ sudo apt update
sudo apt install -y llvm clang lld
[sudo] password for usuario: 
Des:1 https://cli.github.com/packages stable InRelease [3.917 B]
...
```

You can use the `scripts/llvm-health-check.sh` to check that LLVM is working:

```
usuario@ubuntu:~/pl/hello-llvm$ scripts/llvm-health-check.sh
[check] Platform: Linux
[check] Workspace: /home/usuario/pl/hello-llvm
[check] clang: Ubuntu clang version 18.1.3 (1ubuntu1)
[check] llvm-config: 18.1.3
[check] Detected Linux (Codespaces environment)
[check] Compiling factorial example...
[check] Running tmp/f...
```

### Fedora:

```bash
sudo dnf install -y llvm clang lld
llvm-config --version
```

### Arch Linux:

```bash
sudo pacman -S llvm clang lld
llvm-config --version
```

## Windows

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

## GitHub CodeSpaces DevContainer

See section [/docs/installing/github-codespaces.md](/docs/installing/github-codespaces.md)

## Building from source

See also the LLVM section
[Getting Started with the LLVM System¶](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm)
