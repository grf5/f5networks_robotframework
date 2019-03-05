*** Settings ***
Documentation       Suite description
...                 Notes:
...                 All layer 3 tests are implied to be executed via both IPv4 and IPv6 unless otherwise explicitly stated.
...
...                 1.	Dual Stack Management Interface (DCNETARCH-SLB-0010)
...
...                 If available, the dedicated management interface of the SLB must be able to be dual stacked and support all management related functions on both IPv4 and IPv6
...
...                 Hardware and/or Software Under Test
... 	                    F5 BIG-IP
...
...                 Steps
...                 -	Configure management interface with both IPv4 and IPv6 addresses
...                 -	Ensure the following protocols work over both:
...                     o	SSH
...                     o	NTP
...                     o	SNMP Poll
...                     o	SNMP Trap
...                     o	HTTP(S) Web GUI (if applicable)
...                     o	Streaming Telemetry via gRPC (if it’s supported)
...
...                 Expected Results:
...                 All management protocols work over both IPv4 and IPv6.

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Library             SnmpLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Test IPv4 SNMP Traps
    Generate Token
    Create SNMPv2 IPv4 Trap Desination
    Delete Token

*** Keywords ***
Create SNMPv2 IPv4 Trap Desination
    ${api_payload}                  create dictionary       name=${SNMPv2_TRAP_HOST}
    ${api_uri}                      /mgmt/tm/sys/snmp/v2-traps
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions
