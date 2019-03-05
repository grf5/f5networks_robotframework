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
Delete Static Route on the BIG-IP
    Generate Token
    ${static_route_json}            to json                 ${STATIC_ROUTE_OBJECT}
    ${static_route_name}            get from dictionary     ${static_route_json}      name
    set test variable               ${static_route_name}
    ${static_route_partition}       get from dictionary     ${static_route_json}      partition
    set test variable               ${static_route_partition}
    Delete Static Route Configuration on the BIG-IP
    Verify Static Route Deletion on the BIG-IP
    Verify Static Route Removal in BIG-IP Route Table
    Delete Token

*** Keywords ***
Delete Static Route Configuration on the BIG-IP
    ${api_uri}                      set variable            /mgmt/tm/net/route/~${static_route_partition}~${static_route_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Verify Static Route Deletion on the BIG-IP
    ${api_uri}                      set variable            /mgmt/tm/net/route/~${static_route_partition}~${static_route_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     404
    [Teardown]                      delete all sessions

Verify Static Route Removal in BIG-IP Route Table
    log to console                  Verify route is gone from table
    ${api_uri}                      set variable            /mgmt/tm/net/route/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     200
    ${api_response_json}            to json         ${api_response.content}
    ${route_table_entries}          get from dictionary     ${api_response_json}    entries
    log                             ROUTE TABLE LIST: ${route_table_entries}
    ${selflink_name}                set variable        https://localhost/mgmt/tm/net/route/~${static_route_partition}~${static_route_name}/stats
    list should not contain value   ${route_table_entries}      ${selflink_name}
    [Teardown]                      Delete All Sessions
