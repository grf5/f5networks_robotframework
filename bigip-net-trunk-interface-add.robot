*** Settings ***
Documentation    Suite description
...             This test concerns the configuration of physical interfaces

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot
${TARGET_INTERFACE}             1.3

*** Test Cases ***
Add Physical Interface to BIG-IP Trunk
    Generate Token
    Get Current List of Interfaces in BIG-IP Trunk
    Add Interface from BIG-IP Trunk
    Verify BIG-IP Trunk Interface Addition
    Delete Token

*** Keywords ***
Get Current List of Interfaces in BIG-IP Trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_object_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_interface_list}       get from dictionary             ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list                 ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    set test variable               ${initial_interface_list}
    [Teardown]                      Delete All Sessions

Add Interface from BIG-IP Trunk
    BIG-IP Clear API Parameters
    list should not contain value   ${initial_interface_list}       ${TARGET_INTERFACE}
    ${new_interface_list}           set variable                    ${initial_interface_list}
    append to list                  ${initial_interface_list}       ${TARGET_INTERFACE}
    log                       d      New interface list: ${initial_interface_list} ${new_interface_list}
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    &{api_payload}                  create dictionary               interfaces      ${new_interface_list}
    set test variable               &{api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_object_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface Addition
    BIG-IP Clear API Parameters
    log                             Verifying addition of physical interface from BIG-IP trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      set variable            /mgmt/tm/net/trunk/${trunk_object_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item     ${api_response_dict}      interfaces     ${new_interface_list}
    [Teardown]                      Delete All Sessions