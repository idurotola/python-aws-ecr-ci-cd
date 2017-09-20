#!/bin/bash
CLUSTER='autodeploy'

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
  register_definition
  if [[ $(aws ecs update-service --cluster autodeploy --service sample-webapp-service --task-definition $revision | \
        $JQ '.service.taskDefinition') != $revision ]]; then
      echo "Error updating service."
      return 1
  fi
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
          "containerPort": 5555,
          "hostPort": 80
        }
      ]
    }
  ]'
  
  task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $CIRCLE_SHA1)
}

push_ecr_image(){
  eval $(aws ecr get-login --region us-west-2)
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/autodeploy:$CIRCLE_SHA1
}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
      echo "Revision: $revision"
    else
      echo "Failed to register task definition"
      return 1
    fi

}

if [ "${CIRCLE_BRANCH}" == "master" ]; then
  configure_aws_cli
  push_ecr_image
  deploy_cluster
else
  echo "Not on master branch - Not Deploying"
fi
