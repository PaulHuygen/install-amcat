#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OLDD=`pwd`
cd $CWD
cd ..
SOCKET=`pwd`
cd $OLDD
source $CWD/base.sh
JAVABALL=jre-8u111-linux-x64.tar.gz
ELASTICVERSION="1.4.4"
ELASTICDEB=elasticsearch-$ELASTICVERSION.deb
ELASTIC_DEB_URL=https://download.elasticsearch.org/elasticsearch/elasticsearch/$ELASTICDEB

#echo "Installing curl"
#apt-get install -y curl

set +e
stop elastic

echo "Checking java install"
which java >/dev/null
if [ $? -ne 0 ]; then
    if
      [ ! -e ../$JAVABALL ]
    then
      echo No java. Please download $JAVABALL into $SOCKET 
      exit 4
    fi
   set -e
   cd /usr/local/share
   tar -xzf $SOCKET/$JAVABALL   
   export JAVA_HOME=/usr/local/share/jre1.8.0_111
   echo 'export JAVA_HOME=/usr/local/share/jre1.8.0_111' >> /etc/profile.d/amcat
   for file in $JAVA_HOME/bin/* ; do ln -s $file /usr/local/bin/ ; done 
fi

set -e

# Install Elasticsearch
cd /tmp
wget $ELASTIC_DEB_URL
dpkg -i $ELASTICDEB
rm $ELASTICDEB
cd $OLDD

# Install plugins
/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-icu/2.4.2
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
/usr/share/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk

# Allow dynamic scripting 
echo -e "\nscript.disable_dynamic: false" | tee -a /etc/elasticsearch/elasticsearch.yml

#
# Hitcount
#
wget http://hmbastiaan.nl/martijn/amcat/hitcount.jar -O /usr/share/elasticsearch/hitcount.jar
sed </etc/init.d/elasticsearch '/ES_HOME=/a\ES_CLASSPATH=$ES_HOME/hitcount.jar' >/tmp/es1
sed </tmp/es1 '/ES_CLASSPATH=/a\export ES_CLASSPATH' >/tmp/es2
sed </tmp/es2 '/DAEMON_OPTS=/s/\"$/ -Des.index.similarity.default.type=nl.vu.amcat.HitCountSimilarityProvider\"/' >/etc/init.d/elasticsearch
rm /tmp/es1 /tmp/es2
service elasticsearch restart

