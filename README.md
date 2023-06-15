# CS 312 Midterm

## Video Demo
- https://youtu.be/GoWg8F8hCXs

## Pipeline Overview
- Install any Requirements (CLI tools, Configure AWS credentials, create SSH keys, check IP addesses, etc)
- Make some edits to `main.tf` as needed to fit your specific credentials, EC2 instance `ami`, SSH key file path, etc.
- Use AWS Terraform to create the specified EC2 instance, install Java and Minecraft `server.jar` on it, and run the server
- After Terraform has provisioned and installed everything for the Minecraft server, connect to the Minecraft server running on the EC2 instance from Minecraft instance (or by using `telnet` CLI tool)

## Requirements
- Have AWS CLI installed: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  - In case it is relevant, I am on WSL2 (Windows Subsystems on Linux 2), Ubuntu version
  - So, I followed the instructions for installing AWS CLI for Linux as specified by the link above
- Create file `~/.aws/credentials` and put in the credentials from `AWS Academy Learner Lab` > `AWS Details`
  - Regardless of if you are on AWS Academy, you will still need to configure `aws_access_key_id`, `aws_secret_access_key`, and `aws_session_token` in `~/.aws/credentials`
- Install AWS Terraform CLI here: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
  - I used `Linux` (rightmost option) > `Ubuntu/Debian`, since my WSL2 instance is Ubuntu OS
  - Follow prompts in tutorial linked above
- To authenticate the Terraform provider, run `export AWS_ACCESS_KEY_ID=` and `export AWS_SECRET_ACCESS_KEY=` in terminal
- You will need an SSH Key pair, run `ssh-keygen -t rsa -b 2048` in terminal
  - I put these in my project directory but you could put them wherever, as long as you adjust the relative file paths in the code (more on this below)

## Tutorial

- At this point you can git clone my code

### Minor File Edits Needed
- Run `aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*" --query 'sort_by(Images, &CreationDate)[].Name'`
  - [Reference](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)
- I chose `amzn2-ami-ecs-hvm-2.0.20210623-x86_64-ebs` as it's x86_64 (matching the architecture of the Java version used in `main.tf`), and it also supports `t2.small` instance type (minimum size to run this kind of minecraft server)
- Run `aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-ecs-hvm-2.0.20210623-x86_64-ebs" --query 'Images[0].ImageId' --output text`
  - This returns the actual `ami` value
  - Or substitute `amzn2-ami-ecs-hvm-2.0.20210623-x86_64-ebs` with the image of your choice
  - Edit the `ami` value in line 49 of `main.tf` to match the output of the above `aws ec2 describe-images...` command
  - Reference: ChatGPT June 2023 version
- Run `curl ifconfig.me` to get your local public IP address, and copy the result to line 22 of `main.tf`  (read this as `cidr_blocks = ["<local public ip address>/32"]`)
- In case you have your SSH key pair in a directory other than the project directory root, then adjust line 45 of `main.tf`
- Go to `https://www.minecraft.net/en-us/download/server`
  - Right click `minecraft_server..jar` link here, copy link
  - Edit line 60 to use this the link you just copied

### Running the Server
- If you didn't already, run `cd 312-final` (or whatever you named the repo folder locally), so you are in the project directory in terminal
< insert edits to main.tf ami and also ssh keygen>
- Run `terraform init`
- Run `terraform fmt`
- Run `terraform validate`
- Run `terraform apply`
- Note the public IP address of your newly created EC2 instance which will be printed to the console
  - Watch for an output that starts with `instance_public_ip`
- Wait for a few minutes
  - Debug Tip: You can run `ssh -i <private key file path> ec2-user@<EC2 public key file path>` to manually SSH into the EC2 instance and see what's going on, for example run `java` to see if Java has installed itself yet
- In the meantime you can run `telnet <EC2 public IP> 25565` to see if Java has finished installing and the Minecraft server has started yet
  - The `EC2 public IP` here refers to the public IP address of the EC2 instance that is printed after `terraform apply` finishes running, to clarify
- If so, you can open Minecraft client (1.20.1 version) and connect to your new Minecraft server. Go to `Multiplayer` > `Direct Connection` > your `EC2 public IP`

## Resources / Sources Used
- CS 312 Lab 9 on AWS Terraform
- Terraform Docs
  - [Build](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build)
  - [Change](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-change)
  - [Destroy](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-destroy)
  - [Query Outputs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-outputs)
- [This Github Repo](https://github.com/HarryNash/terraform-minecraft) by [HarryNash](https://github.com/HarryNash)
  - I did have to adjust:
    - The AMI ID
    - The local IP address (obviously)
    - Had to use curl instead of wget for downloading the `server.jar` file when getting Minecraft server running, because I guess `wget` is not installed by default on Amazon Linux OS, while `curl` is
    - Had to get edit the download link for the `server.jar` file
    - Decided to change the SSH key location to make it easier to manage
    - Needed to adjust Minecraft `server.jar` URL
- [This Document on Amazon Linux AMI](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)
  - Helped with finding the AMI
- ChatGPT June 2023 Version
  - Helped with finding the AMI

