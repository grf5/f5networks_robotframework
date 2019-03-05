*** Settings ***
Documentation       Suite description
...                 This test verifies connectivity to an F5 BIG-IP via the iControl REST API on port 443 of the management interface.
...                 Both IPv4 and IPv6 addresses are supported (dual-stack support in TMOS 14.0+)

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Test IPv4 iControlREST API Connectivity
    Retrieve BIG-IP Version with Basic Auth

*** Keywords ***
Retrieve BIG-IP Version with Basic Auth
    ${api_auth}                     create list                    ${GUI_USERNAME}             ${GUI_PASSWORD}
    ${api_uri}                      set variable                    /mgmt/tm/sys/version
    set test variable               ${api_auth}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl BasicAuth GET
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

