# Security Group Child Module

Reusable AWS Security Group component that generates dynamic TCP ingress rules based on a provided list of port numbers.

## Inputs

| Name | Type | Description | Default | Required |
| ------ | ------ | ------------- | --------- | :--------: |
| name | string | Security group name | n/a | yes |
| description | string | Description of security group purpose | `"Managed by Terraform"` | no |
| vpc_id | string | VPC ID where security group will be placed | n/a | yes |
| ingress_ports | list(number) | List of TCP ports to allow for ingress | `[]` | no |
| allowed_cidr_blocks | list(string) | CIDR blocks allowed for ingress traffic | `["0.0.0.0/0"]` | no |
| tags | map(string) | Custom tags to merge with default tags | `{}` | no |

## Outputs

| Name | Description |
| ------ | ------------- |
| security_group_id | The ID of the created security group |
| security_group_name | The name of the created security group |
| security_group_arn | The ARN of the created security group |
