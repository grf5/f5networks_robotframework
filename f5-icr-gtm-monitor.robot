*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Variables ***
${MGMT_IP}                          %{MGMT_IP}
${HTTP_USERNAME}                    %{HTTP_USERNAME}
${HTTP_PASSWORD}                    %{HTTP_PASSWORD}
${HTTP_RESPONSE_OK}                 %{HTTP_RESPONSE_OK}
${HTTP_RESPONSE_NOT_FOUND}          %{HTTP_RESPONSE_NOT_FOUND}