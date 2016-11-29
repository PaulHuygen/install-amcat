Installing AmCAT
================

This repository contains a number of useful scripts for automatic
installation of AmCAT version 3.4 (github.com/amcat/amcat). 
In particular, it has scripts to install the separate components of AmCAT on the same or different computers.

The components/scripts are:
* install_elastic.sh. This installs elastic together with the HitCountSimilarity extension
* install_wsgi.sh. This installs the AmCAT navigator on uwsgi+nginx. If the database is set to localhost, it also sets up the database. It assumes that an elastic node is reachable.

The repository contains a number of -dist files that function as templates for configuration files. The default.cfg file contains default values for the various parameters needed to install the AmCAT components. You can edit this file or supply these variables as environment variables.

Context
-------

The scripts are aimed at (and tested on) ubuntu 14.04 and rely on apt
and pip to install dependencies. They use upstart (/etc/init) scripts
to install services. These scripts are supposed to be run as root.

Java
----

Amcat needs Oracle Java vs. 8. Installation of this software from the
reo of Oracle cannot be done automatically. Therefore the user should
download the package jre-8u111-linux-x64.tar.gz manually from
[Oracle](https://java.com/nl/download/manual.jsp)  and put it in the
directory in which the current directory resides.

