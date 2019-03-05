*** Settings ***
Documentation    Suite description
...             This test adds an entry to the SSH allow ACL on the BIG-IP

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot
${NEW_CIDR_ENTRY}               192.168.0.0/16

*** Test Cases ***
Add CIDR Entry to BIG-IP SSHd Allow ACL
    Generate Token
    Get Current SSH Allow ACL
    Apply new SSH Allow ACL
    Verify SSH Allow ACL Configuration
    Delete Token

*** Keywords ***
Get Current SSH Allow ACL
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_sshd_allow_acl}       get from dictionary     ${api_response_dict}    allow
    log                             Initial SSH Allow ACL: ${initial_sshd_allow_acl}
    set test variable               ${initial_sshd_allow_acl}
    [Teardown]                      Delete All Sessions

Apply new SSH Allow ACL
    list should not contain value   ${initial_sshd_allow_acl}       ${NEW_CIDR_ENTRY}
    ${new_sshd_allow_acl}           set variable                    ${initial_sshd_allow_acl}
    append to list                  ${new_sshd_allow_acl}           ${NEW_CIDR_ENTRY}
    log                             Updated SSH Allow ACL: ${new_sshd_allow_acl}
    &{api_payload}                  create dictionary               allow      ${new_sshd_allow_acl}
    set test variable               &{api_payload}
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Verify SSH Allow ACL Configuration
    ${api_uri}                      set variable                    /mgmt/tm/sys/sshd
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${sshd_allow_acl}               get from dictionary     ${api_response_dict}         allow
    list should contain value       ${sshd_allow_acl}     ${NEW_CIDR_ENTRY}
    [Teardown]                      Delete All Sessions
