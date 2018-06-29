Image should be build by openshift, inside openshift and pushed to internal openshift registry
Starts from core from building all kinds of middleware images to be used to build the final application image
This can also self built be S2I images
NOTE: this is for demo only, in production it would be better to directly use the existing prebuild s2i middleware that centos/Red Hat maintains if building is happening in openshift already


to build on openshift
oc login -u system:admin
oc get svc -n default | grep registry
oc new-build --context-dir=dockerfiles/middleware/httpd --name=centos-httpd --strategy=docker  https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true

to build locally
docker build -t centos-httpd ./
to run locally
docker run  -p 8080:8080 --name testhttpd centos-httpd


If this needs building outside of openshift better use something like ansible-containers or buildah?