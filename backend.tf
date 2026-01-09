terraform {
  backend "s3" {
    bucket         = "vegan-studio-tf-state-graj902"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-south-1" # <--- CHANGED
    dynamodb_table = "vegan-studio-tf-lock"
    encrypt        = true
  }
}
