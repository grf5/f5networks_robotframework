*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Retrieve BIG-IP Version with Basic Auth
    ${api_auth}                     create list                    ${HTTP_USERNAME}             ${HTTP_PASSWORD}
    ${api_uri}                      set variable                    /mgmt/tm/sys/version
    set test variable               ${api_auth}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl BasicAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

