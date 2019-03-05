*** Settings ***
Documentation       Suite description
...                 This test verifies proper operation of an existing NTP configuration

Resource            ${VARIABLES_FILENAME}
Library             Collections
Library             RequestsLibrary
Library             String
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Verify NTP Operation
    Generate Token
    Ping host from BIG-IP
    Delete Token

*** Keywords ***
Ping host from BIG-IP
#${PING_TEST_DETAILS}                {"host":"1.1.1.1","count":"5","interval":"5","packetsize":"1000","source":"192.168.1.101"}
    ${ping_test_dict}               to json                         ${PING_TEST_DETAILS}
    ${ping_test_host}               get from dictionary             ${ping_test_dict}       host
    ${ping_test_count}              get from dictionary             ${ping_test_dict}       count
    ${ping_test_interval}           get from dictionary             ${ping_test_dict}       interval
    ${ping_test_packetsize}         get from dictionary             ${ping_test_dict}       packetsize
    ${ping_test_source}             get from dictionary             ${ping_test_dict}       source
    Create Session                  bigip-util-ping                 https://${IPV4_MGMT}
    &{api_headers}                  Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    &{api_payload}                  Create Dictionary               command=run         utilCmdArgs=${ping_test_host} -c ${ping_test_count} -i ${ping_test_interval} -s ${ping_test_packetsize} -I ${ping_test_source}
    Log to console                            API PAYLOAD: ${api_payload}
    ${api_response}                 Post Request                     bigip-util-ping         /mgmt/tm/util/ping                  headers=${api_headers}      json=${api_payload}
    Should Be Equal As Strings      ${api_response.status_code}     200
    Log                             API RESPONSE: ${api_response.content}
    ${api_response_json}            To Json                 ${api_response.content}
    ${ping_output}                  Get from Dictionary     ${api_response_json}     commandResult
    log                             ${ping_output}
    [Teardown]                      Delete All Sessions

Generate Token
    Create Session                  gen-token                       https://${IPV4_MGMT}
    ${api_auth} =                   Create List                     ${GUI_USERNAME}             ${GUI_PASSWORD}
    &{api_headers} =                Create Dictionary               Content-type=application/json
    &{api_payload} =                Create Dictionary               username=${GUI_USERNAME}    password=${GUI_PASSWORD}    loginProviderName=tmos
    Log                             TOKEN REQUEST PAYLOAD: ${api_payload}
    ${api_response} =               Post Request                    gen-token                   /mgmt/shared/authn/login    json=${api_payload}         headers=${api_headers}
    Log                             TOKEN REQUEST RESPONSE: ${api_response.content}
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_json} =          To Json                         ${api_response.content}
    ${api_auth_token} =             Get From Dictionary             ${api_response_json}        token
    ${api_auth_token} =             Get From Dictionary             ${api_auth_token}           token
    ${api_auth_token} =             Set Test Variable               ${api_auth_token}
    [Teardown]                      Delete All Sessions

Delete Token
    Create Session                  delete-token                    https://${IPV4_MGMT}
    &{api_headers} =                Create Dictionary               Content-type=application/json       X-F5-Auth-Token=${api_auth_token}
    ${api_response} =               Delete Request                  delete-token                /mgmt/shared/authz/tokens/${api_auth_token}             headers=${api_headers}
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

