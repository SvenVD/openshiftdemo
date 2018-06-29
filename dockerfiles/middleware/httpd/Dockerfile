#Demo file should not use in production should import known trusted rpm keys
FROM corebuild:latest
EXPOSE 8080
RUN yum -y install httpd
#Openshift by default does not run the container as root so need a port above 1024
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
