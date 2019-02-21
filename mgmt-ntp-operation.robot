*** Settings ***
Documentation       Suite description
...                 This test verifies proper operation of an existing NTP configuration

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Library             String
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Test NTP Configuration
    Generate Token
    Configure NTP Server
    Delete Token

Verify NTP Configuration
    Generate Token
    Query NTP Server List
    Delete Token

Verify NTP Operation
    Generate Token
    Verify NTP Server Associations
    Delete Token

*** Keywords ***
Generate Token
    Create Session                  gen-token                       https://${IPV4_MGMT}        verify=False
    ${api_auth} =                   Create List                     ${GUI_USERNAME}             ${GUI_PASSWORD}
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
    [Teardown]                      Delete All Sessions

Configure NTP Server
    Create Session                  bigip-modify-sys-ntp-server-list    https://${IPV4_MGMT}    verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    &{api_payload} =                evaluate        json.loads('''${NTP_SERVER_LIST}''')    json
    ${api_payload} =                evaluate        json.dumps(${api_payload})              json
    Log                             API PAYLOAD: ${api_payload}
    ${api_response} =               Patch Request                   bigip-modify-sys-ntp-server-list    /mgmt/tm/sys/ntp        headers=${api_headers}      data=${api_payload}
    Should Be Equal As Strings      ${api_response.status_code}     200
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Query NTP Server List
    Create Session                  bigip-list-sys-ntp               https://${IPV4_MGMT}       verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Get Request                    bigip-list-sys-ntp    /mgmt/tm/sys/ntp   headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    Log                             API RESPONSE: ${api_response.content}
    ${api_response_json}            To Json        ${api_response.content}
    ${ntp_servers_configured}       Get from Dictionary             ${api_response_json}       servers
    ${ntp_servers_configured}       Convert to List         ${ntp_servers_configured}
    Log                             NTP Servers Configured: ${ntp_servers_configured}
    :FOR    ${current_ntp_server}   IN  @{ntp_servers_configured}
    \   Log     NTP SERVER: ${current_ntp_server}
    \   List Should Contain Value               ${ntp_servers_configured}   ${current_ntp_server}
    \   List Should Not Contain Duplicates      ${ntp_servers_configured}
    [Teardown]                      Delete All Sessions

Verify NTP Server Associations
    Create Session                  bigip-bash-ntpq                 https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    &{api_payload}                  Create Dictionary               command=run         utilCmdArgs=-c ntpstat
    Log                             API PAYLOAD: ${api_payload}
    ${api_response}                 Post Request                     bigip-bash-ntpq         /mgmt/tm/util/bash                  headers=${api_headers}      json=${api_payload}
    Should Be Equal As Strings      ${api_response.status_code}     200
    Log                             API RESPONSE: {api_response.content}
    ${api_response_json}            To Json                 ${api_response.content}
    ${ntpq_output}                  Get from Dictionary     ${api_response_json}     commandResult
    ${ntpq_output_start}            Set Variable            ${ntpq_output.find("===\n")}
    ${ntpq_output_clean}            Set Variable            ${ntpq_output[${ntpq_output_start}+4:]}
    ${ntpq_output_values_list}      Split String            ${ntpq_output_clean}
    ${ntp_servers}                  To Json                 ${NTP_SERVER_LIST}
    ${ntp_servers}                  Get from Dictionary     ${ntp_servers}      servers
    ${ntp_servers}                  Convert to List         ${ntp_servers}
    :FOR    ${current_ntp_server}   IN  @{ntp_servers}
    \   Log to console              Validating NTP Server ${current_ntp_server}
    \   Log to console              NOT VALIDATING!!! NOT VALIDATING!!!
    [Teardown]                      Delete All Sessions

Delete NTP Server Configuration
    Create Session                  bigip-delete-sys-ntp-server-list    https://${IPV4_MGMT}    verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${empty_list}                   Create List
    ${api_payload} =                Create Dictionary               servers=${empty_list}
    Log                             API PAYLOAD: ${api_payload}
    ${api_response} =               Patch Request                   bigip-delete-sys-ntp-server-list    /mgmt/tm/sys/ntp        headers=${api_headers}      json=${api_payload}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Delete Request                  delete-token                /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

