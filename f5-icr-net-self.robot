*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create BIG-IP Non-floating Self IP Address
    [Arguments]                         ${name}     ${vlan}     ${address}    ${partition}="Common"    ${allow-service}="none"    ${description}="Robot Framework"      ${traffic-group}="traffic-group-local-only"
    ${api_payload}                      Create Dictionary   name=${name}    partition=${partition}  address=${address}  allowService=${allow-service}   trafficGroup=${traffic-group}   description=${description}  vlan=${vlan}
    set test variable                   ${api_payload}
    ${api_uri}                          set variable        /mgmt/tm/net/self
    set test variable                   ${api_uri}
    ${api_response}                     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings          ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                          Delete All Sessions

Create BIG-IP Floating Self IP Address
    [Arguments]                         ${name}     ${vlan}     ${address}     ${partition}="Common"   ${allow-service}="none"    ${description}="Robot Framework"      ${traffic-group}="traffic-group-1"
    ${api_payload}                      Create Dictionary   name=${name}    partition=${partition}  address=${address}  allowService=${allow-service}   trafficGroup=${traffic-group}   description=${description}  vlan=${vlan}
    set test variable                   ${api_payload}
    ${api_uri}                          set variable        /mgmt/tm/net/self
    set test variable                   ${api_uri}
    ${api_response}                     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings          ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                          Delete All Sessions
