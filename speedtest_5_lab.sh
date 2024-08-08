#!/bin/bash

LOG_FILE="speedtest_5.log"
CSV_FILE="speedtest_5.csv"
SUMMARY_FILE="summary.csv"

# ฟังก์ชั่นเพื่อรันการทดสอบความเร็ว
run_speedtest() {
    echo "$(date) | Running Script By $USER@$HOSTNAME" >> $LOG_FILE

    speedtest-cli --csv-header > $CSV_FILE
    echo "SERVER ID, DATE, DOWNLOAD SPEED (Mbps), UPLOAD SPEED (Mbps)" > $SUMMARY_FILE

    total_download_speed=0
    total_upload_speed=0
    test_count=0

    for SERVER_ID in $(speedtest-cli --list | grep -o -E "[0-9]{1,5})" | grep -o "[0-9]*")
    do
        echo "SERVER ID: $SERVER_ID, $(date)"
        result=$(speedtest-cli --server $SERVER_ID --csv)
        echo $result >> $CSV_FILE

        download_speed=$(echo $result | cut -d ',' -f 7)
        upload_speed=$(echo $result | cut -d ',' -f 8)

        echo "$SERVER_ID, $(date), $download_speed, $upload_speed" >> $SUMMARY_FILE

        # คำนวณค่าความเร็วรวมเพื่อใช้หาค่าเฉลี่ย
        total_download_speed=$(echo "$total_download_speed + $download_speed" | bc)
        total_upload_speed=$(echo "$total_upload_speed + $upload_speed" | bc)
        test_count=$((test_count + 1))

        echo DONE
    done

    # คำนวณค่าเฉลี่ย
    if [ $test_count -gt 0 ]; then
        avg_download_speed=$(echo "$total_download_speed / $test_count" | bc -l)
        avg_upload_speed=$(echo "$total_upload_speed / $test_count" | bc -l)
    else
        avg_download_speed=0
        avg_upload_speed=0
    fi

    # เพิ่มสรุปลงในไฟล์ log
    echo "Average Download Speed: $avg_download_speed Mbps" >> $LOG_FILE
    echo "Average Upload Speed: $avg_upload_speed Mbps" >> $LOG_FILE

    # แสดงผลสรุปที่คอนโซล
    printf "Average Download Speed: %.2f Mbps\n" $avg_download_speed
    printf "Average Upload Speed: %.2f Mbps\n" $avg_upload_speed
}

# รันการทดสอบความเร็วทุก 1 นาที
while true; do
    run_speedtest
    sleep 60
done
