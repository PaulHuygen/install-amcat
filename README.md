<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. Installing AmCAT</a></li>
<li><a href="#sec-2">2. Installation steps</a></li>
<li><a href="#sec-3">3. Description of the files</a></li>
</ul>
</div>
</div>



# Installing AmCAT<a id="sec-1" name="sec-1"></a>

This repository contains a number of useful scripts for automatic
installation of AmCAT version 3.4 (<http://github.com/amcat/amcat>) on a server
running Ubuntu 14.04. 
In contrast to older versions of this repo, this version contains a
single script, `install_amcat`, to install everything that is needed on a single server,
i.e.:

1.  postgresql
2.  elastic search (with the HitCountSimilarity extension)
3.  amcat
4.  wsgi+nginx
5.  celery

## Context<a id="sec-1-1" name="sec-1-1"></a>

The scripts are aimed at (and tested on) ubuntu 14.04 and rely on apt
and pip to install dependencies. They use upstart (`/etc/init`) scripts
to install services. These scripts are supposed to be run as root.

## Java<a id="sec-1-2" name="sec-1-2"></a>

ElasticSearch needs Java 8. The script installs Java if it doesn't
find a Java binary in the path. So, if the server supports an obsolete
version of java, there is a chance that ElasticSearch will not work.

Oracle java cannot be installed automatically from a repository on
Internet. Therefore, the user should download the tarball
`jre-8u111-linux-x64.tar.gz` from [Oracle](https://java.com/nl/download/manual.jsp) and place it in the `/tmp/` 
directory. If the script needs the tarball, but cannot find it, it aborts execution.

# Installation steps<a id="sec-2" name="sec-2"></a>

1.  Clone this repository.
2.  Check `defaults.cfg`. Generate a `local.cfg` if settings need to be
    to overridden.
3.  Download `jre-8u111-linux-x64.tar.gz` from Oracle and put it in the
    `/tmp` directory.
4.  Run "install<sub>amcat</sub>"

# Description of the files<a id="sec-3" name="sec-3"></a>

## `defaults.cfg`: Defaults for the parameters.<a id="sec-3-1" name="sec-3-1"></a>

The defaults will only be set when they didn't exist before invoking
the script. Furthermore, the parameters can be overriden by setting
them in a file `local.cfg` in the same directory.

## `install_amcat`<a id="sec-3-2" name="sec-3-2"></a>

The script that performs the installation

## "dist"-files<a id="sec-3-3" name="sec-3-3"></a>

`amcat_wsgi.conf-dist`, `amcat_celery.conf-dist`,
`nginx-amcat.conf-dist`. They contain the content for configuration-files.

## `apt-requirements.txt`<a id="sec-3-4" name="sec-3-4"></a>

The Ubuntu packages that need to be installed for the Amcat environment.

## `Dockerfile`<a id="sec-3-5" name="sec-3-5"></a>

To build a docker container. Will be explained in a later commit.
