#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
data_dir=${script_dir}/../data
papertrail_token=${PAPERTRAIL_TOKEN:=$(pass Mozilla/papertrail/grenade-token)}

for ye in 2021; do
  for mo in ${ye}-{07..11}; do
    csv_mo=${data_dir}/${mo}.csv
    for dt in ${mo}-{01..31}; do
      csv_dt=${data_dir}/${mo}/${dt}.csv
      if date -d ${dt} &> /dev/null; then
        echo "- ${dt}"
        mkdir -p ${data_dir}/${mo}/${dt}
        for dthr in ${dt}-{00..23}; do
          archive=${data_dir}/${dthr}.tsv.gz
          csv_hr=${data_dir}/${mo}/${dt}/${dthr}.csv
          #if [ -s ${csv_hr} ] && grep -Fxq "${dt},${dthr##*-}," ${csv_hr}; then
          if [ -s ${csv_hr} ]; then
            echo "  - ${dthr}: detected previous processing (${csv_hr})"
          else
            echo "  - ${dthr}: processing (creating ${csv_hr})..."
            if [ ! -s ${archive} ] || ! gzip -t ${archive}; then
              url=https://papertrailapp.com/api/v1/archives/${dthr}/download
              if curl -s \
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
              gzip -cd ${archive} | grep "finished successfully" | cut -f5,10 | sed -n 's/^\([^\t]*\)\t.* \([^\s]*\) finished successfully.*$/'${dt},${dthr##*-}',\2,\1/p' >> ${csv_hr}
              echo "    - extracted $(wc -l < ${csv_hr}) tasks from ${dthr}.tsv.gz to ${csv_hr}"
            fi
          fi
        done
        sort -u ${data_dir}/${mo}/${dt}/${dt}-*.csv > ${csv_dt}
        echo "  - sorted $(wc -l < ${csv_dt}) tasks into ${csv_dt}"
      fi
    done
    sort -u ${data_dir}/${mo}/*.csv > ${csv_mo}
    echo "- sorted $(wc -l < ${csv_mo}) tasks into ${csv_mo}"
  done
done
