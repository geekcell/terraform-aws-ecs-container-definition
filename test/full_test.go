package test

import (
	"encoding/json"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
)

type DependsOn struct {
	Condition     string `json:"condition"`
	ContainerName string `json:"containerName"`
}

type EnvVar struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

type Secret struct {
	Name      string `json:"name"`
	ValueFrom string `json:"valueFrom"`
}

type TypeValue struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}

type Host struct {
	HostName  string `json:"hostname"`
	IpAddress string `json:"ipAddress"`
}

type MountPoint struct {
	ContainerPath string `json:"containerPath"`
	SourceVolume  string `json:"sourceVolume"`
	ReadOnly      bool   `json:"readOnly"`
}

type PortMapping struct {
	ContainerPort int    `json:"containerPort"`
	HostPort      int    `json:"hostPort"`
	Protocol      string `json:"protocol"`
}

type SystemControl struct {
	Namespace string `json:"namespace"`
	Value     string `json:"value"`
}

type ULimit struct {
	Name      string `json:"name"`
	HardLimit int    `json:"hardLimit"`
	ValueFrom int    `json:"valueFrom"`
}

type Volume struct {
	SourceContainer string `json:"SourceContainer"`
	ReadOnly        bool   `json:"readOnly"`
}

type Device struct {
	ContainerPath string   `json:"containerPath"`
	HostPath      string   `json:"hostPath"`
	Permissions   []string `json:"permissions"`
}

type Tmpf struct {
	ContainerPath string   `json:"containerPath"`
	Size          int      `json:"size"`
	MountOptions  []string `json:"mountOptions"`
}

type TaskDefinitionFull struct {
	Image            string `json:"image"`
	Name             string `json:"name"`
	User             string `json:"user"`
	WorkingDirectory string `json:"workingDirectory"`

	Cpu               int `json:"cpu"`
	Memory            int `json:"memory"`
	MemoryReservation int `json:"memoryReservation"`

	StartTimeout int `json:"startTimeout"`
	StopTimeout  int `json:"stopTimeout"`

	Essential              bool `json:"essential"`
	DisableNetworking      bool `json:"disableNetworking"`
	Interactive            bool `json:"interactive"`
	Privileged             bool `json:"privileged"`
	PseudoTerminal         bool `json:"pseudoTerminal"`
	ReadonlyRootFilesystem bool `json:"readonlyRootFilesystem"`

	Command               []string        `json:"command"`
	DependsOn             []DependsOn     `json:"dependsOn"`
	DnsSearchDomains      []string        `json:"dnsSearchDomains"`
	DnsServers            []string        `json:"dnsServers"`
	DockerSecurityOptions []string        `json:"dockerSecurityOptions"`
	EntryPoint            []string        `json:"entryPoint"`
	EnvVars               []EnvVar        `json:"environment"`
	Secrets               []Secret        `json:"secrets"`
	EnvFiles              []TypeValue     `json:"environmentFiles"`
	ExtraHosts            []Host          `json:"extraHosts"`
	Links                 []string        `json:"links"`
	MountPoints           []MountPoint    `json:"mountPoints"`
	PortMappings          []PortMapping   `json:"portMappings"`
	ResourceRequirements  []TypeValue     `json:"resourceRequirements"`
	SystemControls        []SystemControl `json:"systemControls"`
	ULimits               []ULimit        `json:"ulimits"`
	VolumesFrom           []Volume        `json:"volumesFrom"`

	DockerLabels struct {
		Baz string `json:"com.example.baz"`
		Foo string `json:"com.example.foo"`
	} `json:"dockerLabels"`

	HealthCheck struct {
		Command     []string `json:"command"`
		Interval    int      `json:"interval"`
		Retries     int      `json:"retries"`
		StartPeriod int      `json:"start_period"`
		Timeout     int      `json:"timeout"`
	} `json:"healthCheck"`

	RepositoryCredentials struct {
		CredentialsParameter string `json:"credentialsParameter"`
	} `json:"repositoryCredentials"`

	LogConfiguration struct {
		LogDriver string `json:"logDriver"`
		Options   struct {
			EndPoint string `json:"endpoint"`
		} `json:"options"`
		SecretOptions []Secret `json:"secretOptions"`
	} `json:"logConfiguration"`

	LinuxParameters struct {
		Capabilities struct {
			Add  []string `json:"add"`
			Drop []string `json:"drop"`
		} `json:"capabilities"`
		InitProcessEnabled bool     `json:"initProcessEnabled"`
		MaxSwap            int      `json:"maxSwap"`
		SharedMemorySize   int      `json:"sharedMemorySize"`
		Swappiness         int      `json:"swappiness"`
		Devices            []Device `json:"devices"`
		Tmpfs              []Tmpf   `json:"tmpfs"`
	} `json:"linuxParameters"`
}

