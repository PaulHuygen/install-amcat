#!/bin/bash
# Install amcat 3.4 in wsgi-server on Ubuntu 14.04
#  "???" means: is what follows still necessary? 
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OLDD=`pwd`
source $CWD/base.sh

# Create logdir ???
if [ ! -e $AMCAT_LOGDIR ]
then
  mkdir -p $AMCAT_LOGDIR
  chown :$AMCAT_USER $AMCAT_LOGDIR
  chmod g+w $AMCAT_LOGDIR
fi

# Postgresql
if [ "$AMCAT_DB_HOST" = "localhost" ]; then
    echo "Setting up database"
    # Postgresql
    service postgresql start
    sudo -u postgres createuser -s $USER
    createdb amcat
#    apt-get install -y postgresql postgresql-contrib-9.1
#    su postgres <<EOF
#      set +e
#      echo Create database $AMCAT_DB_NAME.
#      createdb $AMCAT_DB_NAME
#      echo Create  $AMCAT_DB_USER with password $AMCAT_DB_PASSWORD.
#      psql $AMCAT_DB_NAME -c "create user $AMCAT_DB_USER password '$AMCAT_DB_PASSWORD';" 
#      set -e
#      psql -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' amcat
#EOF
fi

#
# Bower
#
#apt-get -y install nodejs-legacy npm
npm install -g bower

#
# Download and install Amcat
#
echo Download amcat in $AMCAT_ROOT
AMCAT_REPO=$AMCAT_ROOT
if [ ! -d "$AMCAT_REPO" ]; then
    echo "Cloning repository into $AMCAT_REPO"
#   git clone https://github.com/amcat/amcat.git  $AMCAT_REPO
   git clone -b $AMCAT_GITBRANCHE  $REMOTE_AMCAT_REPO  $AMCAT_REPO
   chown -R $AMCAT_USER:adm $AMCAT_REPO
   chmod -R g+ws $AMCAT_REPO
   echo "Repository cloned"
fi

echo "Installing amcat dependencies"
cat $AMCAT_REPO/apt_requirements.txt | tr '\n' ' ' | xargs apt-get install -y
pip install -r $AMCAT_REPO/requirements.txt 

export PYTHONPATH=$PYTHONPATH:/usr/local/share/amcat
export AMCAT_ES_LEGACY_HASH=N
echo 'export PYTHONPATH=$PYTHONPATH:/usr/local/share/amcat' >> /etc/profile.d/amcat
echo 'export AMCAT_ES_LEGACY_HASH=N' >> /etc/profile.d/amcat
cd amcat
bower --allow-root install
python -m amcat.manage syncdb



#
# WSGI
#

echo "Installing uwsgi"
pip install uwsgi

set +e
stop amcat_wsgi
set -e

SRC=$CWD/amcat_wsgi.conf-dist
TRG=/etc/init/amcat_wsgi.conf
echo "Checking upstart script at $TRG"
if [ ! -e $TRG ]; then
    echo "Creating upstart script $TRG from $SRC"
    sed -e "s#__AMCAT_ROOT__#$AMCAT_REPO#" \
	-e "s#__AMCAT_USER__#$AMCAT_USER#" \
	-e "s#__AMCAT_DB_HOST__#$AMCAT_DB_HOST#" \
	-e "s#__AMCAT_DB_USER__#$AMCAT_DB_USER#" \
	-e "s#__AMCAT_DB_NAME__#$AMCAT_DB_NAME#" \
	-e "s#__AMCAT_DB_PASSWORD__#$AMCAT_DB_PASSWORD#" \
	-e "s#__UWSGI_SOCKET__#$UWSGI_SOCKET#"  < $SRC > $TRG
    chmod 600 $TRG
fi
set +e
start amcat_wsgi
set -e

#echo "Installing nginx" ???
#apt-get install -y nginx

# The default nginx conflicts with amcat, so throw it out of the way
rm -rf /etc/nginx/sites-enabled/default

SRC=$CWD/nginx-amcat.conf-dist
TRG=/etc/nginx/sites-available/amcat.conf
echo "Checking nginx site at $TRG"
if [ ! -e $TRG ]; then
    echo "Creating upstart script $TRG from $SRC"
    sed -e "s#__SERVER_NAME__#$SERVER_NAME#" \
        -e "s#__AMCAT_REPO__#$AMCAT_REPO#" \
        -e "s#__NGINX_UWSGI_SOCKET__#$NGINX_UWSGI_SOCKET#"  < $SRC > $TRG
fi
LN=/etc/nginx/sites-enabled/amcat.conf
if [ ! -e $LN ]; then
    echo "Linking $LN -> $TRG"
    ln -s $TRG $LN
fi

set +e
/etc/init.d/nginx restart
set -e

#
# Celery
#

echo "Configuring and starting celery workers"
set +e
stop amcat_celery
set -e

SRC=$CWD/amcat_celery.conf-dist
TRG=/etc/init/amcat_celery.conf
echo "Checking upstart script at $TRG"
if [ ! -e $TRG ]; then
    echo "Creating upstart script $TRG from $SRC"
    sed -e "s#__AMCAT_ROOT__#$AMCAT_REPO#" \
        -e "s#__AMCAT_USER__#$AMCAT_USER#" \
        -e "s#__AMCAT_DB_HOST__#$AMCAT_DB_HOST#" \
        -e "s#__AMCAT_DB_USER__#$AMCAT_DB_USER#" \
        -e "s#__AMCAT_DB_NAME__#$AMCAT_DB_NAME#" \
        -e "s#__AMCAT_DB_PASSWORD__#$AMCAT_DB_PASSWORD#" < $SRC > $TRG
    chmod 600 $TRG
fi
set +e
start amcat_celery
set -e

