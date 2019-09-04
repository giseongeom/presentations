# Set InstallationPolicty
#  Currently not working as of PowerShell 6.2.2
#  See https://github.com/PowerShell/PowerShellGet/issues/35)
Find-Module -Name AWSPowerShell*
Install-Module -Name AWSPowerShell.NetCore -Scope CurrentUser -Verbose
Get-Module -Name AWS* -ListAvailable

Get-PSRepository
Get-PSRepository | Set-PSRepository -InstallationPolicy Trusted -Verbose
Get-PSRepository | Set-PSRepository -InstallationPolicy Untrusted -Verbose


# prepare
Import-Module AWSPowerShell.NetCore
Set-AWSCredential -ProfileName demo -Verbose
Set-DefaultAWSRegion -Region ap-northeast-1 -Verbose

# Check current version and AWS Account environment
Get-AWSPowerShellVersion
(Get-IAMUser).Arn
Get-DefaultAWSRegion

# chdir
# used when running pwsh on WSL
# Set-Location /mnt/c/Users/giseong.eom/Documents/GitHub/my/presentations/2019/2019.09.03-AWS-cli

# Set default profile / region
Set-AWSCredential -ProfileName demo -Verbose
Set-DefaultAWSRegion -Region ap-northeast-1 -Verbose

# Re-check
Get-IAMUser
Get-DefaultAWSRegion


# Keypair
Get-EC2KeyPair

# Import existing keypair
$sshpubkey = Get-Content ~\.ssh\id_rsa_vagrant.pub -Raw
$b64_pubkey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($sshpubkey))
Import-EC2KeyPair -KeyName vagrant -PublicKeyMaterial $b64_pubkey  -Force -Verbose


# Cloudformation
$myIP = (Invoke-WebRequest -Uri 'https://wtfismyip.com/json/' | ConvertFrom-Json).YourFuckingIPAddress + "/32"
New-CFNStack -StackName AwsTools4PsCoreLab -Capability CAPABILITY_NAMED_IAM `
  -Parameter @( @{Key="DemoLocationIp"; Value="$myIP"}  ) `
  -TemplateBody $(get-content -Path .\cfn-lab.yml -Raw) -Verbose

# View CFN event
Get-CFNStackEvent -StackName AwsTools4PsCoreLab | Select-Object -First 10

$myIP = (Invoke-WebRequest -Uri 'https://wtfismyip.com/json/' | ConvertFrom-Json).YourFuckingIPAddress + "/32"
Update-CFNStack -StackName AwsTools4PsCoreLab -Capability CAPABILITY_NAMED_IAM -Parameter @(@{Key="DemoLocationIp"; Value="$myIP"}) -TemplateBody $(get-content -Path .\cfn-lab.yml -Raw) -Verbose



# View private/public IP Addresses
Get-EC2Address | Format-Table -AutoSize Domain,PrivateIpAddress,PublicIp

# (Running) InstanceIds
(Get-EC2Instance).Instances | Where-Object { $_.State.Code -eq '16' }
(Get-EC2InstanceStatus).InstanceId

# Retrieve (Windows) password
$WindowsInstanceId = (Get-EC2Instance).Instances | Where-Object { ( $_.State.Code -eq '16') -and ($_.Platform -eq 'Windows') } | Select-Object -First 1 -ExpandProperty Instanceid
Get-EC2PasswordData -InstanceId $WindowsInstanceId -Decrypt -PemFile ~/.ssh/id_rsa_vagrant | clip.exe

# Connect (Windows) Instance
$WindowsInstancePIP = (Get-EC2Instance).Instances | Where-Object { ( $_.State.Code -eq '16') -and ($_.Platform -eq 'Windows') } | Select-Object -First 1 -ExpandProperty PublicIpAddress
mstsc /v:$WindowsInstancePIP


# Connect (Linux) instance
(Get-EC2Instance).Instances | 
    Where-Object { ( $_.State.Code -eq '16') -and ($_.Platform -ne 'Windows') } |
    Select-Object -ExpandProperty PublicIpAddress | 
    ForEach-Object {
        Start-Process "ssh" -WindowStyle Normal -ArgumentList "-i ~/.ssh/id_rsa_vagrant demouser@$_"
    }





# View EC2 security Group
$lab_sg = (Get-EC2SecurityGroup | Where-Object { $_.GroupName -like "AwsTools4PS*" }).GroupId
Get-EC2SecurityGroup -GroupId $lab_sg | Select-Object -ExpandProperty IpPermissions | Format-Table -AutoSize IPRanges,FromPort,ToPort


# Tags
Get-EC2Tag



# cleanup
Remove-CFNStack -StackName AwsTools4PsCoreLab -Verbose -Force
Get-EC2KeyPair | Remove-EC2KeyPair -Verbose -Force








# aws ec2 describe-images --owner amazon --query "Images[?starts_with(Name, 'amzn2-ami-hvm-2.0')] | sort_by([], &CreationDate) | reverse([])[0].[Name,Description,ImageId,CreationDate]"
Get-EC2Image -Owner amazon | 
    Where-Object { $_.name -like "amzn2-ami-hvm-2.0*" } | 
    Sort-Object -Property CreationDate -Descending |
    Select-Object -First 1 -Property Name,Description,ImageId,CreationDate


# aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='vpc-b01433d4'] | [?contains(Description, 'Demo')]"
Get-EC2SecurityGroup | 
 ? { ($_.VpcId -eq 'vpc-b01433d4') -and ($_.Description -like "*Demo*") }

# aws ec2 describe-instances --query "Reservations[].Instances[].[PublicIpAddress,State.Name]" --output table
(Get-EC2Instance).Instances | ft -AutoSize PublicIpAddress,@{l='State';e={$_.State.Name}}