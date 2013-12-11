#!/bin/bash
# eraser -- erase Amcat, elaastic and celery to generate a clean slate.
# usage: Invoke as superuser.
# 20131211 Paul Huygen
#
# Get parameter-values
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CWD/base.sh
#
# Stop everything
#
set +e
/etc/init.d/nginx stop
stop amcat_wsgi
stop amcat_celery
stop elastic
#
# Remove configuration-files
#
rm -f /etc/init/amcat_wsgi.conf
rm -f /etc/nginx/sites-enabled/amcat.conf
rm -f /etc/nginx/sites-available/amcat.conf
rm -f /etc/init/amcat_celery.conf
rm -f /etc/init/elastic.conf
#
# Remove database from postgresql
#
su postgres <<EOF
      dropdb $AMCAT_DB_NAME
EOF
#
# Remove directories with programs
#
rm -rf $ELASTIC_HOME
rm -rf $AMCAT_REPO
#
# Remove amcat user and it's home directory
#
rm -rf $AMCAT_ROOT
deluser --remove-home $AMCAT_USER
