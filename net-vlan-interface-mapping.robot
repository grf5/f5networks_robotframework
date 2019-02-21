*** Settings ***
Documentation       Suite description
...                 This test case contains the creation of all vlans from vlan tag 0 to 4093 on the F5 BIG-IP
...

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot
${TARGET_INTERFACE}             ['test_trunk']

*** Test Cases ***
Add BIG-IP VLAN to Physical Interface or Trunk
    Generate Token
    Extend Token
    Get Current List of Interfaces Mapped to VLAN
    Modify Interface Mapping on BIG-IP VLAN
    Delete Token

*** Keywords ***
Get Current List of Interfaces Mapped to VLAN
    log                             Getting list of existing interfaces on trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    create session                  bigip-list-net-trunk-interfaces                     https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 Get Request   bigip-list-net-trunk-interfaces    /mgmt/tm/net/trunk/${trunk_object_name}    headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_interface_list}       get from dictionary     ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list         ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    set global variable             ${initial_interface_list}
    [Teardown]                      Delete All Sessions

Modify Interface Mapping on BIG-IP VLAN
    :FOR    ${current_vlan}     IN RANGE    1   128
    \   Set Test Variable               ${vlan_name}                vlan${current_vlan}
    \   Log                             Mapping VLAN ${vlan_name} to interface ${TARGET_INTERFACE}
    \   Create Session                  bigip-modify-net-vlan            https://${IPV4_MGMT}        verify=False
    \   &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    \   &{api_payload}                  Create Dictionary               interfaces     ${TARGET_INTERFACE}
    \   Log                             API PAYLOAD: ${api_payload}
    \   ${api_response}                 Patch Request                   bigip-modify-net-vlan    /mgmt/tm/net/vlan/~Common~vlan${current_vlan}        headers=${api_headers}      json=${api_payload}
    \   Should Be Equal As Strings      ${api_response.status_code}     200
    \   Log                             API RESPONSE: ${api_response.content}
    \   log                             Verifying configuration of vlan${current_vlan}
    \   create session                  bigip-list-net-vlan                 https://${IPV4_MGMT}        verify=False
    \   &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    \   ${api_response}                 get request                     bigip-list-net-vlan     /mgmt/tm/net/vlan/~Common~vlan${current_vlan}   headers=${api_headers}
    \   Log                             API RESPONSE: ${api_response.content}
    \   should be equal as strings      ${api_response.status_code}     200
    \   ${api_response_dict}            to json                         ${api_response.content}
    \   dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    \   dictionary should contain item  ${api_response_dict}        mtu     ${vlan_mtu}
    \   dictionary should contain item  ${api_response_dict}        name                ${vlan_name}
    [Teardown]                      Delete All Sessions

Generate Token
    Create Session                  gen-token                       https://${IPV4_MGMT}        verify=False
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
    Log                             API Auth Token: ${api_auth_token}
    [Teardown]                      Delete All Sessions

Extend Token
    Create Session                  extend-token                       https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    &{api_payload} =                Create Dictionary               timeout=${36000}
    Log                             TOKEN EXTEND REQUEST PAYLOAD: ${api_payload}
    ${api_response}                 Patch Request    extend-token    /mgmt/shared/authz/tokens/${api_auth_token}    json=${api_payload}     headers=${api_headers}
    Log                             TOKEN EXTEND REQUEST RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_token_status}             to json                         ${api_response.content}
    dictionary should contain item  ${api_token_status}             timeout         36000
    Log                             API Auth Token: ${api_auth_token}
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Delete Request                  delete-token                /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

