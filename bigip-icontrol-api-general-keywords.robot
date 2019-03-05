*** Settings ***
Documentation       Suite description
...                 Resource file for F5's iControl REST API

Resource            default_variables.robot
Library             Collections
Library             RequestsLibrary

*** Keywords ***
Generate Token
    ${api_uri}                      set variable                    /mgmt/shared/authn/login
    set test variable               ${api_uri}
    ${api_payload}                  Create Dictionary               username=${GUI_USERNAME}    password=${GUI_PASSWORD}    loginProviderName=tmos
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl NoAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json}            To Json                         ${api_response.content}
    ${api_auth_token}               Get From Dictionary             ${api_response_json}        token
    ${api_auth_token}               Get From Dictionary             ${api_auth_token}           token
    ${api_auth_token}               Set Test Variable               ${api_auth_token}
    [Teardown]                      Delete All Sessions

Extend Token
    &{api_payload}                  Create Dictionary               timeout=${36000}
    ${api_uri}                      set variable                    /mgmt/shared/authz/tokens/${api_auth_token}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_token_status}             to json                         ${api_response.content}
    dictionary should contain item  ${api_token_status}             timeout         36000
    [Teardown]                      Delete All Sessions

Delete Token
    ${api_uri}                      set variable                    /mgmt/shared/authz/tokens/${api_auth_token}
    set test variable               ${api_uri}
    log                             DELETE TOKEN URI: https://${IPV4_MGMT}${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

BIG-IP iControl TokenAuth GET
    log                             iControl GET Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    create session                  bigip-icontrol-get-tokenauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 get request     bigip-icontrol-get-tokenauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth POST
    log                             iControl POST Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-tokenauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 post request     bigip-icontrol-post-tokenauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth PUT
    log                             iControl PUT Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-tokenauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 put request     bigip-icontrol-put-tokenauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth PATCH
    log                             iControl PATCH Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-tokenauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 patch request     bigip-icontrol-patch-tokenauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth DELETE
    log                             iControl DELETE Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-tokenauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 delete request     bigip-icontrol-delete-tokenauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth GET
    log                             iControl GET Variables: HOST: ${IPV4_MGMT} URI: ${api_uri}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    create session                  bigip-icontrol-get-basicauth    https://${IPV4_MGMT}        auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 get request     bigip-icontrol-get-basicauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth POST
    log                             iControl POST Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-basicauth    https://${IPV4_MGMT}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 post request     bigip-icontrol-post-basicauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth PUT
    log                             iControl PUT Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-basicauth    https://${IPV4_MGMT}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 put request     bigip-icontrol-put-basicauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth PATCH
    log                             iControl PATCH Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-basicauth    https://${IPV4_MGMT}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 patch request     bigip-icontrol-patch-basicauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth DELETE
    log                             iControl DELETE Variables: HOST: ${IPV4_MGMT} URI: ${api_uri}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-basicauth    https://${IPV4_MGMT}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 delete request     bigip-icontrol-delete-basicauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth GET
    log                             iControl GET Variables: HOST: ${IPV4_MGMT} URI: ${api_uri}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    create session                  bigip-icontrol-get-noauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 get request     bigip-icontrol-get-noauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth POST
    log                             iControl POST Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-noauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 post request     bigip-icontrol-post-noauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth PUT
    log                             iControl PUT Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-noauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 put request     bigip-icontrol-put-noauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth PATCH
    log                             iControl PATCH Variables: HOST: ${IPV4_MGMT} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-noauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 patch request     bigip-icontrol-patch-noauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth DELETE
    log                             iControl DELETE Variables: HOST: ${IPV4_MGMT} URI: ${api_uri}
    return from keyword if          "${IPV4_MGMT}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-noauth    https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 delete request     bigip-icontrol-delete-noauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP Clear API Parameters
    ${api_payload}                  set global variable                    ${null}
    ${api_headers}                  set global variable                    ${null}
    ${api_uri}                      set global variable                    ${null}
    ${api_response}                 set global variable                    ${null}
    ${api_response_text}            set global variable                    ${null}