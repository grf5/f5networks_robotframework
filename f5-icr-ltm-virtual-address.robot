*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Configure Route Health Injection on a Virtual Address
    [Documentation]             Requires address and route-advertisement parameters, partition and route_domain_id are optional. "address" is a IPv4 or IPv6 network. "route-advertisement" can be enabled or disabled.
    [Arguments]                 ${address}    ${route-advertisement}      ${partition}=Common   ${route_domain_id}=0
    Set Log Level               Debug
    ${api_payload}              create dictionary       route-advertisement=${route-advertisement}
    set test variable           ${api_payload}
    ${api_uri}                  set variable            /mgmt/tm/ltm/virtual-address/~${partition}~${address}
    set test variable           ${api_uri}
    ${api_response}             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings  ${api_response.status_code}     ${HTTP_RESPONSE_OK}