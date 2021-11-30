#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
data_dir=${script_dir}/../data

for json_path in ${data_dir}/task-*.json; do
  bname=$(basename ${json_path})
  task_dthr=${bname%%.*}
  timestamp=${task_dthr#*-}
  echo "- ${timestamp}"
  jq --arg period ${timestamp} '[ .tasks | group_by (.queue)[] | { queue: .[0].queue, tasks: length, period: $period } | select(.queue != "") ]' ${json_path} > ${data_dir}/count-${timestamp}.json
  case ${#timestamp} in
    7)
    [ -f ${data_dir}/count-month-${timestamp:0:4}.json ] || echo "[]" > ${data_dir}/count-month-${timestamp:0:4}.json
    jq -s '. | add' ${data_dir}/count-month-${timestamp:0:4}.json ${data_dir}/count-${timestamp}.json > ${data_dir}/count-month-${timestamp:0:4}-tmp.json
    mv ${data_dir}/count-month-${timestamp:0:4}-tmp.json ${data_dir}/count-month-${timestamp:0:4}.json
    ;;
    10)
    [ -f ${data_dir}/count-day-${timestamp:0:7}.json ] || echo "[]" > ${data_dir}/count-day-${timestamp:0:7}.json
    jq -s '. | add' ${data_dir}/count-day-${timestamp:0:7}.json count-${timestamp}.json > ${data_dir}/count-day-${timestamp:0:7}-tmp.json
    mv ${data_dir}/count-day-${timestamp:0:7}-tmp.json ${data_dir}/count-day-${timestamp:0:7}.json
    ;;
    13)
    [ -f ${data_dir}/count-hour-${timestamp:0:10}.json ] || echo "[]" > ${data_dir}/count-hour-${timestamp:0:10}.json
    jq -s '. | add' ${data_dir}/count-hour-${timestamp:0:10}.json ${data_dir}/count-${timestamp}.json > ${data_dir}/count-hour-${timestamp:0:10}-tmp.json
    mv ${data_dir}/count-hour-${timestamp:0:10}-tmp.json ${data_dir}/count-hour-${timestamp:0:10}.json
    ;;
  esac
  [ -f ${data_dir}/count-${timestamp}.json ] && rm ${data_dir}/count-${timestamp}.json
done

cd ${script_dir}/..
git pull
git config user.name "relops bean counter"
git config user.email "relops@mozilla.com"
git add data/count-*.json
git commit -m "auto gleaned beans"
git push origin main
sleep 240
