### Install the AWS CLI
`sudo apt install awscli -y`
`aws configure` -> AWS Access Key ID, AWS Secret Access Key, Default region name (e.g., eu-west-1), Default output format(json)
`aws iam list-users`

### Config Github
git config --global user.email "you@example.com"
git config --global user.name "felipedds"

### Set up AWS_PROFILE
1. Create or update your AWS config and credentials

2. Edit or create the following files in ~/.aws/:
`mkdir -p ~/.aws`

3. Create and edit the credentials file
`nano ~/.aws/credentials`

[admin]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY

4. Create the config file
`~/.aws/config`

[admin]
region = eu-west-1
output = json

Replace YOUR_ACCESS_KEY_ID and YOUR_SECRET_ACCESS_KEY with your actual credentials.
If you've already run aws configure, you can find them in ~/.aws/credentials under the [default] profile — just copy them and rename the profile to [admin].

### To use a profile for multiple commands set the AWS_PROFILE.
`export AWS_PROFILE=[NAME]`
`export AWS_PROFILE=terraform-staging`

### Returns details about the IAM user or role whose credentials are used to call the operation.
`aws sts get-caller-identity`

#### Force unlock a Terraform state lock with the given lock ID
`terragrunt force-unlock 5d516cd4-571a-4cab-786b-120723bd3853`