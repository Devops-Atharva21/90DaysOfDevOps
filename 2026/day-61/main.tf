##Region

provider "aws" {
  region = "ap-south-1"
}

## S3 Bucket creation

resource "aws_s3_bucket" "remote-s3-bucket" {
  bucket = "practice-remote-backend-bucket-awsatharva"
  tags = {
    Name = "remote-backend-bucket"
 }
}

## Instance Creation

resource "aws_instance" "my-practice-instance" {
  ami = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  tags = {
    Name = "TerraWeek-Day1"
}
}
