*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create BIG-IP Trunk                                 [documentation]    Creates a trunk object on the BIG-IP
    [arguments]                                     ${name}
    ${api_uri}                                      set variable        /mgmt/tm/net/trunk
    set test variable                               ${api_uri}
    ${api_payload}                                  create dictionary       name=${name}
    set test variable                               ${api_payload}
    ${api_response}                                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings                      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                      Delete All Sessions

Verify BIG-IP Trunk Exists                          [documentation]     Verifies that a trunk object exists on the BIG-IP
    [arguments]                                     ${name}
    ${api_uri}                                      set variable        /mgmt/tm/net/trunk/${name}
    set test variable                               ${api_uri}
    ${api_response}                                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings                      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}                            to json                         ${api_response.content}
    ${trunk_name_dict}                              create dictionary               name=${name}
    dictionary should contain sub dictionary        ${api_response_dict}        ${trunk_name_dict}
    [Teardown]                                      Delete All Sessions

Delete BIG-IP Trunk
    [arguments]                                     ${name}
    ${api_uri}                                      set variable        /mgmt/tm/net/trunk/${name}
    set test variable                               ${api_uri}
    ${api_response}                                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings                      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                      Delete All Sessions

Set Trunk Description
    [arguments]                                     ${trunk_name}       ${trunk_description}
    ${api_uri}                                      set variable        /mgmt/tm/net/trunk/${trunk_name}
    set test variable                               ${api_uri}
    ${api_payload}                                  create dictionary       description=${trunk_description}
    set test variable                               ${api_payload}
    ${api_response}                                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings                      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                                      Delete All Sessions

Retrieve BIG-IP Trunk Status and Statistics
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable        /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary     ${api_response_dict}            entries
    log                             ${trunk_stats_dict}
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk is Up
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable        /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary     ${api_response_dict}            entries
    ${trunk_stats_status}           get from dictionary     ${trunk_stats_dict}             https:\/\/localhost\/mgmt\/tm\/net\/trunk\/${trunk_name}\/${trunk_name}\/stats
    ${trunk_stats_status}           get from dictionary     ${trunk_stats_status}           nestedStats
    ${trunk_stats_status}           get from dictionary     ${trunk_stats_status}           entries
    ${trunk_stats_status}           get from dictionary     ${trunk_stats_status}           status
    ${trunk_stats_status}           get from dictionary     ${trunk_stats_status}           description
    Should Be Equal As Strings      ${trunk_stats_status}      up
    [Teardown]                      Delete All Sessions

Set BIG-IP Trunk Interface List
    [Arguments]                     ${trunk_name}       ${physical_interface_list}
    ${physical_interface_list}      convert to list                 ${physical_interface_list}
    ${api_payload}                  create dictionary               interfaces      ${physical_interface_list}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

