*** Settings ***
Resource            f5-icr-icontrol-api-general-keywords.robot
Library             SnmpLibrary

*** Keywords ***
Create BIG-IP SNMP Community
    [arguments]                     ${name}     ${communityName}    ${access}=ro    ${ipv6}=disabled    ${description}=
    ${api_payload}                  Create Dictionary   access=${access}     communityName=${communityName}      ipv6=${ipv6}   description=${description}    name=${name}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/sys/snmp/communities
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Create SNMPv3 User
    [arguments]                     ${name}     ${username}     ${authProtocol}     ${privacyProtocol}    ${authPassword}   ${privacyPassword}     ${securityLevel}
    ${api_uri}                      set variable                    /mgmt/tm/sys/snmp/users
    set test variable               ${api_uri}
    ${api_payload}                  create dictionary       name=${name}     username=${username}     authProtocol=${authProtocol}   privacyProtocol=${privacyProtocol}    authPassword=${authPassword}   privacyPassword=${privacyPassword}     securityLevel=${securityLevel}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Delete SNMP Community
    [arguments]                     ${name}
    ${api_uri}                      set variable                        /mgmt/tm/sys/snmp/communities/${name}
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth DELETE
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Remove Host from BIG-IP SNMP Allow-List
    [arguments]                     ${snmphost}
    ${api_uri}                      set variable                    /mgmt/tm/sys/snmp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${snmp-allow-list}              evaluate        json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}              Get from Dictionary         ${snmp-allow-list}      allowedAddresses
    Log                             Pre-modification SNMP allow list: ${snmp-allow-list}
    Remove from List                ${snmp-allow-list}      ${snmphost}
    Log                             Post-modification SNMP allow list: ${snmp-allow-list}
    BIG-IP Clear API Parameters
    ${api_uri}                      set variable                    /mgmt/tm/sys/snmp
    set test variable               ${api_uri}
    ${api_payload}                  Create Dictionary               allowedAddresses=${snmp-allow-list}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Add Host to BIG-IP SNMP Allow-List
    [Arguments]                     ${snmphost}
    ${api_uri}                      set variable                    /mgmt/tm/sys/snmp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth GET
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    ${snmp-allow-list}              evaluate        json.loads('''${api_response.content}''')   json
    ${snmp-allow-list}              Get from Dictionary         ${snmp-allow-list}      allowedAddresses
    Append to List                  ${snmp-allow-list}      ${snmphost}
    BIG-IP Clear API Parameters
    ${api_uri}                      set variable                    /mgmt/tm/sys/snmp
    ${api_payload}                  Create Dictionary               allowedAddresses=${snmp-allow-list}
    set test variable               ${api_payload}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Get SNMPv2 IPv4 sysDescr
    [Arguments]                     ${snmphost}     ${snmpcommunity}        ${snmpv2_port}      ${snmpv2_timeout}       ${snmpv2_retries}
    ${connect_status}               Open Snmp Connection        host=${snmphost}    community_string=${snmpcommunity}   port=${snmpv2_port}     timeout=${snmpv2_timeout}       retries=${snmpv2_retries}
    Log                             SNMP Connect Status: ${connect_status}
    ${snmp_ipv4_sysDescr} =         Get Display String             .iso.3.6.1.2.1.1.5
    Log                             SNMP value for OID .iso.3.6.1.2.1.1.5 returned: ${snmp_ipv4_sysDescr}
    [Teardown]                      Close All Snmp Connections

Create New SNMPv3 User on BIG-IP
    ${api_payload}                  create dictionary       name    ${SNMPV3_USER}      username    ${SNMPV3_USER}      authPassword    ${SNMPV3_AUTH_PASS}     authProtocol    ${SNMPV3_AUTH_PROTO}    privacyPassword     ${SNMPV3_PRIV_PASS}     privacyProtocol     ${SNMPV3_PRIV_PROTO}        securityLevel   ${SNMPV3_SECURITY_LEVEL}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/sys/snmp/users
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Get SNMPv3 IPv4 sysDescr
    [Arguments]                     ${snmphost}     ${snmpv3_user}      ${snmpv3_auth_pass}     ${snmpv3_priv_pass}     ${snmpv3_auth_proto}        ${snmpv3_priv_proto}    ${snmpv3_port}      ${snmpv3_timeout}   ${snmpv3_retries}
    ${connect_status}               Open Snmp V3 Connection        ${snmphost}     ${snmpv3_user}      ${snmpv3_auth_pass}     ${snmpv3_priv_pass}     ${snmpv3_auth_proto}        ${snmpv3_priv_proto}    ${snmpv3_port}      ${snmpv3_timeout}   ${snmpv3_retries}
    Log                             SNMP Connect Status: ${connect_status}
    ${snmp_ipv4_sysDescr} =         Get Display String             .iso.3.6.1.2.1.1.5
    Log                             SNMP value for OID .iso.3.6.1.2.1.1.5 returned: ${snmp_ipv4_sysDescr}
    [Teardown]                      Close All Snmp Connections

Create BIG-IP SNMPv2 Trap Destination
    [Arguments]                     ${snmphost}
    ${api_payload}                  to json                 ${snmphost}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/sys/snmp
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth PATCH
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Trigger an SNMPv2 Trap on the BIG-IP
    [Arguments]                     ${snmpv2_trap_facility}     ${snmpv2_trap_level}        ${snmpv2_trap_message}
    ${api_payload}                  create dictionary       command     run     utilCmdArgs     -c "logger -p ${snmpv2_trap_facility}}.${snmpv2_trap_level}} '${snmpv2_trap_message}}'"
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/util/bash
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Walk SNMPv3 Host
    [Arguments]                     ${snmphost}     ${snmpv3_user}      ${snmpv3_auth_pass}     ${snmpv3_priv_pass}     ${snmpv3_auth_proto}        ${snmpv3_priv_proto}    ${snmpv3_port}      ${snmpv3_timeout}   ${snmpv3_retries}
    ${connect_status}               Open Snmp V3 Connection        ${snmphost}     ${snmpv3_user}      ${snmpv3_auth_pass}     ${snmpv3_priv_pass}     ${snmpv3_auth_proto}        ${snmpv3_priv_proto}    ${snmpv3_port}      ${snmpv3_timeout}   ${snmpv3_retries}
    Log                             SNMP Connect Status: ${connect_status}
    ${walk_response}                walk                .iso.3.6.1.2.1.1
    log                             SNMP Walk Result: ${walk_response}

Create BIG-IP SNMPv3 Trap Destination
    [Arguments]                     ${snmphost}     ${snmpv3_user}      ${snmpv3_auth_pass}     ${snmpv3_priv_pass}     ${snmpv3_auth_proto}        ${snmpv3_priv_proto}    ${snmpv3_port}      ${snmpv3_community}     ${snmpv3_security_level}    ${snmpv3_security_name}
    ${api_payload}                  create dictionary       name=robot_framework_snmpv3  authPassword=${snmpv3_auth_pass}     authProtocol=${snmpv3_auth_proto}     community=${snmpv3_community}     host=${snmphost}     port=${${snmpv3_port}}  privacyPassword=${snmpv3_priv_pass}     privacyProtocol=${snmpv3_priv_proto}    securityName=${snmpv3_security_name}     version=3   securityLevel=${snmpv3_security_level}
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/sys/snmp/traps
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions

Trigger an SNMPv3 Trap on the BIG-IP
    BIG-IP Clear API Parameters
    ${api_payload}                  create dictionary       command     run     utilCmdArgs     -c "logger -p ${SNMPV3_TRAP_FACILITY}.${SNMPV3_TRAP_LEVEL} '${SNMPV3_TRAP_MESSAGE}'"
    set test variable               ${api_payload}
    ${api_uri}                      set variable            /mgmt/tm/util/bash
    set test variable               ${api_uri}
    ${api_response}                 BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
    [Teardown]                      Delete All Sessions