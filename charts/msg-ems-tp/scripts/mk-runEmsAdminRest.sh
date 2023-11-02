#!/bin/bash 
#
# Copyright (c) 2023. Cloud Software Group, Inc.
# This file is subject to the license terms contained 
# in the license file that is distributed with this file.  
#

bootDir=${1:-"/logs/$MY_POD_NAME/boot"}
outfile="$bootDir/runEmsAdminRest.sh"

export MY_POD_NAME=${MY_POD_NAME:-$(hostname)}
export EMS_TCP_PORT=${EMS_TCP_PORT:-"9011"}

# FIXME : Mount admin user/password from K8s secret

# Generate start script
cat - <<EOF > $outfile
#!/bin/bash
TIBEMS_ROOT=/opt/tibco/ems/current-version
TIBEMS_LIB=\$TIBEMS_ROOT/lib
TIBEMS_BIN=\$TIBEMS_ROOT/bin
export LD_LIBRARY_PATH="\$TIBEMS_LIB:\$LD_LIBRARY_PATH"

tibemsrestd --config $bootdir/ems-admin-config.yaml

EOF
chmod +x $outfile

cat - <<EOF > $bootdir/ems-admin-config.yaml
# Example EMS REST Server configuration file.

# The EMS REST Server can be configured via a yaml configuration
# file like this, via command-line options, or via environment
# variables (or via any combination of those three).
# Command-line options have the highest priority, followed by
# environment variables, followed by configuration files, which
# have the lowest priority.

# Nearly every option can be set via any of the three methods,
# with a few sensible exceptions (e.g. the path to the configuration
# itself must be specified via either a '--config /path/to/config.yaml'
# command-line option or a 'EMS_CONFIG=/path/to/config.yaml' environment
# variable... it can't be specified inside the config file itself.

# In general, the command-line flag equivalent of any option from
# the configuration file has the same name and value type, with a
# period (.) used for hierarchy.  E.g., to set the REST proxy's
# server certificate file via the command-line, the option would
# be:
# --proxy.certificate /path/to/cert.pem
#
# For environment variables, make the option name all uppercase,
# prefix "EMSRESTD_" to the front of it, and use an underscore (_) as the
# hierarchical separator.  E.g.:
# EMS_PROXY_CERTIFICATE=/path/to/cert.pem
#
# A few options (like "listeners") are lists.  When specifying
# lists on the command-line or via an environment variable,
# list items are comma-separated.  E.g.:
# --proxy.listeners localhost:8080,localhost:8081
# EMS_PROXY_LISTENERS=localhost:8080,localhost:8081


# Valid values in ascending order of amount of output:
# "panic", "fatal", "error", "warn", "info", "debug", "trace"
# Default value is "info"
loglevel: debug

# Options in the 'proxy' section mostly apply between clients of the proxy
# and the proxy itself.
proxy:
  # Name of this EMS Rest proxy instance. Used only for display and logging.
  name: "$MY_POD_NAME"
  # List of interface:port pairs the proxy should listen on.
  listeners:
    - 0.0.0.0:$EMS_ADMIN_PORT
  # Maximum time a session will remain valid after initial login. In seconds.
  # 0 (zero) means no time limit (session will remain valid until logged out).
  session_timeout: 0
  # Maximum number of items to return at one time for REST APIs that support
  # paging. A value of 0 means unlimited. This limit will override a user's
  # 'limit' query parameter if the user-requested limit is higher. The
  # default value is 100.
  page_limit: 4000
  # TLS is enabled by default. To enable plaintext http, set 'disable_tls'
  # below to true.
  # WARNING: Disabling TLS means user credentials and tokens will be
  # transmitted in plaintext and potentially expose the proxy to a wide
  # range of attacks and security problems. This is an enormous security
  # risk. Please only disable TLS at the proxy if you are certain you
  # have considered and otherwise addressed the security problems doing so
  # will create.
  disable_tls: true
  # The TLS server certificate to use with the list of listeners above.
  # *** FIXME: Allow HTTP ***
  # TLS is _required_. The EMS REST proxy does not support plaintext
  # http connections. If a certificate is not configured, a temporary
  # random self-signed certificate and key will be generated at startup.
  # Must be PEM-encoded.
  # certificate: /opt/tibco/ems/10.2/samples/certs/server.cert.pem
  # Private key file for the server certificate above. Must be PEM-encoded PKCS#8.
  # private_key: /opt/tibco/ems/10.2/samples/certs/server.key.p8
  # If the private key file is encrypted, the password to decrypt it can be
  # given below.  It is usually more secure, however, to use the
  # EMS_PROXY_PRIVATE_KEY_PASSWORD environment variable instead, or a
  # protected file containing the password, as below.
  # private_key_password: password
  # The private key password can also be specified via a file.
  #private_key_password_file: /path/to/password_file
  # Certificates and CAs to trust when verifying a client certificate.
  # Required if 'require_client_certificate' below is true
  # trusted_client_certificates: /opt/tibco/ems/10.2/samples/certs/client_root.cert.pem
  # Require clients connecting to the proxy to present a valid and trusted
  # client certificate. Default is false.
  require_client_certificate: true

# Items in the "ems" section relate to the connection between the proxy and the EMS servers.
ems:
  # List of EMS broker URLs to attempt to connect to.
  brokers:
    - tcp://localhost:$EMS_TCP_PORT
  # List of health check URLs that ALL must respond with a 200 status
  # to a 'GET /isReady' check for the proxy's own 'GET /health' API to return OK.
  health_check_urls:
    - http://localhost:$EMS_HTTP_PORT
  # EMS client ID of the proxy itself
  client_id: "EMS REST Proxy"
  # The EMS server's certificate or a CA certificate to trust.
  # Required if the EMS server is using TLS
  # certificate: /opt/tibco/ems/10.2/samples/certs/server_root.cert.pem
  # Verify that the EMS server's hostname matches its certificate. Defaults to true
  verify_hostname: false
  # The client certificate to use when connecting as a client to the EMS server.
  # client_certificate: /opt/tibco/ems/10.2/samples/certs/client.cert.pem
  # Private key for the above client certificate. PEM-formatted PKCS8.
  # client_private_key: /opt/tibco/ems/10.2/samples/certs/client.key.p8
  # If the client private key file is encrypted, the password to decrypt it can be
  # given below.  It is usually more secure, however, to use the
  # EMS_EMS_CLIENT_PRIVATE_KEY_PASSWORD environment variable instead, or a
  # protected file containing the password, as below.
  # client_private_key_password: password
  # The private key password can also be specified via a file.
  # client_private_key_password_file: /path/to/password_file
  # The certificate_authority section is optional and is used to
  # generate client certificates to use to connect to the EMS
  # server if needed (e.g. the EMS server has been configured to
  # require client certificates and to use them for authentication).
  certificate_authority:
    # The CA root certificate.
    # Required if either of 'clone_client_certificates' or
    # 'generate_missing_client_certificates' below are true
    # certificate: /opt/tibco/ems/10.2/samples/certs/client_root.cert.pem
    # private_key: /opt/tibco/ems/10.2/samples/certs/client_root.key.p8 # required if 'ca_certificate' is set
    # private_key_password: password
    #private_key_password_file: /path/to/password_file
    # If true and proxy client has connected to the proxy with a client cert
    # that the proxy trusts, the proxy will create a new client cert with same
    # user ID to use to connect to the EMS server; this cert will be used for
    # this particular client instead of 'tls.client_certificate' in the section
    # above. Defaults to false.
    # clone_client_certificates: true
EOF