func TestTerraformFull(t *testing.T) {
	taskDefinitionName := "terraform-test-task-definition-" + GetShortId()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/full",
		Vars: map[string]interface{}{
			"name": taskDefinitionName,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	jsonOutput := terraform.Output(t, terraformOptions, "json")
	assert.NotEmpty(t, jsonOutput)

	hclOutput := terraform.Output(t, terraformOptions, "hcl")
	assert.NotEmpty(t, hclOutput)

	var definitionJson TaskDefinitionFull
	err := json.Unmarshal([]byte(jsonOutput), &definitionJson)
	assert.NoError(t, err)

	assert.Equal(t, taskDefinitionName, definitionJson.Name)
	assert.Equal(t, "nginx:latest", definitionJson.Image)
	assert.Equal(t, "root", definitionJson.User)
	assert.Equal(t, "/tmp", definitionJson.WorkingDirectory)

	assert.Equal(t, 256, definitionJson.Cpu)
	assert.Equal(t, 512, definitionJson.Memory)
	assert.Equal(t, 1024, definitionJson.MemoryReservation)

	assert.Equal(t, 60, definitionJson.StartTimeout)
	assert.Equal(t, 60, definitionJson.StopTimeout)

	assert.True(t, definitionJson.Essential)
	assert.True(t, definitionJson.Privileged)
	assert.True(t, definitionJson.ReadonlyRootFilesystem)

	assert.False(t, definitionJson.DisableNetworking)
	assert.False(t, definitionJson.PseudoTerminal)

	assert.Equal(t, 2, len(definitionJson.Command))
	assert.Equal(t, "sleep", definitionJson.Command[0])
	assert.Equal(t, "1000", definitionJson.Command[1])

	assert.Equal(t, 1, len(definitionJson.DnsSearchDomains))
	assert.Equal(t, "example.com", definitionJson.DnsSearchDomains[0])

	assert.Equal(t, 1, len(definitionJson.DnsServers))
	assert.Equal(t, "10.0.0.1", definitionJson.DnsServers[0])

	assert.Equal(t, 1, len(definitionJson.DockerSecurityOptions))
	assert.Equal(t, "label:type:container_t", definitionJson.DockerSecurityOptions[0])

	assert.Equal(t, 2, len(definitionJson.EntryPoint))
	assert.Equal(t, "/bin/sh", definitionJson.EntryPoint[0])
	assert.Equal(t, "-c", definitionJson.EntryPoint[1])

	assert.Equal(t, 1, len(definitionJson.DependsOn))
	assert.Equal(t, "HEALTHY", definitionJson.DependsOn[0].Condition)
	assert.Equal(t, "redis", definitionJson.DependsOn[0].ContainerName)

	assert.Equal(t, 1, len(definitionJson.Links))
	assert.Equal(t, "app", definitionJson.Links[0])

	assert.Equal(t, 2, len(definitionJson.EnvVars))
	assert.Equal(t, "APP_DEBUG", definitionJson.EnvVars[0].Name)
	assert.Equal(t, "false", definitionJson.EnvVars[0].Value)
	assert.Equal(t, "APP_ENV", definitionJson.EnvVars[1].Name)
	assert.Equal(t, "dev", definitionJson.EnvVars[1].Value)

	assert.Equal(t, 2, len(definitionJson.Secrets))
	assert.Equal(t, "APP_SECRET", definitionJson.Secrets[0].Name)
	assert.Equal(t, "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:APP_SECRET::", definitionJson.Secrets[0].ValueFrom)
	assert.Equal(t, "DATABASE_USER", definitionJson.Secrets[1].Name)
	assert.Equal(t, "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:DB_PASS::", definitionJson.Secrets[1].ValueFrom)

	assert.Equal(t, 2, len(definitionJson.ExtraHosts))
	assert.Equal(t, "local.host", definitionJson.ExtraHosts[0].HostName)
	assert.Equal(t, "127.0.0.1", definitionJson.ExtraHosts[0].IpAddress)
	assert.Equal(t, "loopback", definitionJson.ExtraHosts[1].HostName)
	assert.Equal(t, "127.0.0.1", definitionJson.ExtraHosts[1].IpAddress)

	assert.Equal(t, 1, len(definitionJson.EnvFiles))
	assert.Equal(t, "s3", definitionJson.EnvFiles[0].Type)
	assert.Equal(t, "s3://bucket/key/to/file.env", definitionJson.EnvFiles[0].Value)

	assert.Equal(t, 1, len(definitionJson.MountPoints))
	assert.Equal(t, "/tmp", definitionJson.MountPoints[0].ContainerPath)
	assert.Equal(t, "tmp", definitionJson.MountPoints[0].SourceVolume)
	assert.False(t, definitionJson.MountPoints[0].ReadOnly)

	assert.Equal(t, 2, len(definitionJson.PortMappings))
	assert.Equal(t, "tcp", definitionJson.PortMappings[0].Protocol)
	assert.Equal(t, 80, definitionJson.PortMappings[0].ContainerPort)
	assert.Equal(t, 80, definitionJson.PortMappings[0].HostPort)
	assert.Equal(t, "tcp", definitionJson.PortMappings[1].Protocol)
	assert.Equal(t, 443, definitionJson.PortMappings[1].ContainerPort)
	assert.Equal(t, 443, definitionJson.PortMappings[1].HostPort)

	assert.Equal(t, 2, len(definitionJson.ResourceRequirements))
	assert.Equal(t, "GPU", definitionJson.ResourceRequirements[0].Type)
	assert.Equal(t, "256", definitionJson.ResourceRequirements[0].Value)
	assert.Equal(t, "InferenceAccelerator", definitionJson.ResourceRequirements[1].Type)
	assert.Equal(t, "eia1.medium", definitionJson.ResourceRequirements[1].Value)

	assert.Equal(t, 2, len(definitionJson.SystemControls))
	assert.Equal(t, "net.core.somaxconn", definitionJson.SystemControls[0].Namespace)
	assert.Equal(t, "1024", definitionJson.SystemControls[0].Value)
	assert.Equal(t, "net.ipv4.tcp_syncookies", definitionJson.SystemControls[1].Namespace)
	assert.Equal(t, "1", definitionJson.SystemControls[1].Value)

	assert.Equal(t, 2, len(definitionJson.ULimits))
	assert.Equal(t, "nofile", definitionJson.ULimits[0].Name)
	assert.Equal(t, 2048, definitionJson.ULimits[0].HardLimit)
	assert.Equal(t, 1024, definitionJson.ULimits[0].ValueFrom)
	assert.Equal(t, "nproc", definitionJson.ULimits[1].Name)
	assert.Equal(t, 2048, definitionJson.ULimits[1].HardLimit)
	assert.Equal(t, 1024, definitionJson.ULimits[1].ValueFrom)

	assert.Equal(t, 1, len(definitionJson.VolumesFrom))
	assert.Equal(t, "app", definitionJson.VolumesFrom[0].SourceContainer)
	assert.True(t, definitionJson.VolumesFrom[0].ReadOnly)

	assert.Equal(t, "qux", definitionJson.DockerLabels.Baz)
	assert.Equal(t, "bar", definitionJson.DockerLabels.Foo)

	assert.Equal(t, 2, len(definitionJson.HealthCheck.Command))
	assert.Equal(t, "CMD-SHELL", definitionJson.HealthCheck.Command[0])
	assert.Equal(t, "curl -f http://localhost/ || exit 1", definitionJson.HealthCheck.Command[1])
	assert.Equal(t, 30, definitionJson.HealthCheck.Interval)
	assert.Equal(t, 3, definitionJson.HealthCheck.Retries)
	assert.Equal(t, 0, definitionJson.HealthCheck.StartPeriod)
	assert.Equal(t, 5, definitionJson.HealthCheck.Timeout)

	assert.Equal(t, "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter", definitionJson.RepositoryCredentials.CredentialsParameter)

	assert.Equal(t, "awsfirelens", definitionJson.LogConfiguration.LogDriver)
	assert.Equal(t, "https://example.com", definitionJson.LogConfiguration.Options.EndPoint)
	assert.Equal(t, 2, len(definitionJson.LogConfiguration.SecretOptions))
	assert.Equal(t, "APP_SECRET", definitionJson.LogConfiguration.SecretOptions[0].Name)
	assert.Equal(t, "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:APP_SECRET::", definitionJson.LogConfiguration.SecretOptions[0].ValueFrom)
	assert.Equal(t, "DATABASE_USER", definitionJson.LogConfiguration.SecretOptions[1].Name)
	assert.Equal(t, "arn:aws:ssm:us-east-1:awsExampleAccountID:parameter/awsExampleParameter:DB_PASS::", definitionJson.LogConfiguration.SecretOptions[1].ValueFrom)

	assert.Equal(t, 1, len(definitionJson.LinuxParameters.Capabilities.Add))
	assert.Equal(t, "SYS_TIME", definitionJson.LinuxParameters.Capabilities.Add[0])
	assert.Equal(t, 1, len(definitionJson.LinuxParameters.Capabilities.Drop))
	assert.Equal(t, "MKNOD", definitionJson.LinuxParameters.Capabilities.Drop[0])
	assert.True(t, definitionJson.LinuxParameters.InitProcessEnabled)
	assert.Equal(t, 1024, definitionJson.LinuxParameters.MaxSwap)
	assert.Equal(t, 1024, definitionJson.LinuxParameters.SharedMemorySize)
	assert.Equal(t, 50, definitionJson.LinuxParameters.Swappiness)
	assert.Equal(t, 1, len(definitionJson.LinuxParameters.Devices))
	assert.Equal(t, "/dev/null", definitionJson.LinuxParameters.Devices[0].ContainerPath)
	assert.Equal(t, "/dev/null", definitionJson.LinuxParameters.Devices[0].HostPath)
	assert.Equal(t, 2, len(definitionJson.LinuxParameters.Devices[0].Permissions))
	assert.Equal(t, "read", definitionJson.LinuxParameters.Devices[0].Permissions[0])
	assert.Equal(t, "write", definitionJson.LinuxParameters.Devices[0].Permissions[1])
	assert.Equal(t, 1, len(definitionJson.LinuxParameters.Tmpfs))
	assert.Equal(t, "/tmp", definitionJson.LinuxParameters.Tmpfs[0].ContainerPath)
	assert.Equal(t, 1024, definitionJson.LinuxParameters.Tmpfs[0].Size)
	assert.Equal(t, 4, len(definitionJson.LinuxParameters.Tmpfs[0].MountOptions))
	assert.Equal(t, "nodev", definitionJson.LinuxParameters.Tmpfs[0].MountOptions[0])
	assert.Equal(t, "noexec", definitionJson.LinuxParameters.Tmpfs[0].MountOptions[1])
	assert.Equal(t, "nosuid", definitionJson.LinuxParameters.Tmpfs[0].MountOptions[2])
	assert.Equal(t, "rw", definitionJson.LinuxParameters.Tmpfs[0].MountOptions[3])
}
