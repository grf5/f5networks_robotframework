*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create a Route Domain on the BIG-IP
    [Arguments]                                 ${route_domain_name}    ${route_domain_id}      ${partition}=Common
    ${api_payload}                              create dictionary       name=${route_domain_name}   id=${route_domain_id}   partition=${partition}
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${verification_dict}                        create dictionary       kind=tm:net:route-domain:route-domainstate      name=${route_domain_name}   partition=${partition}
    ${api_response_dict}                        to json         ${api_response.text}
    dictionary should contain subdictionary     ${api_response_dict}     ${verification_dict}
    [Teardown]                                  Delete All Sessions

Add a Description to a BIG-IP Route Domain
    [Arguments]                                 ${route_domain_name}    ${description}      ${partition}=Common
    ${api_payload}                              create dictionary       description=${description}
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                  Delete All Sessions

Enable BGP Only on BIG-IP Route Domain
    [Arguments]                                 ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}                create list             BGP
    ${api_payload}                              create dictionary       routingProtocol=${api_routing_protocol_list}
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Sleep                                       10s
    [Teardown]                                  Delete All Sessions

Enable BGP and BFD on BIG-IP Route Domain
    [Arguments]                                 ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}                create list             BGP     BFD
    ${api_payload}                              create dictionary       routingProtocol=${api_routing_protocol_list}
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Sleep                                       10s
    [Teardown]                                  Delete All Sessions

Disable Dynamic Routing on BIG-IP Route Domain
    [Arguments]                                 ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}                create list
    ${api_payload}                              create dictionary       routingProtocol=${api_routing_protocol_list}
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Sleep                                       5s
    [Teardown]                                  Delete All Sessions

Enable Route Domain Strict Routing
    [Arguments]                                 ${route_domain_name}    ${partition}=Common
    ${api_payload}                              create dictionary       strict=enabled
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                  Delete All Sessions

Disable Route Domain Strict Routing
    [Arguments]                                 ${route_domain_name}    ${partition}=Common
    ${api_payload}                              create dictionary       strict=disabled
    set test variable                           ${api_payload}
    ${api_uri}                                  set variable            /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    set test variable                           ${api_uri}
    ${api_response}                             BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                  ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                  Delete All Sessions

