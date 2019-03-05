*** Settings ***
Documentation       Suite description
...                 This test case contains the creation of all vlans from vlan tag 0 to 4093 on the F5 BIG-IP
...

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
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
    ${api_uri}                      /mgmt/tm/net/trunk/${trunk_object_name}
    ${api_response}                 BIG-IP iControl TokenAuth GET
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
    \   &{api_payload}                  Create Dictionary               interfaces     ${TARGET_INTERFACE}
    \   ${api_uri}                      /mgmt/tm/net/vlan/~Common~vlan${current_vlan}
    \   ${api_response}                 BIG-IP iControl TokenAuth PATCH
    \   Should Be Equal As Strings      ${api_response.status_code}     200
    \   log                             Verifying configuration of vlan${current_vlan}
    \   ${api_uri}                      /mgmt/tm/net/vlan/~Common~vlan${current_vlan}
    \   ${api_response}                 BIG-IP iControl TokenAuth GET
    \   Should Be Equal As Strings      ${api_response.status_code}     200
    \   ${api_response_dict}            to json                         ${api_response.content}
    \   dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    \   dictionary should contain item  ${api_response_dict}        mtu         ${vlan_mtu}
    \   dictionary should contain item  ${api_response_dict}        name        ${vlan_name}
    [Teardown]                      Delete All Sessions