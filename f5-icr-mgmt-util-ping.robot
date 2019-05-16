*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot
Library             String

*** Keywords ***
Ping Host from BIG-IP
    [Arguments]                     ${host}     ${count}=1      ${interval}=100    ${packetsize}=56
    ${api_payload}                  Create Dictionary               command=run         utilCmdArgs=-c ${count} -i ${interval} -s ${packetsize} ${host}
    set test variable               ${api_payload}
    ${api_uri}                      set variable           /mgmt/tm/util/ping
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_json}            To Json                 ${api_response.content}
    ${ping_output}                  Get from Dictionary     ${api_response_json}     commandResult
    log                             ${ping_output}
    Should Contain                  ${ping_output}      , 0% packet loss
    [Teardown]                      Delete All Sessions