#!/bin/sh

wget https://downloads.lightbend.com/scala/2.12.13/scala-2.12.13.tgz 
rm -rf /usr/lib/scala-2.12.13
tar -zxvf scala-2.12.13.tgz

rm -rf /usr/lib/scala
mkdir -p /usr/lib/scala
mv scala-2.12.13 /usr/lib/scala

export SCALA_HOME=/usr/lib/scala/scala-2.12.13
export PATH=$SCALA_HOME/bin:$PATH

cat <<EOF >  /etc/profile
export SCALA_HOME=/usr/lib/scala/scala-2.12.13
export PATH=$SCALA_HOME/bin:$PATH
EOF
source /etc/profile