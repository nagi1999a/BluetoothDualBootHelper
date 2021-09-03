# Bluetooth Dual Boot Helper
## Introduction
When someone want to dual boot Windows and Linux, and use Bluetooth mouse or headset/speaker, it will not cannect at both side because of the pair key inconsistence between Windows and Linux System. Addtional to original solution, the script create a simple GUI interface with whiptail/dialog to help user copy windows key to linux.

- Most logic taken from [here](https://gist.github.com/madkoding/f3cfd3742546d5c99131fd19ca267fd4)
- Immediate break taken from [here](https://stackoverflow.com/questions/9893667/is-there-a-way-to-write-a-bash-function-which-aborts-the-whole-execution-no-mat)

## Test Platform
- KDE Neon 5.22
- Windows 10 21H1

## Command Line Usage
**The script need root privilege to modify key stored in /var/lib/bluetooth, so please run with sudo**  

sudo ./helper.sh <WINDOWS_DIRECTORY>

ex. sudo ./helper.sh /mnt/win/Windows

## Usage
**This Instruction is for ubuntu based system, others distro will not work!**
1. Pair device in Linux
2. Pair device in Windows
3. Back to Linux
4. Install ntchpw
  ```
  sudo apt install chntpw
  ```
5. if Windows Partition not mounted, mount Windows Partition, suppose mount `sda3` at `/mnt/win`
  ```
  sudo mount /dev/sda3 /mnt/win
  ```
6. execute `helper.sh`
  ```
  sudo ./helper.sh /mnt/win/Windows
  ```

## Screenshot
![Screenshot_20210902_145424](https://user-images.githubusercontent.com/49529145/131796908-3408a969-4645-453e-8cf4-6c76d71e1762.png)
![Screenshot_20210902_144712](https://user-images.githubusercontent.com/49529145/131796903-4ff7e4f8-6410-46a7-acf8-22966928df7d.png)
![Screenshot_20210903_141353](https://user-images.githubusercontent.com/49529145/131959656-9e413ede-8ed2-4823-ade7-d8364373105e.png)
![Screenshot_20210903_142236](https://user-images.githubusercontent.com/49529145/131959840-f4fbb838-f7fa-48a1-a7f3-0ba7b44522aa.png)
