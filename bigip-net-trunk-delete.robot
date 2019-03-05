*** Settings ***
Documentation    Suite description
...             This test concerns the configuration of physical interfaces
...             {
...                 "kind": "tm:net:trunk:trunkcollectionstate",
...                 "selfLink": "https://localhost/mgmt/tm/net/trunk/example?ver=12.1.3.7",
...                 "items": [
...                     {
...                         "propertyDescriptions": {
...                             "appService": "The application service that the object belongs to.",
...                             "description": "User defined description.",
...                             "distributionHash": "Specifies the basis for the hash that the system uses as the frame distribution algorithm. The system uses the resulting hash to determine which interface to use for forwarding traffic.",
...                             "interfaces": "Specifies the interfaces by name separated by spaces that you want to add to the trunk, delete from the trunk, or with which you want to replace all existing interfaces associated with the trunk.",
...                             "lacp": "Specifies, when enabled, that the system supports the link aggregation control protocol (LACP), which monitors the trunk by exchanging control packets over the member links to determine the health of the links. If LACP detects a failure in a member link, it removes the link from the link aggregation. LACP is disabled by default, for backward compatibility.",
...                             "lacpMode": "Specifies the operation mode for link aggregation control protocol (LACP), if LACP is enabled for the trunk.",
...                             "lacpTimeout": "Specifies the rate at which the system sends the LACP control packets.",
...                             "linkSelectPolicy": "Sets the LACP policy that the trunk uses to determine which member link (interface) can handle new traffic. Note that link aggregation is allowed only when all the interfaces are operating at the same media speed and connected to the same partner aggregation system. When there is a mismatch among configured members due to configuration errors or topology changes (auto-negotiation), link selection policy determines which links become working members and form the aggregation.",
...                             "qinqEthertype": "Specifies the protocol identifier associated with the tagged mode of the trunk.",
...                             "stp": "Enables or disables STP. If you disable STP, the system does not transmit or receive STP, RSTP, or MSTP packets on the trunk, and STP has no control over forwarding or learning on the trunk. The default value is enabled."
...                         },
...                         "appService": "",
...                         "description": "",
...                         "distributionHash": "src-dst-ipport",
...                         "interfaces": [],
...                         "lacp": "disabled",
...                         "lacpMode": "active",
...                         "lacpTimeout": "long",
...                         "linkSelectPolicy": "auto",
...                         "qinqEthertype": "0x8100",
...                         "stp": "enabled",
...                         "naturalKeyPropertyNames": [
...                             "name"
...                         ]
...                     }
...                 ]
...             }

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             Collections
Library             RequestsLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Delete F5 BIG-IP aggregate interface
    Generate Token
    Delete BIG-IP trunk object
    Delete Token

*** Keywords ***
Delete BIG-IP trunk object
    log                             Beginning trunk object configuration
    ${trunk_object_payload}         to json     @{TRUNK_ATTRIBUTES}
    ${trunk_object_name}            get from dictionary     ${trunk_object_payload}     name
    ${api_uri}                      set variable        /mgmt/tm/net/trunk/${trunk_object_name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     200
    delete all sessions
    BIG-IP Clear API Parameters
    ${api_uri}                      set variable        /mgmt/tm/net/trunk/${trunk_object_name}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     404
    [Teardown]                      Delete All Sessions
