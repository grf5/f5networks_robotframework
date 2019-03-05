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
Create All Vlans on the BIG-IP
    Generate Token
    Extend Token
    Create All VLANs on the BIG-IP
    Delete Token

*** Keywords ***
Create All VLANs on the BIG-IP
    :FOR    ${current_vlan}     IN RANGE    1   4094
    \   Set Test Variable           ${vlan_tag}                 ${${current_vlan}}
    \   Set Test Variable           ${vlan_name}                vlan${current_vlan}
    \   Set Test Variable           ${vlan_mtu}                 ${${default_vlan_mtu}}
    \   Set Test Variable           ${vlan_source-checking}     enabled
    \   Log                               Creating VLAN for tag ${current_vlan}
    \   &{api_payload}                  Create Dictionary               name    ${vlan_name}   tag  ${vlan_tag}     mtu     ${vlan_mtu}     sourceChecking  ${vlan_source-checking}     description     Created by ROBOT FRAMEWORK
    \   ${api_uri}                      /mgmt/tm/net/vlan
    \   ${api_response}                 BIG-IP iControl TokenAuth POST
    \   delete all sessions
    \   log                             Verifying configuration of vlan${current_vlan}
    \   ${api_uri}                      /mgmt/tm/net/vlan/~Common~vlan${current_vlan}
    \   ${api_repsonse}                 BIG-IP iControl TokenAuth GET
    \   Should Be Equal As Strings      ${api_response.status_code}     200
    \   ${api_response_dict}            to json                         ${api_response.content}
    \   dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    \   dictionary should contain item  ${api_response_dict}        tag     ${current_vlan}
    \   dictionary should contain item  ${api_response_dict}        mtu     ${vlan_mtu}
    \   dictionary should contain item  ${api_response_dict}        sourceChecking      ${vlan_source-checking}
    \   dictionary should contain item  ${api_response_dict}        name                ${vlan_name}
    [Teardown]                      Delete All Sessions