module "minimal" {
  source = "../../"

  name  = "nginx"
  image = "nginx:1.23-alpine"
}
