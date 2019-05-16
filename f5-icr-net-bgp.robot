*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create BGP IPv4 Neighbor
    [Arguments]                     ${bgp_local_as_number}    ${bgp_peer_ip}      ${bgp_peer_as_number}     ${route_domain_id}=0
    ${bgp_commands}                 set variable        configure terminal,router bgp ${bgp_local_as_number},neighbor ${bgp_peer_ip} remote-as ${bgp_peer_as_number},end,copy running-config startup-config
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Create BGP IPv6 Neighbor
    [Arguments]                     ${bgp_local_as_number}    ${bgp_peer_ip}      ${bgp_peer_as_number}     ${route_domain_id}=0
    ${bgp_commands}                 set variable        configure terminal,router bgp ${bgp_local_as_number},neighbor ${bgp_peer_ip} remote-as ${bgp_peer_as_number},address-family ipv6,neighbor ${bgp_peer_ip} activate,end,copy running-config startup-config
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Create BGP IPv4 Network Advertisement
    [Arguments]                     ${bgp_as_number}        ${ipv4_prefix}      ${ipv4_mask}        ${route_domain_id}=0
    ${bgp_commands}                 set variable        configure terminal,router bgp ${bgp_as_number},network ${ipv4_prefix} mask ${ipv4_mask},end,copy running-config startup-config
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Create BGP IPv6 Network Advertisement
    [Arguments]                     ${bgp_as_number}        ${ipv6_cidr}      ${route_domain_id}=0
    ${bgp_commands}                 set variable        configure terminal,router bgp ${bgp_as_number},address-family ipv6,network ${ipv6_cidr},end,copy running-config startup-config
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Enable BGP Redistribution of Kernel Routes
    [Arguments]                     ${bgp_as_number}    ${route_domain_id}=0
    ${bgp_commands}                 set variable        configure terminal,router bgp ${bgp_as_number},redistribute kernel,end,copy running-config startup-config
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Show Route Domain BGP Configuration
    [Arguments]                     ${route_domain_id}=0
    ${bgp_commands}                 set variable        show running-config bgp
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Show Route Domain BGP Status
    [Arguments]                     ${route_domain_id}=0
    ${bgp_commands}                 set variable        show ip bgp, show bgp, show bgp neighbors, show bgp ipv4 neighbors, show bgp ipv6 neighbors
    Run BGP Commands on BIG-IP      commands=${bgp_commands}    route_domain_id=${route_domain_id}

Run BGP Commands on BIG-IP
    [Arguments]                     ${commands}     ${route_domain_id}
    ${api_payload}                  create dictionary       command=run     utilCmdArgs=-c "zebos -r ${route_domain_id} cmd ${commands}"
    set test variable               ${api_payload}
    ${api_uri}                      set variable    /mgmt/tm/util/bash
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

