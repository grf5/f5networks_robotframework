*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Retrieve All BIG-IP Performance Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/all-stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance Connection Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/connections
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance DNS Express Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/dnsexpress
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance DNSSEC Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/dnssec
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance RAM Cache Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/ramcache
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance System Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/system
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

Retrieve BIG-IP Performance Throughput Statistics
    ${api_uri}                      set variable                    /mgmt/tm/sys/performance/throughput
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions
    Return from Keyword             ${api_response.content}

