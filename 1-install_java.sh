#!/bin/sh
echo installing java from jdk-11_linux-x64_bin.tar.gz
mkdir -p /usr/lib/jvm
tar -zxvf jdk-11_linux-x64_bin.tar.gz -C /usr/lib/jvm
cat <<EOF >  /etc/profile
export JAVA_HOME=/usr/lib/jvm/jdk-jdk-11_linux-x64_bin
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
EOF
source /etc/profile