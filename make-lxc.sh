#!/usr/bin/env bash
set -euo pipefail


# Packages adapted for CentOS (dnf)
packages=(
  git
  binutils
  bzip2
  diffutils
  findutils
  flex
  gawk
  gcc
  util-linux
  grep
  coreutils
  glibc-devel
  zlib-devel
  make
  perl
  python3
  rsync
  subversion
  unzip
  which
  patch
  wget
  ncurses-devel
  ncurses-libs
  xz
)
pkg_mgr=dnf
echo "Installing packages: ${packages[*]}"
$pkg_mgr install -y "${packages[@]}"


# Clone the iStoreOS repository

rm -rf istoreos
git clone https://github.com/istoreos/istoreos.git
cd istoreos

_pwd=$(pwd)

# download iStoreOS default config and feeds.conf
wget  -O .config https://fw0.koolcenter.com/iStoreOS/x86_64/config.seed
wget -O feeds.conf https://fw0.koolcenter.com/iStoreOS/x86_64/feeds.conf

# Modify .config to enable TARGZ rootfs
sed -i 's/# CONFIG_TARGET_ROOTFS_TARGZ is not set/CONFIG_TARGET_ROOTFS_TARGZ=y/' .config


# If the line doesn't exist, add it
grep -q "CONFIG_TARGET_ROOTFS_TARGZ" .config || echo "CONFIG_TARGET_ROOTFS_TARGZ=y" >> .config

# Update and install feeds
$_pwd/scripts/feeds update -a
$_pwd/scripts/feeds install -a

# Uninstall incompatible drivers
./scripts/feeds uninstall inter_i40e || true

# Set FORCE_UNSAFE_CONFIGURE to bypass checks
export FORCE_UNSAFE_CONFIGURE=1
grep -q "export FORCE_UNSAFE_CONFIGURE=1" ~/.bashrc || echo "export FORCE_UNSAFE_CONFIGURE=1" >> ~/.bashrc

export GOPROXY=https://goproxy.cn,https://goproxy.io,https://proxy.golang.com.cn,direct
grep -q "export GOPROXY=https://goproxy.cn,https://goproxy.io,https://proxy.golang.com.cn,direct" ~/.bashrc || echo "export GOPROXY=https://goproxy.cn,https://goproxy.io,https://proxy.golang.com.cn,direct" >> ~/.bashrc
export GOSUMDB=sum.golang.google.cn
grep -q "export GOSUMDB=sum.golang.google.cn" ~/.bashrc || echo "export GOSUMDB=sum.golang.google.cn" >> ~/.bashrc
export GO111MODULE=on
grep -q "export GO111MODULE=on" ~/.bashrc || echo "export GO111MODULE=on" >> ~/.bashrc

# turn .config into a standard config file
make defconfig

# Build the firmware
make -j"$(nproc)" V=s 2>&1 | tee build.log

target=$(ls $_pwd/bin/targets/x86/64/*rootfs.tar.gz)

echo "Build completed. The root filesystem tarball is located at: $target"