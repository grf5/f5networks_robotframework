*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Assign BIG-IP VLANs to Trunk
    [Arguments]                     ${trunk_name}       ${vlan_list}
    :FOR    ${current_vlan}         IN          @{vlan_list}
    \   ${api_payload}              create dictionary   name=${trunk_name}
    \   set test variable           ${api_payload}
    \   ${api_uri}                  set variable        /mgmt/tm/net/vlan/${current_vlan}
    \   set test variable           ${api_uri}
    \   ${api_response}             BIG-IP iControl TokenAuth POST
    \   Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Create A Vlan on the BIG-IP
    [Arguments]                     ${vlan_name}    ${vlan_tag}
    ${api_payload}                  Create Dictionary               name    ${vlan_name}   tag  ${vlan_tag}
    set test variable               ${api_payload}
    ${api_uri}                      set variable        /mgmt/tm/net/vlan
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Verify a Vlan on the BIG-IP
    [Arguments]                     ${vlan_name}    ${vlan_tag}
    ${api_uri}                      /mgmt/tm/net/vlan/${vlan_name}
    set test variable               ${api_uri}
    ${api_repsonse}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    dictionary should contain item  ${api_response_dict}        tag     ${vlan_tag}
    dictionary should contain item  ${api_response_dict}        name    ${vlan_name}
    [Teardown]                      Delete All Sessions

Get Current List of Interfaces Mapped to VLAN
    [Arguments]                     ${vlan_name}
    ${api_uri}                      set variable            /mgmt/tm/net/vlan/${vlan_name}/interfaces
    ${api_response}                 BIG-IP iControl TokenAuth GET
    ${api_response_dict}            to json                         ${api_response.content}
    Dictionary Should Contain Key   ${api_response_dict}    interfaces
    ${initial_interface_list}       get from dictionary     ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list         ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    set global variable             ${initial_interface_list}
    [Teardown]                      Delete All Sessions

Modify VLAN Mapping on BIG-IP VLAN
    [Arguments]                     ${vlan_name}        ${vlan_interface_list}
    ${api_payload}                  Create Dictionary               interfaces     ${vlan_interface_list}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/vlan/${vlan_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Modify MTU on BIG-IP VLAN
    [Arguments]                     ${vlan_name}        ${vlan_mtu}
    ${api_payload}                  Create Dictionary               mtu     ${vlan_mtu}
    set test variable               ${api_payload}
    ${api_uri}                      set variable        /mgmt/tm/net/vlan/${vlan_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Verify MTU on BIG-IP VLAN
    [Arguments]                     ${vlan_name}        ${vlan_mtu}
    ${api_uri}                      set variable        /mgmt/tm/net/vlan/${vlan_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    dictionary should contain item  ${api_response_dict}        mtu         ${vlan_mtu}
    dictionary should contain item  ${api_response_dict}        name        ${vlan_name}
    [Teardown]                      Delete All Sessions

Verify dot1q Tag on BIG-IP VLAN
    [Arguments]                     ${vlan_name}        ${vlan_tag}     ${partition}=Common
    ${api_uri}                      set variable        /mgmt/tm/net/vlan/~${partition}~${vlan_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}        kind        tm:net:vlan:vlanstate
    dictionary should contain item  ${api_response_dict}        tag         ${vlan_tag}
    dictionary should contain item  ${api_response_dict}        name        ${vlan_name}
    [Teardown]                      Delete All Sessions

Configure VLAN Failsale on BIG-IP
    [Arguments]                     ${vlan}     ${partition}=Common   ${failsafe}=disabled   ${failsafe-action}=failover   ${failsafe-timeout}=60
    ${api_payload}                  create dictionary       failsafe=${failsafe}        failsafe-action=${failsafe-action}      failsafe-timeout=${failsafe-timeout}
    set test variable               ${api_payload}
    ${api_uri}                      set variable        /mgmt/tm/net/vlan/~${partition}~${vlan}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
#    dictionary should contain item  ${api_response_dict}        name                ${vlan}
#    dictionary should contain item  ${api_response_dict}        partition           ${partition}
#    dictionary should contain item  ${api_response_dict}        failsafe            ${failsafe}
#    dictionary should contain item  ${api_response_dict}        failsafe-action     ${failsafe-action}
#    dictionary should contain item  ${api_response_dict}        failsafe-timeout    ${failsafe-timeout}
    [Teardown]                      Delete All Sessions

Delete a BIG-IP VLAN
    [Arguments]                     ${vlan_name}
    ${api_uri}                      set variable        /mgmt/tm/net/vlan/${vlan_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions