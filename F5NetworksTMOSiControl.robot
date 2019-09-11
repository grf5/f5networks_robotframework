*** Settings ***
Documentation    Resource file for F5's iControl REST API
Library    Collections
Library    RequestsLibrary
Library    String
Library    SnmpLibrary
Library    SSHLibrary

*** Keywords ***
######################################
## iControl HTTP Operations Keywords
######################################
Generate Token    
    [Documentation]    Generates an API Auth token using username/password (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}   ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/shared/authn/login
    ${api_payload}    Create Dictionary    username=${bigip_username}    password=${bigip_password}    loginProviderName=tmos
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}
    ...    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    200
    ${api_response_json}    To Json    ${api_response.content}
    ${api_token}    Get From Dictionary    ${api_response_json}    token
    ${api_token}    Get From Dictionary    ${api_token}    token
    [Teardown]    Delete All Sessions
    [Return]    ${api_token}

Extend Token    
    [Documentation]    Extends the timeout on an existing auth token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}   ${api_token}   ${timeout}=${36000}
    ${api_token}    Generate Token    ${bigip_host}
    ${api_payload}    Create Dictionary    timeout=${timeout}
    ${api_uri}    set variable    /mgmt/shared/authz/tokens/${api_token}
    ${api_response}    BIG-IP iControl TokenAuth PATCH    bigip_host=${bigip_host}    api_token=${api_token}    api_url=${api_uri}
    ...    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    200
    ${api_token_status}    to json    ${api_response.content}
    dictionary should contain item    ${api_token_status}    timeout    36000
    [Teardown]    Delete All Sessions
    [Return]    ${api_token_status}

Delete Token    
    [Documentation]    Deletes an auth token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}
    ${api_uri}    set variable    /mgmt/shared/authz/tokens/${api_token}
    log    DELETE TOKEN URI: https://${bigip_host}${api_uri}
    ${api_response}    BIG-IP iControl TokenAuth DELETE    bigip_host=${bigip_host}    api_token=${api_token}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    200
    [Teardown]    Delete All Sessions

BIG-IP iControl TokenAuth GET    
    [Documentation]    Performs an iControl REST API GET call using a pre-generated token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}    ${api_uri}
    log    iControl GET Variables: HOST: ${bigip_host} URI: ${api_uri} AUTH-TOKEN: ${api_token}
    create session    bigip-icontrol-get-tokenauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json    X-F5-Auth-Token=${api_token}
    ${api_response}    get request    bigip-icontrol-get-tokenauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl TokenAuth POST    
    [Documentation]    Performs an iControl REST API POST call using a pre-generated token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}    ${api_uri}    ${api_payload}
    log    iControl POST Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_token}
    create session    bigip-icontrol-post-tokenauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json    X-F5-Auth-Token=${api_token}
    ${api_response}    post request    bigip-icontrol-post-tokenauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl TokenAuth PUT    
    [Documentation]    Performs an iControl REST API PUT call using a pre-generated token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}    ${api_uri}    ${api_payload}
    log    iControl PUT Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_token}
    create session    bigip-icontrol-put-tokenauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json    X-F5-Auth-Token=${api_token}
    ${api_response}    put request    bigip-icontrol-put-tokenauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl TokenAuth PATCH    
    [Documentation]    Performs an iControl REST API PATCH call using a pre-generated token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}    ${api_uri}    ${api_payload}
    log    iControl PATCH Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_token}
    create session    bigip-icontrol-patch-tokenauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json    X-F5-Auth-Token=${api_token}
    ${api_response}    patch request    bigip-icontrol-patch-tokenauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl TokenAuth DELETE    
    [Documentation]    Performs an iControl REST API DELETE call using a pre-generated token (See pages 20-21 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_token}    ${api_uri}
    log    iControl DELETE Variables: HOST: ${bigip_host} URI: ${api_uri} AUTH-TOKEN: ${api_token}
    create session    bigip-icontrol-delete-tokenauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json    X-F5-Auth-Token=${api_token}
    ${api_response}    delete request    bigip-icontrol-delete-tokenauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    log    API Response (should be null for successful delete operations): ${api_response.content}
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl BasicAuth GET    
    [Documentation]    Performs an iControl REST API GET call using basic auth (See pages 25-38 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${api_uri}
    ${api_auth}    Create List    ${bigip_username}   ${bigip_password}
    log    iControl GET Variables: HOST: ${bigip_host} URI: ${api_uri}
    create session    bigip-icontrol-get-basicauth    https://${bigip_host}    auth=${api_auth}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    get request    bigip-icontrol-get-basicauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl BasicAuth POST    
    [Documentation]    Performs an iControl REST API POST call using basic auth (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${api_uri}    ${api_payload}
    ${api_auth}    Create List    ${bigip_username}   ${bigip_password}
    log    iControl POST Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    create session    bigip-icontrol-post-basicauth    https://${bigip_host}		auth=${api_auth}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    post request    bigip-icontrol-post-basicauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl BasicAuth PUT    
    [Documentation]    Performs an iControl REST API PUT call using basic auth (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${api_uri}    ${api_payload}
    ${api_auth}    Create List    ${bigip_username}   ${bigip_password}
    log    iControl PUT Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    create session    bigip-icontrol-put-basicauth    https://${bigip_host}		auth=${api_auth}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    put request    bigip-icontrol-put-basicauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl BasicAuth PATCH    
    [Documentation]    Performs an iControl REST API PATCH call using basic auth (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${api_uri}    ${api_payload}
    ${api_auth}    Create List    ${bigip_username}   ${bigip_password}
    log    iControl PATCH Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    create session    bigip-icontrol-patch-basicauth    https://${bigip_host}		auth=${api_auth}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    patch request    bigip-icontrol-patch-basicauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl BasicAuth DELETE    
    [Documentation]    Performs an iControl REST API DELETE call using basic auth (See pages 13 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${api_uri}
    ${api_auth}    Create List    ${bigip_username}   ${bigip_password}
    log    iControl DELETE Variables: HOST: ${bigip_host} URI: ${api_uri}
    create session    bigip-icontrol-delete-basicauth    https://${bigip_host}		auth=${api_auth}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    delete request    bigip-icontrol-delete-basicauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    log    API Response (should be null for successful delete operations): ${api_response.content}
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl NoAuth GET    
    [Documentation]    Performs an iControl REST API GET call without authentication (See pages 25-38 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_uri}    ${api_payload}
    log    iControl GET Variables: HOST: ${bigip_host} URI: ${api_uri}
    return from keyword if    "${bigip_host}" == "${EMPTY}"
    return from keyword if    "${api_uri}" == "${EMPTY}"
    create session    bigip-icontrol-get-noauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    get request    bigip-icontrol-get-noauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl NoAuth POST    
    [Documentation]    Performs an iControl REST API POST call without authentication (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_uri}    ${api_payload}
    log    iControl POST Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if    "${bigip_host}" == "${EMPTY}"
    return from keyword if    "${api_uri}" == "${EMPTY}"
    ${payload_length}    get length  ${api_payload}
    return from keyword if    ${payload_length} == 0
    create session    bigip-icontrol-post-noauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    post request    bigip-icontrol-post-noauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl NoAuth PUT    
    [Documentation]    Performs an iControl REST API PUT call without authentication (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_uri}    ${api_payload}
    log    iControl PUT Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if    "${bigip_host}" == "${EMPTY}"
    return from keyword if    "${api_uri}" == "${EMPTY}"
    ${payload_length}    get length  ${api_payload}
    return from keyword if    ${payload_length} == 0
    create session    bigip-icontrol-put-noauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    put request    bigip-icontrol-put-noauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl NoAuth PATCH    
    [Documentation]    Performs an iControl REST API PATCH call without authentication (See pages 39-44 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${api_uri}    ${api_payload}
    log    iControl PATCH Variables: HOST: ${bigip_host} URI: ${api_uri} PAYLOAD: ${api_payload}
    create session    bigip-icontrol-patch-noauth    https://${bigip_host}
    &{api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    patch request    bigip-icontrol-patch-noauth   ${api_uri}    headers=${api_headers}    json=${api_payload}
    log    HTTP Response Code: ${api_response}
    ${api_response.json}    to json    ${api_response.content}
    log    ${api_response.json}    formatter=repr
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

BIG-IP iControl NoAuth DELETE    
    [Documentation]    Performs an iControl REST API DELETE call without authentication (See pages 13 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}   ${api_uri}
    log    iControl DELETE Variables: HOST: ${bigip_host} URI: ${api_uri}
    create session    bigip-icontrol-delete-noauth    https://${bigip_host}
    ${api_headers}    Create Dictionary    Content-type=application/json
    ${api_response}    delete request    bigip-icontrol-delete-noauth   ${api_uri}    headers=${api_headers}
    log    HTTP Response Code: ${api_response}
    log    API Response (should be null for successful delete operations): ${api_response.content}
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

#############################
## Generic Testing Keywords
#############################

Ping Host from BIG-IP
    [Documentation]    Sends an ICMP echo request from the BIG-IP (See page 63 of https://cdn.f5.com/websites/devcentral.f5.com/downloads/icontrol-rest-api-user-guide-13-1-0-a.pdf.zip)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${host}    ${count}=1    ${interval}=100
    ...   ${packetsize}=56
    ${api_payload}    Create Dictionary    command=run    utilCmdArgs=-c ${count} -i ${interval} -s ${packetsize} ${host}
    ${api_uri}    set variable    /mgmt/tm/util/ping
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}
    ...   bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    ${ping_output}    Get from Dictionary    ${api_response_json}    commandResult
    log    ${ping_output}
    Should Contain    ${ping_output}    , 0% packet loss
    [Return]    ${api_response}

Retrieve BIG-IP Login Page
    [Documentation]    Tests connectivity and availability of the BIG-IP web UI login page
    [Arguments]    ${bigip_host}
    create session    webui    https://${bigip_host}
    ${api_response}    get request    webui    /tmui/login.jsp
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    Web UI HTTP RESPONSE: ${api_response.text}
    should contain    ${api_response.text}    <meta name="description" content="BIG-IP&reg; Configuration Utility" />
    [Teardown]    Delete All Sessions
    [Return]    ${api_response}

Query DNS Record
    [Documentation]    Executes the dig command on a BIG-IP
    [Arguments]    ${query}    ${ns_address}=4.2.2.1    ${query_type}=A
    [Return]

Reset All Statistics
    [Documentation]    Resets all statistics on the BIG-IP
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    
    Reset All Interface Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Trunk Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Self-IP Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Virtual Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Node Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Pool Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Reset All Performance Stats    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}

########
## BGP
########

Create BGP IPv4 Neighbor
    [Documentation]    Creates a BGP IPv4 Neighbor on the BIG-IP (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${bgp_local_as_number}    ${bgp_peer_ip}   ${bgp_peer_as_number}    ${route_domain_id}=0
    ${bgp_commands}    set variable    configure terminal,router bgp ${bgp_local_as_number},neighbor ${bgp_peer_ip} remote-as ${bgp_peer_as_number},end,copy running-config startup-config
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Create BGP IPv6 Neighbor
    [Documentation]    Creates a BGP IPv6 neighbor on the BIG-IP (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${bgp_local_as_number}    ${bgp_peer_ip}    ${bgp_peer_as_number}    ${route_domain_id}=0
    ${bgp_commands}    set variable    configure terminal,router bgp ${bgp_local_as_number},neighbor ${bgp_peer_ip} remote-as ${bgp_peer_as_number},address-family ipv6,neighbor ${bgp_peer_ip} activate,end,copy running-config startup-config
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Create BGP IPv4 Network Advertisement
    [Documentation]    Creates a IPv4 network statement on the BIG-IP (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${bgp_as_number}    ${ipv4_prefix}    ${ipv4_mask}    ${route_domain_id}=0
    ${bgp_commands}    set variable    configure terminal,router bgp ${bgp_as_number},network ${ipv4_prefix} mask ${ipv4_mask},end,copy running-config startup-config
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Create BGP IPv6 Network Advertisement
    [Documentation]    Creates an IPv6 address-family network statement on the BIG-IP (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${bgp_as_number}    ${ipv6_cidr}    ${route_domain_id}=0
    ${bgp_commands}    set variable    configure terminal,router bgp ${bgp_as_number},address-family ipv6,network ${ipv6_cidr},end,copy running-config startup-config
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Enable BGP Redistribution of Kernel Routes
    [Documentation]    Enables redistribution of kernel routes on the BIG-IP (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${bgp_as_number}    ${route_domain_id}=0
    ${bgp_commands}    set variable    configure terminal,router bgp ${bgp_as_number},redistribute kernel,end,copy running-config startup-config
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Show Route Domain BGP Configuration
    [Documentation]    Lists the BGP configuration on a route-domain on the BIG-IP (defaults to RD 0) (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_id}=0
    ${bgp_commands}    set variable    show running-config bgp
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Show Route Domain BGP Status
    [Documentation]    Shows the BGP status on a route-domain on the BIG-IP (defaults to 0) (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/related/bgp-commandreference-7-10-4/_jcr_content/pdfAttach/download/file.res/arm-bgp-commandreference-7-10-4.pdf)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_id}=0
    ${bgp_commands}    set variable    show ip bgp, show bgp, show bgp neighbors, show bgp ipv4 neighbors, show bgp ipv6 neighbors
    ${api_response}    Run BGP Commands on BIG-IP    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    commands=${bgp_commands}    route_domain_id=${route_domain_id}
    [Return]    ${api_response}

Run BGP Commands on BIG-IP
    [Documentation]    Generic handler for command separate list of BGP commands on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/big-ip-dynamic-routing-with-tmsh-and-icontrol-rest-14-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${commands}    ${route_domain_id}
    ${api_payload}    create dictionary    command=run    utilCmdArgs=-c "zebos -r ${route_domain_id} cmd ${commands}"
    ${api_uri}    set variable    /mgmt/tm/util/bash
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

#######
## cm
#######

Get CM Self Device
    [Documentation]    Retrieves the CM device configuration of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to Json    ${api_response.text}
    ${api_response_dict}    Convert to Dictionary    ${api_response_json}
    ${items_list}    Get from Dictionary    ${api_response_dict}    items
    :FOR    ${current_device}    IN    @{items_list}
    \    ${self_device_flag}    Get from Dictionary    ${current_device}    selfDevice
    \    ${cm_self_device}    Set Variable If    '${self_device_flag}' == 'true'    ${current_device}
    \    return from keyword if    '${self_device_flag}' == 'true'    ${cm_self_device}
    [Return]    ${cm_self_device}

Retrieve BIG-IP CM Hostname
    [Documentation]    Retrieves the CM hostname of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_hostname}    Get From Dictionary    ${cm_self_device}    hostname
    [Return]    ${cm_hostname}

Retrieve BIG-IP CM Name
    [Documentation]    Retrieves the CM object name of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_name}    Get From Dictionary    ${cm_self_device}    name
    [Return]    ${cm_name}

Retrieve TMOS Version
    [Documentation]    Retrieves the CM TMOS version of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_version}    Get From Dictionary    ${cm_self_device}    version
    [Return]    ${cm_version}

Retrieve TMOS Build
    [Documentation]    Retrieves the CM TMOS build of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_build}    Get From Dictionary    ${cm_self_device}    build
    [Return]    ${cm_build}

Retrieve TMOS Edition
    [Documentation]    Retrieves the CM TMOS edition of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_edition}    Get From Dictionary    ${cm_self_device}    edition
    [Return]    ${cm_edition}

Retrieve CM Timezone
    [Documentation]    Retrieves the CM timezone of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_timezone}    Get From Dictionary    ${cm_self_device}    timeZone
    [Return]    ${cm_timezone}

Retrieve CM Platform ID
    [Documentation]    Retrieves the CM platform ID of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_platform_id}    Get From Dictionary    ${cm_self_device}    platformId
    [Return]    ${cm_platform_id}

Retrieve CM Multicast Port
    [Documentation]    Retrieves the CM multicast port of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_multicast_port}    Get From Dictionary    ${cm_self_device}    multicastPort
    [Return]    ${cm_multicast_port}

Retrieve CM Multicast IP
    [Documentation]    Retrieves the CM multicast IP address of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_multicast_ip}    Get From Dictionary    ${cm_self_device}    multicastIp
    [Return]    ${cm_multicast_ip}

Retrieve CM Mirror IP
    [Documentation]    Retrieves the CM connection mirroring IP address of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_mirror_ip}    Get From Dictionary    ${cm_self_device}    mirrorIp
    [Return]    ${cm_mirror_ip}

