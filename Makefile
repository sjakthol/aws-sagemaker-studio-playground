# Mapping from long region names to shorter ones that is to be
# used in the stack names
AWS_eu-north-1_PREFIX = en1
AWS_eu-west-1_PREFIX = ew1
AWS_us-east-1_PREFIX = ue1

# Some defaults
AWS ?= aws
AWS_REGION ?= eu-west-1
AWS_CMD = $(AWS) --region $(AWS_REGION)
AWS_ACCOUNT_ID = $(eval AWS_ACCOUNT_ID := $(shell $(AWS_CMD) sts get-caller-identity --query Account --output text))$(AWS_ACCOUNT_ID)
DEPLOYMENT = $(AWS_$(AWS_REGION)_PREFIX)-sagemaker

TAGS ?= DeploymentName=$(DEPLOYMENT)

# Generic deployment and teardown targets
deploy-%:
	$(AWS_CMD) cloudformation deploy \
		--stack-name $(DEPLOYMENT)-$* \
		--tags $(TAGS) \
		--template-file templates/$*.yaml \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides DeploymentName=$(DEPLOYMENT) $(EXTRA_PARAMETERS) \
		$(EXTRA_ARGS)

delete-%:
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(DEPLOYMENT)-$*

# Customizations
IDENTITY_ARN ?= $(shell $(AWS_CMD) iam get-role --role-name $$($(AWS_CMD) sts get-caller-identity --query Arn --output text | cut -d "/" -f 2) --output text --query Role.Arn)
deploy-infra-servicecatalog: EXTRA_PARAMETERS=ExtraPrincipal=$(IDENTITY_ARN)
deploy-infra-servicecatalog: upload-cluster-template
upload-cluster-template:
	sed "s/DEPLOYMENT_DEFAULT/$(DEPLOYMENT)/g" templates/emr-cluster.yaml | \
		$(AWS_CMD) s3 cp - s3://$(AWS_ACCOUNT_ID)-$(AWS_REGION)-build-resources/$(DEPLOYMENT)/emr-cluster.yaml

# Concrete deploy and delete targets for autocompletion
$(addprefix deploy-,$(basename $(notdir $(wildcard templates/*.yaml)))):
$(addprefix delete-,$(basename $(notdir $(wildcard templates/*.yaml)))):