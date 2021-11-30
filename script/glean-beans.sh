#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
data_dir=${script_dir}/../data
papertrail_token=${PAPERTRAIL_TOKEN:=$(pass Mozilla/papertrail/grenade-token)}

for ye in 2021; do
  for mo in ${ye}-{07..11}; do
    for dt in ${mo}-{01..31}; do
      if date -d ${dt} &> /dev/null; then
        echo "- ${dt}"
        mkdir -p ${mo}/${dt}
        for dthr in ${dt}-{00..23}; do
          archive=${data_dir}/${dthr}.tsv.gz
          #if [ -s ${mo}/${dt}/${dthr}.csv ] && grep -Fxq "${dt},${dthr##*-}," ${mo}/${dt}/${dthr}.csv; then
          if [ -s ${mo}/${dt}/${dthr}.csv ]; then
            echo "  - ${dthr}: detected previous processing"
          else
            echo "  - ${dthr}: processing..."
            if [ ! -s ${archive} ] || ! gzip -t ${archive}; then
              url=https://papertrailapp.com/api/v1/archives/${dthr}/download
              if curl \
                -H "X-Papertrail-Token: ${papertrail_token}" \
                -o ${archive} \
                -L ${url} && gzip -t ${archive}; then
                echo "    - ${archive} fetched from ${url}"
              else
                echo "    - failed to fetch ${archive} from ${url}"
                [ -f ${archive} ] && rm ${archive}
              fi
            else
              echo "    - ${archive} detected locally"
            fi
            if [ -s ${archive} ] && gzip -t ${archive}; then
              gzip -cd ${archive} | grep "finished successfully" | cut -f5,10 | sed -n 's/^\([^\t]*\)\t.* \([^\s]*\) finished successfully.*$/'${dt},${dthr##*-}',\2,\1/p' >> ${mo}/${dt}/${dthr}.csv
            fi
          fi
        done
        sort -u ${mo}/${dt}/${dt}-*.csv > ${mo}/${dt}.csv
      fi
    done
    sort -u ${mo}/*.csv > ${mo}.csv
  done
done
