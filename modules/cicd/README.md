## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| artifacts\_bucket | name of the S3 bucket to use for build artifacts | `string` | n/a | yes |
| ci\_buildspec| rendered buildspec template for CI (build/test) | `string` | n/a | yes |
| cd\_buildspec| rendered buildspec template for CD (build/deploy) | `string` | n/a | yes |
| govcloud | n/a | `bool` | `false` | no |
| kms\_key\_arn | KMS key for the cicd pipeline | `string` | n/a | yes |
| project\_name | The name of the CICD project | `string` | n/a | yes |
| services\_account\_id | Services account ID | `string` | n/a | yes |
| tags | resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cicd\_outputs | n/a |

