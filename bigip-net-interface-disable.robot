*** Settings ***
Documentation    Suite description
...              This test concerns the configuration of physical interfaces
...               (f5_robot) f5admin@robot1:~/f5_robot$ curl -sk -u admin:admin -H "Content-type: application/json" https://192.168.1.101/mgmt/tm/net/interface/example | python3 -m json.tool
...               {
...                   "kind": "tm:net:interface:interfacecollectionstate",
...                   "selfLink": "https://localhost/mgmt/tm/net/interface/example?ver=12.1.3.7",
...                   "items": [
...                       {
...                           "propertyDescriptions": {
...                               "bundle": "Enables or disables bundle capability.",
...                               "bundleSpeed": "Sets the bundle speed. The speed is applicable only when the bundle is enabled.",
...                               "description": "User defined description.",
...                               "disabled": "Disables the specified interfaces from passing traffic.",
...                               "enabled": "Enables the specified interfaces to pass traffic.",
...                               "flowControl": "Specifies how the system controls the sending of PAUSE frames. The default value is tx-rx.",
...                               "forceGigabitFiber": "Enables or disables forcing of gigabit fiber media. If this is enabled for a gigabit fiber interface, the media setting will be forced, and no auto-negotiation will be performed. If it is disabled, auto-negotiation will be performed with just a single gigabit fiber option advertised.",
...                               "forwardErrorCorrection": "Enables or disables IEEE 802.3bm Clause 91 Reed-Solomon Forward Error Correction (RS-FEC) on 100G interfaces.  Not valid for LR4 media.",
...                               "lldpAdmin": "",
...                               "lldpTlvmap": "",
...                               "mediaFixed": "Specifies the settings for a fixed (non-pluggable) interface. Use this option only with a combo port to specify the media type for the fixed interface, when it is not the preferred port.",
...                               "mediaSfp": "Specifies the settings for an SFP (pluggable) interface. Use this option only with a combo port to specify the media type for the SFP interface, when it is not the preferred port.",
...                               "preferPort": "Indicates which side of a combo port the interface uses, if both sides have the potential for an external link. The default value for a combo port is sfp. Do not use this option for non-combo ports.",
...                               "qinqEthertype": "Specifies the protocol identifier associated with the tagged mode of the interface.",
...                               "sflow": {
...                                   "pollInterval": "Specifies the maximum interval in seconds between two pollings. To enable this setting, you must also set the poll-interval-global setting to no.",
...                                   "pollIntervalGlobal": "Specifies whether the global interface poll-interval setting overrides the object-level poll-interval setting. The default value is yes."
...                               },
...                               "stp": "Enables or disables STP. If you disable STP, no STP, RSTP, or MSTP packets are transmitted or received on the interface or trunk, and spanning tree has no control over forwarding or learning on the port or the trunk. The default value is enabled.",
...                               "stpAutoEdgePort": "Sets STP automatic edge port detection for the interface. The default value is true. When automatic edge port detection is set to true for an interface, the system monitors the interface for incoming STP, RSTP, or MSTP packets. If no such packets are received for a sufficient period of time (about three seconds), the interface is automatically given edge port status. When automatic edge port detection is set to false for an interface, the system never gives the interface edge port status automatically. Any STP setting set on a per-interface basis applies to all spanning tree instances. ",
...                               "stpEdgePort": "Specifies whether the interface connects to an end station instead of another spanning tree bridge. The default value is true.",
...                               "stpLinkType": "Specifies the STP link type for the interface. The default value is auto. The spanning tree system includes important optimizations that can only be used on point-to-point links, that is, on links which connect just two bridges. If these optimizations are used on shared links, incorrect or unstable behavior may result. By default, the implementation assumes that full-duplex links are point-to-point and that half-duplex links are shared."
...                           },
...                           "bundle": "not-supported",
...                           "bundleSpeed": "not-supported",
...                           "description": "",
...                           "enabled": true,
...                           "flowControl": "tx-rx",
...                           "forceGigabitFiber": "disabled",
...                           "forwardErrorCorrection": "not-supported",
...                           "lldpAdmin": "txonly",
...                           "lldpTlvmap": 130943,
...                           "mediaFixed": "auto",
...                           "mediaSfp": "auto",
...                           "preferPort": "sfp",
...                           "qinqEthertype": "0x8100",
...                           "sflow": {
...                               "pollInterval": 0,
...                               "pollIntervalGlobal": "yes"
...                           },
...                           "stp": "enabled",
...                           "stpAutoEdgePort": "enabled",
...                           "stpEdgePort": "true",
...                           "stpLinkType": "auto",
...                           "naturalKeyPropertyNames": [
...                               "name"
...                           ]
...                       }
...                   ]
...               }

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
Bounce a BIG-IP physical interface
    Generate Token
    Disable a BIG-IP physical interface
    Verify disabled state of BIG-IP physical interface
    Verify down state of BIG-IP physical interface
    Delete Token

*** Keywords ***
Disable a BIG-IP physical interface
    log                             Disabling interface ${TARGET_INTERFACE}
    &{api_payload}                  create dictionary       kind=tm:net:interface:interfacestate    name=${TARGET_INTERFACE}    disabled=${True}
    set test variable               &{api_payload}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${TARGET_INTERFACE}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json     ${api_response.content}
    dictionary should contain item    ${api_response_dict}      disabled    True
    [Teardown]                      Delete All Sessions

Verify disabled state of BIG-IP physical interface
    log                             Verifying the Disabling interface ${TARGET_INTERFACE}
    ${api_uri}                      set variable            /mgmt/tm/net/interface/${TARGET_INTERFACE}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    should be equal as strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    dictionary should contain item  ${api_response_dict}      disabled      True
    [Teardown]                      Delete All Sessions

Verify down state of BIG-IP physical interface
    log                             Verifying the Down state of interface ${TARGET_INTERFACE}
    ${api_uri}                      set variable       /mgmt/tm/net/interface/stats
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     200
    ${api_response_dict}            to json                         ${api_response.content}
    ${interface_stats_entries}      get from dictionary  ${api_response_dict}          entries
    ${interface_stats_dict}         get from dictionary  ${interface_stats_entries}    https://localhost/mgmt/tm/net/interface/${TARGET_INTERFACE}/stats
    ${interface_stats_dict}         get from dictionary  ${interface_stats_dict}       nestedStats
    ${interface_stats_dict}         get from dictionary  ${interface_stats_dict}       entries
    ${interface_status_dict}        get from dictionary  ${interface_stats_dict}       status
    ${interface_status}             get from dictionary  ${interface_status_dict}      description
    ${interface_tmname}             get from dictionary  ${interface_stats_dict}       tmName
    ${interface_tmname}             get from dictionary  ${interface_tmname}           description
    should be equal as strings      ${interface_status}  disabled
    [Teardown]                      Delete All Sessions
