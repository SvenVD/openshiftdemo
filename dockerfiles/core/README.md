Pulls from upstream and adds basic changes from upstream that is needed for all other images, like in house repos or mirrors
Image should be build by openshift, inside openshift and pushed to internal openshift registry

If this needs building outside of openshift better use something like ansible-containers or buildah?

oc new-build --context-dir=dockerfiles/core --name=corebuild --strategy=docker  https://github.com/SvenVD/openshiftdemo/ -n development

alternative way:
oc create -f yaml/imagestream.yaml
oc create -f yaml/buildconfig.yaml OR oc create -f yaml/buildconfig_withInlineDockerFile.yaml

to build locally
docker build -t development/corebuild:latest ./