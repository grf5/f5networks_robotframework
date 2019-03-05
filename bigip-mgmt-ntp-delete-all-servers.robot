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
    Delete NTP Server Configuration
    Delete Token

*** Keywords ***
Delete NTP Server Configuration
    ${empty_list}                   Create List
    ${api_payload}                  Create Dictionary               servers=${empty_list}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ntp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions
