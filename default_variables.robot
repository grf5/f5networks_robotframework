*** Variables ***
${ROBOT_HOST_IP}                    192.168.1.51
${IPV4_MGMT}                        192.168.1.101
${IPV6_MGMT}                        2607:fe80::192:168:1:101
${SSH_USERNAME}                     root
${SSH_PASSWORD}                     default
${GUI_USERNAME}                     admin
${GUI_PASSWORD}                     admin
${TESTED_TMOS_VERSION}              12.1.3.7
${TESTED_TMOS_BUILD}                0.0.2
${NTP_SERVER_LIST}                  {"servers":["0.pool.ntp.org","1.pool.ntp.org","172.31.255.255"]}
${SNMPv2_TRAP_HOST}                 {"name":"AAT-SNMPV2TRAPS","host":"192.168.1.51","version":"2c","port":"162"}
${SNMPV2_POLL_COMMUNITY}            AAT-SNMPV2POLL
${DEFAULT_VLAN_MTU}                 1500
${DESIRED_VLAN_MTU}                 9198
@{PHYS_INTERFACE_DETAILS}           {"name":"1.1","description":"Configured by ROBOT FRAMEWORK","lldpAdmin":"txrx"}    {"name":"1.2","description":"Configured by ROBOT FRAMEWORK","lldpAdmin":"txrx"}    {"name":"1.3","description":"Configured by ROBOT FRAMEWORK","lldpAdmin":"txrx"}
@{TRUNK_ATTRIBUTES}                 {"name":"test_trunk","description":"Configured by ROBOT FRAMEWORK","distributionHash":"src-dst-ipport","lacp":"disabled","lacpMode":"active","lacpTimeout":"short","stp":"enabled","interfaces":["1.1","1.2","1.3"]}
