*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot
Library             String

*** Variables ***
${MGMT_IP}                          %{MGMT_IP}
${HTTP_USERNAME}                    %{HTTP_USERNAME}
${HTTP_PASSWORD}                    %{HTTP_PASSWORD}
${HTTP_RESPONSE_OK}                 %{HTTP_RESPONSE_OK}
${HTTP_RESPONSE_NOT_FOUND}          %{HTTP_RESPONSE_NOT_FOUND}
${timeout_in_secs}                  300

*** Test Cases ***
Disable DHCP on BIG-IP Management Interface
    Generate Token
    Disable BIG-IP Management Interface DHCP
    Delete Token

Configure the hostname on the BIG-IP
    Generate Token
    Configure BIG-IP Hostname       hostname=
    Delete Token

Disable GUI Setup Wizard
    Generate Token
    Disable BIG-IP GUI Setup Wizard
    Delete Token

Configure Console Inactivity Timeout
    Generate Token
    Configure Console Inactivity Timeout on BIG-IP      console_timeout=${timeout_in_secs}
    Delete Token

Disable Console Inactivity Timeout on BIG-IP
    Generate Token
    Disable Console Inactivity Timeout on BIG-IP
    Delete Token

*** Keywords ***
Disable BIG-IP Management Interface DHCP
    &{api_payload}                  create dictionary               mgmtDhcp    disabled
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Enable BIG-IP Management Interface DHCP
    &{api_payload}                  create dictionary               mgmtDhcp    enabled
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Configure BIG-IP Hostname
    [Arguments]                     ${hostname}
    &{api_payload}                  create dictionary               hostname        ${hostname}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Disable BIG-IP GUI Setup Wizard
    &{api_payload}                  create dictionary               guiSetup    disabled
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Enable BIG-IP GUI Setup Wizard
    &{api_payload}                  create dictionary               guiSetup    enabled
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Disable Console Inactivity Timeout on BIG-IP
    &{api_payload}                  create dictionary               consoleInactivityTimeout    ${0}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Configure Console Inactivity Timeout on BIG-IP
    [Arguments]                     ${console_timeout}
    &{api_payload}                  create dictionary               consoleInactivityTimeout    ${console_timeout}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/global-settings
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

