line=$(top -bn 1 | head -n 8 | tail -n 1 ); 
PID=$(echo $line | awk '{print $1}' ); 
USER=$(echo $line | awk '{print $2}' ); 
CPU=$(echo $line | awk '{print $9}' ); 
if [[ "$USER" != "root"  ]]; then 
    if [[ $(echo $CPU'>'50.0 | bc -l) ]]; then 
	#echo $USER; echo $PID; echo $CPU; 
	#kill -9 $PID; 
    fi; 
fi

