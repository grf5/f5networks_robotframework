*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create Static Route Configuration on the BIG-IP
    [Arguments]                     ${name}     ${partition}    ${cidr_network}     ${gateway}      ${description}
    ${api_payload}                  create dictionary       name=${name}    network=${cidr_network}     gw=${gateway}   partition=${partition}  description=${description}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/net/route
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            To Json        ${api_response.content}
    [Teardown]                      Delete All Sessions

Verify Static Route Configuration on the BIG-IP
    [Arguments]                     ${name}     ${partition}    ${cidr_network}     ${gateway}      ${description}
    ${verification_dict}            create dictionary       name=${name}    partition=${partition}      network=${cidr_network}     gw=${gateway}   description=${description}
    ${api_uri}                      set variable        /mgmt/tm/net/route/~${partition}~${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            to json        ${api_response.content}
    dictionary should contain sub dictionary       ${api_response_json}        ${verification_dict}
    [Teardown]                      delete all sessions

Verify Static Route Presence in BIG-IP Route Table
    [Arguments]                     ${name}     ${partition}    ${cidr_network}     ${gateway}
    ${api_uri}                      set variable        /mgmt/tm/net/route/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            to json         ${api_response.content}
    ${route_table_entries}          get from dictionary     ${api_response_json}    entries
    log                             ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}                set variable        https://localhost/mgmt/tm/net/route/~${partition}~${name}/stats
    list should contain value       ${route_table_entries}      ${selflink_name}
    [Teardown]                      Delete All Sessions

Delete Static Route Configuration on the BIG-IP
    [Arguments]                     ${name}     ${partition}
    ${api_uri}                      set variable            /mgmt/tm/net/route/~${partition}~${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Verify Static Route Deletion on the BIG-IP
    [Arguments]                     ${name}     ${partition}
    ${api_uri}                      set variable            /mgmt/tm/net/route/~${partition}~${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_NOT_FOUND}
    [Teardown]                      delete all sessions

Verify Static Route Removal in BIG-IP Route Table
    [Arguments]                     ${name}     ${partition}
    log to console                  Verify route is gone from table
    ${api_uri}                      set variable            /mgmt/tm/net/route/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            to json         ${api_response.content}
    ${route_table_entries}          get from dictionary     ${api_response_json}    entries
    log                             ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}                set variable        https://localhost/mgmt/tm/net/route/~${partition}~${name}/stats
    list should not contain value   ${route_table_entries}      ${selflink_name}
    [Teardown]                      Delete All Sessions

Display BIG-IP Static Route Configuration
    ${api_uri}                      set variable                    /mgmt/tm/net/route
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            To Json        ${api_response.content}
    log dictionary                  ${api_response_json}
    [Teardown]                      Delete All Sessions
