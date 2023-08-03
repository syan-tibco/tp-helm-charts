# ............... WATCHDOG CONFIG .............
export TCM_SUB_ID=${TCM_SUB_ID:-hello}
export MY_POD_NAME="${MY_POD_NAME:-$(hostname)}"
outfile=${1:-watchdog.yml}
cat - <<EOF > $outfile
services:
  - name: ftl
    config:
      cmd: /opt/tibco/ftl/bin/tibftlserver -n ${MY_POD_NAME} -c /logs/${MY_POD_NAME}/boot/ftlserver.yml
      # cmd: wait-for-shutdown.sh
      cwd: /logs/${MY_POD_NAME}
      log:
        size: 200
        num: 50
        # debugfile: /logs/${MY_POD_NAME}/ftlserver.log
        rotateonfirststart: true
  # - name: fluentbit
  #   config:
  #     cmd: /opt/td-agent-bit/bin/td-agent-bit -c /data/fluentbit.conf
  #     # cwd must be unique for each service when using shared volumes
  #     # because services generate lots of metadata (lock files, pid files)
  #     cwd: /logs/${MY_POD_NAME}/fluentbits
  #     logger: stdout
  #     log:
  #       size: 200
  #       num: 25
  #       rotateonfirststart: true
EOF
