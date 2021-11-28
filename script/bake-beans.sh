#!/bin/bash

mkdir ./task

while true; do
  ye=2021
  for mo in ${ye}-{01..12}; do
    for dt in ${mo}-{01..31}; do
      if date -d ${dt}; then
        for hr in ${dt}-{00..23}; do
          echo "- ${hr}"
          if [ -s ${mo}/${dt}/${hr}.csv ]; then
            for task_id in $(cat ${mo}/${dt}/${hr}.csv | cut -d ',' -f3); do
              echo "  - ${task_id}"
              if [ ! -s ./task/${task_id}.json ]; then
                if curl -sL -o ./task/${task_id}.json https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}; then
                  echo "    - ./task/${task_id}.json fetched from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                elif [ -f ./task/${task_id}.json ]; then
                  rm ./task/${task_id}.json
                  echo "    - failed to fetch ./task/${task_id}.json from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                else
                  echo "    - failed to fetch ./task/${task_id}.json from https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${task_id}"
                fi
              else
                echo "    - ./task/${task_id}.json detected"
              fi
              if [ -s ./task/${task_id}.json ]; then
                queue=$(jq -r '.taskQueueId' ./task/${task_id}.json)
                name=$(jq -r '.metadata.name' ./task/${task_id}.json)
                if [ "${queue}" != "null" ] && ! grep -q ${task_id} task-${hr}.csv; then
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> task-${mo}.csv 
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> task-${dt}.csv
                  echo ${dt},${hr##*-},${queue},${task_id},${name} >> task-${hr}.csv
                fi
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
            }' task-${hr}.csv > task-${hr}.json
          fi
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
          }' task-${dt}.csv > task-${dt}.json
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
      }' task-${mo}.csv > task-${mo}.json
    fi
  done
done
