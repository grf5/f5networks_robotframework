*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Load the BIG-IP Default Configuration
    ${api_auth}                     create list                    ${HTTP_USERNAME}             ${HTTP_PASSWORD}
    ${api_payload}                  create dictionary               command=load        name=default
    ${api_uri}                      set variable                    /mgmt/tm/sys/config
    set test variable               ${api_auth}
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl BasicAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

