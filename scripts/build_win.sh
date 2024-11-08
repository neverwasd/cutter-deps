set -euo pipefail

pacman -S --needed --noconfirm tree

# Configure MSVC path
#MSVC_PATH="/c/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/MSVC/14.29.30133/bin/HostX64/x64"
#export PATH="${MSVC_PATH}:$PATH"

# Python
PYTHON_FTP="https://www.python.org/ftp/python"
PYTHON_VERSION="3.11.9"
PYTHON_ARCH="amd64"
PYTHON_INSTALLER="python-${PYTHON_VERSION}-${PYTHON_ARCH}.exe"
PYTHON_URL="${PYTHON_FTP}/${PYTHON_VERSION}/${PYTHON_INSTALLER}"
PYTHON_INSTALL_DIR="${PWD}/python-${PYTHON_VERSION}-${PYTHON_ARCH}"
wget --progress=dot:giga "${PYTHON_URL}"
${PYTHON_INSTALLER} /quiet Include_debug=1 Include_dev=1 Include_lib=1 Include_pip=1 PrependPath=1 CompileAll=1 InstallAllUsers=0 TargetDir=${PYTHON_INSTALL_DIR}
tree "${PYTHON_INSTALL_DIR}"
${PYTHON_INSTALL_DIR}\python.exe -c "import sys; print(sys.version)"
exit 255
echo "e7de3240a8bc2b1e1ba5c81bf943f06861ff494b69fda990ce2722a504c6153d  ./${PYTHON_ARCHIVE}" | sha256sum -c -
tar -xf ${PYTHON_ARCHIVE}
PYTHON_SRC_DIR=${PWD}/${PYTHON_NAME}
cd "${PYTHON_SRC_DIR}"
./PCbuild/build.bat -e -d -p x64
cd ..
tree "${PYTHON_SRC_DIR}"

# clang+llvm
LLVM_NAME=clang+llvm-18.1.5-x86_64-pc-windows-msvc
LLVM_ARCHIVE="${LLVM_NAME}.tar.xz"
wget --progress=dot:giga https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.5/${LLVM_ARCHIVE}
echo "7027f03bcab87d8a72fee35a82163b0730a9c92f5160373597de95010f722935  ./${LLVM_ARCHIVE}" | sha256sum -c -
tar -xf ${LLVM_ARCHIVE}
export LLVM_INSTALL_DIR=${PWD}/${LLVM_NAME}
export CMAKE_PREFIX_PATH=${LLVM_INSTALL_DIR}
#export Clang_DIR="${LLVM_INSTALL_DIR}/lib/cmake/clang"

# REMOVE any gcc installs (possibly provided by msys) from path, we are trying to do a MSVC based build
which cl
which gcc
export PATH=`echo $PATH | tr ":" "\n" | grep -v "mingw64" | grep -v "Strawberry" | tr "\n" ":"`
echo $PATH
which gcc || echo "No GCC in path, OK!"

make PLATFORM=win "PYTHON_WINDOWS=${PYTHON_INSTALL_DIR}"
