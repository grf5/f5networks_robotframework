#!/usr/bin/env bash

# Environmental variables
robot_fullpath=/path/to/your/robot/binary
export PYTHONWARNINGS='ignore:Unverified HTTPS request'

# Test case variables
export SSH_USERNAME='root'
export SSH_PASSWORD='default'
export HTTP_USERNAME='admin'
export HTTP_PASSWORD='admin'
export HTTP_RESPONSE_OK='200'
export HTTP_RESPONSE_NOT_FOUND='404'

export BIGIP_PRIMARY_MGMT_IP='192.168.100.101'
# set BIGIP_SECONDARY_MGMT_IP to 'false' if using single device
export BIGIP_SECONDARY_MGMT_IP='192.168.100.102'

echo ======================
echo = DCNETARCH-SLB-0010 =
echo ======================
test=tmos_connectivity_tests; $robot_fullpath --outputdir ./reports -o $test.xml -l $test.log.html -r $test.report.html ./bin/$test.robot
