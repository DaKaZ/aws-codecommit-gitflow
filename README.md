# AWS Terraform GitFlow

__Finally: Run CI on PR Create / Update__

---

## Quickstart

1. Set the project_name and other info `terraform.tfvars`
2. Deploy infrastrcuture `terraform apply` 
3. Connect your application repo to the code-commit repo created in step 2
4. Create a branch in your application's code: `git checkout -b feature/cool-new-feature`
5. Make a change and push your branch to code-commit
6. Create a PR on code-commit
7. Grab a beer and watch the magi

---

## Details

This project sets up a couple of Lambda's that are triggered by CloudWatch events:
* `pr-create` lambda 
  * Triggered when a PR is created or updated
  * Creates an approval rule
  * Adds a comment to the PR stating that CI is starting
  * Dismiss previous approval (if any)
  * Triggers the CodeBuild CI Buildspec
* `ci-complete` lambda
  * Triggered when a CI buildspec completes
  * Adds a comment to the PR stating the CI was successful or failed
  * Sets the approval status based on the CI success/failure

## Background 

In order to use AWS's developer tools (code-commit, code-build, code-pipeline) with a standard GitFlow style setup, we have to create some helpers.  This project can serve as a template for setting it all up.

## License

This project is freely available and distributed via the MIT license, see the [LICENSE](LICENSE.md) file for full details