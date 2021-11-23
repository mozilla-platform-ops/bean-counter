#!/bin/bash

local_archive=/home/grenade/pt-logs/pt-logs
remote_archive=192.168.0.106:/home/grenade/pt-logs

ye=2021
#for mo in ${ye}-{01..12}; do
for mo in ${ye}-10; do
  for dt in ${mo}-{01..31}; do
    echo "- ${dt}"
    mkdir -p ${mo}/${dt}
    for archive in ./${dt}-{00..23}.tsv.gz; do
      bname=$(basename ${archive})
      dthr=${bname%%.*}
      #if [ -s ${mo}/${dt}/${dthr}.csv ] && grep -Fxq "${dt},${dthr##*-}," ${mo}/${dt}/${dthr}.csv; then
      if [ -s ${mo}/${dt}/${dthr}.csv ]; then
        echo "  - ${dthr}: detected previous processing"
      else
        echo "  - ${dthr}: processing..."
        if [ ! -f ${archive} ] && [ -s ${local_archive}/${bname} ] && gzip -t ${local_archive}/${bname}; then
          mv ${local_archive}/${bname} ${archive}
        fi
        if [ ! -s ${archive} ] || ! gzip -t ${archive}; then
          url=https://papertrailapp.com/api/v1/archives/${dthr}/download
          if scp ${remote_archive}/${bname} ${archive} && gzip -t ${archive}; then
            echo "    - ${archive} fetched from ${remote_archive}/${bname}"
          elif curl -sL \
            -H "X-Papertrail-Token: $(pass Mozilla/papertrail/grenade-token)" \
            -o ${archive}
            ${url} && gzip -t ${archive}; then
            echo "    - ${archive} fetched from ${url}"
          else
            echo "    - failed to fetch ${archive} from ${url}"
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
  done
  sort -u ${mo}/*.csv > ${mo}.csv
done
