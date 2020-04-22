#!/bin/bash -e

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Find jq
if ! hash jq >/dev/null 2>&1; then
    echo "You need jq installed to use this script"
    exit 1
fi

FILE=packer.json
IMAGE_NAME=$(jq -r '.builders[0].image_name' ${FILE})

echo "Building and provisioning image with: packer build ${FILE}..."
packer build ${FILE}

echo "Saving image locally..."
openstack image save --file ${IMAGE_NAME}_large.qcow2 ${IMAGE_NAME}

echo "Deleting image on openstack..."
openstack image delete ${IMAGE_NAME}

echo "Compressing image..."
qemu-img convert -c -o compat=0.10 -O qcow2 ${IMAGE_NAME}_large.qcow2 ${IMAGE_NAME}_small.qcow2
rm ${IMAGE_NAME}_large.qcow2

echo "Uploading compressed image to openstack..."
openstack image create --disk-format qcow2 --container-format bare --file ${IMAGE_NAME}_small.qcow2 ${IMAGE_NAME}
openstack image set --property default_user=ubuntu ${IMAGE_NAME}
openstack image set --property nectar_name=${IMAGE_NAME} ${IMAGE_NAME}
openstack image set --property os_distro=ubuntu ${IMAGE_NAME}
openstack image set --property os_version=18.04 ${IMAGE_NAME}

openstack image unset --property owner_specified.openstack.sha256
openstack image unset --property owner_specified.openstack.object
openstack image unset --property owner_specified.openstack.md5