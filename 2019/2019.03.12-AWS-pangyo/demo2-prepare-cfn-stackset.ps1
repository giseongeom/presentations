# cfn stackset Administrator Account
#
# us-east-1

# AWSCloudFormationStackSetAdministrationRole 생성
aws cloudformation create-stack --stack-name enable-cfn-stackset-admin `
  --template-body file://AWSCloudFormationStackSetAdministrationRole.yml  `
  --capabilities CAPABILITY_NAMED_IAM `
  --profile demoadmin --region us-east-1


# cfn stackset Target Account
#
# us-east-1 

# AWSCloudFormationStackSetAdministrationRole이 생성되어 있는 Administrator AWS AccountId의 값을 추출
$StackSetAdminAccountId = (Get-STSCallerIdentity -ProfileName demoadmin).Account

# AWSCloudFormationStackSetExecutionRole 생성
aws cloudformation create-stack --stack-name enable-cfn-stackset-target `
  --template-body file://AWSCloudFormationStackSetExecutionRole.yml  `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameters ParameterKey=AdministratorAccountId,ParameterValue=$StackSetAdminAccountId `
  --profile demotarget --region us-east-1


<#

# cfn stackset Role 삭제
#
# AWSCloudFormationStackSetAdministrationRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-admin --profile demoadmin --region us-east-1

# AWSCloudFormationStackSetExecutionRole 삭제
aws cloudformation delete-stack --stack-name enable-cfn-stackset-target --profile demotarget --region us-east-1

#>