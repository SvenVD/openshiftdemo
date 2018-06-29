Image should be build by openshift, inside openshift and pushed to internal openshift registry
Starts from core from building all kinds of middleware images to be used to build the final application image
This can also be self build S2I images
NOTE: this is for demo only, in production it would be better to directly use the existing prebuild s2i middleware that centos/Red Hat maintains if building is happening in openshift already

oc new-build --context-dir=dockerfiles/middleware/httpd --name=centos-httpd --strategy=docker  https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true -n development

to build locally
docker build -t 172.30.1.1:5000/development/centos-httpd ./
to run locally
docker run  -p 8080:8080 --name testhttpd 172.30.1.1:5000/development/centos-httpd


If this needs building outside of openshift better use something like ansible-containers or buildah?
