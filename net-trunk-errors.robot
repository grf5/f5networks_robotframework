*** Settings ***
Documentation    Suite description
...             This test checks a trunk on the BIG-IP for errors

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Check BIG-IP for Trunk Errors
    Generate Token
    Verify Trunk Error Counters on BIG-IP
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

Verify Trunk Error Counters on BIG-IP
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    create session                  show-net-trunk-errors       https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 get request                     show-net-trunk-errors   /mgmt/tm/net/trunk/${trunk_object_name}/stats   headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary     ${api_response_dict}            entries
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           https://localhost/mgmt/tm/net/trunk/${trunk_object_name}/${trunk_object_name}/stats
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           nestedStats
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           entries
    ${counters_errorsIn_dict}       get from dictionary         ${trunk_stats_dict}       counters.errorsIn
    ${counters_errorsIn_count}      get from dictionary         ${counters_errorsIn_dict}   value
    ${counters_errorsOut_dict}      get from dictionary         ${trunk_stats_dict}       counters.errorsOut
    ${counters_errorsOut_count}     get from dictionary         ${counters_errorsOut_dict}   value
    ${trunk_tmname}         get from dictionary         ${trunk_stats_dict}           tmName
    ${trunk_tmname}         get from dictionary         ${trunk_tmname}               description
    log                             Trunk ${trunk_tmname} - Errors In: ${counters_errorsIn_count}
    log                             Trunk ${trunk_tmname} - Errors Out: ${counters_errorsOut_count}
    should be equal as strings      ${counters_errorsIn_count}    0
    should be equal as strings      ${counters_errorsOut_count}    0
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}        verify=False
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}     Delete Request  delete-token    /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions



