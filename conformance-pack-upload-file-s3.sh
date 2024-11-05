#!/bin/bash

# Check if AWS_REGION is set
if [ -z "$AWS_REGION" ]; then
    echo "AWS_REGION is not set. Please set it before running this script."
    exit 1
fi

echo "Using AWS Region: $AWS_REGION"

# Wait for the stack to complete 
aws cloudformation wait stack-create-complete \
--stack-name conformance-pack-bucket-stack \
--region $AWS_REGION

# Get the bucket name from the stack outputs 
BUCKET_NAME=$(aws cloudformation describe-stacks \
--stack-name conformance-pack-bucket-stack \
--query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
--output text \
--region $AWS_REGION)

# Upload the conformance pack template to the S3 bucket 
aws s3 cp Operational-Best-Practices-for-Amazon-S3.yaml \
s3://$BUCKET_NAME/my-conformance-pack.yaml \
--region $AWS_REGION