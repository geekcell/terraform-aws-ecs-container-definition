/**
 * # Terraform AWS ECS Container Definition
 *
 * This module is used to generate a container definition for use in an AWS ECS task definition.
 */
locals {
  container_definition = {
    name      = var.name
    image     = var.image
    essential = var.essential

    command    = var.command
    entryPoint = var.entrypoint
    user       = var.user

    interactive    = var.interactive
    pseudoTerminal = var.pseudo_terminal

    cpu               = var.cpu
    memory            = var.memory
    memoryReservation = var.memory_reservation

    workingDirectory       = var.working_directory
    readonlyRootFilesystem = var.readonly_root_filesystem

    portMappings = [
      for port_mapping in var.port_mappings : {
        appProtocol        = port_mapping.app_protocol
        containerPortRange = port_mapping.container_port_range
        containerPort      = port_mapping.container_port
        hostPort           = port_mapping.host_port
        protocol           = port_mapping.protocol
      }
    ]

    links       = var.links
    volumesFrom = [for k, v in var.volumes_from : { sourceContainer : k, readOnly : v.read_only }]
    mountPoints = [
      for mount_point in var.mount_points : {
        sourceVolume  = mount_point.source_volume
        containerPath = mount_point.container_path
        readOnly      = mount_point.read_only
      }
    ]

    hostname   = var.hostname
    extraHosts = [for k, v in var.extra_hosts : { hostname : k, ipAddress : v }]

    dnsServers       = var.dns_servers
    dnsSearchDomains = var.dns_search_domains

    privileged        = var.privileged
    disableNetworking = var.disable_networking
    ulimits           = [for k, v in var.ulimits : { name : k, hardLimit : v.hard_limit, valueFrom : v.soft_limit }]

    systemControls        = [for k, v in var.system_controls : { namespace : k, value : v }]
    dockerSecurityOptions = var.docker_security_options
    linuxParameters = var.linux_parameters != null ? {
      initProcessEnabled = var.linux_parameters.init_process_enabled

      sharedMemorySize = var.linux_parameters.shared_memory_size
      maxSwap          = var.linux_parameters.max_swap
      swappiness       = var.linux_parameters.swappiness

      capabilities = {
        add  = sort(var.linux_parameters.capabilities.add)
        drop = sort(var.linux_parameters.capabilities.drop)
      }

      devices = [
        for device in var.linux_parameters.devices : {
          containerPath = device.container_path
          hostPath      = device.host_path
          permissions   = sort(device.permissions)
        }
      ]

      tmpfs = [
        for tmpfs in var.linux_parameters.tmpfs : {
          containerPath = tmpfs.container_path
          mountOptions  = sort(tmpfs.mount_options)
          size          = tmpfs.size
        }
      ]
    } : null

    environment      = [for k, v in var.environment : { name : k, value : v }]
    environmentFiles = [for v in var.environment_files : { type : "s3", value : v }]
    secrets          = [for k, v in var.secrets : { name : k, valueFrom : v }]

    dockerLabels = var.docker_labels

    startTimeout = var.start_timeout
    stopTimeout  = var.stop_timeout
    dependsOn    = [for k, v in var.depend_on : { containerName : k, condition : v }]
    healthCheck  = var.healthcheck

    firelensConfiguration = var.firelens_configuration
    logConfiguration = var.log_configuration != null ? {
      logDriver     = var.log_configuration.log_driver
      options       = var.log_configuration.options
      secretOptions = [for k, v in var.secrets : { name : k, valueFrom : v }]
    } : null

    resourceRequirements = [for k, v in var.resource_requirements : { type : k, value : v }]
    repositoryCredentials = var.repository_credentials != null ? {
      credentialsParameter : var.repository_credentials
    } : null
  }
}

# AWS will complain if we send any optional values with a null value. A simple way to get around this is to use jq
# to remove any null values and empty arrays from the JSON before sending it to AWS.
data "jq_query" "main" {
  query = "del(.. | nulls) | del(.. | select(. == []))"
  data  = jsonencode(local.container_definition)
}
