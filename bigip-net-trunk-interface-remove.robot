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
Remove Physical Interface to BIG-IP Trunk
    Generate Token
    Get Current List of Interfaces in BIG-IP Trunk
    Remove Interface from BIG-IP Trunk
    Verify BIG-IP Trunk Interface Removal
    Delete Token

*** Keywords ***
Get Current List of Interfaces in BIG-IP Trunk
    log                             Getting list of existing interfaces on trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      /mgmt/tm/net/trunk/${trunk_object_name}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${initial_interface_list}       get from dictionary     ${api_response_dict}    interfaces
    ${initial_interface_list}       convert to list         ${initial_interface_list}
    log                             Initial Interface List: ${initial_interface_list}
    ${initial_interface_list}       set global variable       ${initial_interface_list}
    [Teardown]                      Delete All Sessions

Remove Interface from BIG-IP Trunk
    log                             Removing target interface from interface list
    list should contain value       ${initial_interface_list}       ${TARGET_INTERFACE}
    ${new_interface_list}           set variable                    ${initial_interface_list}
    set test variable               ${new_interface_list}
    remove values from list         ${initial_interface_list}       ${TARGET_INTERFACE}
    log                             New interface list: ${initial_interface_list} ${new_interface_list}
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    &{api_payload}                  create dictionary               interfaces      ${new_interface_list}
    ${api_uri}                      /mgmt/tm/net/trunk/${trunk_object_name}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    [Teardown]                      Delete All Sessions

Verify BIG-IP Trunk Interface Removal
    log                             Verifying removal of physical interface from BIG-IP trunk
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      /mgmt/tm/net/trunk/${trunk_object_name}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    log                             ${api_response_dict}
    dictionary should not contain value       ${api_response_dict}      ${TARGET_INTERFACE}
    [Teardown]                      Delete All Sessions
