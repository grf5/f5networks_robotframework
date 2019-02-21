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
Test IPv4 SNMP Polling
    Generate Token
    Create SNMP Community
    Add Test Host to SNMP Allow-List
    Delete Token
    Get SNMP IPv4 sysDescr

Test IPv6 SNMP Polling

# Dual stack management is not supported until TMOS version 14.0

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

Create SNMP Community
    Create Session                  bigip-create-snmp-community             https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_payload}                  Create Dictionary               access=ro       communityName=${SNMPV2_POLL_COMMUNITY}      ipv6=disabled   description=ACCEPTANCE TESTING    name=${SNMPV2_POLL_COMMUNITY}
    Log                             API PAYLOAD: ${api_payload}
    ${api_response}                 Post Request                    bigip-create-snmp-community     /mgmt/tm/sys/snmp/communities       headers=${api_headers}      json=${api_payload}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Delete SNMP Community
    Create Session                  bigip-delete-snmp-community             https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 Delete Request                    bigip-delete-snmp-community     /mgmt/tm/sys/snmp/communities/${SNMPV2_POLL_COMMUNITY}       headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Add Test Host to SNMP Allow-List
    Create Session                  bigip-list-snmp-allow-list            https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 Get Request                     bigip-list-snmp-allow-list      /mgmt/tm/sys/snmp           headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${snmp-allow-list}              evaluate        json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}              Get from Dictionary         ${snmp-allow-list}      allowedAddresses
    Log                             Pre-modification SNMP allow list: ${snmp-allow-list}
    Append to List                  ${snmp-allow-list}      ${ROBOT_HOST_IP}
    Log                             Post-modification SNMP allow list: ${snmp-allow-list}
    Create Session                  bigip-modify-snmp-allow-list            https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_payload}                  Create Dictionary               allowedAddresses=${snmp-allow-list}
    Log                             API PAYLOAD: ${api_payload}
    ${api_response}                 Patch Request                    bigip-modify-snmp-allow-list     /mgmt/tm/sys/snmp       headers=${api_headers}      json=${api_payload}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Remove Test Host from SNMP Allow-List
    Create Session                  bigip-list-snmp-allow-list            https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 Get Request                     bigip-list-snmp-allow-list      /mgmt/tm/sys/snmp           headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${snmp-allow-list}              evaluate        json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}              Get from Dictionary         ${snmp-allow-list}      allowedAddresses
    Log                             Pre-modification SNMP allow list: ${snmp-allow-list}
    Remove from List                ${snmp-allow-list}      ${ROBOT_HOST_IP}
    Log                             Post-modification SNMP allow list: ${snmp-allow-list}
    Create Session                  bigip-modify-snmp-allow-list            https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_payload}                  Create Dictionary               allowedAddresses=${snmp-allow-list}
    Log                             API PAYLOAD: ${api_payload}
    ${api_response}                 Patch Request                    bigip-modify-snmp-allow-list     /mgmt/tm/sys/snmp       headers=${api_headers}      json=${api_payload}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Get SNMP IPv4 sysDescr
    ${connect_status}               Open Snmp Connection        ${IPV4_MGMT}        ${SNMPV2_POLL_COMMUNITY}
    Log                             SNMP Connect Status: ${connect_status}
    ${snmp_ipv4_sysDescr} =         Get Display String             .iso.3.6.1.2.1.1.5
    Log                             SNMP value for OID .iso.3.6.1.2.1.1.5 returned: ${snmp_ipv4_sysDescr}
    [Teardown]                      Close All Snmp Connections


