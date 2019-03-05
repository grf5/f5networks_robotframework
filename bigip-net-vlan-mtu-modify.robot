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

*** Test Cases ***
Modify MTU on Range of Vlans on the BIG-IP
    Generate Token
    Extend Token
    Modify MTU on Range of VLANs on the BIG-IP
    Delete Token

*** Keywords ***
Modify MTU on Range of VLANs on the BIG-IP
    :FOR    ${current_vlan}     IN RANGE    1   4094
    \   Set Test Variable               ${vlan_name}                vlan${current_vlan}
    \   Set Test Variable               ${vlan_mtu}                 ${${DESIRED_VLAN_MTU}}
    \   Log                             Modifying MTU on VLAN ${vlan_name}
    \   &{api_payload}                  Create Dictionary               mtu     ${vlan_mtu}
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