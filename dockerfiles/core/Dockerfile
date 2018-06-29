#Demo file  should not use in production should import known trusted rpm keys
FROM docker.io/centos:7.5.1804
#Better use a script that contains all changes if RUN commands are becoming to big
RUN ["/bin/bash", "-c", "/usr/bin/date > /etc/builddate"]
RUN yum -y install net-tools

