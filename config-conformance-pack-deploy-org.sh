#!/bin/bash

# Set variables
ORG_CONFORMANCE_PACK_NAME="MyOrgConformancePack"
TEMPLATE_S3_URI="s3://your-bucket-name/my-conformance-pack.yaml"
DELIVERY_S3_BUCKET="your-delivery-bucket-name"

# Deploy the organization conformance pack
aws configservice put-organization-conformance-pack \
    --organization-conformance-pack-name $ORG_CONFORMANCE_PACK_NAME \
    --template-s3-uri $TEMPLATE_S3_URI \
    --delivery-s3-bucket $DELIVERY_S3_BUCKET

# Check the deployment status
aws configservice describe-organization-conformance-packs \
    --organization-conformance-pack-names $ORG_CONFORMANCE_PACK_NAME