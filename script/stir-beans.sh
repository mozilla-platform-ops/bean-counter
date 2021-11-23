#!/bin/bash

rm count-{month,day,hour}-*.json

for json_path in task-*.json; do
  bname=$(basename ${json_path})
  task_dthr=${bname%%.*}
  timestamp=${task_dthr#*-}
  echo "- ${timestamp}"
  jq --arg period ${timestamp} '[ .tasks | group_by (.queue)[] | { queue: .[0].queue, tasks: length, period: $period } | select(.queue != "") ]' ${json_path} > count-${timestamp}.json
  case ${#timestamp} in
    7)
    [ -f count-month-${timestamp:0:4}.json ] || echo "[]" > count-month-${timestamp:0:4}.json
    jq -s '. | add' count-month-${timestamp:0:4}.json count-${timestamp}.json > count-month-${timestamp:0:4}-tmp.json
    mv count-month-${timestamp:0:4}-tmp.json count-month-${timestamp:0:4}.json
    ;;
    10)
    [ -f count-day-${timestamp:0:7}.json ] || echo "[]" > count-day-${timestamp:0:7}.json
    jq -s '. | add' count-day-${timestamp:0:7}.json count-${timestamp}.json > count-day-${timestamp:0:7}-tmp.json
    mv count-day-${timestamp:0:7}-tmp.json count-day-${timestamp:0:7}.json
    rm count-${timestamp}.json
    ;;
    13)
    [ -f count-hour-${timestamp:0:10}.json ] || echo "[]" > count-hour-${timestamp:0:10}.json
    jq -s '. | add' count-hour-${timestamp:0:10}.json count-${timestamp}.json > count-hour-${timestamp:0:10}-tmp.json
    mv count-hour-${timestamp:0:10}-tmp.json count-hour-${timestamp:0:10}.json
    ;;
  esac
  [ -f count-${timestamp}.json ] && rm count-${timestamp}.json
done
