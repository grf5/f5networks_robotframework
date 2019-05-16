*** Settings ***
Resource        f5-icr-icontrol-api-general-keywords.robot

*** Keywords ***
Create a BIG-IP Client SSL Profile
    [Arguments]         ${name}	 	${partition}=Common     ${alertTimeout}=indefinite	 	${allowDynamicRecordSizing}=disabled	 	${allowExpiredCrl}=disabled	 	${allowNonSsl}=disabled	 	${authenticate}=once	 	${authenticateDepth}=9	${cacheSize}=262144	${cacheTimeout}=3600	${cert}=/Common/default.crt	 	${certLifespan}=30	${certLookupByIpaddrPort}=disabled	 	${ciphers}=DEFAULT	 	${defaultsFrom}=/Common/clientssl	 	${forwardProxyBypassDefaultAction}=intercept	 	${genericAlert}=enabled	 	${handshakeTimeout}=10	 	${inheritCertkeychain}=true	 	${key}=/Common/default.key	 	${kind}=tm:ltm:profile:client-ssl:client-sslstate	 	${maxActiveHandshakes}=indefinite	 	${maxAggregateRenegotiationPerMinute}=indefinite	 	${maxRenegotiationsPerMinute}=5	${maximumRecordSize}=16384	${modSslMethods}=disabled	 	${mode}=enabled	 	${peerCertMode}=ignore	 	${peerNoRenegotiateTimeout}=10	 	${proxySsl}=disabled	 	${proxySslPassthrough}=disabled	 	${renegotiateMaxRecordDelay}=indefinite	 	${renegotiatePeriod}=indefinite	 	${renegotiateSize}=indefinite	 	${renegotiation}=enabled	 	${retainCertificate}=true	 	${secureRenegotiation}=require	 	${sessionMirroring}=disabled	 	${sessionTicket}=disabled	 	${sessionTicketTimeout}=0	${sniDefault}=false	 	${sniRequire}=false	 	${sslForwardProxy}=disabled	 	${sslForwardProxyBypass}=disabled	 	${sslSignHash}=any	 	${strictResume}=disabled	 	${uncleanShutdown}=enabled
    Set Log Level       Debug
    ${api_payload}      create dictionary   name=${name}    partition=${partition}  name=${name}    alertTimeout=${alertTimeout}    allowDynamicRecordSizing=${allowDynamicRecordSizing}    allowExpiredCrl=${allowExpiredCrl}    allowNonSsl=${allowNonSsl}    authenticate=${authenticate}    authenticateDepth=${authenticateDepth}    certLifespan=${certLifespan}    ciphers=${ciphers}    defaultsFrom=${defaultsFrom}    forwardProxyBypassDefaultAction=${forwardProxyBypassDefaultAction}    genericAlert=${genericAlert}    handshakeTimeout=${handshakeTimeout}    inheritCertkeychain=${inheritCertkeychain}    key=${key}    kind=${kind}    maxActiveHandshakes=${maxActiveHandshakes}    maxAggregateRenegotiationPerMinute=${maxAggregateRenegotiationPerMinute}    maxRenegotiationsPerMinute=${maxRenegotiationsPerMinute}    mode=${mode}    peerCertMode=${peerCertMode}    peerNoRenegotiateTimeout=${peerNoRenegotiateTimeout}    proxySsl=${proxySsl}    proxySslPassthrough=${proxySslPassthrough}    renegotiateMaxRecordDelay=${renegotiateMaxRecordDelay}    renegotiatePeriod=${renegotiatePeriod}    renegotiateSize=${renegotiateSize}    renegotiation=${renegotiation}    retainCertificate=${retainCertificate}    secureRenegotiation=${secureRenegotiation}    sessionMirroring=${sessionMirroring}    sessionTicket=${sessionTicket}    sessionTicketTimeout=${sessionTicketTimeout}    sniRequire=${sniRequire}    sslForwardProxy=${sslForwardProxy}    sslForwardProxyBypass=${sslForwardProxyBypass}    sslSignHash=${sslSignHash}    strictResume=${strictResume}    uncleanShutdown=${uncleanShutdown}
    set test variable   ${api_payload}
    ${api_uri}          set variable    /mgmt/tm/ltm/profile/client-ssl
    set test variable   ${api_uri}
    ${api_response}     BIG-IP iControl TokenAuth POST
    Should Be Equal As Strings      ${api_response.status_code}     ${HTTP_RESPONSE_OK}
