Day 62 -- Providers, Resources and Dependencies
Task
Yesterday you created standalone resources. But real infrastructure is connected -- a server lives inside a subnet, a subnet lives inside a VPC, a security group controls what traffic gets in. Today you build a complete networking stack on AWS and learn how Terraform figures out what to create first.

Understanding dependencies is what separates a Terraform beginner from someone who can build production infrastructure.

Expected Output
A VPC with subnet, internet gateway, route table, security group, and an EC2 instance -- all created via Terraform
A dependency graph visualized with terraform graph
A markdown file: day-62-providers-resources.md
Challenge Tasks
Task 1: Explore the AWS Provider
Create a new project directory: terraform-aws-infra
Write a providers.tf file:
Define the terraform block with required_providers pinning the AWS provider to version ~> 5.0
Define the provider "aws" block with your region
Run terraform init and check the output -- what version was installed?
Read the provider lock file .terraform.lock.hcl -- what does it do?
Document: What does ~> 5.0 mean? How is it different from >= 5.0 and = 5.0.0?

Task 2: Build a VPC from Scratch
Create a main.tf and define these resources one by one:

aws_vpc -- CIDR block 10.0.0.0/16, tag it "TerraWeek-VPC"
aws_subnet -- CIDR block 10.0.1.0/24, reference the VPC ID from step 1, enable public IP on launch, tag it "TerraWeek-Public-Subnet"
aws_internet_gateway -- attach it to the VPC
aws_route_table -- create it in the VPC, add a route for 0.0.0.0/0 pointing to the internet gateway
aws_route_table_association -- associate the route table with the subnet
Run terraform plan -- you should see 5 resources to create.

Verify: Apply and check the AWS VPC console. Can you see all five resources connected?

Task 3: Understand Implicit Dependencies
Look at your main.tf carefully:

The subnet references aws_vpc.main.id -- this is an implicit dependency
The internet gateway references the VPC ID -- another implicit dependency
The route table association references both the route table and the subnet
Answer these questions:

How does Terraform know to create the VPC before the subnet?
What would happen if you tried to create the subnet before the VPC existed?
Find all implicit dependencies in your config and list them
Task 4: Add a Security Group and EC2 Instance
Add to your config:

aws_security_group in the VPC:

Ingress rule: allow SSH (port 22) from 0.0.0.0/0
Ingress rule: allow HTTP (port 80) from 0.0.0.0/0
Egress rule: allow all outbound traffic
Tag: "TerraWeek-SG"
aws_instance in the subnet:

Use Amazon Linux 2 AMI for your region
Instance type: t2.micro
Associate the security group
Set associate_public_ip_address = true
Tag: "TerraWeek-Server"
Apply and verify -- your EC2 instance should have a public IP and be reachable.

Task 5: Explicit Dependencies with depends_on
Sometimes Terraform cannot detect a dependency automatically.

Add a second aws_s3_bucket resource for application logs
Add depends_on = [aws_instance.main] to the S3 bucket -- even though there is no direct reference, you want the bucket created only after the instance
Run terraform plan and observe the order
Now visualize the entire dependency tree:

terraform graph | dot -Tpng > graph.png
If you don't have dot (Graphviz) installed, use:

terraform graph
and paste the output into an online Graphviz viewer.

Document: When would you use depends_on in real projects? Give two examples.

Task 6: Lifecycle Rules and Destroy
Add a lifecycle block to your EC2 instance:
lifecycle {
  create_before_destroy = true
}
Change the AMI ID to a different one and run terraform plan -- observe that Terraform plans to create the new instance before destroying the old one

Destroy everything:

terraform destroy
Watch the destroy order -- Terraform destroys in reverse dependency order. Verify in the AWS console that everything is cleaned up.
Document: What are the three lifecycle arguments (create_before_destroy, prevent_destroy, ignore_changes) and when would you use each?
