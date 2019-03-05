*** Settings ***
Documentation    Suite description
...             This test checks a trunk on the BIG-IP for drops

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Check BIG-IP for Trunk Drops
    Generate Token
    Verify Trunk Drop Counters on BIG-IP
    Delete Token

*** Keywords ***
Verify Trunk Drop Counters on BIG-IP
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_object_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary   ${api_response_dict}        entries
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}         https://localhost/mgmt/tm/net/trunk/${trunk_object_name}/${trunk_object_name}/stats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}         nestedStats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}         entries
    ${counters_dropsIn_dict}        get from dictionary   ${trunk_stats_dict}         counters.dropsIn
    ${counters_dropsIn_count}       get from dictionary   ${counters_dropsIn_dict}    value
    ${counters_dropsOut_dict}       get from dictionary   ${trunk_stats_dict}         counters.dropsOut
    ${counters_dropsOut_count}      get from dictionary   ${counters_dropsOut_dict}   value
    ${trunk_tmname}                 get from dictionary   ${trunk_stats_dict}         tmName
    ${trunk_tmname}                 get from dictionary   ${trunk_tmname}             description
    log                             Trunk ${trunk_tmname} - Drops IN: ${counters_dropsIn_count}
    log                             Trunk ${trunk_tmname} - Drops Out: ${counters_dropsOut_count}
    should be equal as strings      ${counters_dropsIn_count}    0
    should be equal as strings      ${counters_dropsOut_count}    0
    [Teardown]                      Delete All Sessions