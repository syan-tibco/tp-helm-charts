outfile=${1:-parsers.conf}
cat - <<EOF > $outfile

[MULTILINE_PARSER]
    name multiline-ems
    type regex
    flush_Timeout 1000
    key_content message
    #
    # Regex rules for multiline parsing
    # ---------------------------------
    #
    # configuration hints:
    #
    #  - first state always has the name: start_state
    #  - every field in the rule must be inside double quotes
    #
    # rules |   state name  | regex pattern                  | next state
    # ------|---------------|--------------------------------------------
    rule     "start_state"   "/^[\S]+\s+[0-9-]+\s[0-9:.]+\s+[\S]+.*/" "cont"
    rule     "cont"          "/^[\S]+\s+(?![0-9-]+\s)\S+/"            "cont"

[PARSER]
    Name emstibemsd
    Format regex
    # level, caller, msg, stacktrace, error, errorVerbose
    Regex   /^(?<caller>[^ ]+)\s+(?<date>[0-9-]+)\s(?<time>[0-9:.]+)\s+(?:(?<level>[a-z]+|[A-Z]+):?\s+)?(?<message>(?:\s+\w+?:\s+)?.*)/m

EOF