Retrieve CM Secondary Mirror IP
    [Documentation]    Retrieves the CM secondary mirroring IP address of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_mirror_secondary_ip}    Get From Dictionary    ${cm_self_device}    mirrorSecondaryIp
    [Return]    ${cm_mirror_secondary_ip}

Retrieve CM Marketing Name
    [Documentation]    Retrieves the CM marketing name, or platform name, of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_marketing_name}    Get From Dictionary    ${cm_self_device}    marketingName
    [Return]    ${cm_marketing_name}

Retrieve CM Management IP
    [Documentation]    Retrieves the CM management-ip of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_management_ip}    Get From Dictionary    ${cm_self_device}    managementIp
    [Return]    ${cm_management_ip}

Retrieve CM Failover State
    [Documentation]    Retrieves the CM failover state of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_failover_state}    Get From Dictionary    ${cm_self_device}    failoverState
    [Return]    ${cm_failover_state}

Retrieve CM Configsync IP
    [Documentation]    Retrieves the CM config sync IP address of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_configsync_ip}    Get From Dictionary    ${cm_self_device}    configsyncIp
    [Return]    ${cm_configsync_ip}

Retrieve CM Active Modules
    [Documentation]    Retrieves the CM active modules list of the local BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    ${cm_self_device}    Get CM Self Device    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    ${cm_active_modules}    Get From Dictionary    ${cm_self_device}    activeModules
    [Return]    ${cm_active_modules}

