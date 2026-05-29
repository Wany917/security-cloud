module "ec2_instance" {
  source        = "./ec2_instance"
  my_ip         = chomp(data.http.myip.body)
  instance_name = "groupe-10"
}

module "s3_bucket" {
  source                        = "./s3_bucket"
  bucket_name                   = "groupe-10"
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

module "iam" {
  source      = "./iam"
  username    = "groupe-10"
  policy_name = "groupe-10"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}
