output "private_shh_key" {
  value     = tls_private_key.private_key_pair[0].private_key_pem
  sensitive = true
}