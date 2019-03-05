*** Settings ***
Documentation       Suite description
...                 This test verifies proper operation of an existing NTP configuration

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Create Static Route on the BIG-IP
    Generate Token
    Create Static Route Configuration on the BIG-IP
    Verify Static Route Configuration on the BIG-IP
    Verify Static Route Presence in BIG-IP Route Table
    Delete Token

*** Keywords ***
Create Static Route Configuration on the BIG-IP
    create session                  bigip-create-net-route          https://${IPV4_MGMT}
    &{api_payload}                  to json                         ${STATIC_ROUTE_OBJECT}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/net/route
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json}            To Json        ${api_response.content}
    [Teardown]                      Delete All Sessions

Verify Static Route Configuration on the BIG-IP
    ${static_route_json}            to json                 ${STATIC_ROUTE_OBJECT}
    ${static_route_name}            get from dictionary     ${static_route_json}      name
    ${static_route_partition}       get from dictionary     ${static_route_json}      partition
    log                             STATIC ROUTE NAME: ~${static_route_partition}~${static_route_name}
    ${api_uri}                      set variable        /mgmt/tm/net/route/~${static_route_partition}~${static_route_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     200
    ${api_response_json}            to json         ${api_response.content}
    log                             ${api_response_json}
    dictionary should contain sub dictionary                  ${api_response_json}        ${static_route_json}
    [Teardown]                      delete all sessions

Verify Static Route Presence in BIG-IP Route Table
    ${static_route_json}            to json                 ${STATIC_ROUTE_OBJECT}
    ${static_route_name}            get from dictionary     ${static_route_json}      name
    ${static_route_partition}       get from dictionary     ${static_route_json}      partition
    ${api_uri}                      set variable        /mgmt/tm/net/route/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     200
    ${api_response_json}            to json         ${api_response.content}
    ${route_table_entries}          get from dictionary     ${api_response_json}    entries
    log                             ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}                set variable        https://localhost/mgmt/tm/net/route/~${static_route_partition}~${static_route_name}/stats
    list should contain value       ${route_table_entries}      ${selflink_name}
    [Teardown]                      Delete All Sessions