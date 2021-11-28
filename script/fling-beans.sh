#!/bin/bash

while true; do
  cd /run/media/grenade/953af29f-6eba-461e-8c01-eae014e770e9/beans/data
  script/stir-beans.sh
  cd /run/media/grenade/953af29f-6eba-461e-8c01-eae014e770e9/beans
  git add .
  git commit -m "auto gleaned beans"
  git push origin main
  sleep 240
done
