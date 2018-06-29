#Demo file should not use in production should import known trusted rpm keys
#In production this should reference openshift internal registry to prevent accidently pulling from dockerhub
#Note this container runs as root, should not run as root needs to be fixed for production


FROM 172.30.1.1:5000/development/corebuild:latest
EXPOSE 8080
RUN yum -y install httpd
#Openshift by default does not run the container as root so need a port above 1024
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
