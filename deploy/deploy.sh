#!/bin/bash
CLUSTER='autodeploy'
APP_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/autodeploy:$CIRCLE_SHA1"

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli(){
  aws --version
  aws configure set default.region us-west-2
  aws configure set default.output json
}

deploy_cluster() {

  family="sample-webapp-task-family"

  make_task_def
  #register_definition
  aws ecs register-task-definition --container-definitions "$task_def" --family $family
  aws ecs update-service --cluster autodeploy --service sample-webapp-service
  #if [[ $(aws ecs update-service --cluster autodeploy --service sample-webapp-service --task-definition $revision | \
  #     $JQ '.service.taskDefinition') != $revision ]]; then
  #   echo "Error updating service."
  #   return 1
 # fi
}

make_task_def(){
  task_template='[
    {
      "name": "autodeploy",
      "image": "%s.dkr.ecr.us-west-2.amazonaws.com/autodeploy:%s",
      "essential": true,
      "memory": 200,
      "cpu": 10,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 80
        }
      ]
    }
  ]'
  
  task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $CIRCLE_SHA1)
}

push_ecr_image(){
  echo "Preparing to push, building now..."

  # docker build -t APP_IMAGE .
  eval $(aws ecr get-login --no-include-email --region us-west-2)
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/autodeploy:$CIRCLE_SHA1
  docker run -d --restart=always -p 8080:80 -t $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/autodeploy:$CIRCLE_SHA1
}

register_definition() {
  if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
    echo "Revision: $revision"
  else
    echo "Failed to register task definition"
    return 1
  fi
}

configure_aws_cli
push_ecr_image
deploy_cluster

