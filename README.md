# aws-sagemaker-studio-playground

CloudFormation stacks for setting up Amazon SageMaker Studio with Amazon EMR integration.

## Features

* Amazon SageMaker Studio setup with AWS SSO authentication
* Amazon EMR setup for SageMaker Studio with AWS Service Catalog

## Prerequisites

* VPC, NAT and bucket stacks from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).

## Deployment

Deploy stacks as follows to setup SageMaker Studio with Amazon EMR integration:

```bash
# Infra for EMR Clusters
make deploy-infra-emr

# Infra for SageMaker Studio
make deploy-infra-studio

# Service Catalog Portfolio for EMR Cluster creation via SageMaker Studio
make deploy-infra-servicecatalog

# SageMaker Studio with AWS SSO authentication
make deploy-studio

# Optional: EMR Cluster for testing (or skip and provision one from SageMaker Studio with Service Catalog)
make deploy-emr-cluster
```

Once done, you can assign AWS SSO users or groups to your studio and log in with AWS SSO.

### Cleanup

Cleanup resources by deleting all resources in reverse order from deployment:

```bash
# Delete EMR cluster setup manually (delete clusters setup via SageMaker from
# SageMaker)
make delete-emr-cluster

# Note: You must delete all EMR clusters created via the Studio UI, all Studio
# applications and users before deleting the studio. Also remember to delete the
# EFS volume for SageMaker Studio.
make delete-studio

# Service Catalog (!! delete any provisioned applications first !!)
make delete-infra-servicecatalog

# Infra for SageMaker Studio
make delete-infra-studio

# Infra for EMR Clusters. Note: You must remove security groups rules from EMR managed security groups
# for deletion to succeed.
make delete-infra-emr
```

## Stacks

* infra-emr - IAM roles and security groups for EMR Clusters
* infra-studio - IAM roles and security groups for SageMaker Studio
* infra-servicecatalog - Service Catalog portfolio for EMR cluster templates
* studio - SageMaker Studio instance with AWS SSO authentication
* emr-cluster - EMR cluster template

## Credits and References

This work is based on https://github.com/aws-samples/sagemaker-studio-emr (AWS, MIT License).

## License

MIT.
