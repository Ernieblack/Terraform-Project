terraform {
  backend "s3" {
    bucket = "terr3"
    key    = "Key-for-lab"
    region = "eu-west-1"
  }
}