data template_file ci_buildspec {
  template = <<EOF
version: 0.2
phases:
  install:
    commands:
      - export AWS_DEFAULT_REGION=${var.aws_region}
      - wget https://releases.hashicorp.com/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip
      - unzip -q terraform_${var.terraform_version}_linux_amd64.zip -d /usr/local/bin
      - chmod +x /usr/local/bin/terraform
      - wget "https://github.com/candidpartners/terraform-provider-candidaws/releases/download/${var.candidaws_version}/bin.linux_amd64"
      - mv bin.linux_amd64 "/usr/local/bin/terraform-provider-candidaws_${var.candidaws_version}"
      - chmod +x "/usr/local/bin/terraform-provider-candidaws_${var.candidaws_version}"
  pre_build:
    commands:
      # -  terraform get
      # - terraform init
  build:
    commands:
      # - terraform apply --auto-approve
      - echo "Running tests"
      - pwd
      - ls -la
      - npm ci && npm test
EOF
}
