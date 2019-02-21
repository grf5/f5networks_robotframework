*** Settings ***
Documentation    Suite description
...              This test grabs the output from all interface counters and fails if errors are found

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Check BIG-IP for Interface Drops
    Generate Token
    Verify Interface Drop Counters on the BIG-IP
    Delete Token

*** Keywords ***
Generate Token
    Create Session                  gen-token                       https://${IPV4_MGMT}        verify=False
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
    Log                             GREG ${api_auth_token}
    [Teardown]                      Delete All Sessions

Verify Interface Drop Counters on the BIG-IP
    create session                  show-net-interface-errors       https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 get request                     show-net-interface-errors   /mgmt/tm/net/interface/stats   headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    delete all sessions
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary     ${api_response_dict}    entries
    :FOR    ${current_interface}    IN  @{interface_stats_entries}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_entries}        ${current_interface}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           nestedStats
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           entries
    \   ${counters_drops_dict}     get from dictionary          ${interface_stats_dict}           counters.dropsAll
    \   ${counters_drops_count}    get from dictionary          ${counters_drops_dict}            value
    \   ${interface_tmname}         get from dictionary         ${interface_stats_dict}           tmName
    \   ${interface_tmname}         get from dictionary         ${interface_tmname}               description
    \   log                         Interface ${interface_tmname} - Drops: ${counters_drops_count}
    \   should be equal as strings      ${counters_drops_count}    0
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}     Delete Request  delete-token    /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions


