RECORDINGS_DIR=~/Recordings

if [ "$1" = "--start" ]; then
  REGION="$(slurp)"
  [ -z "$REGION" ] && notify-send -i dialog-error "No region selected" && exit

  FILENAME=$(zenity --entry --title="Recording name" --text="Enter file name (without extension):")
  if [ $? -ne 0 ]; then
    notify-send -i dialog-warning "Recording canceled"
    exit
  fi
  [ -z "$FILENAME" ] && FILENAME="recording"

  FULL_FILENAME="${FILENAME}_$(date +%Y-%m-%d_%H-%M-%S).mp4"
  nid=$(notify-send -i dialog-information "Recording $FULL_FILENAME" "Recording in 3..." -t 2800 --print-id)
  sleep 1
  notify-send -i dialog-information "Recording $FULL_FILENAME" "Recording in 2..." --replace-id=$nid
  sleep 1
  notify-send -i dialog-information "Recording $FULL_FILENAME" "Recording in 1..." --replace-id=$nid
  sleep 0.8
  notify-send -i dialog-information "Recording $FULL_FILENAME" "Recording!" --replace-id=$nid -t 150
  sleep 0.2
  wf-recorder -g "$REGION" -f "$RECORDINGS_DIR/${FILENAME}_$(date +%Y-%m-%d_%H-%M-%S).mp4"
elif [ "$1" = "--stop" ]; then
    pkill wf-recorder \
        && notify-send -i dialog-information "Recording stopped." \
        || notify-send -i dialog-warning "No recording was running."
else
    echo "Usage: $0 --start|--stop"
    exit 1
fi
