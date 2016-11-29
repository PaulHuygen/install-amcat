PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $PWD/defaults.cfg

echo "Installing basic Ubuntu features."
#
# To install recent version of R
#
apt-get update && apt-get -y upgrade 
apt-get -y install apt-transport-https 
echo 'deb https://mirrors.cicku.me/CRAN/bin/linux/ubuntu trusty/' > /etc/apt/sources.list.d/r-cran-trusty.list
echo 'deb https://cran.rstudio.com/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list.d/r-cran-trusty.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $APT_KEY
#
# Install required Ubuntu packages
#
cat apt_requirements.txt | tr '\n' ' ' | xargs apt-get install -y

echo "Checking whether user $AMCAT_USER exists"
# The directory that contains $AMCAT_ROOT will be the user's home directory
getent passwd $AMCAT_USER  > /dev/null
if [ $? -eq 2 ]; then
    echo "Creating user..."
    set -e
    USER_HOME=`dirname $AMCAT_ROOT` 
    useradd -Ms/bin/bash --home "$USER_HOME" $AMCAT_USER
    mkdir -p $USER_HOME
    chown amcat:amcat $USER_HOME
fi
set -e

echo "Create folder $AMCAT_ROOT if needed"
mkdir -p $AMCAT_ROOT
chown amcat:amcat $AMCAT_ROOT
set +e
