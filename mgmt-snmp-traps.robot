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
Generate Token
    Create Session                  gen-token                       https://${IPV4_MGMT}        verify=False
    ${api_auth} =                   Create List                     ${GUI_USERNAME}             ${GUI_PASSWORD}
    &{api_headers} =                Create Dictionary               Content-type=application/json
    &{api_payload} =                Create Dictionary               username=${GUI_USERNAME}    password=${GUI_PASSWORD}    loginProviderName=tmos
    Log                             TOKEN REQUEST PAYLOAD: ${api_payload}
    ${api_response} =               Post Request                    gen-token                   /mgmt/shared/authn/login    json=${api_payload}         headers=${api_headers}
    Log                             TOKEN REQUEST RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json} =          To Json                         ${api_response.content}
    ${api_auth_token} =             Get From Dictionary             ${api_response_json}        token
    ${api_auth_token} =             Get From Dictionary             ${api_auth_token}           token
    ${api_auth_token} =             Set Test Variable               ${api_auth_token}
    Log                             GREG ${api_auth_token}
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Delete Request                  delete-token                /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Create SNMPv2 IPv4 Trap Desination
    Create Session                  bigip-create-snmp-v2-ipv4-trap-destination        https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_payload}                  ${SNMPv2_TRAP_HOST}
    Log                             API PAYLOAD: ${api_payload}
    ${api_response}                 Post Request                    bigip-create-snmp-v2-ipv4-trap-destination     /mgmt/tm/sys/snmp/v2-traps           headers=${api_headers}      json=${api_payload}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

