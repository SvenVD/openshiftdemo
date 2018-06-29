#Demo file should not use in production should import known trusted rpm keys
#In production this should reference openshift internal registry to prevent accidently pulling from dockerhub
#Note this container runs as root, should not run as root needs to be fixed for production

FROM 172.30.1.1:5000/development/centos-httpd:latest
EXPOSE 8080
COPY code/index.html /var/www/html/
RUN rm -fv /etc/httpd/conf.d/welcome.conf
CMD sed -i "s/application/application instanceid: $RANDOM  environment: ${OPENSHIFT_BUILD_NAMESPACE}/g" /var/www/html/index.html ; exec /usr/sbin/httpd -D FOREGROUND

