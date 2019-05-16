*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Retrieve BIG-IP Login Page
    create session                  webui                          https://${MGMT_IP}
    ${api_response}                 get request                     webui                   /tmui/login.jsp
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             Web UI HTTP RESPONSE: ${api_response.text}
    should contain                  ${api_response.text}         <meta name="description" content="BIG-IP&reg; Configuration Utility" />
    [Teardown]                      Delete All Sessions

