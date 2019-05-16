*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Retrieve CPU Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/cpu
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}
