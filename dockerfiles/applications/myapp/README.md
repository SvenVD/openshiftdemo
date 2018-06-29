Image should be build by openshift, inside openshift and pushed to internal openshift registry
Starts from core from building all kinds of middleware images to be used to build the final application image
NOTE: this is for demo only, in production it would be better to directly use the existing prebuild s2i middleware that centos/Red Hat maintains if building is happening in openshift already


to build on openshift
oc new-build --context-dir=dockerfiles/applications/myapp --name=myapp --strategy=docker  https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true -n development
with deployment config and service
oc new-app --name=myapp  --context-dir=dockerfiles/applications/myapp --strategy=docker https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true -n development
oc expose service myapp --name=myapp
oc get route

to build locally
docker build -t development/myapp ./
to run locally
docker run  -p 8080:8080 --name myapp development/myapp


If this needs building outside of openshift better use something like ansible-containers or buildah?