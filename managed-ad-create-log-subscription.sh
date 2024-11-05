#!/bin/bash

# Set your stack name
STACK_NAME="managed-ad-primary-region"

# Get the stack outputs
OUTPUTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs' --output json)

# Extract the Managed AD ID and Log Group Name
MANAGED_AD_ID=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ManagedADId") | .OutputValue')
LOG_GROUP_NAME=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="LogGroupName") | .OutputValue')
echo "Managed AD ID: $MANAGED_AD_ID"
echo "Log Group Name: $LOG_GROUP_NAME"

# Create the log subscription
aws ds create-log-subscription --directory-id $MANAGED_AD_ID --log-group-name $LOG_GROUP_NAME

# Check the result
if [ $? -eq 0 ]; then
    echo "Log subscription created successfully"
else
    echo "Failed to create log subscription"
fi