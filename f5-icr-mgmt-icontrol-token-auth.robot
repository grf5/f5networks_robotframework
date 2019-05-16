*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Retrieve BIG-IP Version
    ${api_uri}                      set variable                /mgmt/tm/sys/version
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${verification_text}            set variable  "kind":"tm:sys:version:versionstats"
    should contain                  ${api_response.text}         ${verification_text}
    [Teardown]                      Delete All Sessions
