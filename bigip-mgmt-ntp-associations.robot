*** Settings ***
Documentation       Suite description
...                 This test verifies proper operation of an existing NTP configuration

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Library             String
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Verify NTP Operation
    Generate Token
    Verify NTP Server Associations
    Delete Token

*** Keywords ***

Verify NTP Server Associations
    &{api_payload}                  Create Dictionary               command     run         utilCmdArgs     -c \'ntpq -pn\'
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/util/bash
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     200
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

