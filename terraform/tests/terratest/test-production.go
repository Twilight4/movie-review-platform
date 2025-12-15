package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestMovieApiTerraform(t *testing.T) {
	terraformOptions := &terraform.Options{
		// Path to the Terraform configuration being tested
		TerraformDir: "../../envs/production/",
	}

	// Always destroy infra, even on failure
	defer terraform.Destroy(t, terraformOptions)

	// Deploy infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Read the healthcheck URL from Terraform outputs
	healthURL := terraform.Output(t, terraformOptions, "healthcheck_url")

	fmt.Println("Health check URL:", healthURL)

	// Default TLS config (HTTP works too; TLS required if HTTPS)
	tlsConfig := tls.Config{}

	// Sends an HTTP GET request to the application endpoint
	// Retries until the service becomes available
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		healthURL,     // Target URL of the deployed application
		&tlsConfig,    // TLS configuration for HTTPS
		60,            // Maximum number of retries
		10*time.Second, // Delay between retries
		validateHealth,  // custom validation
	)
}

// Custom validation function used by Terratest
func validateHealth(status int, body string) bool {
	fmt.Println("Response body:", body)

	// Expect:
	// - HTTP 200
	// - body contains "ok"
	return status == 200 && body == "ok"
}
