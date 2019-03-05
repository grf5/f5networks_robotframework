*** Settings ***
Documentation       Suite description
...                 This test verifies proper operation of an existing NTP configuration

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
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

*** Keywords ***
Configure NTP Server
    &{api_payload}                  to json                         ${NTP_SERVER_LIST}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Query NTP Server List
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json}            To Json        ${api_response.content}
    ${ntp_servers_configured}       Get from Dictionary             ${api_response_json}       servers
    ${ntp_servers_configured}       Convert to List         ${ntp_servers_configured}
    Log                             NTP Servers Configured: ${ntp_servers_configured}
    :FOR    ${current_ntp_server}   IN  @{ntp_servers_configured}
    \   Log     NTP SERVER: ${current_ntp_server}
    \   List Should Contain Value               ${ntp_servers_configured}   ${current_ntp_server}
    \   List Should Not Contain Duplicates      ${ntp_servers_configured}
    [Teardown]                      Delete All Sessions
