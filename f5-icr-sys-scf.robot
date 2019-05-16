*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Save an SCF on the BIG-IP
    [Arguments]                     ${scf_filename}
    ${api_auth}                     create list                     ${HTTP_USERNAME}             ${HTTP_PASSWORD}
    ${options_dict}                 create dictionary               file=${SCF_FILENAME}    no-passphrase=
    ${options_list}                 create list                     ${options_dict}
    ${api_payload}                  create dictionary               command=save        options=${options_list}
    ${api_uri}                      set variable                    /mgmt/tm/sys/config
    set test variable               ${api_auth}
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl BasicAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

Load an SCF on the BIG-IP
    [Arguments]                     ${ucs_filename}
    ${api_auth}                     create list                    ${HTTP_USERNAME}             ${HTTP_PASSWORD}
    ${options_dict}                 create dictionary              file=${SCF_FILENAME}     no-passphrase=
    ${options_list}                 create list                     ${options_dict}
    ${api_payload}                  create dictionary               command=load        options=${options_list}
    ${api_uri}                      set variable                    /mgmt/tm/sys/config
    set test variable               ${api_auth}
    set test variable               ${api_uri}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl BasicAuth POST
    should be equal as strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    Log                             API RESPONSE: ${api_response.content}
    [Teardown]                      Delete All Sessions

