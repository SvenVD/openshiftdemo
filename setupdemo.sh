#preparation commands (note all this stuff can be in one yaml also)

#Start minishift
minishift addons install --defaults; minishift addons enable admin-user;minishift addons enable anyuid;  minishift start --vm-driver=virtualbox --memory 8G --cpus 4 --host-data-dir /var/hostdata_persistent --iso-url centos

#minishift console

eval $(minishift oc-env)

#Create pipeline upfront because this seem to take a while to start the jenkins
oc login -u developer -p developer
oc new-project cicd --display-name='CICD Jenkins' --description='CICD Jenkins'
oc create -n cicd -f https://raw.githubusercontent.com/SvenVD/openshiftdemo/master/pipelines/applicationpipeline.yaml
#Increase memory default spawned jenkins
oc apply -f https://raw.githubusercontent.com/SvenVD/openshiftdemo/master/pipelines/deploymentconfigjenkins.yaml -n cicd

#==============
#Setup all environments/projects


oc new-project development --display-name='Development'  --description='Development'
oc new-project testing --display-name='Testing' --description='Testing'
oc new-project production --display-name='Production' --description='Production'

#Allow CI/CD environment to control stuff in the other environments
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n development
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n testing
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n production

#Allow  Testing and Production environment to pull images from the Development environment (where the images are build
oc policy add-role-to-group system:image-puller system:serviceaccounts:testing -n development
oc policy add-role-to-group system:image-puller system:serviceaccounts:production  -n development

#minishift console

#================
#CREATE BUILD AND DEPLOYMENT OBJECTS

#Next steps can be combined in ONE yaml file, but for demo do this on cli for now

#Make build config objects for building the core and middleware images
oc new-build --context-dir=dockerfiles/core --name=corebuild --strategy=docker https://github.com/SvenVD/openshiftdemo/ -n development
oc new-build --context-dir=dockerfiles/middleware/httpd --name=centos-httpd --strategy=docker https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true -n development
oc set triggers bc centos-httpd --from-image='corebuild:latest' -n development

#Create build and deployment config for the app in development
oc new-app --name=myapp  --context-dir=dockerfiles/applications/myapp --strategy=docker https://github.com/SvenVD/openshiftdemo/ --allow-missing-images=true -e ENVPROJECT=development -n development
#oc set probe dc/myapp -n development --readiness --get-url=http://:8080/  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=20
oc set probe dc/myapp -n development --readiness  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=5 -- /usr/local/bin/checkreadiness.sh
oc expose service myapp --name=myapp -n development
oc get route  -n development

#Wacht tot alle images gemaakt zijn
#Run desnoods

oc start-build centos-httpd -n development
oc start-build myapp -n development


#==============
#CREATE PIPELINE

#myapp buildconfig should only be started when applicationpipeline tells it to be started, it should not start by any other trigger, so removing default trigger
oc set triggers bc myapp --from-github --remove -n development
oc set triggers bc myapp --from-webhook --remove -n development
oc set triggers bc myapp --from-image='centos-httpd:latest' --remove -n development

#By default those both images are cascading build and get automatically a trigger "on change image" ,openshift figured it out via the from option
#If we want to manage them in  a jenkins pipeline we should remove all default triggers and trigger the jenkins pipeline on image change
#Start the pipeline whenever the middleware image changes
#oc patch bc applicationpipeline -n cicd -p '{"spec":{"triggers":[{"type":"ImageChange","imageChange":{"from":{"kind":"ImageStreamTag","namespace": "development","name": "centos-httpd:latest"}}}]}}'

#Create the application pipeline this already contains a trigger to start on middleware image change, it also should start on code change, this can be done via a webhook on gitlab but is not configured now
#oc create -n cicd -f https://raw.githubusercontent.com/SvenVD/openshiftdemo/master/pipelines/applicationpipeline.yaml

#=======
#Create deployment configs in other environments (this can be a single yaml file also)

#Create Testing deployment
oc create dc myapp --image=172.30.1.1:5000/development/myapp:promoteQA -n testing
oc rollout cancel dc myapp -n testing
#Always pull if image is updated not only if not present
oc patch dc/myapp  -p '{"spec":{"template":{"spec":{"containers":[{"name":"default-container","imagePullPolicy":"Always"}]}}}}' -n testing
#oc set probe dc/myapp -n testing --readiness --get-url=http://:8080/  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=20
oc set probe dc/myapp -n testing --readiness  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=5 -- /usr/local/bin/checkreadiness.sh
oc rollout cancel dc myapp-n testing
oc set env dc/myapp --overwrite ENVPROJECT=testing -n testing
oc rollout cancel dc myapp -n testing
oc expose dc myapp --port=8080 -n testing
oc expose service myapp --name=myapp -n testing


#Create Production deployment
oc create dc myapp --image=172.30.1.1:5000/development/myapp:promotePRD -n production
oc rollout cancel dc myapp -n production
#Always pull if image is updated not only if not present
oc patch dc/myapp  -p '{"spec":{"template":{"spec":{"containers":[{"name":"default-container","imagePullPolicy":"Always"}]}}}}' -n production
#oc set probe dc/myapp -n production --readiness --get-url=http://:8080/  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=20
oc set probe dc/myapp -n production --readiness  --initial-delay-seconds=5 --timeout-seconds=5 --failure-threshold=5 -- /usr/local/bin/checkreadiness.sh
oc rollout cancel dc myapp -n production
oc set env dc/myapp --overwrite ENVPROJECT=production -n production
oc rollout cancel dc myapp -n production
oc expose dc myapp --port=8080 -n production
oc expose service myapp --name=myapp -n production
oc describe  dc/myapp -n development


#=======
#showcase rolling deployment

eval $(minishift oc-env);export URL=$(oc get route -o yaml -n production |grep "host: myapp" | head -n 1 | cut -d: -f2);
while true;do date +%s; echo -n "exit code:" ;curl -s  $URL | grep instance; echo;sleep 1 ;done