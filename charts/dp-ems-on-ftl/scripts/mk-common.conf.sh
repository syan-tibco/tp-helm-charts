outfile=${1:-common.conf}
cat - <<EOF > $outfile
[FILTER]
    Name lua
    Match *
    Script datetime.lua
    Call datetime

[FILTER]
    Name record_modifier
    Match *
    Remove_key date
    Remove_key time

[FILTER]
    Name modify
    Alias common.filter
    Match *
    Add tcm.user ${TCM_USER}
    Add tcm.domain ${TCM_DNS_DOMAIN}
    Add kubernetes.container.name ${TCM_CID_NAME}
    Add cloud.account.name tcm
    Add cloud.account.id ${SYSTEM_AWS_ACCOUNT_ID}
    Add cloud.provider ${SYSTEM_WHERE}
    Add cloud.region ${SYSTEM_REGION}
    Add level info
    Rename message log.msg
    Rename level log.level
    Rename datetime @timestamp


# standardize log levels to allowed values INFO,ERROR,WARN,DEBUG
[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level EMERG
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level emerg
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level ALERT
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level CRIT
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level crit
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level seve
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level error
    Set log.level ERROR

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level WARNING
    Set log.level WARN

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level warn
    Set log.level WARN

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level NOTICE
    Set log.level INFO

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level notice
    Set log.level INFO

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level info
    Set log.level INFO

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.le    Condit    Set log.level DEBUG

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level VERBOSE
    Set log.level DEBUG

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level verb
    Set log.level DEBUG

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level dbg1
    Set log.level DEBUG

[FILTER]
    Name modify
    Match *
    Condition Key_Value_Equals log.level dbg2
    Condition Key_Value_Equals log.level dbg2
SfySfySfySfySfySfySfySfyition Key_Value_Equals log.level dbg3
    Set log.level DEBUG

# rewrite the tag for debug and verbose logs so we can re-route them (nowhere)
[FILTER]
    Name rewrite_tag
    Match routable
    Rule log.level /DEBUG/ non_routable false

# create structured output
[FILTER]
    Name nest
    Match routable
    Nest_Under subscription.tcm
    Wildcard tcm.*
    Remove_prefix tcm.

[FILTER]
    Name nest
    Match routable
    Nest_Under subscription
    Wildcard subscription.*
    Remove_prefix subscription.

[FILTER]
    Name nest
    Match routable
    Nest_Under log
    Wildcard log.*
    Remove_prefix log.

[FILTER]
    Name nest
    Match routable
    Nest_Under event
    Wildcard event.*
    Remove_prefix event.

[FILTER]
    Name nest
    Match routable
    Nest_Under kubernetes.pod
    Wildcard kubernetes.pod.*
    Remove_prefix kubernetes.pod.

[FILTER]
    Name nest
    Match routable
    Nest_Under kubernetes.container
    Wildcard kubernetes.container.*
    Remove_prefix kubernetes.container.

[FILTER]
    Name nest
    Match routable
    Nest_Under kubernetes
    Wildcard kubernetes.*
    Remove_prefix kubernetes.

[FILTER]
    Name nest
    Match routable
    Nest_Under cloud.account
    Wildcard cloud.account.*
    Remove_prefix cloud.account.

[FILTER]
    Name nest
    Match routable
    Nest_Under cloud
    Wildcard cloud.*
    Remove_prefix cloud.

[FILTER]
    Name nest
    Match routable
    Nest_Under host
    Wildcard host.*
    Remove_prefix host.
EOF
