/**
 * # Terraform AWS ECS Container Definition
 *
 * Introducing the AWS ECS Container Definitions Terraform Module, a highly
 * optimized solution for creating and managing your container definitions
 * within Amazon Web Services. This module has been expertly crafted by our
 * team, who have years of experience working with AWS and Terraform.
 *
 * We have taken the time to fine-tune the settings and configurations to
 * provide you with the best possible experience when using this module. Our
 * team is comprised of experts in AWS and Terraform, and we are proud to share
 * our knowledge and expertise with you.
 *
 * This Terraform module offers a preconfigured solution for managing your
 * container definitions, allowing you to focus on developing your applications
 * and not on the infrastructure setup. By using this module, you can be
 * confident that your container definitions are created and managed in a
 * secure, scalable, and efficient manner.
 *
 * So, whether you're a seasoned AWS user or just starting out, the AWS ECS
 * Container Definitions Terraform Module is the perfect solution for managing
 * your container definitions. Give it a try and see the difference it can make
 * in your workflow!
 */
locals {
  # TODO: Filter out null values on the container definition.
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

  filtered_container_definition = { for k, v in local.container_definition : k => v if v != null && v != [] }
  filtered_port_mappings        = [for pm in local.container_definition.portMappings : { for k, v in pm : k => v if v != null && v != [] }]

  # Merge all filtered values into one definition
  final_container_definition = merge(
    local.filtered_container_definition,
    {
      portMappings = local.filtered_port_mappings
    }
  )
}
