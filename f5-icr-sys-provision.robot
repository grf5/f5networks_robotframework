*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Provision AFM Module on the BIG-IP
    [Arguments]                     ${provisioning_level}
    ${api_payload}                  create dictionary               level=${provisioning_level}
    ${api_uri}                      set variable                    /mgmt/tm/sys/provision/afm
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    should be equal as strings      ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Provision GTM Module on the BIG-IP
    [Arguments]                     ${provisioning_level}
    ${api_payload}                  create dictionary               level=${provisioning_level}
    ${api_uri}                      set variable                    /mgmt/tm/sys/provision/gtm
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Verify AFM is Provisioned
    ${api_uri}                      set variable                    /mgmt/tm/sys/provision/afm
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log to Console                  API RESPONSE: ${api_response.content}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Verify GTM is Provisioned
    ${api_uri}                      set variable                    /mgmt/tm/sys/provision/gtm
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}    ${HTTP_RESPONSE_OK}
    Log to Console                  API RESPONSE: ${api_response.content}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
