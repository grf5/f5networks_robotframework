*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Enable a BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Enabling interface ${interface_name}
    &{api_payload}                  create dictionary               kind=tm:net:interface:interfacestate    name=${interface_name}    enabled=${True}
    set test variable               &{api_payload}
    ${api_uri}                      set variable        /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json     ${api_response.content}
    dictionary should contain item  ${api_response_dict}      enabled    True
    [Teardown]                      Delete All Sessions

Verify enabled state of BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Verifying the Enabling interface ${interface_name}
    ${api_uri}                      set variable    /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}      enabled      True
    [Teardown]                      Delete All Sessions

Verify up state of BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Verifying the Up state of interface ${interface_name}
    ${api_uri}                      set variable    /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary   ${api_response_dict}         entries
    ${interface_stats_dict}         get from dictionary   ${interface_stats_entries}   https://localhost/mgmt/tm/net/interface/${interface_name}/stats
    ${interface_stats_dict}         get from dictionary   ${interface_stats_dict}      nestedStats
    ${interface_stats_dict}         get from dictionary   ${interface_stats_dict}      entries
    ${interface_status_dict}        get from dictionary   ${interface_stats_dict}      status
    ${interface_status}             get from dictionary   ${interface_status_dict}     description
    ${interface_tmname}             get from dictionary   ${interface_stats_dict}      tmName
    ${interface_tmname}             get from dictionary   ${interface_tmname}          description
    should be equal as strings      ${interface_status}   enabled
    [Teardown]                      Delete All Sessions

Disable a BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Disabling interface ${interface_name}
    ${api_payload}                  create dictionary       kind=tm:net:interface:interfacestate    name=${interface_name}    disabled=${True}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json     ${api_response.content}
    dictionary should contain item    ${api_response_dict}      disabled    True
    [Teardown]                      Delete All Sessions

Verify disabled state of BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Verifying the Disabling interface ${interface_name}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}      disabled      True
    [Teardown]                      Delete All Sessions

Verify down state of BIG-IP physical interface
    [Arguments]                     ${interface_name}
    log                             Verifying the Down state of interface ${interface_name}
    ${api_uri}                      set variable       /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary  ${api_response_dict}          entries
    ${interface_stats_dict}         get from dictionary  ${interface_stats_entries}    https://localhost/mgmt/tm/net/interface/${interface_name}/stats
    ${interface_stats_dict}         get from dictionary  ${interface_stats_dict}       nestedStats
    ${interface_stats_dict}         get from dictionary  ${interface_stats_dict}       entries
    ${interface_status_dict}        get from dictionary  ${interface_stats_dict}       status
    ${interface_status}             get from dictionary  ${interface_status_dict}      description
    ${interface_tmname}             get from dictionary  ${interface_stats_dict}       tmName
    ${interface_tmname}             get from dictionary  ${interface_tmname}           description
    should be equal as strings      ${interface_status}  disabled
    [Teardown]                      Delete All Sessions

Configure BIG-IP Interface Description
    [Arguments]                     ${interface_name}       ${interface_description}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       description=${interface_description}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Set BIG-IP Interface LLDP to Transmit Only
    [Arguments]                     ${interface_name}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       lldpAdmin=txonly
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Set BIG-IP Interface LLDP to Receive Only
    [Arguments]                     ${interface_name}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       lldpAdmin=rxonly
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Set BIG-IP Interface LLDP to Transmit and Receive
    [Arguments]                     ${interface_name}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       lldpAdmin=txrx
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Disable BIG-IP LLDP on Interface
    [Arguments]                     ${interface_name}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${interface_name}
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       lldpAdmin=disable
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

List all BIG-IP Interfaces
    ${api_uri}                      set variable        /mgmt/tm/net/interface
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_list}               get from dictionary             ${api_response_dict}     items
    :FOR    ${current_interface}    IN  @{interface_list}
    \   ${interface_name}           get from dictionary         ${current_interface}        name
    \   ${interface_media_active}   get from dictionary         ${current_interface}        mediaActive
    \   ${interface_media_max}      get from dictionary         ${current_interface}        mediaMax
    \   log                         Name: ${interface_name} Media Active: ${interface_media_active} Fastest Optic Supported: ${interface_media_max}
    [Teardown]                      Delete All Sessions

Verify Interface Drop Counters on the BIG-IP
    ${api_uri}                      set variable            /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
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

Verify Interface Error Counters on the BIG-IP
    ${api_uri}                      set variable        /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary     ${api_response_dict}    entries
    :FOR    ${current_interface}    IN  @{interface_stats_entries}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_entries}        ${current_interface}
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           nestedStats
    \   ${interface_stats_dict}     get from dictionary         ${interface_stats_dict}           entries
    \   ${counters_errors_dict}     get from dictionary         ${interface_stats_dict}           counters.errorsAll
    \   ${counters_errors_count}    get from dictionary         ${counters_errors_dict}           value
    \   ${interface_tmname}         get from dictionary         ${interface_stats_dict}           tmName
    \   ${interface_tmname}         get from dictionary         ${interface_tmname}               description
    \   log                         Interface ${interface_tmname} - Errors: ${counters_errors_count}
    \   should be equal as strings      ${counters_errors_count}    0
    [Teardown]                      Delete All Sessions