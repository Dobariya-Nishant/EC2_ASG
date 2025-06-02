resource "tls_private_key" "private_key_pair" {
  count = var.key_pair_name == null && local.enable_ssh == true ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count = var.key_pair_name == null && local.enable_ssh == true ? 1 : 0

  key_name   = "${local.pre_fix}-key"
  public_key = tls_private_key.private_key_pair[0].public_key_openssh
}

resource "local_file" "private_key_file" {
  count = var.key_pair_name == null && local.enable_ssh == true ? 1 : 0

  filename        = "${path.root}/keys/${aws_key_pair.generated_key[0].key_name}.pem"
  content         = tls_private_key.private_key_pair[0].private_key_openssh
  file_permission = "0600"
}