List BIG-IP Trunk Interface Configuration
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Add Interface to BIG-IP Trunk
    [Arguments]                     ${trunk_name}       ${physical_interface}
    log                             Getting list of existing interfaces on trunk
    ${api_uri}                      set variable    /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain key   ${api_response_dict}    interfaces
    ${initial_interface_list}       get from dictionary     ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list         ${initial_interface_list}
    ${initial_interface_list}       set test variable       ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    BIG-IP Clear API Parameters
    log                             Adding target interface to interface list
    ${physical_interface}           convert to list                 ${physical_interface}
    list should not contain value   ${initial_interface_list}       ${physical_interface}
    ${new_interface_list}           set variable                    ${initial_interface_list}
    append to list                  ${initial_interface_list}       ${physical_interface}
    log                             New interface list: ${initial_interface_list} ${new_interface_list}
    &{api_payload}                  create dictionary               interfaces      ${new_interface_list}
    set test variable               &{api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Remove Interface from BIG-IP Trunk
    [Arguments]                     ${trunk_name}       ${physical_interface}
    log                             Getting list of existing interfaces on trunk
    ${api_uri}                      set variable    /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_interface_list}       get from dictionary     ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list         ${initial_interface_list}
    ${initial_interface_list}       set test variable       ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    BIG-IP Clear API Parameters
    log                             Removing target interface from interface list
    ${physical_interface}           convert to list                 ${physical_interface}
    list should contain value       ${initial_interface_list}       ${physical_interface}
    ${new_interface_list}           set variable                    ${initial_interface_list}
    set test variable               ${new_interface_list}
    remove values from list         ${initial_interface_list}       ${physical_interface}
    log                             New interface list: ${initial_interface_list} ${new_interface_list}
    &{api_payload}                  create dictionary               interfaces      ${new_interface_list}
    ${api_uri}                      /mgmt/tm/net/trunk/${trunk_name}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface Removal
    [Arguments]                     ${trunk_name}       ${physical_interface}
    log                             Verifying removal of physical interface from BIG-IP trunk
    ${api_uri}                      set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    log                             ${api_response_dict}
    dictionary should not contain value       ${api_response_dict}      ${physical_interface}
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface Addition
    [Arguments]                     ${trunk_name}       ${physical_interface}
    log                             Verifying addition of physical interface from BIG-IP trunk
    ${api_uri}                      set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    log                             ${api_response_dict}
    dictionary should contain value       ${api_response_dict}      ${physical_interface}
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface List
    [Arguments]                     ${trunk_name}       ${physical_interface_list}
    log                             Verifying addition of physical interface from BIG-IP trunk
    ${api_uri}                      set variable   /mgmt/tm/net/trunk/${trunk_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${configured_interface_list}    get from dictionary             ${api_response_dict}        interfaces
    log                             Full API response: ${api_response_dict}
    list should contain sub list    ${physical_interface_list}      ${configured_interface_list}
    list should contain sub list    ${configured_interface_list}    ${physical_interface_list}
    [Teardown]                      Delete All Sessions

Verify Trunk Collision Counters on BIG-IP
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable    /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary     ${api_response_dict}            entries
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           nestedStats
    ${trunk_stats_dict}             get from dictionary     ${trunk_stats_dict}           entries
    ${counters_collisions_dict}     get from dictionary         ${trunk_stats_dict}       counters.collisions
    ${counters_collisions_count}    get from dictionary         ${counters_collisions_dict}   value
    ${trunk_tmname}                 get from dictionary         ${trunk_stats_dict}           tmName
    ${trunk_tmname}                 get from dictionary         ${trunk_tmname}               description
    log                             Trunk ${trunk_tmname} - Collisions: ${counters_collisions_count}
    should be equal as strings      ${counters_collisions_count}    0
    [Teardown]                      Delete All Sessions

Verify Trunk Drop Counters on BIG-IP
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary   ${api_response_dict}        entries
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}         https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
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

Verify Trunk Error Counters on BIG-IP
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary   ${api_response_dict}         entries
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          nestedStats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          entries
    ${counters_errorsIn_dict}       get from dictionary   ${trunk_stats_dict}          counters.errorsIn
    ${counters_errorsIn_count}      get from dictionary   ${counters_errorsIn_dict}    value
    ${counters_errorsOut_dict}      get from dictionary   ${trunk_stats_dict}          counters.errorsOut
    ${counters_errorsOut_count}     get from dictionary   ${counters_errorsOut_dict}   value
    ${trunk_tmname}                 get from dictionary   ${trunk_stats_dict}          tmName
    ${trunk_tmname}                 get from dictionary   ${trunk_tmname}              description
    log                             Trunk ${trunk_tmname} - Errors In: ${counters_errorsIn_count}
    log                             Trunk ${trunk_tmname} - Errors Out: ${counters_errorsOut_count}
    should be equal as strings      ${counters_errorsIn_count}    0
    should be equal as strings      ${counters_errorsOut_count}    0
    [Teardown]                      Delete All Sessions

Get BIG-IP Trunk bitsIn Value
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary   ${api_response_dict}         entries
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          nestedStats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          entries
    ${counters_bitsIn_dict}         get from dictionary   ${trunk_stats_dict}          counters.bitsIn
    ${counters_bitsIn_count}        get from dictionary   ${counters_bitsIn_dict}      value
    ${trunk_tmname}                 get from dictionary   ${trunk_stats_dict}          tmName
    ${trunk_tmname}                 get from dictionary   ${trunk_tmname}              description
    log                             Trunk ${trunk_tmname} - Bits In Counter: ${counters_bitsIn_count}
    [Teardown]                      Delete All Sessions

Get BIG-IP Trunk bitsOut Value
    [Arguments]                     ${trunk_name}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}    kind    tm:net:trunk:trunkstats
    ${trunk_stats_dict}             get from dictionary   ${api_response_dict}         entries
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          https://localhost/mgmt/tm/net/trunk/${trunk_name}/${trunk_name}/stats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          nestedStats
    ${trunk_stats_dict}             get from dictionary   ${trunk_stats_dict}          entries
    ${counters_bitsOut_dict}        get from dictionary   ${trunk_stats_dict}          counters.bitsOut
    ${counters_bitsOut_count}       get from dictionary   ${counters_bitsOut_dict}     value
    ${trunk_tmname}                 get from dictionary   ${trunk_stats_dict}          tmName
    ${trunk_tmname}                 get from dictionary   ${trunk_tmname}              description
    log                             Trunk ${trunk_tmname} - Bits Out Counter: ${counters_bitsOut_count}
    [Teardown]                      Delete All Sessions