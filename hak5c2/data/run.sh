#!/usr/bin/env bashio

LICENSE_KEY=$(bashio::config 'license.key')
LOGGING=$(bashio::config 'logging')
SSLCERTFILE=$(bashio::config 'certfile')
SSLKEYFILE=$(bashio::config 'keyfile')
C2HOSTNAME=$(bashio::config 'hostname')

## Main ##
if bashio::config.true 'ssl'; then
  /usr/src/app/c2_community-linux-64 -certFile /ssl/"$SSLCERTFILE" -keyFile /ssl/"$SSLKEYFILE" -hostname "${C2HOSTNAME}" -https -reverseProxy -reverseProxyPort 443 -listenport 8686
  WAIT_PIDS+=($!)
else
  /usr/src/app/c2_community-linux-64 -hostname "${C2HOSTNAME}" -reverseProxy -reverseProxyPort 80 -listenport 8686
  WAIT_PIDS+=($!)
fi

# Handling Closing
function stop_hak5c2() {
    bashio::log.info "Shutdown Hak5 C2 system"
    kill -15 "${WAIT_PIDS[@]}"

    wait "${WAIT_PIDS[@]}"
}
trap "stop_hak5c2" SIGTERM SIGHUP

# Wait and hold Add-on running
wait "${WAIT_PIDS[@]}"
