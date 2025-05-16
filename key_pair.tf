resource "tls_private_key" "private_key_pair" {
  count = var.key_pair_name == null && var.enable_ssh == true ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count = var.key_pair_name == null && var.enable_ssh == true ? 1 : 0

  key_name   = local.key_name
  public_key = tls_private_key.private_key_pair[0].public_key_openssh
}
