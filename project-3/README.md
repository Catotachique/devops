 ### Prerequisites
- aws
- git
- terraform
- terragrunt

## Configuring AWS CLI and GitHub
### Install the AWS CLI
`sudo apt install awscli -y`
`aws configure` -> AWS Access Key ID, AWS Secret Access Key, Default region name (e.g., eu-west-1), Default output format(json)
`aws iam list-users`

### Config Github
`git config --global user.email "you@example.com"`
`git config --global user.name "felipedds"`

`ls ~/.ssh/id_*.pub`

#### Generate a new SSH key
`ssh-keygen -t ed25519 -C "felipedds@yahoo.com"`

#### Start the SSH agent and add the key
`eval "$(ssh-agent -s)"`
`ssh-add ~/.ssh/id_ed25519`

#### Copy the public key
`cat ~/.ssh/id_ed25519.pub`

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

[development]
region = eu-west-1
output = json

Replace YOUR_ACCESS_KEY_ID and YOUR_SECRET_ACCESS_KEY with your actual credentials.
If you've already run aws configure, you can find them in ~/.aws/credentials under the [default] profile — just copy them and rename the profile to [development].

5. Ensure both files are readable by your user:
`chmod 600 ~/.aws/credentials ~/.aws/config`

### To use a profile for multiple commands set the AWS_PROFILE.
`export AWS_PROFILE=[NAME]`
`export AWS_PROFILE=development`

### Returns details about the IAM user or role whose credentials are used to call the operation.
`aws sts get-caller-identity`

# How do you deploy the infrastructure?

### Pre-requisites
1. Install [Terraform](https://www.terraform.io/) version `1.2.5` and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.38.4` or newer.
2. Configure your AWS credentials using one of the supported [authentication
   mechanisms](https://www.terraform.io/docs/providers/aws/#authentication).

## Terragrunt create your State Backend(State Locking)
For a few popular backend types (S3 and GCS), if you're using the remote_state block, Terragrunt can automatically create the backend for you. That is, when you run terragrunt init or terragrunt apply, Terragrunt will check if the backend exists, and if it doesn't, it'll make API calls to set up the backend automatically / transparently, following best practices. <br>
Links:
https://github.com/orgs/gruntwork-io/discussions/769
https://www.youtube.com/watch?v=p7oB_OsWNAU

### Initialize backend resources for storing the Terraform state remotely (in this case, an S3 bucket and a table in DynamoDB)
`terragrunt init --backend-bootstrap`

### Deploying a single module
1. `cd` into the module's folder (e.g. `cd research/eu-west-1/network`).
2. Run `terragrunt plan` to see the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply`.

### Deploying all modules in a region
1. `cd` into the region folder (e.g. `cd research/eu-west-1`).
2. Run `terragrunt plan-all` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply-all`.

## How is the code in this repo organized?
The code in this repo uses the following folder hierarchy:

```
.
├── live                     # Actual infrastructure state
│   ├── _envcommon           # Each resource in a region has a file here to DRY common configurations 
│   │   ├── ...
│   │   └──s3
│   ├── common.hcl           # Common variables used in all accounts and regions
│   ├── account              # Each AWS account has a folder at this level (production, development or staging)
│   │   ├── _global          # Resources that doesn't depends of region (iam, route53, ...)
│   │   │   ├── ...          # Global resources folders
│   │   │   └── region.hcl
│   │   ├── region           # Each AWS region has a folder at this level (eu-west-1, ...)
│   │   │   ├── ...          # Region resources folders
│   │   │   └── region.hcl   # Variables used in all resources of a region
│   │   │── ...              # Others regions 
│   │   └── account.hcl      # Variables used in all resources of a account 
│   ├── ...                  # Others accounts
│   └── terragrunt.hcl       # Root terragrunt configuration
└── modules                  # Reusable modules (rds, iam, ec2, ....)
    └── ...
```

## First Commit
### Verify if repository is up to date
`git checkout master`
`git pull origin master`

### Create a branch
`git checkout -b <branch>`  -> Merge `<branch>` into the current branch.
`git checkout -b terraform-files`

### Verify if you stay at correct branch
`git status`


# Change the Infrastructure code
#### Steps:
1. Always first do commit
2. Apply the plan in terragrunt
3. Apply the apply command in terragrunt

### Access the repository
`cd ~/Documents/CleverAdvertizing/infrastructure-terraform`

### Access the folder that have the file: /terragrunt.hcl
`~/Documents/CleverAdvertizing/infrastructure-terraform/infrastructure-terraform/live/`..

### To use a profile for multiple commands set the AWS_PROFILE.
`export AWS_PROFILE=[NAME]`
`export AWS_PROFILE=terraform-staging`

### Returns details about the IAM user or role whose credentials are used to call the operation.
`aws sts get-caller-identity`

#### Add the files to push
`git add .`

#### Verify what you will change
`git status`

#### Verify the differences about the old file and new file
`git diff --staged`

#### Commit
`git commit -m "add files to deploy"`

#### Verify what you will change
`git status`

#### Push
`git push origin` [NAME_BRANCH]
`git push origin terraform-files`

#### Copy content from some branch to master
## Change branch to master
`git checkout master`

## Do a merge from terraform-files to master
`git merge <branch>`  -> Merge `<branch>` into the current branch.
`git merge terraform-files`

#### Delete branch
`git branch -d <branch>`  -> Merge `<branch>` into the current branch.
`git branch -d terraform-files`

#### Execute the plan
`terragrunt plan`

#### Apply the plan
`terragrunt run-all apply`

#### Import resources that already exist in AWS(resources that are created from AWS not Terraform)
terragrunt import '[REFERENCE COMPLETE]' [NAME]
`terragrunt import 'aws_s3_bucket_versioning.this["staging-bi-clever-output"]' staging-bi-clever-output`



#### Force unlock a Terraform state lock with the given lock ID
`terragrunt force-unlock 5d516cd4-571a-4cab-786b-120723bd3853`