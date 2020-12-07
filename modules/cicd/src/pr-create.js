
const AWS = require('aws-sdk');
const codecommit = new AWS.CodeCommit({apiVersion: '2015-04-13'});
const codebuild = new AWS.CodeBuild({apiVersion: '2016-10-06'});

/**
 * Add a comment to the PR
 * @param {*} params 
 * @param {String} content 
 */
async function postComment(params, content) {
  const result = await codecommit.postCommentForPullRequest({
    ...params,
    content
  }).promise();
  console.log(JSON.stringify({params, result}));
  return result;
}

/**
 * Update the PR's approval bassed on if the CI run passed or failed
 * @param {*} pr 
 * @param {Boolean} passFail 
 */
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
 * Start the CI code build with information about this PR
 * @param {*} sourceVersion The GIT SHA of the version we are testing
 * @param {*} info A JSON String of the PR information so that we can easily associate the build results with this PR
 */
function startBuild(sourceVersion, info) {
  const params = {
    projectName: process.env.CODEBUILD_CI_PROJECT_NAME,
    sourceLocationOverride: process.env.CODECOMMIT_REPO,
    sourceTypeOverride: 'CODECOMMIT',
    environmentVariablesOverride: [ 
      {
        name: 'PR_PARAMS',
        value: JSON.stringify(info),
        type: 'PLAINTEXT'
      }
    ],
    sourceVersion    
  };
  return codebuild.startBuild(params).promise();
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

/**
 * Create the Pull Request Approval Rule which requires one approval and that approval must be from our lambda role which evaluates the CI Build
 * @param {*} pr The Pull Request Object
 */
async function createPrApprovalRule(pr) {
  const params = {
    approvalRuleContent: "{\"Version\":\"2018-11-08\",\"Statements\":[{\"Type\":\"Approvers\",\"NumberOfApprovalsNeeded\":1,\"ApprovalPoolMembers\":[\"CodeCommitApprovers:demo-cicd-project-lambda-assume-role/demo-cicd-project-ci-complete-function\"]}]}",
    approvalRuleName: 'CI Build Successful',
    pullRequestId: pr.pullRequestId
  };
  const result = await codecommit.createPullRequestApprovalRule(params).promise();
  console.log({ result });
  return result;
}

/**
 * Handler function for the PR Create or PR Update events
 * @param {*} event 
 * @param {*} context 
 */
exports.handler = async (event, context) => {
  console.log(JSON.stringify({
    event,
    context
  }, null, 2));

  const {
    destinationCommit: beforeCommitId,
    pullRequestId,
    sourceCommit: afterCommitId,
    repositoryNames,
    event: eventDetail
  } = event.detail;

  const params = {
    afterCommitId, /* required */
    beforeCommitId, /* required */        
    pullRequestId, /* required */
    repositoryName: repositoryNames[0], /* required */
  };
  const pr = await getPR(pullRequestId);
  switch(eventDetail) {
    case "pullRequestCreated":
      console.log('handling pullRequestCreated');
      await createPrApprovalRule(pr);
      await postComment(params, "Starting CodeBuild");
      await startBuild(afterCommitId, params);
      break;
    case "pullRequestSourceBranchUpdated":
      console.log('handling pullRequestSourceBranchUpdated');
      // dismiss any approval as stale
      await updateApproval(pr, false);
      // TODO: find any CodeBuild jobs for this PR currently running and stop them
      await postComment(params, "Starting CodeBuild");
      await startBuild(afterCommitId, params);
      break;
  }
  console.log('all done');
  return "all done";
}

  /*
{
    "event": {
        "version": "0",
        "id": "49e2b50b-6333-6e47-2b46-86c1da7c825b",
        "detail-type": "CodeCommit Pull Request State Change",
        "source": "aws.codecommit",
        "account": "807177163833",
        "time": "2020-12-05T15:07:15Z",
        "region": "us-west-2",
        "resources": [
            "arn:aws:codecommit:us-west-2:807177163833:demo-cicd-project-code"
        ],
        "detail": {
            "author": "arn:aws:sts::807177163833:assumed-role/AWSReservedSSO_AdministratorAccess_c1dc373eb0d60d9e/mike.kazmier@candidpartners.com",
            "callerUserArn": "arn:aws:sts::807177163833:assumed-role/AWSReservedSSO_AdministratorAccess_c1dc373eb0d60d9e/mike.kazmier@candidpartners.com",
            "creationDate": "Sat Dec 05 15:07:04 UTC 2020",
            "destinationCommit": "f62aad83bd00e86f8f1e9f894af859151dad29c0",
            "destinationReference": "refs/heads/master",
            "event": "pullRequestCreated",
            "isMerged": "False",
            "lastModifiedDate": "Sat Dec 05 15:07:04 UTC 2020",
            "notificationBody": "A pull request event occurred in the following AWS CodeCommit repository: demo-cicd-project-code. User: arn:aws:sts::807177163833:assumed-role/AWSReservedSSO_AdministratorAccess_c1dc373eb0d60d9e/mike.kazmier@candidpartners.com. Event: Created. Pull request name: 1. Additional information: A pull request was created with the following ID: 1. The title of the pull request is: Add readme. For more information, go to the AWS CodeCommit console https://us-west-2.console.aws.amazon.com/codesuite/codecommit/repositories/demo-cicd-project-code/pull-requests/1?region=us-west-2.",
            "pullRequestId": "1",
            "pullRequestStatus": "Open",
            "repositoryNames": [
                "demo-cicd-project-code"
            ],
            "revisionId": "d99014ff335a12d87cd01004c36d5d1e90c20e6b53cf3a42de51eabf4a48d22c",
            "sourceCommit": "484aaaca3f80ab8f47f21b4f7baec78c06c6eace",
            "sourceReference": "refs/heads/feature/a",
            "title": "Add readme"
        }
    },
    "context": {
        "callbackWaitsForEmptyEventLoop": true,
        "functionVersion": "$LATEST",
        "functionName": "demo-cicd-project-pr-create-function",
        "memoryLimitInMB": "128",
        "logGroupName": "/aws/lambda/demo-cicd-project-pr-create-function",
        "logStreamName": "2020/12/05/[$LATEST]5a3f591bfeb447c0b17a72913f47b71a",
        "invokedFunctionArn": "arn:aws:lambda:us-west-2:807177163833:function:demo-cicd-project-pr-create-function",
        "awsRequestId": "49885d91-6c3b-4711-879c-a8332c92096b"
    }
}
  */