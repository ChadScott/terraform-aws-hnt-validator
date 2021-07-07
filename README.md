# Helium Validator Terraform Module

This module creates a [Helium Validator](https://docs.helium.com/mine-hnt/validators) in the AWS cloud environment. It assumes you have already created a VPC, at least one subnet, and this subnet can both attach Elastic IPs and reach the Internet.

It will create:
* An encrypted EBS volume to store Validator state information
* An on-demand instance to run the Validator
* A security group for ingress/egress to/from the instance
* A unique RSA public/private key pair for the instance
* A schedule to automatically snapshot the Validator state volume on a daily basis (if enabled)
* A CloudWatch autorecovery rule to replace the Validator if the instance fails

**WARNING**: *There will be significant network transfer, EBS storage, and instance compute costs associated with this module. All these costs are your responsibility. In addition, a Helium Validator requires a significant stake of HNT coins to be deposited before it can participate in a consensus group and therefore earn HNT coins of its own. It is your responsibility to understand what a Helium Validator is and the risks, costs, and all other pertinent information prior to using this module.*

## Minimal Invocation
```
module "my_validator" {
  source = "github.com/ChadScott/terraform-aws-hnt-validator"
  validator_subnet = "subnet-deadbeef"
}
```

## Input Variables
|Name|Type|Required|Default Value|Description|
|-|-|-|-|-|
|output_keys|Boolean|No|`false`|Determines if the private key for the validator is output to local disk. The filename will take the form `validator-<random_hash>.key` and is useful for logging into the instance for debugging purposes. See also the `private_key` output, below.|
|ssh_allowlist|List of Strings|No|`[]`|Defines the allowlist for the SSH listener on port 22. **It is strongly recommended you make this list as short as possible, ideally empty, while the validator is running.**|
|validator_ami|String|No|*latest Ubuntu 20.04 AMI*|The AMI used to launch the validator instance. Only Ubuntu 20.04 is tested. If left blank, the latest Ubuntu 20.04 AMI will be automatically selected, which may result in an occasional restart of the Validator.|
|validator_autorecover|Boolean|No|`true`|Determines whether the instance will be automatically restarted when a status check fails. This is not foolproof and only evaluates AWS' own internal status checks. It will not detect a Validator software failure.|
|validator_ebs_snapshot|String|No|`""`|An EBS snapshot to restore into the Validator volume. Useful for recovering from an AZ failure, Terraform state corruption issue, etc.|
|validator_instance_type|String|No|`"t3.large"`|The instance type to use for the Validator. The documentation recommends a `t3.large` or better.|
|
