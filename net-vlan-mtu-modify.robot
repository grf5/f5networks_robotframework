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

*** Test Cases ***
Modify MTU on Range of Vlans on the BIG-IP
    Generate Token
    Extend Token
    Modify MTU on Range of VLANs on the BIG-IP
    Delete Token

*** Keywords ***
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


Modify MTU on Range of VLANs on the BIG-IP
    :FOR    ${current_vlan}     IN RANGE    1   4094
    \   Set Test Variable               ${vlan_name}                vlan${current_vlan}
    \   Set Test Variable               ${vlan_mtu}                 ${${DESIRED_VLAN_MTU}}
    \   Log                             Modifying MTU on VLAN ${vlan_name}
    \   Create Session                  bigip-modify-net-vlan            https://${IPV4_MGMT}        verify=False
    \   &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    \   &{api_payload}                  Create Dictionary               mtu     ${vlan_mtu}
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

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Delete Request                  delete-token                /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

