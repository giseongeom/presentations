# cfn demo stack 생성: us-east-1, us-west-1
aws cloudformation create-stack --stack-name simple-cfn-demo --template-body file://simple-cfn-stack.yml --profile demo --region us-east-1
aws cloudformation create-stack --stack-name simple-cfn-demo --template-body file://simple-cfn-stack.yml --profile demo --region us-west-1


# v2로 stack 업데이트
aws cloudformation update-stack --stack-name simple-cfn-demo --template-body file://simple-cfn-stackV2.yml --profile demo --region us-east-1
aws cloudformation update-stack --stack-name simple-cfn-demo --template-body file://simple-cfn-stackV2.yml --profile demo --region us-west-1


# cfn demo stack 삭제
aws cloudformation delete-stack --stack-name simple-cfn-demo --profile demo --region us-east-1
aws cloudformation delete-stack --stack-name simple-cfn-demo --profile demo --region us-west-1 


<#

# 모든 region에 stack 배포
Get-AWSRegion | % {
  aws cloudformation create-stack --stack-name simple-cfn-demo --template-body file://simple-cfn-stack.yml --profile demo --region $_.Region
}

# 모든 region에 stack 삭제
Get-AWSRegion | % {
  aws cloudformation delete-stack --stack-name simple-cfn-demo --profile demo --region $_.Region
}

#>