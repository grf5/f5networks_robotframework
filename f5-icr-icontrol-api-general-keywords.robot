*** Settings ***
Documentation       Resource file for F5's iControl REST API
Library             Collections
Library             RequestsLibrary

*** Keywords ***
Generate Token                      [documentation]                 Generates an API Auth token using username/password
    ${api_uri}                      set variable                    /mgmt/shared/authn/login
    set test variable               ${api_uri}
    ${api_payload}                  Create Dictionary               username=${HTTP_USERNAME}    password=${HTTP_PASSWORD}    loginProviderName=tmos
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl NoAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json}            To Json                         ${api_response.content}
    ${api_auth_token}               Get From Dictionary             ${api_response_json}        token
    ${api_auth_token}               Get From Dictionary             ${api_auth_token}           token
    ${api_auth_token}               Set Test Variable               ${api_auth_token}
    [Teardown]                      Delete All Sessions

Extend Token                        [documentation]                 Extends the timeout on an existing auth token
    ${api_payload}                  Create Dictionary               timeout=${36000}
    set test variable               ${api_payload}
    ${api_uri}                      set variable                    /mgmt/shared/authz/tokens/${api_auth_token}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_token_status}             to json                         ${api_response.content}
    dictionary should contain item  ${api_token_status}             timeout         36000
    [Teardown]                      Delete All Sessions

Delete Token                        [documentation]                 Deletes an auth token
    ${api_uri}                      set variable                    /mgmt/shared/authz/tokens/${api_auth_token}
    set test variable               ${api_uri}
    log                             DELETE TOKEN URI: https://${MGMT_IP}${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

BIG-IP iControl TokenAuth GET       [documentation]                 Performs an iControl REST API GET call using a pre-generated token
    log                             iControl GET Variables: HOST: ${MGMT_IP} URI: ${api_uri} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    create session                  bigip-icontrol-get-tokenauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 get request     bigip-icontrol-get-tokenauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth POST      [documentation]                 Performs an iControl REST API POST call using a pre-generated token
    log                             iControl POST Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-tokenauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 post request     bigip-icontrol-post-tokenauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth PUT       [documentation]                 Performs an iControl REST API PUT call using a pre-generated token
    log                             iControl PUT Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-tokenauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 put request     bigip-icontrol-put-tokenauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth PATCH     [documentation]                 Performs an iControl REST API PATCH call using a pre-generated token
    log                             iControl PATCH Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-tokenauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 patch request     bigip-icontrol-patch-tokenauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl TokenAuth DELETE    [documentation]                 Performs an iControl REST API DELETE call using a pre-generated token
    log                             iControl DELETE Variables: HOST: ${MGMT_IP} URI: ${api_uri} AUTH-TOKEN: ${api_auth_token}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth_token}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-tokenauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response}                 delete request     bigip-icontrol-delete-tokenauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth GET       [documentation]                 Performs an iControl REST API GET call using basic auth
    log                             iControl GET Variables: HOST: ${MGMT_IP} URI: ${api_uri}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    create session                  bigip-icontrol-get-basicauth    https://${MGMT_IP}        auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 get request     bigip-icontrol-get-basicauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth POST      [documentation]                 Performs an iControl REST API POST call using basic auth
    log                             iControl POST Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-basicauth    https://${MGMT_IP}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 post request     bigip-icontrol-post-basicauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth PUT       [documentation]                 Performs an iControl REST API PUT call using basic auth
    log                             iControl PUT Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-basicauth    https://${MGMT_IP}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 put request     bigip-icontrol-put-basicauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth PATCH     [documentation]                 Performs an iControl REST API PATCH call using basic auth
    log                             iControl PATCH Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-basicauth    https://${MGMT_IP}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 patch request     bigip-icontrol-patch-basicauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl BasicAuth DELETE    [documentation]                 Performs an iControl REST API DELETE call using basic auth
    log                             iControl DELETE Variables: HOST: ${MGMT_IP} URI: ${api_uri}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    return from keyword if          "${api_auth}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-basicauth    https://${MGMT_IP}		auth=${api_auth}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 delete request     bigip-icontrol-delete-basicauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth GET          [documentation]                 Performs an iControl REST API GET call without authentication
    log                             iControl GET Variables: HOST: ${MGMT_IP} URI: ${api_uri}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    create session                  bigip-icontrol-get-noauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 get request     bigip-icontrol-get-noauth   ${api_uri}       headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth POST         [documentation]                 Performs an iControl REST API POST call without authentication
    log                             iControl POST Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-post-noauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 post request     bigip-icontrol-post-noauth   ${api_uri}     headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth PUT          [documentation]                 Performs an iControl REST API PUT call without authentication
    log                             iControl PUT Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-put-noauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 put request     bigip-icontrol-put-noauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth PATCH        [documentation]                 Performs an iControl REST API PATCH call without authentication
    log                             iControl PATCH Variables: HOST: ${MGMT_IP} URI: ${api_uri} PAYLOAD: ${api_payload}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    ${payload_length}               get length  ${api_payload}
    return from keyword if          ${payload_length} == 0
    create session                  bigip-icontrol-patch-noauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 patch request     bigip-icontrol-patch-noauth   ${api_uri}       headers=${api_headers}     json=${api_payload}
    log                             HTTP Response Code: ${api_response}
    log                             HTTP Response Payload: ${api_response.content}
    [Return]                        ${api_response}

BIG-IP iControl NoAuth DELETE       [documentation]                 Performs an iControl REST API DELETE call without authentication
    log                             iControl DELETE Variables: HOST: ${MGMT_IP} URI: ${api_uri}
    return from keyword if          "${MGMT_IP}" == "${EMPTY}"
    return from keyword if          "${api_uri}" == "${EMPTY}"
    create session                  bigip-icontrol-delete-noauth    https://${MGMT_IP}
    &{api_headers}                  Create Dictionary               Content-type=application/json
    ${api_response}                 delete request     bigip-icontrol-delete-noauth   ${api_uri}     headers=${api_headers}
    log                             HTTP Response Code: ${api_response}
    log                             API Response (should be null for successful delete operations): ${api_response.content}
    [Return]                        ${api_response}

BIG-IP Clear API Parameters         [documentation]                         Resets all BIG-IP API-related variables to null values
    ${api_payload}                  set global variable                    ${null}
    ${api_headers}                  set global variable                    ${null}
    ${api_uri}                      set global variable                    ${null}
    ${api_response}                 set global variable                    ${null}
    ${api_response_text}            set global variable                    ${null}