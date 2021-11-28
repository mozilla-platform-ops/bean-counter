#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
data_dir=${script_dir}/../data
task_dir=${data_dir}/task
mkdir -p ${task_dir}

while true; do
  ye=2021
  for mo in ${ye}-{01..12}; do
    for dt in ${mo}-{01..31}; do
      if date -d ${dt}; then
        for hr in ${dt}-{00..23}; do
          count_hr=0
          if [ -s ${data_dir}/${mo}/${dt}/${hr}.csv ]; then
            for task_id in $(cat ${data_dir}/${mo}/${dt}/${hr}.csv | cut -d ',' -f3); do
              #echo "  - ${task_id}"
              if [ ! -s ${task_dir}/${task_id}.json ]; then
                if curl -sL -o ${task_dir}/${task_id}.json https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}; then
                  echo "    - ${task_dir}/${task_id}.json fetched from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                elif [ -f ${task_dir}/${task_id}.json ]; then
                  rm ${task_dir}/${task_id}.json
                  echo "    - failed to fetch ${task_dir}/${task_id}.json from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                else
                  echo "    - failed to fetch ${task_dir}/${task_id}.json from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                fi
              fi
              if [ -s ${task_dir}/${task_id}.json ]; then
                queue=$(jq -r '.taskQueueId' ${task_dir}/${task_id}.json)
                name=$(jq -r '.metadata.name' ${task_dir}/${task_id}.json)
                if [ "${queue}" != "null" ] && ! grep -q ${task_id} ${data_dir}/task-${hr}.csv; then
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> ${data_dir}/task-${mo}.csv 
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> ${data_dir}/task-${dt}.csv
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> ${data_dir}/task-${hr}.csv
                fi
                ((count_hr=count_hr+1))
              fi
            done
            jq -Rsn '{
              "tasks": [
                inputs
                  | . / "\n"
                  | (.[] | select(length > 0) | . / ",") as $values
                  | {
                    "date": $values[0],
                    "hour": $values[1],
                    "queue": $values[2],
                    "task": {
                      "id": $values[3],
                      "name": $values[4]
                    }
                  }
               ]
            }' ${data_dir}/task-${hr}.csv > ${data_dir}/task-${hr}.json
          fi
          echo "- ${hr}: ${count_hr} tasks"
        done
        if [ -s task-${dt}.csv ]; then
          jq -Rsn '{
            "tasks": [
              inputs
                | . / "\n"
                | (.[] | select(length > 0) | . / ",") as $values
                | {
                  "date": $values[0],
                  "hour": $values[1],
                  "queue": $values[2],
                  "task": {
                    "id": $values[3],
                    "name": $values[4]
                  }
                }
             ]
          }' ${data_dir}/task-${dt}.csv > ${data_dir}/task-${dt}.json
        fi
      fi
    done
    if [ -s task-${mo}.csv ]; then
      jq -Rsn '{
        "tasks": [
          inputs
            | . / "\n"
            | (.[] | select(length > 0) | . / ",") as $values
            | {
              "date": $values[0],
              "hour": $values[1],
              "queue": $values[2],
              "task": {
                "id": $values[3],
                "name": $values[4]
              }
            }
         ]
      }' ${data_dir}/task-${mo}.csv > ${data_dir}/task-${mo}.json
    fi
  done
done
