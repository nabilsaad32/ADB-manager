#!/bin/bash

# ADB  Center - nabilsaad32@gmail.com
# Start ADB server and check devices
adb start-server > /dev/null 2>&1

device_count=$(adb devices | grep -w "device" | wc -l)

if [ "$device_count" -eq 0 ]; then
  echo " No devices connected, babe!"
  echo " Plug in your Android and make sure USB debugging is on."
  read -p " Press Enter to retry or Ctrl+C to abort..." 
  exec "$0"
fi

while true; do
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ADB Command Center - Slay Mode "
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 1) Devices & Info"
  echo " 2) Install / Uninstall Apps"
  echo " 3) Post Mortem (Logs & Data)"
  echo " 4) Admin Tasks (Reboot, Push, Wipe)"
  echo " 5) Take Photo / Record Voice"
  echo " 6) Make Call / Send SMS"
  echo " 7) Exit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  read -p " Choose your destiny (1-7): " choice

  case $choice in
    1)
      echo " Devices connected:"
      adb devices
      echo " Device Info:"
      adb shell getprop
      read -p " Press Enter to continue..." ;;
      
    2)
      echo "✨ App Management"
      echo "1) Install APK"
      echo "2) Uninstall App"
      read -p "Choose option: " app_action
      case $app_action in
        1)
          read -p " Path to APK file: " apk_path
          adb install "$apk_path"
          echo " APK installed!"
          ;;
        2)
          read -p " Package name to uninstall: " pkg
          adb uninstall "$pkg"
          echo " App uninstalled!"
          ;;
        *)
          echo " Invalid choice"
          ;;
      esac
      read -p " Press Enter to continue..." ;;
    
    3)
      echo " Post Mortem (PM)"
      echo "1) View logcat"
      echo "2) Bugreport"
      echo "3) Pull app data"
      read -p "Pick your poison: " pm_choice
      case $pm_choice in
        1)
          adb logcat
          ;;
        2)
          adb bugreport > bugreport.txt
          echo " Bugreport saved as bugreport.txt"
          ;;
        3)
          read -p "App package name: " app
          adb pull "/data/data/$app" "./$app-data"
          echo " Data pulled to $PWD/$app-data"
          ;;
        *)
          echo " Invalid option"
          ;;
      esac
      read -p " Press Enter to continue..." ;;
    
    4)
      echo " Admin Menu (AM)"
      echo "1) Reboot"
      echo "2) Factory Reset"
      echo "3) Push file to device"
      read -p "Select one: " am_choice
      case $am_choice in
        1)
          adb reboot
          ;;
        2)
          read -p "⚠ ARE YOU SURE? (y/n): " confirm
          [[ "$confirm" == "y" ]] && adb shell am broadcast -a android.intent.action.MASTER_CLEAR
          ;;
        3)
          read -p " File to push: " file_path
          read -p " Target location on device: " target
          adb push "$file_path" "$target"
          echo " File pushed."
          ;;
        *)
          echo " Invalid input"
          ;;
      esac
      read -p " Press Enter to continue..." ;;

5)
  echo " Media Control"
  echo "1) Take a photo"
  echo "2) Record a voice note"
  read -p "Pick: " media
  case $media in
    1)
		adb shell am start -a android.media.action.STILL_IMAGE_CAMERA
		sleep 2  # Wait for the camera app to load
		sleep 3  # Wait for the photo to be taken
		adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///DCIM/Camera/IMG_12345.jpg
		sleep 4  # Let MediaScanner finish
		
      ;;
    2)
      echo " Opening voice recorder..."
      adb shell am start -a android.provider.MediaStore.RECORD_SOUND
      echo " You may need to tap 'Record' manually depending on your device."
      sleep 3
	  echo " Trying to press the shutter..."
	  
      ;;
    *)
      echo " Nope, invalid."
      ;;
  esac
  read -p " Press Enter to continue..." ;;

    
    6)
      echo " Communication Station"
      echo "1) Make a Call"
      echo "2) Send SMS"
      read -p "What’s your move? " com_choice
      case $com_choice in
        1)
          read -p "📞 Number to call: " number
          adb shell am start -a android.intent.action.CALL -d tel:$number
          ;;
        2)
          read -p " Number to SMS: " number
          read -p " Message: " msg
          adb shell service call isms 7 i32 0 s16 "com.android.mms.service" s16 "$number" s16 "null" s16 "$msg" s16 "null" s16 "null"
          ;;
        *)
          echo " That ain't it."
          ;;
      esac
      read -p " Press Enter to continue..." ;;

    7)
      echo " Bye!"
      exit 0 ;;
      
    *)
      echo " Invalid option."
      read -p "Try again... Press Enter." ;;
  esac
done

