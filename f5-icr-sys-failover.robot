*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Send a BIG-IP to Standby
    ${api_payload}                  create dictionary               kind=tm:sys:failover:runstate       command=run     standby=${true}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/failover
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Take a BIG-IP Offline
    ${api_payload}                  create dictionary               kind=tm:sys:failover:runstate       command=run     offline=${true}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/failover
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Place a BIG-IP Online
    ${api_payload}                  create dictionary               kind=tm:sys:failover:runstate       command=run     online=${true}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/failover
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Send a BIG-IP to Standby for a Traffic Group
    [Arguments]                     ${traffic-group}
    ${api_payload}                  create dictionary               kind=tm:sys:failover:runstate       command=run     standby=${true}    trafficGroup=${traffic_group}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/failover
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
