#! /bin/bash

DIR_CURRENT=`pwd`

PYTHON_SSL_VERSION="openssl-1.1.1"
PYTHON_SSL_PREFIX="/opt/${PYTHON_SSL_VERSION}"

PYTHON_NAME="python-3.6"
PYTHON_PREFIX="/opt/${PYTHON_NAME}"
PYTHON_VERSION="3.6.5"

DIR_TEMP="/tmp/${PYTHON_NAME}-build"
GLIBC_VERSION=`getconf GNU_LIBC_VERSION`

set -e

which yum && yum install gcc
which yum && yum install make
which yum && yum install wget
which yum && yum install tar

which zypper && zypper install gcc
which zypper && zypper install make
which zypper && zypper install wget
which zypper && zypper install tar

which apt-get && apt-get install gcc
which apt-get && apt-get install make
which apt-get && apt-get install wget
which apt-get && apt-get install tar

ls -lah ${PYTHON_PREFIX} > /dev/null || mkdir -p ${PYTHON_PREFIX}
ls -lah ${DIR_TEMP} > /dev/null || mkdir ${DIR_TEMP}

cd ${DIR_TEMP}

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz -O Python-${PYTHON_VERSION}.tar.xz
wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz -O openssl-1.1.1d.tar.gz

tar -xzf openssl-1.1.1d.tar.gz
tar xJf Python-${PYTHON_VERSION}.tar.xz

cd ${DIR_TEMP}/openssl-1.1.1d
./config --prefix=${PYTHON_SSL_PREFIX}
make
make install

cd ${DIR_TEMP}/Python-${PYTHON_VERSION}
export LDFLAGS="-L${PYTHON_SSL_PREFIX}/lib/ -L${PYTHON_SSL_PREFIX}/lib64/"
export LD_LIBRARY_PATH="${PYTHON_SSL_PREFIX}/lib/:${PYTHON_SSL_PREFIX}/lib64/"
export CPPFLAGS="-I${PYTHON_SSL_PREFIX}/include -I${PYTHON_SSL_PREFIX}/include/openssl"
./configure --enable-shared --prefix=${PYTHON_PREFIX} LDFLAGS=-Wl,-rpath=/usr/lib64/${PYTHON_NAME}

make
make install

rm -rf ${DIR_TEMP}

cd ${DIR_CURRENT}
ls ${PYTHON_NAME}.AppDir || mkdir ${PYTHON_NAME}.AppDir
ls ${PYTHON_NAME}.AppDir/opt || mkdir -p ${PYTHON_NAME}.AppDir/opt
ls ${PYTHON_NAME}.AppDir/lib/x86_64-linux-gnu/ || mkdir -p ${PYTHON_NAME}.AppDir/lib/x86_64-linux-gnu/
ls ${PYTHON_SSL_PREFIX} && cp -r ${PYTHON_SSL_PREFIX}/lib/* ${PYTHON_NAME}.AppDir/lib/x86_64-linux-gnu/
ls ${PYTHON_PREFIX} && cp -r ${PYTHON_PREFIX}/lib/* ${PYTHON_NAME}.AppDir/lib/x86_64-linux-gnu/
ls ${PYTHON_PREFIX} && cp -r ${PYTHON_PREFIX} ${PYTHON_NAME}.AppDir/opt

touch ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "[Desktop Entry]" > ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Name=${PYTHON_NAME}" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Exec=AppRun" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Icon=icon" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Type=Application" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Comment=Python interpreter. Version ${PYTHON_VERSION}" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop
echo "Categories=Development;Education;Science;" >> ./${PYTHON_NAME}.AppDir/${PYTHON_NAME}.desktop

touch ./${PYTHON_NAME}.AppDir/AppRun
echo "#! /bin/bash" > ./${PYTHON_NAME}.AppDir/AppRun
echo "set -e"  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "export PYTHONPATH=/usr/lib64/${PYTHON_NAME}:\$PYTHONPATH"  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "export PIP_TARGET=/usr/lib64/${PYTHON_NAME}"  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "export LDFLAGS=\"-L\${APPDIR}/opt/${PYTHON_NAME}/lib/ -L\${APPDIR}/opt/${PYTHON_NAME}/lib64/\""  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib64/${PYTHON_NAME}:\${APPDIR}/opt/${PYTHON_NAME}/lib:\${APPDIR}/lib/x86_64-linux-gnu/"  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "export CPPFLAGS=\"-I\${APPDIR}/opt/${PYTHON_NAME}/include -I\${APPDIR}/opt/${PYTHON_NAME}/include/python3.6m\""  >> ./${PYTHON_NAME}.AppDir/AppRun
echo "exec \${APPDIR}/opt/${PYTHON_NAME}/bin/python3.6 \$@"  >> ./${PYTHON_NAME}.AppDir/AppRun
chmod +x ./${PYTHON_NAME}.AppDir/AppRun
export ARCH=x86_64
wget -O ./${PYTHON_NAME}.AppDir/icon.svg http://www.iconarchive.com/download/i106224/papirus-team/papirus-apps/python.svg

./appimagetool  ./${PYTHON_NAME}.AppDir ${PYTHON_NAME}.AppImage
chmod +x ./${PYTHON_NAME}.AppImage

rm -rf ${PYTHON_SSL_PREFIX}
rm -rf ${PYTHON_PREFIX}

