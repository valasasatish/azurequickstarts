#!/bin/bash

# Dependencies: Azure CLI

AAD_TENANT_ID=""
KEY_VAULT_NAME=""
LOCATION=""
RESOURCE_GROUP_NAME=""
SHARED_IMAGE_GALLERY_NAME=""
STORAGE_ACCOUNT_TIER=""
STORAGE_REPLICATION_TYPE=""
SUBNETS=""
TAGS=""
VNET_ADDRESS_SPACE=""
VNET_NAME=""

usage() {
    printf "Usage: $0 \n  -g RESOURCE_GROUP_NAME\n  -l LOCATION\n  -t TAGS\n  -v VNET_NAME\n  -a VNET_ADDRESS_SPACE\n  -s SUBNETS\n  -i STORAGE_ACCOUNT_TIER\n  -r STORAGE_REPLICATION_TYPE\n  -k KEY_VAULT_NAME\n  -d AAD_TENANT_ID\n  -h SHARED_IMAGE_GALLERY_NAME\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":a:d:g:h:i:k:l:r:s:t:v:" option; do
    case "${option}" in
        a )
            VNET_ADDRESS_SPACE=${OPTARG}
            ;;
        d )
            AAD_TENANT_ID=${OPTARG}
            ;;
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
            ;;
        h )
            SHARED_IMAGE_GALLERY_NAME=${OPTARG}
            ;;
        i )
            STORAGE_ACCOUNT_TIER=${OPTARG}
            ;;
        k )
            KEY_VAULT_NAME=${OPTARG}
            ;;
        l ) 
            LOCATION=${OPTARG}
            ;;
        r )
            STORAGE_REPLICATION_TYPE=${OPTARG}
            ;;
        s )
            SUBNETS=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;
        v )
            VNET_NAME=${OPTARG}
            ;;
        \? )
            usage
            ;;
        : ) 
            echo "Error: -${OPTARG} requires an argument."
            usage
            ;;
    esac
done

printf "Validating RESOURCE_GROUP_NAME '${RESOURCE_GROUP_NAME}'...\n"

if [ -z $RESOURCE_GROUP_NAME ]; then
    echo "Error: Invalid RESOURCE_GROUP_NAME."
    usage
fi

printf "Validating LOCATION '${LOCATION}'...\n"

LOCATION_ID=""
LOCATION_ID=$(az account list-locations --query "[?name=='${LOCATION}'].id" | tr -d '[]" \n')

if [ -z $LOCATION_ID ]; then
    echo "Error: Invalid LOCATION."
    usage
fi

printf "Validating VNET_NAME '${VNET_NAME}'...\n"

if [ -z $VNET_NAME ]; then
    echo "Error: Invalid VNET_NAME."
    usage
fi

printf "Validating VNET_ADDRESS_SPACE '${VNET_ADDRESS_SPACE}'...\n"

if [ -z $VNET_ADDRESS_SPACE ]; then
    echo "Error: Invalid VNET_ADDRESS_SPACE."
    usage
fi

printf "Validating STORAGE_ACCOUNT_TIER '${STORAGE_ACCOUNT_TIER}'\n"

case $STORAGE_ACCOUNT_TIER in
    Standard | Premium )
        ;;
    * )
        echo "Error: Invalid STORAGE_ACCOUNT_TIER."
        usage
        ;;
esac

printf "Validating STORAGE_REPLICATION_TYPE '${STORAGE_REPLICATION_TYPE}'\n"

case $STORAGE_REPLICATION_TYPE in
    LRS | GRS | RAGRS | ZRS )
        ;;
    * )
        echo "Error: Invalid STORAGE_REPLICATION_TYPE."
        usage
        ;;
esac

printf "Validating KEY_VAULT_NAME '${KEY_VAULT_NAME}'\n"

if [ -z $KEY_VAULT_NAME ]; then
    echo "Error: Invalid KEY_VAULT_NAME."
    usage
fi

printf "Validating AAD_TENANT_ID '${AAD_TENANT_ID}'\n"

if [ -z $AAD_TENANT_ID ]; then
    echo "Error: Invalid AAD_TENANT_ID."
    usage
fi

printf "Validating SHARED_IMAGE_GALLERY_NAME '${SHARED_IMAGE_GALLERY_NAME}'\n"
if [ -z $SHARED_IMAGE_GALLERY_NAME ]; then
    echo "Error: Invalid SHARED_IMAGE_GALLERY_NAME."
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id = \"$AAD_TENANT_ID\"\n" > ./terraform.tfvars
printf "key_vault_name = \"$KEY_VAULT_NAME\"\n" >> ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "shared_image_gallery_name = \"$SHARED_IMAGE_GALLERY_NAME\"\n" >> ./terraform.tfvars
printf "storage_account_tier = \"$STORAGE_ACCOUNT_TIER\"\n" >> ./terraform.tfvars
printf "storage_replication_type = \"$STORAGE_REPLICATION_TYPE\"\n" >> ./terraform.tfvars
printf "subnets = $SUBNETS\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vnet_address_space = \"$VNET_ADDRESS_SPACE\"\n" >> ./terraform.tfvars
printf "vnet_name = \"$VNET_NAME\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0