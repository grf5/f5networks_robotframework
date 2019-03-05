*** Settings ***
Documentation    Suite description
...              This test grabs the output from all interface counters and fails if errors are found

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
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
Verify Interface Drop Counters on the BIG-IP
    ${api_uri}                      set variable            /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary         ${api_response_dict}              entries
    :FOR    ${current_interface}    IN  @{interface_stats_entries}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_entries}        ${current_interface}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           nestedStats
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           entries
    \   ${counters_drops_dict}      get from dictionary         ${interface_stats_dict}           counters.dropsAll
    \   ${counters_drops_count}     get from dictionary         ${counters_drops_dict}            value
    \   ${interface_tmname}         get from dictionary         ${interface_stats_dict}           tmName
    \   ${interface_tmname}         get from dictionary         ${interface_tmname}               description
    \   log                         Interface ${interface_tmname} - Drops: ${counters_drops_count}
    \   should be equal as strings      ${counters_drops_count}    0
    [Teardown]                      Delete All Sessions