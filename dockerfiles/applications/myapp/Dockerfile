#Demo file should not use in production should import known trusted rpm keys
#In production this should reference openshift internal registry to prevent accidently pulling from dockerhub
#Note this container runs as root, should not run as root needs to be fixed for production

FROM 172.30.1.1:5000/development/centos-httpd:latest
EXPOSE 8080
ENV ENVPROJECT notset
COPY code/index.html /var/www/html/
COPY code/checkreadiness.sh /usr/local/bin/checkreadiness.sh
RUN chmod +x /usr/local/bin/checkreadiness.sh && rm -fv /etc/httpd/conf.d/welcome.conf
CMD sed -i "s/application/application instanceid: $RANDOM  environment: ${ENVPROJECT}/g" /var/www/html/index.html ; exec /usr/sbin/httpd -D FOREGROUND