Add Device to CM Trust
    [Documentation]    Creates certificate-based trust between two BIG-IPs using one-time username/password credentials for the exchange (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${peer_bigip_host}    ${peer_bigip_username}    ${peer_bigip_password}    ${peer_bigip_cm_name}
    ${api_payload}    Create Dictionary    command    run    name    Root    caDevice    ${True}    device    ${peer_bigip_host}    deviceName    ${peer_bigip_cm_name}    username    ${peer_bigip_username}    password    ${peer_bigip_password}
    ${api_uri}    Set Variable    /mgmt/tm/cm/add-to-trust
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify Trust Sync Status 13.1.1.4
    [Documentation]    Verifies that two BIG-IPs are in a trust group and in-sync (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    Set variable    /mgmt/tm/cm/sync-status
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    ${api_response_json}    to Json    ${api_response.text}
    ${bigip_mode_entries}    Get from Dictionary    ${api_response_json}    entries
    ${bigip_mode_selflink}    Get from Dictionary    ${bigip_mode_entries}    https://localhost/mgmt/tm/cm/sync-status/0
    ${bigip_mode_nestedstats}    Get from Dictionary    ${bigip_mode_selflink}    nestedStats
    ${bigip_mode_sync_entries}    Get from Dictionary    ${bigip_mode_nestedstats}    entries
    ${bigip_mode_status}    Get from Dictionary    ${bigip_mode_sync_entries}    status
    ${bigip_mode_status_description}    Get from Dictionary    ${bigip_mode_status}    description
    ${expected_response}    Create Dictionary    description    In Sync
    Dictionaries Should Be Equal    ${bigip_mode_status}    ${expected_response}
    [Return]    ${api_response}

Create CM Device Group
    [Documentation]    Creates a CM device group on the BIG-IP (syncs across trust-group members) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${cm_device_group_name}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device-group
    ${api_payload}    Create Dictionary    name    ${cm_device_group_name}    type    sync-failover
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response.text}

Add Device to CM Device Group
    [Documentation]    Adds a BIG-IP to a CM device group (syncs across trust-group members) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${cm_device_group_name}    ${cm_device_name}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device-group/~Common~${cm_device_group_name}/devices
    ${api_payload}    Create Dictionary    name    ${cm_device_name}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable CM Auto Sync
    [Documentation]    Enables auto-sync on peers in a DSC (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${cm_device_group_name}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device-group/~Common~${cm_device_group_name}/
    ${api_payload}    Create Dictionary    autoSync    enabled
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable CM Auto Sync
    [Documentation]    Disables auto-sync on peers in a DSC (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${cm_device_group_name}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device-group/~Common~${cm_device_group_name}/
    ${api_payload}    Create Dictionary    autoSync    disabled
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Manually Sync BIG-IP Configurations
    [Documentation]    Manually syncs the configuration between peers in a config-sync group (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${cm_device_group_name}
    ${api_uri}    Set Variable    /mgmt/tm/cm/config-sync
    ${api_payload}    Create Dictionary    command    run    utilCmdArgs    to-group ${cm_device_group_name}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Sleep    3s
    [Return]    ${api_response}

Move CM Device to New Hostname
    [Documentation]    Renames the local cm device (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${current_name}    ${target}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device
    ${api_payload}    Create Dictionary    command    mv    name    ${current_name}    target    ${target}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure CM Device Unicast Address
    [Documentation]    Configures the IP address used to contact the peer for initial certificate based auth configuration (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${device_name}    ${unicast_address}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device/~Common~${device_name}
    ${unicast_address_dict}    Create Dictionary    effectiveIp    ${unicast_address}    ip    ${unicast_address}
    ${api_payload}    Create Dictionary    unicast-address    ${unicast_address_dict}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure CM Device Mirror IP
    [Documentation]    Defines the IP address used for mirroring connections between a stateful device pair (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${device_name}    ${mirror_ip}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device/~Common~${device_name}
    ${api_payload}    Create Dictionary    mirrorIp    ${mirror_ip}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure CM Device Configsync IP
    [Documentation]    Configures the IP address used for configuration replication between pairs in a config-sync group (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-device-service-clustering-administration-13-1-0/5.html))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${device_name}    ${configsync_ip}
    ${api_uri}    Set Variable    /mgmt/tm/cm/device/~Common~${device_name}
    ${api_payload}    Create Dictionary    configsyncIp    ${configsync_ip}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

########
## gtm
########

Create BIG-IP DNS Listener
    [Documentation]    Configures a VIP for listening for DNS requests (https://support.f5.com/csp/article/K14510)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${address}    ${mask}    ${partition}=Common    ${ip-protocol}=udp
    ${api_uri}    Set Variable    /mgmt/tm/gtm/listener
    ${api_payload}    Create Dictionary    name=${name}    address=${address}    mask=${mask}    partition=${partition}    ipProtocol=${ip-protocol}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create a BIG-IP DNS Data Center
    [Documentation]    Creates a data center obect in BIG-IP DNS that specifies a geographic location of services (https://support.f5.com/csp/article/K13347)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${location}    ${description}=Created by Robot Framework    ${partition}=Common
    ${api_uri}    Set Variable    /mgmt/tm/gtm/datacenter
    ${api_payload}    Create Dictionary    name=${name}    location=${location}    description=${description}    partition=${partition}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create a BIG-IP DNS Server
    [Documentation]    Creates a BIG-IP DNS server object
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${datacenter}    ${expose-route-domains}=no    ${partition}=Common    ${description}=Created by Robot Framework    ${virtualServerDiscovery}=disabled    ${product}=bigip
    ${api_uri}    Set Variable    /mgmt/tm/gtm/server
    ${api_payload}    Create Dictionary    name=${name}    partition=${partition}    datacenter=${datacenter}    exposeRouteDomains=${expose-route-domains}    description=${description}    virtualServerDiscovery=${virtualServerDiscovery}    product=${product}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add Devices to a BIG-IP DNS Server
    [Documentation]    Adds a BIG-IP LTM to the BIG-IP DNS Configuration
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${server_name}    ${addresses}    ${partition}=Common
    ${api_uri}    Set Variable    /mgmt/tm/gtm/server/~${partition}~${server_name}/devices
    ${api_payload}    Create Dictionary    name=${name}    partition=${partition}    addresses=${addresses}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable BIG-IP DNS Synchronization
    [Documentation]    Enables BIG-IP DNS Synchronization Globally
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    Set Variable    /mgmt/tm/gtm/global-settings/general
    ${api_payload}    create dictionary    synchronization=yes
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable BIG-IP DNS Synchronization of Zone Files
    [Documentation]    Enables BIG-IP DNS Synchronization of Zone Files
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    Set Variable    /mgmt/tm/gtm/global-settings/general
    ${api_payload}    create dictionary    synchronize-zone-files=yes
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure BIG-IP DNS Synchronization Group Name
    [Documentation]    Configures the BIG-IP DNS Synchronization Group Name
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${sync_group_name}
    ${api_uri}    Set Variable    /mgmt/tm/gtm/global-settings/general
    ${api_payload}    create dictionary    synchronization-group-name=${DNS_SINGLE_ROUTE_DOMAIN_SYNC_GROUP_NAME}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

#############
## ltm node
#############

Create an LTM Node
    [Documentation]    Creates a node in LTM (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${address}    ${partition}=Common    ${route_domain_id}=0    ${connectionLimit}=0    ${dynamicRatio}=1   ${description}=Robot Framework  ${monitor}=default  ${rateLimit}=disabled
    ${api_payload}    create dictionary   name=${name}   address=${address}%${route_domain_id}    partition=${partition}    connectionLimit=${connectionLimit}   dynamicRatio=${dynamicRatio}    description=${description}  monitor=${monitor}  rateLimit=${rateLimit}
    ${api_uri}    set variable    /mgmt/tm/ltm/node
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

List LTM Node Configuration
    [Documentation]    Lists existing nodes in LTM (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}    ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Show LTM Node Statistics
    [Documentation]    Retrieves statistics for a single LTM node (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}    ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable an LTM Node
    [Documentation]    Enables an LTM node, which makes it available to all assigned pools (https://support.f5.com/csp/article/K13310)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}   ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    ${api_payload}    Create Dictionary    session=user-enabled
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable an LTM Node
    [Documentation]    Disables an LTM node; Nodes that have been disabled accept only new connections that match an existing persistence session (https://support.f5.com/csp/article/K13310)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}   ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    [Return]    ${api_response}

Mark an LTM Node as Down
    [Documentation]    Marks an LTM node as down; Nodes that have been forced offline do not accept any new connections, even if they match an existing persistence session (https://support.f5.com/csp/article/K13310)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}   ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    [Return]    ${api_response}

Mark an LTM Node as Up
    [Documentation]    Marks an LTM node as up (https://support.f5.com/csp/article/K13310)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}   ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    [Return]    ${api_response}

Verify an LTM Node Exists
    [Documentation]    Verifies that an LTM node has been created (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}    ${node_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_expected_response_dict}    create dictionary    kind=tm:ltm:node:nodestate    name=${node_name}    partition=${node_partition}
    ${api_response_dict}    to json    ${api_response.content}
    Dictionary should contain subdictionary    ${api_response_dict}    ${api_expected_response_dict}
    [Return]    ${api_response}

Delete an LTM Node
    [Documentation]    Deletes an LTM node (https://techdocs.f5.com/content/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${node_name}    ${node_partition}
    ${api_uri}    set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE
    Should be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Node Stats
    [Documentation]    Clears the statistics for all nodes  (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/ltm/node
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

#############
## ltm pool
#############

Create an LTM Pool
    [Documentation]    Creates a pool of servers in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/4.html#guid-c8d28345-0337-484e-ad92-cf3f21d638f1)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common    ${allowNat}=yes    ${allowSnat}=yes    ${ignorePersistedWeight}=disabled   ${loadBalancingMode}=round-robin    ${minActiveMembers}=${0}    ${minUpMembers}=${0}    ${minUpMembersAction}=failover  ${minUpMembersChecking}=disabled    ${queueDepthLimit}=${0}    ${queueOnConnectionLimit}=disabled    ${queueTimeLimit}=${0}  ${reselectTries}=${0}   ${serviceDownAction}=none   ${slowRampTime}=${10}   ${monitor}=none
    ${api_payload}    create dictionary   name=${name}    partition=${partition}  allowNat=${allowNat}    allowSnat=${allowSnat}    ignorePersistedWeight=${ignorePersistedWeight}  loadBalancingMode=${loadBalancingMode}    minActiveMembers=${minActiveMembers}  minUpMembers=${minUpMembers}    minUpMembersAction=${minUpMembersAction}    minUpMembersChecking=${minUpMembersChecking}    queueDepthLimit=${queueDepthLimit}  queueOnConnectionLimit=${queueOnConnectionLimit}    queueTimeLimit=${queueTimeLimit}    reselectTries=${reselectTries}  serviceDownAction=${serviceDownAction}    slowRampTime=${slowRampTime}    monitor=${monitor}
    ${api_uri}    set variable    /mgmt/tm/ltm/pool
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add an LTM Pool Member to a Pool
    [Documentation]    Adds a node to an existing pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/4.html#guid-c8d28345-0337-484e-ad92-cf3f21d638f1)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${port}    ${address}  ${pool_partition}=Common    ${pool_member_partition}=Common    ${route_domain_id}=0    ${connectionLimit}=${0}    ${dynamicRatio}=${1}    ${inheritProfile}=enabled   ${monitor}=default  ${priorityGroup}=${0}   ${rateLimit}=disabled   ${ratio}=${1}  ${session}=user-enabled    ${state}=user-up
    ${api_payload}    create dictionary   name=${pool_member_name}:${port}    address=${address}    partition=${pool_member_partition}    route_domain_id=${route_domain_id}  connectionLimit=${connectionLimit}  dynamicRatio=${dynamicRatio}    inheritProfile=${inheritProfile}    monitor=${monitor}    priorityGroup=${priorityGroup}    rateLimit=${rateLimit}  ratio=${ratio}  session=${session}    state=${state}
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable an LTM Pool Member
    [Documentation]    Enables a pool member in a particular pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/5.html#guid-ec0ade90-7b1b-4dfe-aa28-13b50071c34e)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${pool_partition}=Common    ${pool_member_partition}=Common
    ${api_payload}    Create Dictionary    session=user-enabled
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable an LTM Pool Member
    [Documentation]    Disables a pool member in a particular pool; the node itself remains available to other pools (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/5.html#guid-ec0ade90-7b1b-4dfe-aa28-13b50071c34e)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${pool_partition}=Common    ${pool_member_partition}=Common
    ${api_payload}    Create Dictionary    session=user-disabled
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Mark an LTM Pool Member as Down
    [Documentation]    Marks a pool member dowm in a particular pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/5.html#guid-ec0ade90-7b1b-4dfe-aa28-13b50071c34e)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${pool_partition}=Common    ${pool_member_partition}=Common
    ${api_payload}    Create Dictionary    state=user-down
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Mark an LTM Pool Member as Up
    [Documentation]    Marks a pool member up in a particular pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/5.html#guid-ec0ade90-7b1b-4dfe-aa28-13b50071c34e)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${pool_partition}=Common    ${pool_member_partition}=Common
    ${api_payload}    Create Dictionary    state=user-up
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Remove an LTM Pool Member from a Pool
    [Documentation]    Removes a single pool member from an existing pool (Marks a pool member dowm in a particular pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/4.html#guid-c8d28345-0337-484e-ad92-cf3f21d638f1))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${pool_member_name}    ${pool_partition}=Common    ${pool_member_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${pool_partition}~{pool_name}/members/~${pool_member_partition}~${pool_member_name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Delete an LTM Pool
    [Documentation]    Deletes an LTM pool, does not delete the node objects for each pool member (Marks a pool member dowm in a particular pool (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/4.html#guid-c8d28345-0337-484e-ad92-cf3f21d638f1))
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve All LTM Pool Statistics
    [Documentation]    Pulls the statistics for all pools (https://devcentral.f5.com/s/articles/getting-started-with-icontrol-working-with-statistics-20513)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve LTM Pool Statistics
    [Documentation]    Pulls the statistics for all LTM pools (https://devcentral.f5.com/s/articles/getting-started-with-icontrol-working-with-statistics-20513)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${partition}~${name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve LTM Pool Member Statistics
    [Documentation]    Pulls the statistics for a single pool member within an existing pool (https://devcentral.f5.com/s/articles/getting-started-with-icontrol-working-with-statistics-20513)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${pool_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/pool/~${partition}~${pool_name}/members/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Pool Stats
    [Documentation]    Clears the statistics for all pools (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/ltm/pool
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}


################
## ltm profile
################

Create a BIG-IP Client SSL Profile
    [Documentation]    Creates a client SSL profile in LTM (https://support.f5.com/csp/article/K14783)
    [Arguments]    ${bigip_host}   ${bigip_username}    ${bigip_password}    ${name}	 	${partition}=Common    ${alertTimeout}=indefinite	 	${allowDynamicRecordSizing}=disabled	 	${allowExpiredCrl}=disabled	 	${allowNonSsl}=disabled	 	${authenticate}=once	 	${authenticateDepth}=9	${cacheSize}=262144	${cacheTimeout}=3600	${cert}=/Common/default.crt	 	${certLifespan}=30	${certLookupByIpaddrPort}=disabled	 	${ciphers}=DEFAULT	 	${defaultsFrom}=/Common/clientssl	 	${forwardProxyBypassDefaultAction}=intercept	 	${genericAlert}=enabled	 	${handshakeTimeout}=10	 	${inheritCertkeychain}=true	 	${key}=/Common/default.key	 	${kind}=tm:ltm:profile:client-ssl:client-sslstate	 	${maxActiveHandshakes}=indefinite	 	${maxAggregateRenegotiationPerMinute}=indefinite	 	${maxRenegotiationsPerMinute}=5	${maximumRecordSize}=16384	${modSslMethods}=disabled	 	${mode}=enabled	 	${peerCertMode}=ignore	 	${peerNoRenegotiateTimeout}=10	 	${proxySsl}=disabled	 	${proxySslPassthrough}=disabled	 	${renegotiateMaxRecordDelay}=indefinite	 	${renegotiatePeriod}=indefinite	 	${renegotiateSize}=indefinite	 	${renegotiation}=enabled	 	${retainCertificate}=true	 	${secureRenegotiation}=require	 	${sessionMirroring}=disabled	 	${sessionTicket}=disabled	 	${sessionTicketTimeout}=0	${sniDefault}=false	 	${sniRequire}=false	 	${sslForwardProxy}=disabled	 	${sslForwardProxyBypass}=disabled	 	${sslSignHash}=any	 	${strictResume}=disabled	 	${uncleanShutdown}=enabled
    ${api_payload}    create dictionary   name=${name}    partition=${partition}  name=${name}    alertTimeout=${alertTimeout}    allowDynamicRecordSizing=${allowDynamicRecordSizing}    allowExpiredCrl=${allowExpiredCrl}    allowNonSsl=${allowNonSsl}    authenticate=${authenticate}    authenticateDepth=${authenticateDepth}    certLifespan=${certLifespan}    ciphers=${ciphers}    defaultsFrom=${defaultsFrom}    forwardProxyBypassDefaultAction=${forwardProxyBypassDefaultAction}    genericAlert=${genericAlert}    handshakeTimeout=${handshakeTimeout}    inheritCertkeychain=${inheritCertkeychain}    key=${key}    kind=${kind}    maxActiveHandshakes=${maxActiveHandshakes}    maxAggregateRenegotiationPerMinute=${maxAggregateRenegotiationPerMinute}    maxRenegotiationsPerMinute=${maxRenegotiationsPerMinute}    mode=${mode}    peerCertMode=${peerCertMode}    peerNoRenegotiateTimeout=${peerNoRenegotiateTimeout}    proxySsl=${proxySsl}    proxySslPassthrough=${proxySslPassthrough}    renegotiateMaxRecordDelay=${renegotiateMaxRecordDelay}    renegotiatePeriod=${renegotiatePeriod}    renegotiateSize=${renegotiateSize}    renegotiation=${renegotiation}    retainCertificate=${retainCertificate}    secureRenegotiation=${secureRenegotiation}    sessionMirroring=${sessionMirroring}    sessionTicket=${sessionTicket}    sessionTicketTimeout=${sessionTicketTimeout}    sniRequire=${sniRequire}    sslForwardProxy=${sslForwardProxy}    sslForwardProxyBypass=${sslForwardProxyBypass}    sslSignHash=${sslSignHash}    strictResume=${strictResume}    uncleanShutdown=${uncleanShutdown}
    set test variable   ${api_payload}
    ${api_uri}    set variable    /mgmt/tm/ltm/profile/client-ssl
    set test variable   ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

################
## ltm virtual
################

Reset Virtual Stats
    [Documentation]    Clears the statistics for a particular virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_payload}    Create Dictionary    command=reset-stats    name=${name}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Virtual Stats
    [Documentation]    Clears the statistics for all virtual servers (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM FastL4 Virtual Server
    [Documentation]    Creates a FastL4 virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=0.0.0.0\/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled    ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM FastL4 IPv6 Virtual Server
    [Documentation]    Creates a FastL4 virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=::/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled    ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM IP Forwarding Virtual Server
    [Documentation]    Creates an IP Forwarding virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=0.0.0.0\/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled   ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM IP Forwarding IPv6 Virtual Server
    [Documentation]    Creates an IP Forwarding virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=::/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled   ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM Standard Virtual Server
    [Documentation]    Creates a Standard virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=0.0.0.0\/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled   ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create an LTM Standard IPv6 Virtual Server
    [Documentation]    Creates a Standard virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${destination}    ${partition}=Common    ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}    ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any    ${source}=0.0.0.0\/0    ${sourcePort}=preserve    ${translateAddress}=disabled    ${translatePort}=disabled   ${pool}=none    ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    ${SourceAddressTranslation}    create dictionary    pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}    create dictionary    name=${name}    destination=${destination}    partition=${partition}    addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}    source=${source}    sourcePort=${sourcePort}    translateAddress=${translateAddress}    translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Delete an LTM Virtual Server
    [Documentation]    Deletes a virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add a Profile to an LTM Virtual Server
    [Documentation]    Adds a LTM profile to a virtual server in LTM (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-profiles-reference-13-1-0/1.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${profile_name}    ${virtual_server_name}    ${profile_partition}=Common    ${virtual_server_partition}=Common
    ${api_payload}    create dictionary
    [Return]    ${api_response}

Retrieve LTM Virtual Server Statistics
    [Documentation]    Pulls statistics on a specific virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve All LTM Virtual Servers Statistics
    [Documentation]    Pulls statistics on all virtual servers (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Get LTM Virtual Server Availability State
    [Documentation]    Pulls the current availability state on a specific virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${partition}~${name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${virtual_server_stats_dict}    to json    ${api_response.content}
    ${virtual_server_status}    get from dictionary    ${virtual_server_stats_dict}    entries
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    https:\/\/localhost\/mgmt\/tm\/ltm\/virtual\/~${partition}~${name}\/~${partition}~${name}\/stats
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    nestedStats
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    entries
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    status.availabilityState
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    description
    [return]    ${virtual_server_status}

Get LTM Virtual Server Enabled State
    [Documentation]    Pulls the current enabled state on a specific virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${partition}~${name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${virtual_server_stats_dict}    to json    ${api_response.content}
    ${virtual_server_status}    get from dictionary    ${virtual_server_stats_dict}    entries
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    https:\/\/localhost\/mgmt\/tm\/ltm\/virtual\/~${partition}~${name}\/~${partition}~${name}\/stats
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    nestedStats
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    entries
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    status.enabledState
    ${virtual_server_status}    get from dictionary    ${virtual_server_status}    description
    [return]    ${virtual_server_status}

Apply Firewall Policy to Virtual Server
    [Documentation]    Binds an existing firewall policy to a specific virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/big-ip-network-firewall-policies-and-implementations-14-1-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${virtual_name}    ${policy_partition}=Common    ${virtual_partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${virtual_partition}~${virtual_name}
    ${api_payload}    create dictionary    fwEnforcedPolicy=/${policy_partition}/${policy_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve the Firewall Policy Attached to a Virtual Server
    [Documentation]    Shows the firewall policy attached a particular virtual server (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/big-ip-network-firewall-policies-and-implementations-14-1-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${virtual_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual/~${partition}~${virtual_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

########################
## ltm virtual-address
########################

Configure Route Health Injection on a Virtual Address    
    [Documentation]    Requires address and route-advertisement parameters, partition and route_domain_id are optional. "address" is a IPv4 or IPv6 network. "route-advertisement" can be enabled or disabled.
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${address}    ${route-advertisement}    ${partition}=Common   ${route_domain_id}=0
    ${api_payload}    create dictionary    route-advertisement=${route-advertisement}
    ${api_uri}    set variable    /mgmt/tm/ltm/virtual-address/~${partition}~${address}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings  ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

##################
## net interface
##################

Reset Interface Stats
    [Documentation]    Resets interface counters on a particular interface (https://support.f5.com/csp/article/K3628)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_payload}    Create Dictionary    command=reset-stats    name=${name}
    ${api_uri}    set variable    /mgmt/tm/net/interface
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Interface Stats
    [Documentation]    Resets interface counters on all interfaces (https://support.f5.com/csp/article/K3628)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/net/interface
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable a BIG-IP physical interface
    [Documentation]    Enables a particular BIG-IP physical interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_payload}    create dictionary    kind=tm:net:interface:interfacestate    name=${interface_name}    enabled=${True}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    enabled    True
    [Return]    ${api_response}

Verify enabled state of BIG-IP physical interface
    [Documentation]    Verifies that a BIG-IP interface is enabled (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    enabled    True
    [Return]    ${api_response}

Verify up state of BIG-IP physical interface
    [Documentation]    Verifies that a physical interface is UP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${interface_stats_entries}    get from dictionary   ${api_response_dict}    entries
    ${interface_stats_dict}    get from dictionary   ${interface_stats_entries}   https://localhost/mgmt/tm/net/interface/${interface_name}/stats
    ${interface_stats_dict}    get from dictionary   ${interface_stats_dict}    nestedStats
    ${interface_stats_dict}    get from dictionary   ${interface_stats_dict}    entries
    ${interface_status_dict}    get from dictionary   ${interface_stats_dict}    status
    ${interface_status}    get from dictionary   ${interface_status_dict}    description
    ${interface_tmname}    get from dictionary   ${interface_stats_dict}    tmName
    ${interface_tmname}    get from dictionary   ${interface_tmname}    description
    should be equal as strings    ${interface_status}   enabled
    [Return]    ${api_response}

Disable a BIG-IP physical interface
    [Documentation]    Disables a BIG-IP physical interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_payload}    create dictionary    kind=tm:net:interface:interfacestate    name=${interface_name}    disabled=${True}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item    ${api_response_dict}    disabled    True
    [Return]    ${api_response}

Verify disabled state of BIG-IP physical interface
    [Documentation]    Verifies that a BIG-IP interface is disabled (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    disabled    True
    [Return]    ${api_response}

Verify down state of BIG-IP physical interface
    [Documentation]    Verifies that a BIG-IP interface is DOWN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${interface_stats_entries}    get from dictionary  ${api_response_dict}    entries
    ${interface_stats_dict}    get from dictionary  ${interface_stats_entries}    https://localhost/mgmt/tm/net/interface/${interface_name}/stats
    ${interface_stats_dict}    get from dictionary  ${interface_stats_dict}    nestedStats
    ${interface_stats_dict}    get from dictionary  ${interface_stats_dict}    entries
    ${interface_status_dict}    get from dictionary  ${interface_stats_dict}    status
    ${interface_status}    get from dictionary  ${interface_status_dict}    description
    ${interface_tmname}    get from dictionary  ${interface_stats_dict}    tmName
    ${interface_tmname}    get from dictionary  ${interface_tmname}    description
    should be equal as strings    ${interface_status}  disabled
    [Return]    ${api_response}

Configure BIG-IP Interface Description
    [Documentation]    Configures the description on a BIG-IP interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}    ${interface_description}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_payload}    create dictionary    description=${interface_description}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Set BIG-IP Interface LLDP to Transmit Only
    [Documentation]    Changes the LLDP mode on a single BIG-IP interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-implementations-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_payload}    create dictionary    lldpAdmin=txonly
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Set BIG-IP Interface LLDP to Receive Only
    [Documentation]    Changes the LLDP mode on a single BIG-IP interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-implementations-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_payload}    create dictionary    lldpAdmin=rxonly
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Set BIG-IP Interface LLDP to Transmit and Receive
    [Documentation]    Changes the LLDP mode on a single BIG-IP interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-implementations-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_payload}    create dictionary    lldpAdmin=txrx
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable BIG-IP LLDP on Interface
    [Documentation]    Changes the LLDP mode on a single BIG-IP interface (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-implementations-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_name}
    ${api_uri}    set variable    /mgmt/tm/net/interface/${interface_name}
    ${api_payload}    create dictionary    lldpAdmin=disable
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

List all BIG-IP Interfaces
    [Documentation]    Retrieves a list of all BIG-IP interfaces (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/net/interface
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${interface_list}    get from dictionary    ${api_response_dict}    items
    :FOR    ${current_interface}    IN  @{interface_list}
    \   ${interface_name}    get from dictionary    ${current_interface}    name
    \   ${interface_media_active}   get from dictionary    ${current_interface}    mediaActive
    \   ${interface_media_max}    get from dictionary    ${current_interface}    mediaMax
    \   log    Name: ${interface_name} Media Active: ${interface_media_active} Fastest Optic Supported: ${interface_media_max}
    [Return]    ${api_response}

Verify Interface Drop Counters on the BIG-IP
    [Documentation]    Verifies that interface drops are below a certain threshold (defaults to 1000) (https://support.f5.com/csp/article/K10191) Note that frames marked with a dot1q VLAN tag that is not configured on the BIG-IP will result in this counter incrementing with the "vlan unknown" status. See https://support.f5.com/csp/article/K10191.
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_drops_threshold}=1000
    ${api_uri}    set variable    /mgmt/tm/net/interface/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${interface_stats_entries}    get from dictionary    ${api_response_dict}    entries
    :FOR    ${current_interface}    IN  @{interface_stats_entries}
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_entries}    ${current_interface}
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_dict}    nestedStats
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_dict}    entries
    \   ${counters_drops_dict}    get from dictionary    ${interface_stats_dict}    counters.dropsAll
    \   ${counters_drops_count}    get from dictionary    ${counters_drops_dict}    value
    \   ${interface_tmname}    get from dictionary    ${interface_stats_dict}    tmName
    \   ${interface_tmname}    get from dictionary    ${interface_tmname}    description
    \   log    Interface ${interface_tmname} - Drops: ${counters_drops_count}
    \   should be true    ${counters_drops_count} < ${interface_drops_threshold}
    [Return]    ${api_response}

Verify Interface Error Counters on the BIG-IP
    [Documentation]    Verifies that interface errors are below a certain threshold (defaults to 1000) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${interface_errors_threshold}=1000
    ${api_uri}    set variable    /mgmt/tm/net/interface/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${interface_stats_entries}    get from dictionary    ${api_response_dict}    entries
    :FOR    ${current_interface}    IN  @{interface_stats_entries}
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_entries}    ${current_interface}
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_dict}    nestedStats
    \   ${interface_stats_dict}    get from dictionary    ${interface_stats_dict}    entries
    \   ${counters_errors_dict}    get from dictionary    ${interface_stats_dict}    counters.errorsAll
    \   ${counters_errors_count}    get from dictionary    ${counters_errors_dict}    value
    \   ${interface_tmname}    get from dictionary    ${interface_stats_dict}    tmName
    \   ${interface_tmname}    get from dictionary    ${interface_tmname}    description
    \   log    Interface ${interface_tmname} - Errors: ${counters_errors_count}
    \   should be true    ${counters_errors_count} < ${interface_errors_threshold}
    [Return]    ${api_response}

##############
## net route
##############

Create Static Route Configuration on the BIG-IP
    [Documentation]    Creates a static route on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}    ${cidr_network}    ${gateway}    ${description}
    ${api_payload}    create dictionary    name=${name}    network=${cidr_network}    gw=${gateway}   partition=${partition}  description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    [Return]    ${api_response}

Verify Static Route Configuration on the BIG-IP
    [Documentation]    Lists configured static routes on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}    ${cidr_network}    ${gateway}    ${description}
    ${verification_dict}    create dictionary    name=${name}    partition=${partition}    network=${cidr_network}    gw=${gateway}   description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to json    ${api_response.content}
    dictionary should contain sub dictionary    ${api_response_json}    ${verification_dict}
    [Return]    ${api_response}

Create Static Default Route Configuration on the BIG-IP
    [Documentation]    Creates a static default route on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${partition}    ${gateway}    ${description}
    ${api_payload}    create dictionary    name=default    gw=${gateway}   partition=${partition}  description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    [Return]    ${api_response}

Verify Static Default Route Configuration on the BIG-IP
    [Documentation]    Verifies the configuration of the static default route (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${partition}    ${gateway}    ${description}
    ${verification_dict}    create dictionary    name=default-inet6    partition=${partition}    gw=${gateway}   description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to json    ${api_response.content}
    dictionary should contain sub dictionary    ${api_response_json}    ${verification_dict}
    [Return]    ${api_response}

Create Static IPv6 Default Route Configuration on the BIG-IP
    [Documentation]    Creates a static default route for IPv6 (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${partition}    ${gateway}    ${description}
    ${api_payload}    create dictionary    name=default    gw=${gateway}   partition=${partition}  description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    [Return]    ${api_response}

Verify Static IPv6 Default Route Configuration on the BIG-IP
    [Documentation]    Verifies the configuration of the static default route for IPv6 (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${partition}    ${gateway}    ${description}
    ${verification_dict}    create dictionary    name=default-inet6    partition=${partition}    gw=${gateway}   description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to json    ${api_response.content}
    dictionary should contain sub dictionary    ${api_response_json}    ${verification_dict}
    [Return]    ${api_response}

Verify Static Route Presence in BIG-IP Route Table
    [Documentation]    Verifies that a route actually exists in the BIG-IP routing table (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}    ${cidr_network}    ${gateway}
    ${api_uri}    set variable    /mgmt/tm/net/route/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to json    ${api_response.content}
    ${route_table_entries}    get from dictionary    ${api_response_json}    entries
    log    ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}    set variable    https://localhost/mgmt/tm/net/route/~${partition}~${name}/stats
    list should contain value    ${route_table_entries}    ${selflink_name}
    [Return]    ${api_response}

Delete Static Route Configuration on the BIG-IP
    [Documentation]    Deletes a static route on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}
    ${api_uri}    set variable    /mgmt/tm/net/route/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify Static Route Deletion on the BIG-IP
    [Documentation]    Verifies that a static route does not exist on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}
    ${api_uri}    set variable    /mgmt/tm/net/route/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_NOT_FOUND}
    [Return]    ${api_response}

Verify Static Route Removal in BIG-IP Route Table
    [Documentation]    Verifies that a static route does not appear in the BIG-IP routing table (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${partition}
    ${api_uri}    set variable    /mgmt/tm/net/route/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    to json    ${api_response.content}
    ${route_table_entries}    get from dictionary    ${api_response_json}    entries
    log    ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}    set variable    https://localhost/mgmt/tm/net/route/~${partition}~${name}/stats
    list should not contain value   ${route_table_entries}    ${selflink_name}
    [Return]    ${api_response}

Display BIG-IP Static Route Configuration
    [Documentation]    Lists the static routes configured on the BIG-IP (https://support.f5.com/csp/article/K13833)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/net/route
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    log dictionary    ${api_response_json}
    [Return]    ${api_response}

#####################
## net route-domain
#####################

Create a Route Domain on the BIG-IP
    [Documentation]    Creates a route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${route_domain_id}    ${partition}=Common
    ${api_payload}    create dictionary    name=${route_domain_name}   id=${route_domain_id}   partition=${partition}
    ${api_uri}    set variable    /mgmt/tm/net/route-domain
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${verification_dict}    create dictionary    kind=tm:net:route-domain:route-domainstate    name=${route_domain_name}   partition=${partition}
    ${api_response_dict}    to json    ${api_response.text}
    dictionary should contain subdictionary    ${api_response_dict}    ${verification_dict}
    [Return]    ${api_response}

Add a Description to a BIG-IP Route Domain
    [Documentation]    Adds a description to an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${description}    ${partition}=Common
    ${api_payload}    create dictionary    description=${description}
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable BGP Only on BIG-IP Route Domain
    [Documentation]    Enables BGP on an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}    create list    BGP
    ${api_payload}    create dictionary    routingProtocol=${api_routing_protocol_list}
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Sleep    10s
    [Return]    ${api_response}

Enable BGP and BFD on BIG-IP Route Domain
    [Documentation]    Enables BGP and BFD on an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}    create list    BGP    BFD
    ${api_payload}    create dictionary    routingProtocol=${api_routing_protocol_list}
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Sleep    10s
    [Return]    ${api_response}

Disable Dynamic Routing on BIG-IP Route Domain
    [Documentation]    Disables all dynamic routing on an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${partition}=Common
    ${api_routing_protocol_list}    create list
    ${api_payload}    create dictionary    routingProtocol=${api_routing_protocol_list}
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Sleep    5s
    [Return]    ${api_response}

Enable Route Domain Strict Routing
    [Documentation]    Enables strict-routing on an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${partition}=Common
    ${api_payload}    create dictionary    strict=enabled
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable Route Domain Strict Routing
    [Documentation]    Disables strict-routing on an existing route domain (VRF) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${route_domain_name}    ${partition}=Common
    ${api_payload}    create dictionary    strict=disabled
    ${api_uri}    set variable    /mgmt/tm/net/route-domain/~${partition}~${route_domain_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

#############
## net self
#############

Reset Self-IP Stats
    [Documentation]    Resets the counters on a particular self-ip on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_payload}    Create Dictionary    command=reset-stats    name=${name}
    ${api_uri}    set variable    /mgmt/tm/net/self
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Self-IP Stats
    [Documentation]    Resets the counters on all self-ips on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/net/self
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create BIG-IP Non-floating Self IP Address
    [Documentation]    Creates a non-floating self-ip on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${vlan}    ${address}    ${partition}="Common"    ${allow-service}="none"    ${description}="Robot Framework"    ${traffic-group}="traffic-group-local-only"
    ${api_payload}    Create Dictionary   name=${name}    partition=${partition}  address=${address}  allowService=${allow-service}   trafficGroup=${traffic-group}   description=${description}  vlan=${vlan}
    ${api_uri}    set variable    /mgmt/tm/net/self
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create BIG-IP Floating Self IP Address
    [Documentation]    Creates a floating self-ip on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${vlan}    ${address}    ${partition}="Common"   ${allow-service}="none"    ${description}="Robot Framework"    ${traffic-group}="traffic-group-1"
    ${api_payload}    Create Dictionary   name=${name}    partition=${partition}  address=${address}  allowService=${allow-service}   trafficGroup=${traffic-group}   description=${description}  vlan=${vlan}
    ${api_uri}    set variable    /mgmt/tm/net/self
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify BIG-IP Non-floating Self IP Address
    [Documentation]    Verifies the configuration of a non-floating self-ip on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${address}    ${partition}="Common"
    ${api_uri}    set variable    /mgmt/tm/net/self/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify BIG-IP Floating Self IP Address
    [Documentation]    Verifies the configuration of a floating self-ip on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${address}    ${partition}="Common"
    ${api_uri}    set variable    /mgmt/tm/net/self/~${partition}~${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

##############
## net trunk
##############

Reset Trunk Stats
    [Documentation]    Resets statistics on a trunk in the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_payload}    Create Dictionary    command=reset-stats    name=${name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset All Trunk Stats
    [Documentation]    Resets statistics on all trunks in the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/net/trunk
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create BIG-IP Trunk    
    [Documentation]    Creates a trunk (port aggregation object) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk
    ${api_payload}    create dictionary    name=${name}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify BIG-IP Trunk Exists    
    [Documentation]    Verifies that a trunk (port aggregation object) exists on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${trunk_name_dict}    create dictionary    name=${name}
    dictionary should contain sub dictionary    ${api_response_dict}    ${trunk_name_dict}
    [Return]    ${api_response}

Delete BIG-IP Trunk
    [Documentation]    Deletes a trunk (port aggregation object) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Set Trunk Description
    [Documentation]    Configures a description on a trunk (port aggregation object) on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${trunk_name}    ${trunk_description}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_payload}    create dictionary    description=${trunk_description}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve BIG-IP Trunk Status and Statistics
    [Documentation]    Retrieve status and statistics for a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary    ${api_response_dict}    entries
    log    ${trunk_stats_dict}
    [Return]    ${api_response}

Verify BIG-IP Trunk is Up
    [Documentation]    Verify UP status on a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary    ${api_response_dict}    entries
    ${trunk_stats_status}    get from dictionary    ${trunk_stats_dict}    https:\/\/localhost\/mgmt\/tm\/net\/trunk\/${trunk_name}\/${trunk_name}\/stats
    ${trunk_stats_status}    get from dictionary    ${trunk_stats_status}    nestedStats
    ${trunk_stats_status}    get from dictionary    ${trunk_stats_status}    entries
    ${trunk_stats_status}    get from dictionary    ${trunk_stats_status}    status
    ${trunk_stats_status}    get from dictionary    ${trunk_stats_status}    description
    Should Be Equal As Strings    ${trunk_stats_status}    up
    [Return]    ${api_response}

Set BIG-IP Trunk Interface List
    [Documentation]    Assign multiple interfaces to a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface_list}
    ${physical_interface_list}    convert to list    ${physical_interface_list}
    ${api_payload}    create dictionary    interfaces    ${physical_interface_list}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

List BIG-IP Trunk Interface Configuration
    [Documentation]    Assign interfaces to a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add Interface to BIG-IP Trunk
    [Documentation]    Adds a single interface to a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface}
    log    Getting list of existing interfaces on trunk
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain key   ${api_response_dict}    interfaces
    ${initial_interface_list}    get from dictionary    ${api_response_dict}    interfaces
    ${initial_interface_list}    convert to list    ${initial_interface_list}
    ${initial_interface_list}    set test variable    ${initial_interface_list}
    log    Initial Interface List: ${initial_interface_list}
    log    Adding target interface to interface list
    ${physical_interface}    convert to list    ${physical_interface}
    list should not contain value   ${initial_interface_list}    ${physical_interface}
    ${new_interface_list}    set variable    ${initial_interface_list}
    append to list    ${initial_interface_list}    ${physical_interface}
    log    New interface list: ${initial_interface_list} ${new_interface_list}
    ${api_payload}    create dictionary    interfaces    ${new_interface_list}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Remove Interface from BIG-IP Trunk
    [Documentation]    Removes a single interface from a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface}
    log    Getting list of existing interfaces on trunk
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${initial_interface_list}    get from dictionary    ${api_response_dict}    interfaces
    ${initial_interface_list}    convert to list    ${initial_interface_list}
    ${initial_interface_list}    set test variable    ${initial_interface_list}
    log    Initial Interface List: ${initial_interface_list}
    log    Removing target interface from interface list
    ${physical_interface}    convert to list    ${physical_interface}
    list should contain value    ${initial_interface_list}    ${physical_interface}
    ${new_interface_list}    set variable    ${initial_interface_list}
    set test variable    ${new_interface_list}
    remove values from list    ${initial_interface_list}    ${physical_interface}
    log    New interface list: ${initial_interface_list} ${new_interface_list}
    ${api_payload}    create dictionary    interfaces    ${new_interface_list}
    ${api_uri}    /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify BIG-IP Trunk Interface Removal
    [Documentation]    Verifies removal of a single interface from a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface}
    log    Verifying removal of physical interface from BIG-IP trunk
    ${api_uri}    set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    log    ${api_response_dict}
    dictionary should not contain value    ${api_response_dict}    ${physical_interface}
    [Return]    ${api_response}

Verify BIG-IP Trunk Interface Addition
    [Documentation]    Verifies the addition of a single interface from a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface}
    log    Verifying addition of physical interface from BIG-IP trunk
    ${api_uri}    set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    log    ${api_response_dict}
    dictionary should contain value    ${api_response_dict}    ${physical_interface}
    [Return]    ${api_response}

Verify BIG-IP Trunk Interface List
    [Documentation]    Verifies the list of interfaces on a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${physical_interface_list}
    log    Verifying addition of physical interface from BIG-IP trunk
    ${api_uri}    set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${configured_interface_list}    get from dictionary    ${api_response_dict}    interfaces
    log    Full API response: ${api_response_dict}
    list should contain sub list    ${physical_interface_list}    ${configured_interface_list}
    list should contain sub list    ${configured_interface_list}    ${physical_interface_list}
    [Return]    ${api_response}

Verify Trunk Collision Counters on BIG-IP
    [Documentation]    Verifies there are no collisions on a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${trunk_collisions_threshold}=250
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary    ${api_response_dict}    entries
    ${trunk_stats_dict}    get from dictionary    ${trunk_stats_dict}    https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}    get from dictionary    ${trunk_stats_dict}    nestedStats
    ${trunk_stats_dict}    get from dictionary    ${trunk_stats_dict}    entries
    ${counters_collisions_dict}    get from dictionary    ${trunk_stats_dict}    counters.collisions
    ${counters_collisions_count}    get from dictionary    ${counters_collisions_dict}   value
    ${trunk_tmname}    get from dictionary    ${trunk_stats_dict}    tmName
    ${trunk_tmname}    get from dictionary    ${trunk_tmname}    description
    log    Trunk ${trunk_tmname} - Collisions: ${counters_collisions_count}
    should be true    ${counters_collisions_count} < ${trunk_collisions_threshold}
    [Return]    ${api_response}

Verify Trunk Drop Counters on BIG-IP
    [Documentation]    Verifies that trunk drops are below a certain threshold (defaults to 1000) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${trunk_dropsIn_threshold}=1000    ${trunk_dropsOut_threshold}=1000
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary   ${api_response_dict}    entries
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    nestedStats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    entries
    ${counters_dropsIn_dict}    get from dictionary   ${trunk_stats_dict}    counters.dropsIn
    ${counters_dropsIn_count}    get from dictionary   ${counters_dropsIn_dict}    value
    ${counters_dropsOut_dict}    get from dictionary   ${trunk_stats_dict}    counters.dropsOut
    ${counters_dropsOut_count}    get from dictionary   ${counters_dropsOut_dict}   value
    ${trunk_tmname}    get from dictionary   ${trunk_stats_dict}    tmName
    ${trunk_tmname}    get from dictionary   ${trunk_tmname}    description
    log    Trunk ${trunk_tmname} - Drops IN: ${counters_dropsIn_count}
    log    Trunk ${trunk_tmname} - Drops Out: ${counters_dropsOut_count}
    should be true    ${counters_dropsIn_count} < ${trunk_dropsIn_threshold}
    should be true    ${counters_dropsOut_count} < ${trunk_dropsOut_threshold}
    [Return]    ${api_response}

Verify Trunk Error Counters on BIG-IP
    [Documentation]    Verifies that trunk errors are below a certain threshold (defaults to 500 for both in and out thresholds) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}    ${trunk_errorsIn_threshold}=500    ${trunk_errorsOut_threshold}=500
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary   ${api_response_dict}    entries
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    nestedStats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    entries
    ${counters_errorsIn_dict}    get from dictionary   ${trunk_stats_dict}    counters.errorsIn
    ${counters_errorsIn_count}    get from dictionary   ${counters_errorsIn_dict}    value
    ${counters_errorsOut_dict}    get from dictionary   ${trunk_stats_dict}    counters.errorsOut
    ${counters_errorsOut_count}    get from dictionary   ${counters_errorsOut_dict}   value
    ${trunk_tmname}    get from dictionary   ${trunk_stats_dict}    tmName
    ${trunk_tmname}    get from dictionary   ${trunk_tmname}    description
    log    Trunk ${trunk_tmname} - Errors In: ${counters_errorsIn_count}
    log    Trunk ${trunk_tmname} - Errors Out: ${counters_errorsOut_count}
    should be true    ${counters_errorsIn_count} < ${trunk_errorsIn_threshold}
    should be true    ${counters_errorsOut_count} < ${trunk_errorsOut_threshold}
    [Return]    ${api_response}

Get BIG-IP Trunk bitsIn Value
    [Documentation]    Retrieve the "bits in" counter on a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary   ${api_response_dict}    entries
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    nestedStats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    entries
    ${counters_bitsIn_dict}    get from dictionary   ${trunk_stats_dict}    counters.bitsIn
    ${counters_bitsIn_count}    get from dictionary   ${counters_bitsIn_dict}    value
    ${trunk_tmname}    get from dictionary   ${trunk_stats_dict}    tmName
    ${trunk_tmname}    get from dictionary   ${trunk_tmname}    description
    log    Trunk ${trunk_tmname} - Bits In Counter: ${counters_bitsIn_count}
    [Return]    ${api_response}

Get BIG-IP Trunk bitsOut Value
    [Documentation]    Retrieve the "bits out" counter on a BIG-IP trunk (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-0-0/3.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${trunk_name}
    ${api_uri}    set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}    get from dictionary   ${api_response_dict}    entries
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    nestedStats
    ${trunk_stats_dict}    get from dictionary   ${trunk_stats_dict}    entries
    ${counters_bitsOut_dict}    get from dictionary   ${trunk_stats_dict}    counters.bitsOut
    ${counters_bitsOut_count}    get from dictionary   ${counters_bitsOut_dict}    value
    ${trunk_tmname}    get from dictionary   ${trunk_stats_dict}    tmName
    ${trunk_tmname}    get from dictionary   ${trunk_tmname}    description
    log    Trunk ${trunk_tmname} - Bits Out Counter: ${counters_bitsOut_count}
    [Return]    ${api_response}

#############
## net vlan
#############

Get Current List of Interfaces Mapped to VLAN
    [Documentation]    Retrieves a list of interfaces/trunks to which a VLAN is mapped (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/${vlan_name}/interfaces
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    Dictionary Should Contain Key   ${api_response_dict}    interfaces
    ${initial_interface_list}    get from dictionary    ${api_response_dict}    interfaces
    ${initial_interface_list}    convert to list    ${initial_interface_list}
    log    Initial Interface List: ${initial_interface_list}
    set global variable    ${initial_interface_list}
    [Return]    ${api_response}

Create A Vlan on the BIG-IP
    [Documentation]    Creates a VLAN on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${vlan_tag}   ${partition}=Common
    ${api_payload}    Create Dictionary    name    ${vlan_name}   tag  ${vlan_tag}    partition=${partition}
    ${api_uri}    set variable    /mgmt/tm/net/vlan
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable dot1q Tagging on a BIG-IP VLAN Interface
    [Documentation]    Enables dot1q tagging on an interface tied to a VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${interface_name}    ${partition}=Common
    ${api_payload}    create dictionary   tagged=${true}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}/interfaces/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify dot1q Tagging Enabled on BIG-IP Vlan Interface
    [Documentation]    Verifies dot1q tagging on an interface tied to a VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${interface_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}/interfaces/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item    ${api_response_dict}    tagged    True
    [Return]    ${api_response}

Modify VLAN Mapping on BIG-IP VLAN
    [Documentation]    Maps a VLAN to an interface or list of interfaces (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${vlan_interface_list}    ${partition}=Common
    ${api_payload}    Create Dictionary    interfaces=${vlan_interface_list}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Modify MTU on BIG-IP VLAN
    [Documentation]    Modifies the MTU on a BIG-IP VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${vlan_mtu}    ${partition}=Common
    ${api_payload}    Create Dictionary    mtu    ${vlan_mtu}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify MTU on BIG-IP VLAN
    [Documentation]    Verifies the MTU configured on a BIG-IP VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${vlan_mtu}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:vlan:vlanstate
    dictionary should contain item  ${api_response_dict}    mtu    ${vlan_mtu}
    dictionary should contain item  ${api_response_dict}    name    ${vlan_name}
    [Return]    ${api_response}

Verify dot1q Tag on BIG-IP VLAN
    [Documentation]    Verifies the dot1q tag configured for a VLAN on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${vlan_tag}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:vlan:vlanstate
    dictionary should contain item  ${api_response_dict}    tag    ${vlan_tag}
    dictionary should contain item  ${api_response_dict}    name    ${vlan_name}
    [Return]    ${api_response}

Verify VLAN Mapping on a BIG-IP VLAN
    [Documentation]    Verifies if a single interface (physical or trunk) is mapped to a VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}    ${interface_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan_name}/interfaces/${interface_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:vlan:interfaces:interfacesstate
    dictionary should contain item  ${api_response_dict}    name    ${interface_name}
    [Return]    ${api_response}

Configure VLAN Failsale on BIG-IP
    [Documentation]    Sets the state and parameters of VLAN failsfe on a BIG-IP VLAN (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-system-essentials-13-1-0/9.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan}    ${partition}=Common   ${failsafe}=disabled   ${failsafe-action}=failover   ${failsafe-timeout}=60
    ${api_payload}    create dictionary    failsafe=${failsafe}    failsafeAction=${failsafe-action}    failsafeTimeout=${failsafe-timeout}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/~${partition}~${vlan}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    dictionary should contain item  ${api_response_dict}    name    ${vlan}
    dictionary should contain item  ${api_response_dict}    partition    ${partition}
    dictionary should contain item  ${api_response_dict}    failsafe    ${failsafe}
    dictionary should contain item  ${api_response_dict}    failsafeAction    ${failsafe-action}
    dictionary should contain item  ${api_response_dict}    failsafeTimeout    ${failsafe-timeout}
    [Return]    ${api_response}

Delete a BIG-IP VLAN
    [Documentation]    Deletes a VLAN from the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-13-1-0/5.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${vlan_name}
    ${api_uri}    set variable    /mgmt/tm/net/vlan/${vlan_name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}  api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

######################
## security firewall
######################

Create Firewall Policy
    [Documentation]    Creates a new blank firewall policy on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/policy
    ${api_payload}    create dictionary    name=${policy_name}    partition=${partition}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify Firewall Policy Exists
    [Documentation]    Verifies if a firewall policy exists on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/policy/~${partition}~${policy_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create Firewall Port List
    [Documentation]    Creates a firewall port list on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${port_list_name}    ${port_list}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/port-list
    ${api_payload}    create dictionary    name=${port_list_name}    partition=${partition}    ports=${port_list}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve Firewall Port List
    [Documentation]    Retrieves a firewall port list from the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${port_list_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/port-list/~${partition}~${port_list_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create Firewall Address List
    [Documentation]    Creates a firewall address list on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${address_list_name}    ${address_list}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/address-list
    ${api_payload}    create dictionary    name=${address_list_name}    partition=${partition}    addresses=${address_list}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve Firewall Address List
    [Documentation]    Retrieves a firewall address list from the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${address_list_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/address-list/~${partition}~${address_list_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add Rule to Firewall Policy
    [Documentation]    Creates a new rule in an AFM firewall policy (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${rule}    ${partition}=Common
    ${rule}    to json    ${rule}
    ${api_uri}    set variable    /mgmt/tm/security/firewall/policy/~${partition}~${policy_name}/rules
    ${api_payload}    set variable    ${rule}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve Firewall Rule from Policy
    [Documentation]    Retrieves a rule from an AFM firewall policy (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/network-firewall-policies-implementations-13-0-0.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${rule_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/policy/~${partition}~${policy_name}/rules/${rule_name}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve Firewall Policy Stats
    [Documentation]    Retrieve hit counters for a firewall policy (https://support.f5.com/csp/article/K00842042)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${policy_name}    ${partition}=Common
    ${api_uri}    set variable    /mgmt/tm/security/firewall/policy/~${partition}~${policy_name}/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

###############
## sys config
###############

Save the BIG-IP Configuration
    [Documentation]    Writes the BIG-IP configuration to disk (https://support.f5.com/csp/article/K50710744)
    [Arguments]    ${bigip_host}   ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    command    save
    ${api_uri}    set variable    /mgmt/tm/sys/config
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}


Load the BIG-IP Default Configuration
    [Documentation]    Loads the factory default configuration to a BIG-IP (https://support.f5.com/csp/article/K50710744)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    command=load    name=default
    ${api_uri}    set variable    /mgmt/tm/sys/config
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

############
## sys cpu
############

Retrieve CPU Statistics
    [Documentation]    Retrieves CPU utilization statistics on the BIG-IP (https://support.f5.com/csp/article/K15468)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/cpu
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

#################
## sys failover
#################

Send a BIG-IP to Standby
    [Documentation]    Sends an active BIG-IP to standby; must be executed on active member (https://support.f5.com/csp/article/K48900343)
    ...   Warning! The Force to Standby feature should not be used when the HA group feature is enabled! (https://support.f5.com/csp/article/K14515)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    kind=tm:sys:failover:runstate    command=run    standby=${true}
    ${api_uri}    set variable    /mgmt/tm/sys/failover
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Take a BIG-IP Offline
    [Documentation]    Instructs a BIG-IP HA member to stop participating in clustering (https://support.f5.com/csp/article/K15122)
    [Arguments]    ${bigip_host}    ${bipip_username}    ${bigip_password}
    ${api_payload}    create dictionary    kind=tm:sys:failover:runstate    command=run    offline=${true}
    set test variable    ${api_payload}
    ${api_uri}    set variable    /mgmt/tm/sys/failover
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Place a BIG-IP Online
    [Documentation]    Instructs a BIG-IP HA member to resume participation in clustering (https://support.f5.com/csp/article/K15122)
    [Arguments]    ${bigip_host}    ${bipip_username}    ${bigip_password}
    ${api_payload}    create dictionary    kind=tm:sys:failover:runstate    command=run    online=${true}
    set test variable    ${api_payload}
    ${api_uri}    set variable    /mgmt/tm/sys/failover
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Send a BIG-IP to Standby for a Traffic Group
    [Documentation]    Forces the active unit in a HA cluster to standby only for a certain traffic group (https://support.f5.com/csp/article/K48900343)
    [Arguments]    ${bigip_host}    ${bipip_username}    ${bigip_password}    ${traffic-group}
    ${api_payload}    create dictionary    kind=tm:sys:failover:runstate    command=run    standby=${true}    trafficGroup=${traffic_group}
    ${api_uri}    set variable    /mgmt/tm/sys/failover
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

########################
## sys global-settings
########################

Disable BIG-IP Management Interface DHCP
    [Documentation]    Disables DHCP on the BIG-IP's mgmt port (https://support.f5.com/csp/article/K14298)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    mgmtDhcp    disabled
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable BIG-IP Management Interface DHCP
    [Documentation]    Enables DHCP on the BIG-IP's mgmt port (https://support.f5.com/csp/article/K14298)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    mgmtDhcp    enabled
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure BIG-IP Hostname
    [Documentation]    Sets the hostname on the BIG-IP, must include a domain in hostname.domain format (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${hostname}
    ${api_payload}    create dictionary    hostname    ${hostname}
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Retrieve BIG-IP Hostname
    [Documentation]    Retrieves the hostname on the BIG-IP (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.text}
    ${configured_hostname}    get from dictionary    ${api_response_dict}    hostname
    [Return]    ${configured_hostname}

Disable BIG-IP GUI Setup Wizard
    [Documentation]    Disables the Setup Wizard in the UI (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    guiSetup    disabled
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Enable BIG-IP GUI Setup Wizard
    [Documentation]    Enables the Setup Wizard in the UI (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    guiSetup    enabled
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Disable Console Inactivity Timeout on BIG-IP
    [Documentation]    Disables the console port timeout on the BIG-IP (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    consoleInactivityTimeout    ${0}
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Configure Console Inactivity Timeout on BIG-IP
    [Documentation]    Sets the console port timeout on the BIG-IP (https://support.f5.com/csp/article/K13369)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${console_timeout}
    ${api_payload}    create dictionary    consoleInactivityTimeout    ${console_timeout}
    ${api_uri}    set variable    /mgmt/tm/sys/global-settings
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

############
## sys ntp
############

Configure NTP Server List
    [Documentation]    Declaratively sets the list of NTP servers on a BIG-IP (https://support.f5.com/csp/article/K13380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${ntp_server_list}
    ${ntp_server_list_payload}    to json    ${ntp_server_list}
    ${api_payload}    create dictionary    servers    ${ntp_server_list_payload}
    ${api_uri}    set variable    /mgmt/tm/sys/ntp
    ${api_response}    BIG-IP iControl BasicAuth PATCH  bigip_host=${bigip_host}    bigip_username=${bigip_username}   bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Query NTP Server List
    [Documentation]    Retrieves a list of configured NTP servers on the BIG-IP (https://support.f5.com/csp/article/K13380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/ntp
    ${api_response}    BIG-IP iControl BasicAuth GET   bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    ${ntp_servers_configured}    Get from Dictionary    ${api_response_json}    servers
    ${ntp_servers_configured}    Convert to List    ${ntp_servers_configured}
    List Should Not Contain Duplicates    ${ntp_servers_configured}
    [Return]    ${ntp_servers_configured}

Verify NTP Server Associations
    [Documentation]    Verifies that all configured NTP servers are synced (https://support.f5.com/csp/article/K13380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command    run    utilCmdArgs    -c \'ntpq -pn\'
    ${api_uri}    set variable    /mgmt/tm/util/bash
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}  bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_json}    To Json    ${api_response.content}
    ${ntpq_output}    Get from Dictionary    ${api_response_json}    commandResult
    ${ntpq_output_start}    Set Variable    ${ntpq_output.find("===\n")}
    ${ntpq_output_clean}    Set Variable    ${ntpq_output[${ntpq_output_start}+4:]}
    ${ntpq_output_values_list}    Split String    ${ntpq_output_clean}
    ${ntpq_output_length}    get length    ${ntpq_output_values_list}
    ${ntpq_output_server_count}    evaluate    ${ntpq_output_length} / 10 + 1
    :FOR    ${current_ntp_server}  IN RANGE    1   ${ntpq_output_server_count}
    \   ${ntp_server_ip}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_reference}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_stratum}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_type}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_when}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_poll}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_reach}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_delay}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_offset}    remove from list    ${ntpq_output_values_list}  0
    \   ${ntp_server_jitter}    remove from list    ${ntpq_output_values_list}  0
    \   log    NTP server status: IP: ${ntp_server_ip} Reference IP: ${ntp_server_reference} Stratum: ${ntp_server_stratum} Type: ${ntp_server_type} Last Poll: ${ntp_server_when} Poll Interval: ${ntp_server_poll} Successes: ${ntp_server_reach} Delay: ${ntp_server_delay} Offset: ${ntp_server_offset} Jitter: ${ntp_server_jitter}
    should not be equal as integers    ${ntp_server_reach}    0
    should not be equal as strings    ${ntp_server_when}    -
    should not be equal as strings    ${ntp_server_reference}    .STEP.
    should not be equal as strings    ${ntp_server_reference}    .LOCL.
    [Return]    ${api_response}

Delete NTP Server Configuration
    [Documentation]    Deletes all NTP servers from a BIG-IP (https://support.f5.com/csp/article/K13380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${empty_list}    Create List
    ${api_payload}    Create Dictionary    servers=${empty_list}
    ${api_uri}    set variable    /mgmt/tm/sys/ntp
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

####################
## sys performance
####################

Retrieve All BIG-IP Performance Statistics
    [Documentation]    Retrieves all of the BIG-IP statistics (CPU, Memory, Throughput, Connections) - See relevant related keyword for documentation
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/all-stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance Connection Statistics
    [Documentation]    Retrieves connection and connections-per-second statistics (https://support.f5.com/csp/article/K14174)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/connections
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance DNS Express Statistics
    [Documentation]    Retrieves statistics on BIG-IP DNS Express (https://support.f5.com/csp/article/K14510)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/dnsexpress
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance DNSSEC Statistics
    [Documentation]    Shows DNSSEC performance statistics (https://support.f5.com/csp/article/K14510)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/dnssec
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance RAM Cache Statistics
    [Documentation]    Retrieves statistics on the BIG-IP's RAM cache usage (https://support.f5.com/csp/article/K13244)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/ramcache
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance System Statistics
    [Documentation]    Retrieves the BIG-IP CPU and Memory utilization (https://support.f5.com/csp/article/K16419)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/system
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Retrieve BIG-IP Performance Throughput Statistics
    [Documentation]    Retrieves the BIG-IP throughput statistics (https://support.f5.com/csp/article/K50309321)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/performance/throughput
    set test variable    ${api_uri}
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Teardown]    Run Keywords   Delete All Sessions
    [Return]    ${api_response}

Reset All Performance Stats
    [Documentation]    Clears all of the performance stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/all-stats
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance Throughput Stats
    [Documentation]    Clears the performance throughput stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/throughput
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance System Stats
    [Documentation]    Clears the performance system stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/system
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance Ramcache Stats
    [Documentation]    Clears the performance ramcache stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/ramcache
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance DNSSEC Stats
    [Documentation]    Clears the performance DNSSEC stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/dnssec
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance DNS Express Stats
    [Documentation]    Clears the performance DNS Express stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/dnsexpress
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset Performance Connection Stats
    [Documentation]    Clears the performance connection stats (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm-basics-13-0-0/2.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    Create Dictionary    command=reset-stats
    ${api_uri}    set variable    /mgmt/tm/sys/performance/connection
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

##################
## sys provision
##################

Provision AFM Module on the BIG-IP
    [Documentation]    Sets the provisioning level of AFM on the BIG-IP (https://support.f5.com/csp/article/K12111)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${provisioning_level}
    ${api_payload}    create dictionary    level=${provisioning_level}
    ${api_uri}    set variable    /mgmt/tm/sys/provision/afm
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Provision GTM Module on the BIG-IP
    [Documentation]    Sets the provisioning level of GTM on the BIG-IP (https://support.f5.com/csp/article/K12111)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${provisioning_level}
    ${api_payload}    create dictionary    level=${provisioning_level}
    ${api_uri}    set variable    /mgmt/tm/sys/provision/gtm
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify AFM is Provisioned
    [Documentation]    Verifies that AFM is provisioned on the BIG-IP (https://support.f5.com/csp/article/K12111)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/provision/afm
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    should not contain    ${api_response.text}    "level":"none"
    [Return]    ${api_response}

Verify GTM is Provisioned
    [Documentation]    Verifies that GTM is provisioned on the BIG-IP (https://support.f5.com/csp/article/K12111)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/provision/gtm
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    should not contain    ${api_response.text}    "level":"none"
    [Return]    ${api_response}

##############
## sys ready  
##############

Verify All BIG-IP Ready States
    [Documentation]    Verifies that the BIG-IP is ready in configuration, license and provisioning state - used by bigip_wait in Ansible (https://clouddocs.f5.com/products/orchestration/ansible/devel/modules/bigip_wait_module.html)    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/ready    
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    To Json    ${api_response.content}
    ${ready_states}    get from dictionary    ${api_response_dict}    entries
    ${ready_states}    get from dictionary    ${ready_states}    https://localhost/mgmt/tm/sys/ready/0
    ${ready_states}    get from dictionary    ${ready_states}    nestedStats
    ${ready_states}    get from dictionary    ${ready_states}    entries
    ${config_ready_state}    get from dictionary    ${ready_states}    configReady
    ${config_ready_state}    get from dictionary    ${config_ready_state}    description
    ${license_ready_state}    get from dictionary    ${ready_states}    licenseReady
    ${license_ready_state}    get from dictionary    ${license_ready_state}    description
    ${provision_ready_state}    get from dictionary    ${ready_states}    provisionReady
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    description
    ${ready_state_value}    set variable    yes
    should be equal as strings    ${ready_state_value}    ${config_ready_state}
    should be equal as strings    ${ready_state_value}    ${license_ready_state}
    should be equal as strings    ${ready_state_value}    ${provision_ready_state}
    [Return]    ${ready_states}
    
Verify BIG-IP Configuration Ready State
    [Documentation]    Verifies that the BIG-IP is in a "configuration loaded" state - used by bigip_wait in Ansible (https://clouddocs.f5.com/products/orchestration/ansible/devel/modules/bigip_wait_module.html)    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/ready    
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    To Json    ${api_response.content}
    ${config_ready_state}    get from dictionary    ${api_response_dict}    entries
    ${config_ready_state}    get from dictionary    ${config_ready_state}    https://localhost/mgmt/tm/sys/ready/0
    ${config_ready_state}    get from dictionary    ${config_ready_state}    nestedStats
    ${config_ready_state}    get from dictionary    ${config_ready_state}    entries
    ${config_ready_state}    get from dictionary    ${config_ready_state}    configReady
    ${config_ready_state}    get from dictionary    ${config_ready_state}    description
    ${ready_state_value}    set variable    yes
    should be equal as strings    ${ready_state_value}    ${config_ready_state}
    [Return]    ${config_ready_state}

Verify BIG-IP License Ready State
    [Documentation]    Verifies that the BIG-IP is in a licensed state - used by bigip_wait in Ansible (https://clouddocs.f5.com/products/orchestration/ansible/devel/modules/bigip_wait_module.html)    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/ready    
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    To Json    ${api_response.content}
    ${license_ready_state}    get from dictionary    ${api_response_dict}    entries
    ${license_ready_state}    get from dictionary    ${license_ready_state}    https://localhost/mgmt/tm/sys/ready/0
    ${license_ready_state}    get from dictionary    ${license_ready_state}    nestedStats
    ${license_ready_state}    get from dictionary    ${license_ready_state}    entries
    ${license_ready_state}    get from dictionary    ${license_ready_state}    licenseReady
    ${license_ready_state}    get from dictionary    ${license_ready_state}    description
    ${ready_state_value}    set variable    yes
    should be equal as strings    ${ready_state_value}    ${license_ready_state}
    [Return]    ${license_ready_state}

Verify BIG-IP Provision Ready State
    [Documentation]    Verifies that the BIG-IP is in a state where any provisioning tasks are complete - used by bigip_wait in Ansible (https://clouddocs.f5.com/products/orchestration/ansible/devel/modules/bigip_wait_module.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/ready    
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    To Json    ${api_response.content}
    ${provision_ready_state}    get from dictionary    ${api_response_dict}    entries
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    https://localhost/mgmt/tm/sys/ready/0
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    nestedStats
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    entries
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    provisionReady
    ${provision_ready_state}    get from dictionary    ${provision_ready_state}    description
    ${ready_state_value}    set variable    yes
    should be equal as strings    ${ready_state_value}    ${provision_ready_state}
    [Return]    ${provision_ready_state}

############
## sys scf
############

Save an SCF on the BIG-IP
    [Documentation]    Saves a Single Configuration File (SCF) on the BIG-IP (https://support.f5.com/csp/article/K13408)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${scf_filename}
    ${options_dict}    create dictionary    file=${SCF_FILENAME}    no-passphrase=
    ${options_list}    create list    ${options_dict}
    ${api_payload}    create dictionary    command=save    options=${options_list}
    ${api_uri}    set variable    /mgmt/tm/sys/config
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Return]    ${api_response}

Load an SCF on the BIG-IP
    [Documentation]    Loads a Single Configuration File (SCF) on the BIG-IP (https://support.f5.com/csp/article/K13408)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}   ${scf_filename}
    ${options_dict}    create dictionary    file=${SCF_FILENAME}    no-passphrase=
    ${options_list}    create list    ${options_dict}
    ${api_payload}    create dictionary    command=load    options=${options_list}
    ${api_uri}    set variable    /mgmt/tm/sys/config
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Return]    ${api_response}

################
## sys service
################

Check for BIG-IP Services Waiting to Restart
    [Documentation]    Checks the daemons on the BIG-IP to see if any are awaiting tmm to release a running semaphore (https://support.f5.com/csp/article/K05645522)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/service/stats
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Should Not Contain    ${api_response.text}    waiting for tmm to release running semaphore
    [Return]    ${api_response}

#############
## sys snmp
#############

Create BIG-IP SNMP Community
    [Documentation]    Creates an SNMP community on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-13-0-0/13.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${communityName}    ${access}=ro    ${ipv6}=disabled    ${description}=
    ${api_payload}    Create Dictionary   access=${access}    communityName=${communityName}    ipv6=${ipv6}   description=${description}    name=${name}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp/communities
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Create SNMPv3 User
    [Documentation]    Creates an SNMPv3 User on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-13-0-0/13.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}    ${username}    ${authProtocol}    ${privacyProtocol}    ${authPassword}   ${privacyPassword}    ${securityLevel}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp/users
    ${api_payload}    create dictionary    name=${name}    username=${username}    authProtocol=${authProtocol}   privacyProtocol=${privacyProtocol}    authPassword=${authPassword}   privacyPassword=${privacyPassword}    securityLevel=${securityLevel}
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Delete SNMP Community
    [Documentation]    Deletes an SNMP community on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-13-0-0/13.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${name}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp/communities/${name}
    ${api_response}    BIG-IP iControl BasicAuth DELETE    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Remove Host from BIG-IP SNMP Allow-List
    [Documentation]    Adds a host to the BIG-IP SNMP allow ACL (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-13-0-0/13.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmphost}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${snmp-allow-list}    evaluate    json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}    Get from Dictionary    ${snmp-allow-list}    allowedAddresses
    Log    Pre-modification SNMP allow list: ${snmp-allow-list}
    Remove from List    ${snmp-allow-list}    ${snmphost}
    Log    Post-modification SNMP allow list: ${snmp-allow-list}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp
    ${api_payload}    Create Dictionary    allowedAddresses=${snmp-allow-list}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Add Host to BIG-IP SNMP Allow-List
    [Documentation]    Adds the IP address or subnet to the SNMP allowed hosts list (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-external-monitoring-implementations-13-0-0/13.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmphost}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${snmp-allow-list}    evaluate    json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}    Get from Dictionary    ${snmp-allow-list}    allowedAddresses
    Append to List    ${snmp-allow-list}    ${snmphost}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp
    ${api_payload}    Create Dictionary    allowedAddresses=${snmp-allow-list}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Get SNMPv2 IPv4 sysDescr
    [Documentation]    Gathers the response of the sysDescr field to test SNMPv2 connectivity on the BIG-IP (https://support.f5.com/csp/article/K13322)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmphost}    ${snmpcommunity}    ${snmpv2_port}    ${snmpv2_timeout}    ${snmpv2_retries}
    ${connect_status}    Open Snmp Connection    host=${snmphost}    community_string=${snmpcommunity}   port=${snmpv2_port}    timeout=${snmpv2_timeout}    retries=${snmpv2_retries}
    Log    SNMP Connect Status: ${connect_status}
    ${snmp_ipv4_sysDescr} =    Get Display String    .iso.3.6.1.2.1.1.5
    Log    SNMP value for OID .iso.3.6.1.2.1.1.5 returned: ${snmp_ipv4_sysDescr}
    [Teardown]    Close All Snmp Connections
    [Return]    ${snmp_ipv4_sysDescr}

Get SNMPv3 IPv4 sysDescr
    [Documentation]    Gathers the response of the sysDescr field to test SNMPv3 connectivity on the BIG-IP (https://support.f5.com/csp/article/K13322)
    [Arguments]    ${snmphost}    ${snmpv3_user}    ${snmpv3_auth_pass}    ${snmpv3_priv_pass}    ${snmpv3_auth_proto}    ${snmpv3_priv_proto}    ${snmpv3_port}    ${snmpv3_timeout}   ${snmpv3_retries}
    ${connect_status}    Open Snmp V3 Connection    ${snmphost}    ${snmpv3_user}    ${snmpv3_auth_pass}    ${snmpv3_priv_pass}    ${snmpv3_auth_proto}    ${snmpv3_priv_proto}    ${snmpv3_port}    ${snmpv3_timeout}   ${snmpv3_retries}
    Log    SNMP Connect Status: ${connect_status}
    ${snmp_ipv4_sysDescr} =    Get Display String    .iso.3.6.1.2.1.1.5
    Log    SNMP value for OID .iso.3.6.1.2.1.1.5 returned: ${snmp_ipv4_sysDescr}
    [Teardown]    Close All Snmp Connections
    [Return]    ${snmp_ipv4_sysDescr}

Create BIG-IP SNMPv2 Trap Destination
    [Documentation]    Creates an SNMPv2 trap destination on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/dos-firewall-implementations-13-1-0/8.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmphost}
    ${api_payload}    to json    ${snmphost}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Trigger an SNMPv2 Trap on the BIG-IP
    [Documentation]    Triggers an SNMP trap from the syslog-ng utility on the BIG-IP (https://support.f5.com/csp/article/K11127)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmpv2_trap_facility}    ${snmpv2_trap_level}    ${snmpv2_trap_message}
    ${api_payload}    create dictionary    command    run    utilCmdArgs    -c "logger -p ${snmpv2_trap_facility}}.${snmpv2_trap_level}} '${snmpv2_trap_message}}'"
    ${api_uri}    set variable    /mgmt/tm/util/bash
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Walk SNMPv3 Host
    [Documentation]    Performs an SNMPv3 walk on the BIG-IP (https://linux.die.net/man/1/snmpwalk)
    [Arguments]    ${snmphost}    ${snmpv3_user}    ${snmpv3_auth_pass}    ${snmpv3_priv_pass}    ${snmpv3_auth_proto}    ${snmpv3_priv_proto}    ${snmpv3_port}    ${snmpv3_timeout}   ${snmpv3_retries}
    ${connect_status}    Open Snmp V3 Connection    ${snmphost}    ${snmpv3_user}    ${snmpv3_auth_pass}    ${snmpv3_priv_pass}    ${snmpv3_auth_proto}    ${snmpv3_priv_proto}    ${snmpv3_port}    ${snmpv3_timeout}   ${snmpv3_retries}
    Log    SNMP Connect Status: ${connect_status}
    ${walk_response}    walk    .iso.3.6.1.2.1.1
    log    SNMP Walk Result: ${walk_response}

Create BIG-IP SNMPv3 Trap Destination
    [Documentation]    Creates an SNMPv3 trap destination on the BIG-IP (https://techdocs.f5.com/kb/en-us/products/big-ip-afm/manuals/product/dos-firewall-implementations-13-1-0/8.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${snmphost}    ${snmpv3_user}    ${snmpv3_auth_pass}    ${snmpv3_priv_pass}    ${snmpv3_auth_proto}    ${snmpv3_priv_proto}    ${snmpv3_port}    ${snmpv3_community}    ${snmpv3_security_level}    ${snmpv3_security_name}
    ${api_payload}    create dictionary    name=robot_framework_snmpv3  authPassword=${snmpv3_auth_pass}    authProtocol=${snmpv3_auth_proto}    community=${snmpv3_community}    host=${snmphost}    port=${${snmpv3_port}}  privacyPassword=${snmpv3_priv_pass}    privacyProtocol=${snmpv3_priv_proto}    securityName=${snmpv3_security_name}    version=3   securityLevel=${snmpv3_security_level}
    ${api_uri}    set variable    /mgmt/tm/sys/snmp/traps
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Trigger an SNMPv3 Trap on the BIG-IP
    [Documentation]    Triggers an SNMP trap from the syslog-ng utility on the BIG-IP (https://support.f5.com/csp/article/K11127)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_payload}    create dictionary    command    run    utilCmdArgs    -c "logger -p ${SNMPV3_TRAP_FACILITY}.${SNMPV3_TRAP_LEVEL} '${SNMPV3_TRAP_MESSAGE}'"
    ${api_uri}    set variable    /mgmt/tm/util/bash
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

############
## sys ssh
############

Get Current SSH Allow ACL
    [Documentation]    View the current SSH allow ACL on the BIG-IP (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${initial_sshd_allow_acl}    get from dictionary    ${api_response_dict}    allow
    log    Initial SSH Allow ACL: ${initial_sshd_allow_acl}
    set test variable    ${initial_sshd_allow_acl}
    [Return]    ${api_response}

Add Host to SSH Allow ACL
    [Documentation]    Add a host to the current SSH allow ACL on the BIG-IP (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${new_ssh_host}
    Get Current SSH Allow ACL    ${bigip_host}    ${bigip_username}    ${bigip_password}
    list should not contain value   ${initial_sshd_allow_acl}    ${new_ssh_host}
    ${new_sshd_allow_acl}    set variable    ${initial_sshd_allow_acl}
    append to list    ${new_sshd_allow_acl}    ${new_ssh_host}
    log    Updated SSH Allow ACL: ${new_sshd_allow_acl}
    ${api_payload}    create dictionary    allow    ${new_sshd_allow_acl}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Remove Host from SSH Allow ACL
    [Documentation]    Remove a host from the current SSH allow ACL on the BIG-IP (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${ssh_host}
    Get Current SSH Allow ACL    ${bigip_host}    ${bigip_username}    ${bigip_password}
    list should contain value    ${initial_sshd_allow_acl}    ${ssh_host}
    ${new_sshd_allow_acl}    set variable    ${initial_sshd_allow_acl}
    remove values from list    ${new_sshd_allow_acl}    ${ssh_host}
    log    Updated SSH Allow ACL: ${new_sshd_allow_acl}
    ${api_payload}    create dictionary    allow    ${new_sshd_allow_acl}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Remove All Hosts from SSH Allow ACL
    [Documentation]    Remove all hosts from the current SSH allow ACL on the BIG-IP (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${new_sshd_allow_acl}    Create List
    ${api_payload}    create dictionary    allow    ${new_sshd_allow_acl}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Reset BIG-IP SSH Allow ACL to Allow All Hosts
    [Documentation]    Resets the  SSH allow ACL on the BIG-IP to the default value to allow all hosts (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${all_ssh_list}    create list    ALL
    ${api_payload}    create dictionary    allow=${all_ssh_list}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Verify SSH Allow ACL
    [Documentation]    Verify that a host exists in the current SSH allow ACL on the BIG-IP (https://support.f5.com/csp/article/K5380)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${verify_ssh_host}
    ${api_uri}    set variable    /mgmt/tm/sys/sshd
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${api_response_dict}    to json    ${api_response.content}
    ${sshd_allow_acl}    get from dictionary    ${api_response_dict}    allow
    list should contain value    ${sshd_allow_acl}    ${verify_ssh_host}
    [Return]    ${api_response}

Run BASH Echo Test
    [Documentation]    Issues a BASH command and looks for the proper response inside of an existing SSH session
    ${BASH_ECHO_RESPONSE}    Execute Command    echo 'BASH TEST'
    Should Be Equal    ${BASH_ECHO_RESPONSE}    BASH TEST
    [Return]    ${BASH_ECHO_RESPONSE}

##################
## sys turboflex
##################

Enable BIG-IP Turboflex Profile
    [Documentation]    Changes the Turboflex profile in use on a BIG-IP platform (not supported on all platforms) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/f5-platform-turboflex-profiles.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}    ${turboflex_profile}
    ${api_uri}    set variable    /mgmt/tm/sys/turboflex/profile-config
    ${api_payload}    create dictionary    kind=tm:sys:turboflex:profile-config:profile-configstate    type=${turboflex_profile}
    ${api_response}    BIG-IP iControl BasicAuth PATCH    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

View BIG-IP Turboflex Profile
    [Documentation]    Displays the current Turboflex profile in use on a BIG-IP platform (not supported on all platforms) (https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/f5-platform-turboflex-profiles.html)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/turboflex/profile-config
    ${api_response}    BIG-IP iControl BasicAuth GET    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

############
## sys ucs
############

Save a UCS on the BIG-IP
    [Documentation]    Saves a configuration backup on a BIG-IP (https://support.f5.com/csp/article/K4423)
    [Arguments]    ${bigip_host}   ${bigip_username}    ${bigip_password}    ${ucs_filename}
    ${api_payload}    create dictionary    command=save    name=${ucs_filename}
    ${api_uri}    set variable    /mgmt/tm/sys/ucs
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

Load a UCS on the BIG-IP
    [Documentation]    Loads a configuration backup to a BIG-IP (https://support.f5.com/csp/article/K4423)
    [Arguments]    ${bigip_host}   ${bigip_username}    ${bigip_password}    ${ucs_filename}
    ${api_payload}    create dictionary    command=load    name=${ucs_filename}
    ${api_uri}    set variable    /mgmt/tm/sys/ucs
    ${api_response}    BIG-IP iControl BasicAuth POST    bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}    api_payload=${api_payload}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    [Return]    ${api_response}

################
## sys version
################

Retrieve BIG-IP Version
    [Documentation]    Shows the current version of software running on the BIG-IP (https://support.f5.com/csp/article/K8759)
    [Arguments]    ${bigip_host}   ${bigip_username}   ${bigip_password}
    ${api_auth}    create list    ${bigip_username}    ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/version
    ${api_response}    BIG-IP iControl BasicAuth GET   bigip_host=${bigip_host}    bigip_username=${bigip_username}    bigip_password=${bigip_password}    api_uri=${api_uri}
    should be equal as strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log    API RESPONSE: ${api_response.content}
    [Return]    ${api_response}

Retrieve BIG-IP Version using Token Authentication
    [Documentation]    Shows the current version of software running on the BIG-IP (https://support.f5.com/csp/article/K8759)
    [Arguments]    ${bigip_host}    ${bigip_username}    ${bigip_password}
    ${api_token}    Generate Token    ${bigip_host}    ${bigip_username}   ${bigip_password}
    ${api_uri}    set variable    /mgmt/tm/sys/version
    ${api_response}    BIG-IP iControl TokenAuth GET    bigip_host=${bigip_host}    api_token=${api_token}    api_uri=${api_uri}
    Should Be Equal As Strings    ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    ${verification_text}    set variable  "kind":"tm:sys:version:versionstats"
    should contain    ${api_response.text}    ${verification_text}
    [Teardown]    Run Keywords    Delete Token    bigip_host=${bigip_host}    api_token=${api_token}    AND    Delete All Sessions
    [Return]    ${api_response}
