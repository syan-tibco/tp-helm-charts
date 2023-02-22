#!/bin/bash

#
# © 2023 Cloud Software Group, Inc.
# All Rights Reserved. Confidential & Proprietary.
#

cd ../charts/dp-core-infrastructure || exit

yq -i eval 'del(.dependencies.[].repository)' Chart.yaml
yq -i eval 'del(.dependencies.[].repository)' Chart.lock
