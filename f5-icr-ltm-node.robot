*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create an LTM Node
    [Arguments]         ${name}    ${address}     ${partition}=Common       ${route_domain_id}=0       ${connectionLimit}=0    ${dynamicRatio}=1   ${description}=Robot Framework  ${monitor}=default  ${rateLimit}=disabled
    Set Log Level       Debug
    ${api_payload}      create dictionary   name=${name}   address=${address}%${route_domain_id}     partition=${partition}    connectionLimit=${connectionLimit}   dynamicRatio=${dynamicRatio}    description=${description}  monitor=${monitor}  rateLimit=${rateLimit}
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/node
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

List LTM Node Configuration
    [Arguments]         ${node_name}    ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Show LTM Node Statistics
    [Arguments]         ${node_name}    ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Enable an LTM Node
    [Arguments]         ${node_name}   ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    set test variable   ${api_uri}
    ${api_payload}      Create Dictionary       session=user-enabled
    set test variable   ${api_payload}
    ${api_response}     BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Disable an LTM Node
    [Arguments]         ${node_name}   ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    set test variable   ${api_uri}

Mark an LTM Node as Down
    [Arguments]         ${node_name}   ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    set test variable   ${api_uri}

Mark an LTM Node as Up
    [Arguments]         ${node_name}   ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}/stats
    set test variable   ${api_uri}

Verify an LTM Node Exists
    [Arguments]         ${node_name}    ${node_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_expected_response_dict}       create dictionary       kind=tm:ltm:node:nodestate      name=${node_name}       partition=${node_partition}
    ${api_response_dict}        to json         ${api_response.content}
    Dictionary should contain subdictionary     ${api_response_dict}     ${api_expected_response_dict}

Delete an LTM Node
    [Arguments]         ${node_name}    ${node_partition}
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/node/~${node_partition}~${node_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth DELETE
    Should be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}



