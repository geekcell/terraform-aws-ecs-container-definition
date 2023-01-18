variable "name" {
  description = "The name of the container."
  type        = string
}

variable "image" {
  description = "The image used to start the container."
  type        = string
}

variable "essential" {
  description = "Whether this container is essential to the task. If the container fails or stops for any reason, all other containers that are part of the task are stopped."
  default     = true
  type        = bool
}

variable "command" {
  description = "The command that is passed to the container."
  default     = null
  type        = list(string)
}

variable "entrypoint" {
  description = "The entry point that is passed to the container."
  default     = null
  type        = list(string)
}

variable "working_directory" {
  description = "The working directory in which to run commands inside the container."
  default     = null
  type        = string
}

variable "readonly_root_filesystem" {
  description = "When this parameter is true, the container is given read-only access to its root file system."
  default     = null
  type        = bool
}

variable "volumes_from" {
  description = "Data volumes to mount from another container."
  default     = {}
  type = map(object({
    read_only = optional(bool, false)
  }))
}

variable "links" {
  description = "Links to other containers."
  default     = null
  type        = list(string)
}

variable "mount_points" {
  description = "The mount points for data volumes in your container."
  default     = []
  type = list(object({
    source_volume  = string
    container_path = string
    read_only      = optional(bool, false)
  }))
}

variable "dns_servers" {
  description = "A list of DNS servers that are presented to the container."
  default     = null
  type        = list(string)
}

variable "dns_search_domains" {
  description = "A list of DNS search domains that are presented to the container."
  default     = null
  type        = list(string)
}

variable "user" {
  description = "The user to use inside the container."
  default     = null
  type        = string
}

variable "cpu" {
  description = "The number of cpu units reserved for the container."
  default     = 0
  type        = number
}

variable "memory" {
  description = "The hard limit (in MiB) of memory to present to the container."
  default     = null
  type        = number
}

variable "memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  default     = null
  type        = number
}

variable "environment" {
  description = "The environment variables to pass to a container."
  default     = {}
  type        = map(string)
}

variable "environment_files" {
  description = "The environment files to pass to a container."
  default     = []
  type        = list(string)
}

variable "ulimits" {
  description = "A list of ulimits to set in the container."
  default     = {}
  type = map(object({
    hard_limit = number
    soft_limit = number
  }))
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)."
  default     = null
  type        = bool
}

variable "disable_networking" {
  description = "When this parameter is true, networking is disabled within the container."
  default     = null
  type        = bool
}

variable "interactive" {
  description = "When this parameter is true, the container is given read-only access to its root file system."
  default     = null
  type        = bool
}

variable "pseudo_terminal" {
  description = "When this parameter is true, a TTY is allocated."
  default     = null
  type        = bool
}

variable "docker_security_options" {
  description = "A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems."
  default     = null
  type        = list(string)
}

variable "hostname" {
  description = "The hostname to use for your container."
  default     = null
  type        = string
}

variable "extra_hosts" {
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container."
  default     = {}
  type        = map(string)
}

variable "secrets" {
  description = "The secrets to pass to the container."
  default     = {}
  type        = map(string)
}

variable "start_timeout" {
  description = "Time duration (in seconds) to wait before giving up on resolving dependencies for a container."
  default     = null
  type        = number
}

variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own."
  default     = null
  type        = number
}

variable "system_controls" {
  description = "A list of namespaced kernel parameters to set in the container."
  default     = {}
  type        = map(string)
}

variable "resource_requirements" {
  description = "The type and amount of a resource to assign to a container."
  default     = {}
  type        = map(string)
}

variable "docker_labels" {
  description = "A key/value map of labels to add to the container."
  default     = null
  type        = map(string)
}

variable "linux_parameters" {
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities."
  default     = null
  type = object({
    init_process_enabled = optional(bool)

    shared_memory_size = optional(number)
    max_swap           = optional(number)
    swappiness         = optional(number)

    capabilities = optional(object({
      add  = optional(list(string))
      drop = optional(list(string))
    }))

    devices = optional(list(object({
      host_path      = string
      container_path = optional(string)
      permissions    = optional(list(string))
    })), [])

    tmpfs = optional(list(object({
      container_path = string
      size           = number
      mount_options  = optional(list(string))
    })), [])
  })
}

variable "port_mappings" {
  description = "The list of port mappings for the container."
  default     = []
  type = list(object({
    app_protocol         = optional(string)
    container_port_range = optional(string)

    container_port = optional(number)
    host_port      = optional(number)
    protocol       = optional(string, "tcp")
  }))
}

variable "healthcheck" {
  description = "The container health check command and associated configuration parameters for the container."
  default     = null
  type = object({
    command      = list(string)
    interval     = optional(number)
    retries      = optional(number)
    start_period = optional(number)
    timeout      = optional(number)
  })
}

variable "depend_on" {
  description = "The dependencies defined for container startup and shutdown."
  default     = {}
  type        = map(string)
}

variable "repository_credentials" {
  description = "The private repository authentication credentials to use."
  default     = null
  type        = string
}

variable "firelens_configuration" {
  description = "The FireLens configuration for the container."
  default     = null
  type = object({
    type    = string
    options = optional(map(string))
  })
}

variable "log_configuration" {
  description = "The log configuration specification for the container."
  default     = null
  type = object({
    log_driver     = optional(string)
    options        = optional(map(string))
    secret_options = optional(map(string))
  })
}
