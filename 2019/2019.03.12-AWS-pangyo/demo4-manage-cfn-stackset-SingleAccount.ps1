# cfn stackset - StandAlone 
# AWSCloudFormationStackSetAdministrationRole, AWSCloudFormationStackSetExecutionRole 
#
# us-east-1

# AWSCloudFormationStackSetAdministrationRole 생성
aws cloudformation create-stack --stack-name enable-cfn-stackset-admin --template-body file://AWSCloudFormationStackSetAdministrationRole.yml  `
  --capabilities CAPABILITY_NAMED_IAM `
  --profile demo --region us-east-1


# AWSCloudFormationStackSetAdministrationRole이 생성되어 있는 Administrator AWS AccountId의 값을 추출
$StackSetAdminAccountId = (Get-STSCallerIdentity -ProfileName demo).Account


# AWSCloudFormationStackSetExecutionRole 생성
aws cloudformation create-stack --stack-name enable-cfn-stackset-target --template-body file://AWSCloudFormationStackSetExecutionRole.yml  `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameters ParameterKey=AdministratorAccountId,ParameterValue=$StackSetAdminAccountId `
  --profile demo --region us-east-1


# upload cfnstackset template into S3
aws s3 cp simple-cfn-stacksetV1.yml s3://cf-templates-qiwjxyzyq-us-east-1/cfnstacksetdemo/ --profile demo --region us-east-1


# cfn stackset 생성
aws cloudformation create-stack-set --stack-set-name singleAWSAccount-Stackset-Demo `
  --template-url https://cf-templates-qiwjxyzyq-us-east-1.s3.amazonaws.com/cfnstacksetdemo/simple-cfn-stacksetV1.yml `
  --profile demo --region us-east-1


# cfn stackset instance 생성
aws cloudformation create-stack-instances --stack-set-name singleAWSAccount-Stackset-Demo `
  --accounts $StackSetAdminAccountId `
  --regions "us-east-1" `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=4 `
  --profile demo --region us-east-1


<#

# cfn stackset / stack instance 추가
aws cloudformation create-stack-instances --stack-set-name singleAWSAccount-Stackset-Demo `
  --accounts $StackSetAdminAccountId `
  --regions us-west-1, us-west-2 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=10 `
  --profile demo --region us-east-1

# cfn stackset 업뎃 (v2)
aws s3 cp simple-cfn-stacksetV2.yml s3://cf-templates-qiwjxyzyq-us-east-1/cfnstacksetdemo/ --profile demo --region us-east-1
aws cloudformation update-stack-set --stack-set-name singleAWSAccount-Stackset-Demo `
  --template-url https://cf-templates-qiwjxyzyq-us-east-1.s3.amazonaws.com/cfnstacksetdemo/simple-cfn-stacksetV2.yml `
  --profile demo --region us-east-1

# cfn stackset 삭제 (v2)
aws cloudformation delete-stack-instances --stack-set-name singleAWSAccount-Stackset-Demo `
  --accounts $StackSetAdminAccountId `
  --regions us-west-1, us-west-2 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=4 `
  --no-retain-stacks `
  --profile demo --region us-east-1

#>


# cfn stackset instance 삭제
aws cloudformation delete-stack-instances --stack-set-name singleAWSAccount-Stackset-Demo `
  --accounts $StackSetAdminAccountId `
  --regions us-east-1 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=4 `
  --no-retain-stacks `
  --profile demo --region us-east-1


# cfn stackset 삭제
aws cloudformation delete-stack-set --stack-set-name singleAWSAccount-Stackset-Demo --profile demo --region us-east-1


# AWSCloudFormationStackSetAdministrationRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-admin --profile demo --region us-east-1

# AWSCloudFormationStackSetExecutionRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-target --profile demo --region us-east-1
