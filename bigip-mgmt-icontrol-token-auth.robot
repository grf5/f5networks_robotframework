*** Settings ***
Documentation       Suite description
...                 This test verifies token based authentication to the iControl REST API on the F5 BIG-IP

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Test IPv4 iControlREST Token Authentication
    Generate Token
    Retrieve BIG-IP Version
    Delete Token

*** Keywords ***
Retrieve BIG-IP Version
    ${api_uri}                      set variable                /mgmt/tm/sys/version
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${verification_text}            set variable  "kind":"tm:sys:version:versionstats"
    should contain                  ${api_response.text}         ${verification_text}
    [Teardown]                      Delete All Sessions
