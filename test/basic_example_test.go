package test

import (
	"encoding/json"
	"os"
	"testing"

	TTAWS "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"

	"github.com/aws/aws-sdk-go/aws/session"
)

type TaskDefinitionSimple struct {
	Cpu          int      `json:"cpu"`
	Essential    bool     `json:"essential"`
	Image        string   `json:"image"`
	Name         string   `json:"name"`
	PortMappings []string `json:"portMappings"`
}

func TestTerraformBasicExample(t *testing.T) {
	taskDefinitionName := "terraform-test-task-definition-" + GetShortId()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic-example",
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

	var definitionJson TaskDefinitionSimple
	err := json.Unmarshal([]byte(jsonOutput), &definitionJson)
	assert.NoError(t, err)

	assert.Equal(t, taskDefinitionName, definitionJson.Name)
	assert.Equal(t, "nginx:1.23-alpine", definitionJson.Image)
	assert.Equal(t, 0, definitionJson.Cpu)
	assert.True(t, definitionJson.Essential)
	assert.Empty(t, definitionJson.PortMappings)
}

func NewSession(region string) (*session.Session, error) {
	sess, err := TTAWS.NewAuthenticatedSession(region)
	if err != nil {
		return nil, err
	}

	return sess, nil
}

func GetShortId() string {
	githubSha := os.Getenv("GITHUB_SHA")
	if len(githubSha) >= 7 {
		return githubSha[0:6]
	}

	return "local"
}
