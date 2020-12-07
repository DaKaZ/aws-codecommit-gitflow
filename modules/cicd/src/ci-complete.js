const AWS = require('aws-sdk');
const codecommit = new AWS.CodeCommit({apiVersion: '2015-04-13'});

async function postComment(params, content) {
  const result = await codecommit.postCommentForPullRequest({
    ...params,
    content
  }).promise();
  console.log(JSON.stringify({params, result}));
  return result;
}

async function updateApproval(pr, passFail) {
  const params = {
    pullRequestId: pr.pullRequestId,
    revisionId: pr.revisionId,
    approvalState: passFail ? "APPROVE" : "REVOKE"
  };
  const result = await codecommit.updatePullRequestApprovalState(params).promise();
  console.log({result});
  return result;
}

/**
 * Retreive the full PR object from AWS
 * @param {*} pullRequestId 
 */
async function getPR(pullRequestId) {
  const result = await codecommit.getPullRequest({ pullRequestId }).promise()
  console.log(JSON.stringify({result}));
  return result.pullRequest;
}

exports.handler = async (event, context) => {
  console.log(JSON.stringify({
    event,
    context
  }, null, 2));

  const buildStatus = event.detail['build-status'];

  // We cheat and add our PR information in as an environment variable with the pr-create lambda
  const prParams = event.detail['additional-information'].environment['environment-variables'].find((env) => env.name === 'PR_PARAMS')
  const params = JSON.parse(prParams.value);

  const pr = await getPR(params.pullRequestId);

  switch(buildStatus) {
    case 'SUCCEEDED': 
      console.log('processings success');
      await postComment(params, "CI Build Succeeded");
      await updateApproval(pr, true);
      break;
    default:
      console.log(`processing ${buildStatus}`);
      await postComment(params, "CI Build Failed");
      await updateApproval(pr, false);
      break;
  }
  console.log('all done');
  return "all done";
}

