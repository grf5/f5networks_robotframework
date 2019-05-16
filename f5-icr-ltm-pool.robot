*** Settings ***
Resource        f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create an LTM Pool
    [Arguments]         ${name}     ${partition}=Common     ${allowNat}=yes     ${allowSnat}=yes    ${ignorePersistedWeight}=disabled   ${loadBalancingMode}=round-robin    ${minActiveMembers}=${0}    ${minUpMembers}=${0}    ${minUpMembersAction}=failover  ${minUpMembersChecking}=disabled    ${queueDepthLimit}=${0}     ${queueOnConnectionLimit}=disabled      ${queueTimeLimit}=${0}  ${reselectTries}=${0}   ${serviceDownAction}=none   ${slowRampTime}=${10}   ${monitor}=none
    Set Log Level       Debug
    ${api_payload}      create dictionary   name=${name}    partition=${partition}  allowNat=${allowNat}    allowSnat=${allowSnat}      ignorePersistedWeight=${ignorePersistedWeight}  loadBalancingMode=${loadBalancingMode}    minActiveMembers=${minActiveMembers}  minUpMembers=${minUpMembers}    minUpMembersAction=${minUpMembersAction}    minUpMembersChecking=${minUpMembersChecking}    queueDepthLimit=${queueDepthLimit}  queueOnConnectionLimit=${queueOnConnectionLimit}    queueTimeLimit=${queueTimeLimit}    reselectTries=${reselectTries}  serviceDownAction=${serviceDownAction}      slowRampTime=${slowRampTime}    monitor=${monitor}
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Add an LTM Pool Member to a Pool
    [Arguments]         ${pool_name}    ${pool_member_name}     ${port}     ${address}  ${pool_partition}=Common    ${pool_member_partition}=Common     ${route_domain_id}=0    ${connectionLimit}=${0}     ${dynamicRatio}=${1}    ${inheritProfile}=enabled   ${monitor}=default  ${priorityGroup}=${0}   ${rateLimit}=disabled   ${ratio}=${1}  ${session}=user-enabled     ${state}=user-up
    Set Log Level       Debug
    ${api_payload}      create dictionary   name=${pool_member_name}:${port}    address=${address}    partition=${pool_member_partition}      route_domain_id=${route_domain_id}  connectionLimit=${connectionLimit}  dynamicRatio=${dynamicRatio}    inheritProfile=${inheritProfile}    monitor=${monitor}      priorityGroup=${priorityGroup}      rateLimit=${rateLimit}  ratio=${ratio}  session=${session}      state=${state}
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Enable an LTM Pool Member
    [Arguments]         ${pool_name}    ${pool_member_name}     ${pool_partition}=Common    ${pool_member_partition}=Common
    Set Log Level       Debug
    ${api_payload}      Create Dictionary       session=user-enabled
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Disable an LTM Pool Member
    [Arguments]         ${pool_name}    ${pool_member_name}     ${pool_partition}=Common    ${pool_member_partition}=Common
    Set Log Level       Debug
    ${api_payload}      Create Dictionary       session=user-disabled
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Mark an LTM Pool Member as Down
    [Arguments]         ${pool_name}    ${pool_member_name}     ${pool_partition}=Common    ${pool_member_partition}=Common
    Set Log Level       Debug
    ${api_payload}      Create Dictionary       state=user-down
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Mark an LTM Pool Member as Up
    [Arguments]         ${pool_name}    ${pool_member_name}     ${pool_partition}=Common    ${pool_member_partition}=Common
    Set Log Level       Debug
    ${api_payload}      Create Dictionary       state=user-up
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~${pool_name}/members/~${pool_member_partition}~${pool_member_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Remove an LTM Pool Member from a Pool
    [Arguments]         ${pool_name}    ${pool_member_name}     ${pool_partition}=Common    ${pool_member_partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${pool_partition}~{pool_name}/members/~${pool_member_partition}~${pool_member_name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Delete an LTM Pool
    [Arguments]         ${name}     ${partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${partition}~${name}
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Retrieve All LTM Pool Statistics
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/stats
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Retrieve LTM Pool Statistics
    [Arguments]         ${name}     ${partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${partition}~${name}/stats
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}

Retrieve LTM Pool Member Statistics
    [Arguments]         ${pool_name}     ${partition}=Common
    Set Log Level       Debug
    ${api_uri}          set variable    /mgmt/tm/ltm/pool/~${partition}~${pool_name}/members/stats
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
