*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot
Library             String

*** Keywords ***
Configure NTP Server List           [arguments]     ${ntp_server_list}
    ${ntp_server_list_payload}      to json                         ${ntp_server_list}
    ${api_payload}                  create dictionary               servers     ${ntp_server_list_payload}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Query NTP Server List
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            To Json        ${api_response.content}
    ${ntp_servers_configured}       Get from Dictionary             ${api_response_json}       servers
    ${ntp_servers_configured}       Convert to List         ${ntp_servers_configured}
    Log                             NTP Servers Configured: ${ntp_servers_configured}
    :FOR    ${current_ntp_server}   IN  @{ntp_servers_configured}
    \   Log     NTP SERVER: ${current_ntp_server}
    \   List Should Contain Value               ${ntp_servers_configured}   ${current_ntp_server}
    \   List Should Not Contain Duplicates      ${ntp_servers_configured}
    [Teardown]                      Delete All Sessions

Verify NTP Server Associations
    &{api_payload}                  Create Dictionary               command     run         utilCmdArgs     -c \'ntpq -pn\'
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/util/bash
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            To Json                 ${api_response.content}
    ${ntpq_output}                  Get from Dictionary     ${api_response_json}     commandResult
    ${ntpq_output_start}            Set Variable            ${ntpq_output.find("===\n")}
    ${ntpq_output_clean}            Set Variable            ${ntpq_output[${ntpq_output_start}+4:]}
    ${ntpq_output_values_list}      Split String            ${ntpq_output_clean}
    ${ntpq_output_length}           get length              ${ntpq_output_values_list}
    ${ntpq_output_server_count}     evaluate                ${ntpq_output_length} / 10 + 1
    :FOR     ${current_ntp_server}  IN RANGE    1   ${ntpq_output_server_count}
    \   ${ntp_server_ip}            remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_reference}     remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_stratum}       remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_type}          remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_when}          remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_poll}          remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_reach}         remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_delay}         remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_offset}        remove from list     ${ntpq_output_values_list}  0
    \   ${ntp_server_jitter}        remove from list     ${ntpq_output_values_list}  0
    \   log                         NTP server status: IP: ${ntp_server_ip} Reference IP: ${ntp_server_reference} Stratum: ${ntp_server_stratum} Type: ${ntp_server_type} Last Poll: ${ntp_server_when} Poll Interval: ${ntp_server_poll} Successes: ${ntp_server_reach} Delay: ${ntp_server_delay} Offset: ${ntp_server_offset} Jitter: ${ntp_server_jitter}
    should not be equal as integers     ${ntp_server_reach}                  0
    should not be equal as strings      ${ntp_server_when}              -
    should not be equal as strings      ${ntp_server_reference}         .STEP.
    should not be equal as strings      ${ntp_server_reference}         .LOCL.
    [Teardown]                      Delete All Sessions

Delete NTP Server Configuration
    ${empty_list}                   Create List
    ${api_payload}                  Create Dictionary               servers=${empty_list}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions
