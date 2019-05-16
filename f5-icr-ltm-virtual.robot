*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create an LTM FastL4 Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=0.0.0.0\/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled       ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Create an LTM FastL4 IPv6 Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=::/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled       ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Create an LTM IP Forwarding Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=0.0.0.0\/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled   ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Create an LTM IP Forwarding IPv6 Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=::/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled   ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Create an LTM Standard Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=0.0.0.0\/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled   ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Create an LTM Standard IPv6 Virtual Server
    [Arguments]                     ${name}     ${destination}      ${partition}=Common     ${addressStatus}=yes    ${autoLasthop}=default  ${connectionLimit}=${0}     ${enabled}=${True}  ${ipProtocol}=any   ${mask}=any     ${source}=0.0.0.0\/0    ${sourcePort}=preserve      ${translateAddress}=disabled        ${translatePort}=disabled   ${pool}=none        ${sourceAddressTranslation_pool}=none   ${sourceAddressTranslation_type}=none
    Set Log Level                   Debug
    ${SourceAddressTranslation}     create dictionary       pool=${sourceAddressTranslation_pool}   type=${sourceAddressTranslation_type}
    ${api_payload}                  create dictionary       name=${name}     destination=${destination}      partition=${partition}     addressStatus=${addressStatus}    autoLasthop=${autoLasthop}  connectionLimit=${connectionLimit}    ipProtocol=${ipProtocol}   mask=${mask}     source=${source}    sourcePort=${sourcePort}      translateAddress=${translateAddress}        translatePort=${translatePort}    pool=${pool}    sourceAddressTranslation=${sourceAddressTranslation}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/ltm/virtual
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Delete an LTM Virtual Server
    [Arguments]                     ${name}     ${partition}=Common
    Set Log Level                   Debug
    ${api_uri}                      set variable        /mgmt/tm/ltm/virtual/~${partition}~${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Add a Profile to an LTM Virtual Server
    [Arguments]                     ${profile_name}     ${virtual_server_name}      ${profile_partition}=Common     ${virtual_server_partition}=Common
    Set Log Level                   Debug
    ${api_payload}                  create dictionary

Retrieve LTM Virtual Server Statistics
    [Arguments]                     ${name}     ${partition}=Common
    ${api_uri}                      set variable                        /mgmt/tm/ltm/virtual/~${partition}~${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Retrieve All LTM Virtual Servers Statistics
    ${api_uri}                      set variable                        /mgmt/tm/ltm/virtual/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Get LTM Virtual Server Availability State
    [Arguments]                     ${name}     ${partition}=Common
    ${api_uri}                      set variable                        /mgmt/tm/ltm/virtual/~${partition}~${name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${virtual_server_stats_dict}    to json                 ${api_response.content}
    ${virtual_server_status}        get from dictionary     ${virtual_server_stats_dict}       entries
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           https:\/\/localhost\/mgmt\/tm\/ltm\/virtual\/~${partition}~${name}\/~${partition}~${name}\/stats
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           nestedStats
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           entries
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           status.availabilityState
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           description
    [return]                        ${virtual_server_status}

Get LTM Virtual Server Enabled State
    [Arguments]                     ${name}     ${partition}=Common
    ${api_uri}                      set variable                        /mgmt/tm/ltm/virtual/~${partition}~${name}/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${virtual_server_stats_dict}    to json                 ${api_response.content}
    ${virtual_server_status}        get from dictionary     ${virtual_server_stats_dict}       entries
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           https:\/\/localhost\/mgmt\/tm\/ltm\/virtual\/~${partition}~${name}\/~${partition}~${name}\/stats
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           nestedStats
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           entries
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           status.enabledState
    ${virtual_server_status}        get from dictionary     ${virtual_server_status}           description
    [return]                        ${virtual_server_status}
