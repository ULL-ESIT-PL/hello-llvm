#!/bin/bash
set -euo pipefail

echo "🔧 Setting up LLVM development environment..."

# Update package list
echo "📦 Updating package list..."
sudo apt-get update -qq

# Install core build tools and dependencies
echo "📦 Installing build tools and dependencies..."
sudo apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  ninja-build \
  git \
  curl \
  wget \
  ca-certificates \
  lsb-release \
  gnupg

# Optional SSH server support for `gh codespace ssh`.
# Keep disabled by default to minimize startup time for students.
ENABLE_SSHD="${ENABLE_SSHD:-0}"
if [ "$ENABLE_SSHD" = "1" ]; then
  echo "📦 Installing optional SSH server..."
  sudo apt-get install -y --no-install-recommends openssh-server
fi

# Install LLVM from official LLVM repository (version 17)
echo "📦 Installing LLVM 17..."
LLVM_VERSION=17
UBUNTU_VERSION=$(lsb_release -sc)

# Add LLVM repository
curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
echo "deb http://apt.llvm.org/${UBUNTU_VERSION}/ llvm-toolchain-${UBUNTU_VERSION}-${LLVM_VERSION} main" | \
  sudo tee /etc/apt/sources.list.d/llvm.list > /dev/null

sudo apt-get update -qq

# Install LLVM and clang
sudo apt-get install -y --no-install-recommends \
  llvm-${LLVM_VERSION} \
  llvm-${LLVM_VERSION}-dev \
  llvm-${LLVM_VERSION}-tools \
  clang-${LLVM_VERSION} \
  clang-format-${LLVM_VERSION} \
  clang-tools-${LLVM_VERSION} \
  lld-${LLVM_VERSION}

# Create symlinks for unversioned commands
sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-${LLVM_VERSION} 100
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 100
sudo update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${LLVM_VERSION} 100

# Verify installation
echo "✅ Verifying installation..."
llvm-config --version
clang --version

# Clean up apt cache to save space in container
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "✅ LLVM development environment is ready!"
