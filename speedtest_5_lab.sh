#!/bin/bash
speedtest-cli  --csv-header > speedtest_5.csv
for SERVER_ID in $(speedtest-cli --list | grep -o -E "[0-9]{1,5})" | grep -o "[0-9]*")
do
  echo "SERVER ID: $SERVER_ID, $(date)"
  speedtest-cli --server $SERVER_ID --csv >> speedtest_5.csv
  echo DONE
done