/*
{
    "event": {
        "version": "0",
        "id": "40ef1105-07ad-31c3-624b-f8c14aff35af",
        "detail-type": "CodeBuild Build State Change",
        "source": "aws.codebuild",
        "account": "807177163833",
        "time": "2020-12-06T04:49:15Z",
        "region": "us-west-2",
        "resources": [
            "arn:aws:codebuild:us-west-2:807177163833:build/demo-cicd-project-ci-build:6c4d6039-e057-46a6-94ae-3c104f906298"
        ],
        "detail": {
            "build-status": "SUCCEEDED",
            "project-name": "demo-cicd-project-ci-build",
            "build-id": "arn:aws:codebuild:us-west-2:807177163833:build/demo-cicd-project-ci-build:6c4d6039-e057-46a6-94ae-3c104f906298",
            "additional-information": {
                "cache": {
                    "type": "NO_CACHE"
                },
                "build-number": 13,
                "timeout-in-minutes": 60,
                "build-complete": true,
                "initiator": "AWSReservedSSO_AdministratorAccess_c1dc373eb0d60d9e/mike.kazmier@candidpartners.com",
                "build-start-time": "Dec 6, 2020 4:48:09 AM",
                "source": {
                    "buildspec": "version: 0.2\nphases:\n  install:\n    commands:\n      - export AWS_DEFAULT_REGION=us-west-2\n      - wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip\n      - unzip -q terraform_0.12.29_linux_amd64.zip -d /usr/local/bin\n      - chmod +x /usr/local/bin/terraform\n      - wget \"https://github.com/candidpartners/terraform-provider-candidaws/releases/download/v1.1.2/bin.linux_amd64\"\n      - mv bin.linux_amd64 \"/usr/local/bin/terraform-provider-candidaws_v1.1.2\"\n      - chmod +x \"/usr/local/bin/terraform-provider-candidaws_v1.1.2\"\n  pre_build:\n    commands:\n      # -  terraform get\n      # - terraform init\n  build:\n    commands:\n      # - terraform apply --auto-approve\n      - echo \"Running tests\"\n      - pwd\n      - ls -la\n      - npm ci && npm test\n",
                    "location": "https://git-codecommit.us-west-2.amazonaws.com/v1/repos/demo-cicd-project-code",
                    "git-clone-depth": 0,
                    "type": "CODECOMMIT"
                },
                "source-version": "8a7939e75264b0e97c4e97f6e41d0b4046a1904d",
                "artifact": {
                    "location": ""
                },
                "environment": {
                    "image": "aws/codebuild/standard:4.0",
                    "privileged-mode": true,
                    "image-pull-credentials-type": "CODEBUILD",
                    "compute-type": "BUILD_GENERAL1_MEDIUM",
                    "type": "LINUX_CONTAINER",
                    "environment-variables": []
                },
                "logs": {
                    "group-name": "/aws/codebuild/demo-cicd-project",
                    "stream-name": "6c4d6039-e057-46a6-94ae-3c104f906298",
                    "deep-link": "https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#logEvent:group=/aws/codebuild/demo-cicd-project;stream=6c4d6039-e057-46a6-94ae-3c104f906298"
                },
                "phases": [
                    {
                        "phase-context": [],
                        "start-time": "Dec 6, 2020 4:48:09 AM",
                        "end-time": "Dec 6, 2020 4:48:10 AM",
                        "duration-in-seconds": 0,
                        "phase-type": "SUBMITTED",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [],
                        "start-time": "Dec 6, 2020 4:48:10 AM",
                        "end-time": "Dec 6, 2020 4:48:11 AM",
                        "duration-in-seconds": 1,
                        "phase-type": "QUEUED",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:48:11 AM",
                        "end-time": "Dec 6, 2020 4:48:46 AM",
                        "duration-in-seconds": 35,
                        "phase-type": "PROVISIONING",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:48:46 AM",
                        "end-time": "Dec 6, 2020 4:48:51 AM",
                        "duration-in-seconds": 4,
                        "phase-type": "DOWNLOAD_SOURCE",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:48:51 AM",
                        "end-time": "Dec 6, 2020 4:49:01 AM",
                        "duration-in-seconds": 10,
                        "phase-type": "INSTALL",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:49:01 AM",
                        "end-time": "Dec 6, 2020 4:49:01 AM",
                        "duration-in-seconds": 0,
                        "phase-type": "PRE_BUILD",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:49:01 AM",
                        "end-time": "Dec 6, 2020 4:49:11 AM",
                        "duration-in-seconds": 10,
                        "phase-type": "BUILD",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:49:11 AM",
                        "end-time": "Dec 6, 2020 4:49:11 AM",
                        "duration-in-seconds": 0,
                        "phase-type": "POST_BUILD",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:49:11 AM",
                        "end-time": "Dec 6, 2020 4:49:11 AM",
                        "duration-in-seconds": 0,
                        "phase-type": "UPLOAD_ARTIFACTS",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "phase-context": [
                            ": "
                        ],
                        "start-time": "Dec 6, 2020 4:49:11 AM",
                        "end-time": "Dec 6, 2020 4:49:13 AM",
                        "duration-in-seconds": 2,
                        "phase-type": "FINALIZING",
                        "phase-status": "SUCCEEDED"
                    },
                    {
                        "start-time": "Dec 6, 2020 4:49:13 AM",
                        "phase-type": "COMPLETED"
                    }
                ],
                "queued-timeout-in-minutes": 480
            },
            "current-phase": "COMPLETED",
            "current-phase-context": "[: ]",
            "version": "1"
        }
    },
    "context": {
        "callbackWaitsForEmptyEventLoop": true,
        "functionVersion": "$LATEST",
        "functionName": "demo-cicd-project-ci-complete-function",
        "memoryLimitInMB": "128",
        "logGroupName": "/aws/lambda/demo-cicd-project-ci-complete-function",
        "logStreamName": "2020/12/06/[$LATEST]7cc9c96e3ca546f09c7490e4d6531d0e",
        "invokedFunctionArn": "arn:aws:lambda:us-west-2:807177163833:function:demo-cicd-project-ci-complete-function",
        "awsRequestId": "2a5f80c4-3cf3-480a-a12d-d12cfc4a1abd"
    }
}

*/