*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot
Library             SSHLibrary

*** Keywords ***
Get Current SSH Allow ACL
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_sshd_allow_acl}       get from dictionary     ${api_response_dict}    allow
    log                             Initial SSH Allow ACL: ${initial_sshd_allow_acl}
    set test variable               ${initial_sshd_allow_acl}
    [Teardown]                      Delete All Sessions

Add Host to SSH Allow ACL
    [Arguments]                     ${new_ssh_host}
    Get Current SSH Allow ACL
    list should not contain value   ${initial_sshd_allow_acl}       ${new_ssh_host}
    ${new_sshd_allow_acl}           set variable                    ${initial_sshd_allow_acl}
    append to list                  ${new_sshd_allow_acl}           ${new_ssh_host}
    log                             Updated SSH Allow ACL: ${new_sshd_allow_acl}
    &{api_payload}                  create dictionary               allow      ${new_sshd_allow_acl}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Remove Host from SSH Allow ACL
    [Arguments]                     ${ssh_host}
    Get Current SSH Allow ACL
    list should contain value       ${initial_sshd_allow_acl}       ${ssh_host}
    ${new_sshd_allow_acl}           set variable                    ${initial_sshd_allow_acl}
    remove values from list         ${new_sshd_allow_acl}           ${ssh_host}
    log                             Updated SSH Allow ACL: ${new_sshd_allow_acl}
    &{api_payload}                  create dictionary               allow      ${new_sshd_allow_acl}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Verify SSH Allow ACL
    [Arguments]                     ${verify_ssh_host}
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${api_response_dict}            to json                         ${api_response.content}
    ${sshd_allow_acl}               get from dictionary             ${api_response_dict}         allow
    list should contain value       ${sshd_allow_acl}               ${verify_ssh_host}
    [Teardown]                      Delete All Sessions

Run BASH Echo Test
    ${BASH_ECHO_RESPONSE}           Execute Command                       echo 'BASH TEST'
    Should Be Equal                 ${BASH_ECHO_RESPONSE}                 BASH TEST
