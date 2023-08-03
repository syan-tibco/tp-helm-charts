outfile=${1:-fluentbit.conf}
cat - <<EOF > $outfile
[SERVICE]
    # Flush
    # =====
    # Set an interval of seconds before to flush records to a destination
    Flush        5

    # Daemon
    # ======
    # Instruct Fluent Bit to run in foreground or background mode.
    Daemon       Off

    # Log_Level
    # =========
    # Set the verbosity level of the service, values can be:
    #
    # - error
    # - warning
    # - info
    # - debug
    # - trace
    #
    # By default 'info' is set, that means it includes 'error' and 'warning'.
    Log_Level    info

    # Parsers_File
    # ============
    # Specify an optional 'Parsers' configuration file
    Parsers_File parsers.conf

    # HTTP Server
    # ===========
    # Enable/Disable the built-in HTTP Server for metrics
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_Port    ${TCM_LOGGER_PORT}

[INPUT]
    Name tail
    Alias mon.stdout
    Tag routable
    Path /logs/${MY_RELEASE}/mon-${MY_POD_NAME}/stdout.log
    Path_Key log.filename
    Key message
    Mem_Buf_Limit 1M
    Multiline On
    Parser_Firstline tcm

[INPUT]
    Name tail
    Alias srv.stdout
    Tag routable
    Path /logs/${MY_RELEASE}/srv-${MY_POD_NAME}/stdout.log
    Path_Key log.filename
    Key message
    Mem_Buf_Limit 1M
    Multiline On
    Parser_Firstline ftl

[INPUT]
    Name tail
    Alias watchdog.stdout
    Tag routable
    Path /logs/${MY_RELEASE}/${MY_POD_NAME}-watchdog.log
    Path_Key log.filename
    Key message
    Mem_Buf_Limit 1M
    Multiline On
    Parser_Firstline tcm

[FILTER]
    Name modify
    Alias subscription.filter
    Match *
    Add subscription.id ${MY_RELEASE}
    Add subscription.domain ${TCM_ACCT_DOMAIN}
    Add subscription.company ${TCM_ACCT_COMPANY}
    Add kubernetes.namespace ${TCM_NAMESPACE}
    Add kubernetes.pod.name ${MY_POD_NAME}
    Add kubernetes.pod.uid ${MY_K8S_UID}
    Add kubernetes.pod.ip ${MY_POD_IP}
    Add host.ip ${MY_NODE_IP}
    Add host.name ${MY_NODE_NAME}
    Rename service event.module
    Rename component event.category

@INCLUDE common.conf
@INCLUDE /data/output.conf
EOF
