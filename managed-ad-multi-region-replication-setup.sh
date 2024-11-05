#!/bin/bash

set -e

# Configuration
PRIMARY_REGION=$AWS_REGION
SECONDARY_REGION=$AWS_REGION_SECONDARY
PRIMARY_STACK_NAME="managed-ad-primary-region" 
SECONDARY_STACK_NAME="managed-ad-second-region-vpc"

# Function to get CloudFormation output value
get_cf_output() {
    local stack_name=$1
    local output_key=$2
    local region=$3
    aws cloudformation describe-stacks \
        --stack-name "$stack_name" \
        --query "Stacks[0].Outputs[?OutputKey=='$output_key'].OutputValue" \
        --output text \
        --region "$region"
}

# Get outputs from primary stack
echo "Fetching information from primary stack..."
DIRECTORY_ID=$(get_cf_output $PRIMARY_STACK_NAME "ManagedADId" $PRIMARY_REGION)

# Get outputs from secondary stack
echo "Fetching information from secondary stack..."
SECONDARY_VPC_ID=$(get_cf_output $SECONDARY_STACK_NAME "SecondaryVPCId" $SECONDARY_REGION)
SECONDARY_SUBNET1_ID=$(get_cf_output $SECONDARY_STACK_NAME "SecondarySubnet1Id" $SECONDARY_REGION)
SECONDARY_SUBNET2_ID=$(get_cf_output $SECONDARY_STACK_NAME "SecondarySubnet2Id" $SECONDARY_REGION)

# Add the secondary region
echo "Adding secondary region for replication..."
aws ds add-region \
    --directory-id "$DIRECTORY_ID" \
    --region-name "$SECONDARY_REGION" \
    --vpc-settings "VpcId=$SECONDARY_VPC_ID,SubnetIds=$SECONDARY_SUBNET1_ID,$SECONDARY_SUBNET2_ID" \
    --region "$PRIMARY_REGION"

echo "Replication setup initiated. Checking status..."

# Check replication status
while true; do
    REGION_INFO=$(aws ds describe-regions \
        --directory-id "$DIRECTORY_ID" \
        --region "$PRIMARY_REGION" \
        --query "RegionsDescription[?RegionName=='$SECONDARY_REGION']" \
        --output json)
    
    STATUS=$(echo $REGION_INFO | jq -r '.[0].Status // empty')
    
    if [ -z "$STATUS" ]; then
        echo "Replication status: Not found. The secondary region may not have been added yet."
    else
        echo "Replication status: $STATUS"
        
        if [ "$STATUS" = "Active" ]; then
            echo "Replication is now active!"
            break
        elif [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Deleted" ]; then
            echo "Replication setup failed."
            exit 1
        fi
    fi
    
    sleep 60  # Wait for 60 seconds before checking again
done

echo "Multi-region replication setup complete."