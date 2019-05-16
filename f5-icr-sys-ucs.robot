*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Save a UCS on the BIG-IP
    [Arguments]                     ${ucs_filename}
    ${api_payload}                  create dictionary               command=save        name=${ucs_filename}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ucs
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Load a UCS on the BIG-IP
    [Arguments]                     ${ucs_filename}
    ${api_payload}                  create dictionary               command=load        name=${ucs_filename}
    ${api_uri}                      set variable                    /mgmt/tm/sys/ucs
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

