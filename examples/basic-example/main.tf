module "basic-example" {
  source = "../../"

  name  = var.name
  image = "nginx:1.23-alpine"
}
