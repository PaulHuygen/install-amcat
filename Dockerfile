FROM ubuntu:14.04
COPY install_amcat /root/
COPY docker.cfg root/local.cfg
COPY amcat_wsgi.conf-dist /root/
COPY nginx-amcat.conf-dist /root/
COPY jre-8u111-linux-x64.tar.gz /tmp/
RUN cd /root && /root/install_amcat


