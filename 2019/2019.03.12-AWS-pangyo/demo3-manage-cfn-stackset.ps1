# cfn stackset Administrator Account
#
# us-east-1

# upload cfnstackset template into S3 (짜증!!!!)
aws s3 cp simple-cfn-stacksetV1.yml s3://cf-templates-ftyijnrfnbtz-us-east-1/cfnstacksetdemo/ --profile demoadmin --region us-east-1

# cfn stackset 생성
aws cloudformation create-stack-set --stack-set-name simple-cfn-stackset-demo `
  --template-url https://cf-templates-ftyijnrfnbtz-us-east-1.s3.amazonaws.com/cfnstacksetdemo/simple-cfn-stacksetV1.yml `
  --profile demoadmin --region us-east-1



# target AWS AccountId 
$StackSetTargetAccountId = (Get-STSCallerIdentity -ProfileName demotarget).Account

# cfn stackset / stack instance 생성
aws cloudformation create-stack-instances --stack-set-name simple-cfn-stackset-demo `
  --accounts $StackSetTargetAccountId `
  --regions us-east-1, us-west-1 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=4 `
  --profile demoadmin --region us-east-1


# cfn stackset 업뎃 (v2)
aws s3 cp simple-cfn-stacksetV2.yml s3://cf-templates-ftyijnrfnbtz-us-east-1/cfnstacksetdemo/ --profile demoadmin --region us-east-1
aws cloudformation update-stack-set --stack-set-name simple-cfn-stackset-demo `
  --template-url https://cf-templates-ftyijnrfnbtz-us-east-1.s3.amazonaws.com/cfnstacksetdemo/simple-cfn-stacksetV2.yml `
  --profile demoadmin --region us-east-1


# cfn stackset / stack instance 추가
aws cloudformation create-stack-instances --stack-set-name simple-cfn-stackset-demo `
  --accounts $StackSetTargetAccountId `
  --regions us-east-2, us-west-2 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=4 `
  --profile demoadmin --region us-east-1

# cfn stackset / stack instance 삭제
aws cloudformation delete-stack-instances --stack-set-name simple-cfn-stackset-demo `
  --accounts $StackSetTargetAccountId `
  --regions us-east-1, us-east-2, us-west-1, us-west-2 `
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=10 `
  --no-retain-stacks `
  --profile demoadmin --region us-east-1


# cfn stackset 삭제
aws cloudformation delete-stack-set --stack-set-name simple-cfn-stackset-demo --profile demoadmin --region us-east-1

# AWSCloudFormationStackSetAdministrationRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-admin --profile demoadmin --region us-east-1

# AWSCloudFormationStackSetExecutionRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-target --profile demotarget --region us-east-1
