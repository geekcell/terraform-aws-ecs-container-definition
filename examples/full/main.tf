module "full" {
  source = "../../"

  name      = "nginx"
  image     = "nginx:latest"
  essential = true

  command    = ["sleep", "1000"]
  entrypoint = ["/bin/sh", "-c"]
  user       = "root"

  interactive     = false
  pseudo_terminal = false

  cpu                = 256
  memory             = 512
  memory_reservation = 1024

  working_directory        = "/tmp"
  readonly_root_filesystem = true

  port_mappings = [
    {
      container_port = 80
      host_port      = 80
      protocol       = "tcp"
    },
    {
      container_port = 443
      host_port      = 443
      protocol       = "tcp"
    }
  ]

  links = ["app"]
  mount_points = [
    {
      container_path = "/tmp"
      source_volume  = "tmp"
      read_only      = false
    }
  ]
  volumes_from = {
    app = { read_only = true }
  }

  dns_search_domains = ["example.com"]
  dns_servers        = ["10.0.0.1"]

  hostname = "nginx"
  extra_hosts = {
    "local.host" = "127.0.0.1"
    "loopback"   = "127.0.0.1"
  }

  privileged         = true
  disable_networking = false
  ulimits = {
    nofile = {
      soft_limit = 1024
      hard_limit = 2048
    }
    nproc = {
      soft_limit = 1024
      hard_limit = 2048
    }
  }

  docker_security_options = ["label:type:container_t"]
  system_controls = {
    "net.ipv4.tcp_syncookies" = 1
    "net.core.somaxconn"      = 1024
  }

  linux_parameters = {
    init_process_enabled = true

    shared_memory_size = 1024
    max_swap           = 1024
    swappiness         = 50

    capabilities = {
      add  = ["SYS_TIME"]
      drop = ["MKNOD"]
    }

    devices = [
      {
        host_path      = "/dev/null"
        container_path = "/dev/null"
        permissions    = ["read", "write"]
      }
    ]

    tmpfs = [
      {
        size           = 1024
        container_path = "/tmp"
        mount_options  = ["rw", "noexec", "nosuid", "nodev"]
      }
    ]
  }

  environment_files = ["s3://bucket/key/to/file.env"]
  environment = {
    APP_ENV   = "dev"
    APP_DEBUG = false
  }

  secrets = {
    DATABASE_USER = "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:DB_PASS::"
    APP_SECRET    = "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:APP_SECRET::"
  }

  docker_labels = {
    "com.example.foo" = "bar"
    "com.example.baz" = "qux"
  }

  start_timeout = 60
  stop_timeout  = 60
  depend_on = {
    redis = "HEALTHY"
  }
  healthcheck = {
    command      = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
    interval     = 30
    retries      = 3
    start_period = 0
    timeout      = 5
  }

  resource_requirements = {
    GPU                  = 256
    InferenceAccelerator = "eia1.medium"
  }

  repository_credentials = "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter"

  log_configuration = {
    log_driver = "awsfirelens"
    options = {
      endpoint = "https://example.com"
    }
    secret_options = {
      apiKey = "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:apiKey::"
    }
  }
}
