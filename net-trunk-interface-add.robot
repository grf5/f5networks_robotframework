*** Settings ***
Documentation    Suite description
...             This test concerns the configuration of physical interfaces

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot
${TARGET_INTERFACE}             1.3

*** Test Cases ***
Add Physical Interface to BIG-IP Trunk
    Generate Token
    Get Current List of Interfaces in BIG-IP Trunk
    Add Interface from BIG-IP Trunk
    Verify BIG-IP Trunk Interface Addition
    Delete Token

*** Keywords ***
Get Current List of Interfaces in BIG-IP Trunk
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

Add Interface from BIG-IP Trunk
    log                             Adding target interface from interface list
    list should not contain value   ${initial_interface_list}       ${TARGET_INTERFACE}
    ${new_interface_list}           set variable                    ${initial_interface_list}
    set test variable               ${new_interface_list}
    append to list                  ${initial_interface_list}       ${TARGET_INTERFACE}
    log                             New interface list: ${initial_interface_list} ${new_interface_list}
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    create session                  bigip-modify-net-trunk              https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    &{api_payload}                  create dictionary               interfaces      ${new_interface_list}
    Log                             API PAYLOAD: &{api_payload}
    ${api_response}                 Patch Request   bigip-modify-net-trunk    /mgmt/tm/net/trunk/${trunk_object_name}    headers=${api_headers}  json=${api_payload}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface Addition
    log                             Verifying addition of physical interface from BIG-IP trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    create session                  bigip-list-net-trunk-interfaces                     https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 Get Request   bigip-list-net-trunk-interfaces    /mgmt/tm/net/trunk/${trunk_object_name}    headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item     ${api_response_dict}      interfaces     ${new_interface_list}
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
    Log                             GREG ${api_auth_token}
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}     Delete Request  delete-token    /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions


