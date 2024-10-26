#!/bin/bash

# Exit on error
set -e

# Function to check if a command was successful
check_success() {
    if [ $? -eq 0 ]; then
        echo "Success: $1"
    else
        echo "Error: $1 failed"
        exit 1
    fi
}

# Check AWS Organizations setup
echo "Checking AWS Organizations setup..."
aws organizations describe-organization
check_success "AWS Organizations check"

# Enable AWS Config in the Organization
echo "Enabling AWS Config in the Organization..."
aws organizations enable-aws-service-access --service-principal config.amazonaws.com
check_success "Enabling AWS Config in Organization"

# Enable Organizational Config Rules
echo "Creating an Organizational Config Rule..."
aws config put-organization-config-rule \
    --organization-config-rule-name MyOrgConfigRule \
    --organization-managed-rule-metadata \
    '{"RuleIdentifier": "REQUIRED_TAGS", "InputParameters": "{\"tag1Key\":\"CostCenter\",\"tag2Key\":\"Owner\"}"}'
check_success "Creating Organizational Config Rule"

# Check Organizational Config Rules
echo "Listing Organizational Config Rules..."
aws config describe-organization-config-rules
check_success "Listing Organizational Config Rules"

# Deploy Config Conformance Pack Organizationally
echo "Deploying Organizational Conformance Pack..."
aws configservice put-organization-conformance-pack \
    --organization-conformance-pack-name MyOrgConformancePack \
    --template-s3-uri s3://awsconfig-conformance-packs-us-east-1/operational-best-practices-for-aws-identity-and-access-management.yaml
check_success "Deploying Organizational Conformance Pack"

# Check Organizational Conformance Packs
echo "Listing Organizational Conformance Packs..."
aws configservice describe-organization-conformance-packs
check_success "Listing Organizational Conformance Packs"

# Monitor Deployment Status
echo "Checking deployment status of Organizational Config Rule..."
aws configservice get-organization-config-rule-detailed-status \
    --organization-config-rule-name MyOrgConfigRule
check_success "Checking Organizational Config Rule status"

echo "Checking deployment status of Organizational Conformance Pack..."
aws configservice get-organization-conformance-pack-detailed-status \
    --organization-conformance-pack-name MyOrgConformancePack
check_success "Checking Organizational Conformance Pack status"

echo "Script completed successfully!"