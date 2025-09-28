IMAGE_TAG=$REPOSITORY:$VERSION
for COMMAND in "$@"
do
  case "${COMMAND}"
  in
    "dev")
      APP_BUILD_ID=1
      VERSION=1.0.$APP_BUILD_ID
      PROJECTID= -dev
      APP_BASE_URL=http://api-p7.agiletech.vn:3000
      ROLLOUT_PRIORITY=false
      SERVICE_NAME=article-bot-storify
      REPOSITORY=eu.gcr.io/$PROJECTID/$SERVICE_NAME
      IMAGE_TAG=$REPOSITORY:$VERSION
    ;;
     "staging")
       APP_BUILD_ID=113
       TEMPLATE_VERSION=1
       VERSION=1.0.$APP_BUILD_ID
       PROJECTID=glossy-essence-248121
       APP_BASE_URL=https://api.bot. .com
       REPOSITORY=eu.gcr.io/$PROJECTID/article-bot-storify-dev
       IMAGE_TAG=$REPOSITORY:$VERSION
       GROUP_NAME=article-bot-storify-instance-group
       TEMPLATE_NAME=article-bot-storify-template
       ROLLOUT_PRIORITY=false
       IS_STAGING=1
       ENV=PROD
    ;;
    "staging2")
      APP_BUILD_ID=1
      VERSION=1.0.$APP_BUILD_ID
      PROJECTID= -dev
      APP_BASE_URL=https://api. y.com
      ROLLOUT_PRIORITY=true
      SERVICE_NAME=article-bot-storify
      REPOSITORY=eu.gcr.io/$PROJECTID/$SERVICE_NAME
      IMAGE_TAG=$REPOSITORY:$VERSION
      GROUP_NAME=article-bot-storify-instance-group-priority
      TEMPLATE_NAME=article-bot-storify-template-priority
      TEMPLATE_VERSION=1
      IS_STAGING=2
      ENV=PROD
    ;;
    "prod")
      APP_BUILD_ID=68
      TEMPLATE_VERSION=1
      IS_PROD=1
      VERSION=2.0.$APP_BUILD_ID
      PROJECTID=glossy-essence-248121
      APP_BASE_URL=https://api.bot. .com
      REPOSITORY=eu.gcr.io/$PROJECTID/article-bot-storify
      IMAGE_TAG=$REPOSITORY:$VERSION
      GROUP_NAME=article-bot-storify-instance-group
      TEMPLATE_NAME=article-bot-storify-template
      ROLLOUT_PRIORITY=false
      ENV=PROD
    ;;
    "prod2")
      APP_BUILD_ID=1
      TEMPLATE_VERSION=1
      IS_PROD=2
      VERSION=2.0.$APP_BUILD_ID
      PROJECTID=glossy-essence-248121
      APP_BASE_URL=https://api.bot. .com
      REPOSITORY=eu.gcr.io/$PROJECTID/article-bot-storify
      IMAGE_TAG=$REPOSITORY:$VERSION
      GROUP_NAME=article-bot-storify-instance-group-priority
      TEMPLATE_NAME=article-bot-storify-template-priority
      ROLLOUT_PRIORITY=true
      ENV=PROD
    ;;
    "removeall")
      docker images -a |  grep $PROJECTID | awk '{print $3}' | xargs docker rmi
      ;;
    "build-base")
      echo BUILD IMAGE: $IMAGE_TAG
      docker build --no-cache \
            -f Dockerfile.base -t $IMAGE_TAG .
    ;;
    "build")
      echo BUILD IMAGE: $IMAGE_TAG
      docker build \
            --build-arg APP_BUILD_ID=$APP_BUILD_ID \
            --build-arg APP_BASE_URL=$APP_BASE_URL \
            --build-arg ROLLOUT_PRIORITY=$ROLLOUT_PRIORITY \
            --build-arg ENV=PROD \
            -f Dockerfile -t $IMAGE_TAG .
    ;;
    "push")
      docker push $REPOSITORY:$VERSION
    ;;
    "deploy")
      echo "update project:" $PROJECTID
      if [[ IS_PROD -eq 1 ]];  then
        echo CREATE TEMPLATE
        gcloud beta compute \
          --project=$PROJECTID instance-templates create-with-container $TEMPLATE_NAME-$TEMPLATE_VERSION \
          --machine-type=e2-standard-4 \
          --subnet=projects/$PROJECTID/regions/europe-west1/subnetworks/ -api-subnet \
          --network-tier=PREMIUM \
          --metadata=google-logging-enabled=true \
          --container-env='BASE_URL=https://api.bot. .com' \
          --container-env='ROLLOUT_PRIORITY=false' \
          --container-env='ENV=PROD' \
          --maintenance-policy=MIGRATE \
          --service-account=751313216443-compute@developer.gserviceaccount.com \
          --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
          --region=europe-west1 --tags=http-https,ssh,elasticsearch-trusted --image=cos-stable-75-12105-97-0 \
          --image-project=cos-cloud --boot-disk-size=50GB --boot-disk-type=pd-ssd \
          --boot-disk-device-name=$TEMPLATE_NAME-$TEMPLATE_VERSION \
          --container-image=$IMAGE_TAG --container-restart-policy=always --labels=container-vm=cos-stable-75-12105-97-0
        # echo UPDATE TEMPLATE
        #   gcloud compute instance-groups managed rolling-action start-update $GROUP_NAME \
        #     --version template=$TEMPLATE_NAME-$TEMPLATE_VERSION \
        #     --region=europe-west1
      fi      
      if [[ IS_PROD -eq 2 ]];  then
        echo CREATE TEMPLATE
        gcloud beta compute \
          --project=$PROJECTID instance-templates create-with-container $TEMPLATE_NAME-$TEMPLATE_VERSION \
		      --machine-type=e2-standard-4 \
          --subnet=projects/$PROJECTID/regions/europe-west1/subnetworks/ -api-subnet \
          --network-tier=PREMIUM \
          --metadata=google-logging-enabled=true \
          --container-env='BASE_URL=https://api.bot. .com' \
          --container-env='ROLLOUT_PRIORITY=true' \
          --container-env='ENV=PROD' \
          --maintenance-policy=MIGRATE \
          --service-account=751313216443-compute@developer.gserviceaccount.com \
          --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
          --region=europe-west1 --tags=http-https,ssh,elasticsearch-trusted --image=cos-stable-75-12105-97-0 \
          --image-project=cos-cloud --boot-disk-size=50GB --boot-disk-type=pd-ssd \
          --boot-disk-device-name=$TEMPLATE_NAME-$TEMPLATE_VERSION \
          --container-image=$IMAGE_TAG --container-restart-policy=always --labels=container-vm=cos-stable-75-12105-97-0
      fi      
      if [[ IS_STAGING -eq 1 ]]; then
        echo CREATE TEMPLATE
        gcloud beta compute \
          --project=$PROJECTID instance-templates create-with-container $TEMPLATE_NAME-$TEMPLATE_VERSION \
          --machine-type=e2-standard-4 \
          --subnet=projects/$PROJECTID/regions/europe-west1/subnetworks/ -dev-api \
          --network-tier=PREMIUM \
          --metadata=google-logging-enabled=true \
          --container-env='ROLLOUT_PRIORITY=false' \
          --container-env='ENV=PROD' \
          --maintenance-policy=TERMINATE \
          --preemptible \
          --service-account=124952962619-compute@developer.gserviceaccount.com \
          --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
          --region=europe-west1 --tags=http-https,ssh,elasticsearch-trusted --image=cos-stable-85-13310-1041-28 \
          --image-project=cos-cloud --boot-disk-size=50GB --boot-disk-type=pd-ssd \
          --boot-disk-device-name=$TEMPLATE_NAME-$TEMPLATE_VERSION \
          --container-image=$IMAGE_TAG --container-restart-policy=always --labels=container-vm=cos-stable-85-13310-1041-28
      fi      
      if [[ IS_STAGING -eq 2 ]]; then
        echo CREATE TEMPLATE
        gcloud beta compute \
          --project=$PROJECTID instance-templates create-with-container $TEMPLATE_NAME-$TEMPLATE_VERSION \
          --machine-type=e2-standard-4 \
          --subnet=projects/$PROJECTID/regions/europe-west1/subnetworks/ -dev-api \
          --network-tier=PREMIUM \
          --metadata=google-logging-enabled=true \
          --container-env='ROLLOUT_PRIORITY=true' \
          --container-env='ENV=PROD' \
          --maintenance-policy=TERMINATE \
          --preemptible \
          --service-account=124952962619-compute@developer.gserviceaccount.com \
          --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
          --region=europe-west1 --tags=http-https,ssh,elasticsearch-trusted --image=cos-stable-85-13310-1041-28 \
          --image-project=cos-cloud --boot-disk-size=50GB --boot-disk-type=pd-ssd \
          --boot-disk-device-name=$TEMPLATE_NAME-$TEMPLATE_VERSION \
          --container-image=$IMAGE_TAG --container-restart-policy=always --labels=container-vm=cos-stable-85-13310-1041-28
      fi
  esac
done
echo DONE AND DONE
