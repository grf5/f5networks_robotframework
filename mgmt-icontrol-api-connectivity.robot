*** Settings ***
Documentation       Suite description
...                 This test verifies connectivity to an F5 BIG-IP via the iControl REST API on port 443 of the management interface.
...                 Both IPv4 and IPv6 addresses are supported (dual-stack support in TMOS 14.0+)

Resource            ${VARIABLES_FILENAME}
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
    ${api_auth} =                   Create List                     ${GUI_USERNAME}             ${GUI_PASSWORD}
    Create Session                  get-bigip-version               https://${IPV4_MGMT}        verify=False    auth=${api_auth}
    &{api_headers} =                Create Dictionary               Content-type=application/json
    ${api_response} =               Get Request                     get-bigip-version           /mgmt/tm/sys/version    headers=${api_headers}
    Log                             API RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${verification_text}            set variable  "kind":"tm:sys:version:versionstats"
    should contain                  ${api_response.text}         ${verification_text}
    [Teardown]                      Delete All Sessions

