#!/usr/bin/bash
TITLE="Bluetooth Dual Boot Pair Helper"
BLUETOOTH_DIR="/var/lib/bluetooth"

# Immediate Stop Function
trap "exit 1" TERM
APP_PID=$$
immediateStop()
{
  kill -s TERM $APP_PID
}

# Display Help
if [ "$1" = "-h" ] || [ "$1" = "" ]
then
  echo -e "$0 <WINDOWS_DIRECTORY>\n\nex. $0 /mnt/c/Windows"
  exit 0
fi

# Check chntpw Exist
if [ "$(which chntpw)" = "" ]
then
  echo "Please install chntpw first!" >&2
  exit 1
fi

dialogSelect()
{
  if [ "$(which whiptail)" != "" ]
  then
    echo "whiptail"
    return 0
  elif [ "$(which dialog)" != "" ]
  then
    echo "dialog"
    return 0
  else
    echo "Please install whiptail or dialog first!" >&2
    immediateStop
  fi
}

adapterSelect()
{
  adapters=()
  for newAdapterMAC in $(ls -1 "$BLUETOOTH_DIR")
  do
    adapters+=("$newAdapterMAC" " #")
  done
  whiptail --title "$TITLE" --menu "Select Bluetooth Adapter" 0 0 0 "${adapters[@]}" 3>&1 1>&2 2>&3
  if [ "$?" != "0" ]
  then
    immediateStop
  fi
}

deviceSelect()
{
  devices=()
  for newDeviceMAC in $(ls -1 "$BLUETOOTH_DIR/$1")
  do
    if [ ! -f "$BLUETOOTH_DIR/$1/$newDeviceMAC/info" ]
    then
      continue
    else
      newDeviceName=$(cat "$BLUETOOTH_DIR/$1/$newDeviceMAC/info" | grep -e '^Name' | cut -d'=' -f 2)
      devices+=("$newDeviceMAC" "$newDeviceName")
    fi
  done
  whiptail --title "$TITLE" --menu "Select Bluetooth Device" 0 0 0 "${devices[@]}" 3>&1 1>&2 2>&3
  if [ "$?" != "0" ]
  then
    immediateStop
  fi
}

keyCheckBox()
{
  whiptail --title "$TITLE" --yesno "The Key will change from\n\n$1\n\nto\n\n$2\n\nProceed?" 0 0 3>&1 1>&2 2>&3
  if [ "$?" != "0" ]
  then
    immediateStop
  fi
}

finalCheckBox()
{
  whiptail --title "$TITLE" --yesno "Is this result resonable?\n\n$(cat $1)" 0 0 3>&1 1>&2 2>&3
  if [ "$?" != "0" ]
  then
    immediateStop
  fi
}

# --------------------------------------

WIN_DIR=$1
TMP_FILE=$(mktemp)
DIALOG_APP=$(dialogSelect)
TARGET_ADAPTER=$(adapterSelect)
TARGET_ADAPTER_MAC=$(echo "$TARGET_ADAPTER" | tr -d ':' | tr '[:upper:]' '[:lower:]')
TARGET_DEVICE=$(deviceSelect $TARGET_ADAPTER)
TARGET_DEVICE_MAC=$(echo "$TARGET_DEVICE" | tr -d ':' | tr '[:upper:]' '[:lower:]')

# Get Registry File
reged -x "$WIN_DIR/System32/config/SYSTEM" "\\" "ControlSet001\\Services\\BTHPORT\\Parameters\\Keys\\$TARGET_ADAPTER_MAC" "$TMP_FILE" > /dev/null
if [ "$?" != "0" ]
then
  echo "Registry Export Failed, Wrong <WINDOWS_DIRECTORY> ?" >&2
  exit 1
fi

# Find Key
WIN_KEY=$(cat "$TMP_FILE" | grep "$TARGET_DEVICE_MAC" | cut -d':' -f2 | tr -d ',\r\n' | tr '[:lower:]' '[:upper:]')
LINUX_KEY=$(cat "$BLUETOOTH_DIR/$TARGET_ADAPTER/$TARGET_DEVICE/info" | grep -e '^Key=.*' | cut -d'=' -f2)
if [ "$WIN_KEY" = "" ]
then
  echo "Key not found on your Windows system, is the device paired?" >&2
  exit 1
fi

# Check Key
keyCheckBox "$LINUX_KEY" "$WIN_KEY"

# Replace Key
TMP_INFO=$(mktemp)
sed "s/^Key=.*/Key=$WIN_KEY/g" "$BLUETOOTH_DIR/$TARGET_ADAPTER/$TARGET_DEVICE/info" > "$TMP_INFO"

# Final Check
finalCheckBox "$TMP_INFO"
mv "$TMP_INFO" "$BLUETOOTH_DIR/$TARGET_ADAPTER/$TARGET_DEVICE/info" && service bluetooth restart
if [ "$?" = "0" ]
then
  echo "Finished Successfully"
else
  echo "Move Failed" >&2
  exit 1
fi
