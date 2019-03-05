*** Settings ***
Documentation       Suite description
...                 Testing SSH Connectivity

Resource            ${VARIABLES_FILENAME}
Resource            bigip-icontrol-api-general-keywords.robot
Library             SSHLibrary
Suite Setup
Suite Teardown

*** Variables ***
${VARIABLES_FILENAME}           default_variables.robot

*** Test Cases ***
Verify SSH Connectivity
    Open SSH Connection
    Login to SSH Session
    Run BASH Echo Test
    Close All Connections

*** Keywords ***
Open SSH Connection
    Open Connection     ${IPV4_MGMT}

Login to SSH Session
    Log In              ${SSH_USERNAME}     ${SSH_PASSWORD}

Run BASH Echo Test
    ${BASH_ECHO_RESPONSE} =     Execute Command                       echo 'BASH TEST'
    Should Be Equal             ${BASH_ECHO_RESPONSE}                 BASH TEST

