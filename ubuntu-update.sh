#!/bin/bash

# bash script to update Ubuntu Linux. Written on 16.04 LTS Server
# Written by Ted LeRoy, adjusted by Kevin Holvoet
# Follow or contribute on GitHub here:
# https://github.com/digihash/ubuntu-update.sh

# Defining Colors for text output
red=$( tput setaf 1 );
yellow=$( tput setaf 3 );
green=$( tput setaf 2 );
normal=$( tput sgr 0 );

# Defining Header
HEADER="
ubuntu-update.sh Copyright (C) 2018 Ted LeRoy

Easily update, upgrade, and clean up your Ubuntu system with this bash script.

This program comes with ABSOLUTELY NO WARRANTY see
https://github.com/TedLeRoy/ubuntu-update.sh/blob/master/LICENSE.md

This is free software, and you are welcome to redistribute it
under certain conditions.

See https://github.com/TedLeRoy/ubuntu-update.sh/blob/master/LICENSE.md
for details."

# Defining USAGE Variable to print usage for -h or undefined args

USAGE="
Usage: sudo bash ubuntu-update.sh [-ugdrh]
       No option - Run all options (recommended)
       -u Don't run apt update
       -g Don't run apt upgrade -y
       -d Don't run apt dist-upgrade -y
       -c Don't run apt clean
       -p Don't run dpkg --configure -a
       -r Don't run apt autoremove -y
       -h Display Usage and exit
"

# Evaluating Command Line args and setting case variables for later use

while getopts ":ugdrh" OPT; do
  case ${OPT} in
    u ) uOff=1
      ;;
    g ) gOff=1
      ;;
    d ) dOff=1
      ;;
    c ) cOff=1
      ;;
    p ) pOff=1
      ;;
    r ) rOff=1
      ;;
    h ) hOn=1
      ;;
    \?) noOpt=1
  esac
done

# Checking whether script is being run as root

if [[ ${UID} != 0 ]]; then
    echo "${red}
    This script must be run as root or with sudo permissions.
    Please run using sudo.${normal}
    "
    exit 1
fi

# Executing based on option selection

if [[ -n $hOn || $noOpt ]]; then
    echo "${red}$USAGE${normal}"
    exit 2
fi

# Display HEADER

echo "${red}$HEADER${normal}"

if [[ ! -n $uOff ]]; then
    echo -e "
\e[32m#############################
#     Updating Data Base    #
#############################\e[0m
"
apt update | tee /tmp/update-output.txt
fi

if [[ ! -n $gOff ]]; then
    echo -e "
\e[32m##############################
# Upgrading Operating System #
##############################\e[0m
"
apt upgrade -y | tee -a /tmp/update-output.txt
fi

if [[ ! -n $dOff ]]; then
    echo -e "
\e[32m#############################
#   Starting Full Upgrade   #
#############################\e[0m
"
apt dist-upgrade -y | tee -a /tmp/update-output.txt
echo -e "
\e[32m#############################
#   Full Upgrade Complete   #
#############################\e[0m
"
fi

if [[ ! -n $cOff ]]; then
    echo -e "
\e[32m#############################
#    Starting Apt Clean     #
#############################\e[0m
"
apt clean | tee -a /tmp/update-output.txt
echo -e "
\e[32m#############################
#     Apt Clean Complete    #
#############################\e[0m
"
fi

if [[ ! -n $pOff ]]; then
    echo -e "
\e[32m#############################
#    Starting Dpkg Config   #
#############################\e[0m
"
dpkg --configure -a | tee -a /tmp/update-output.txt
apt install -f -y | tee -a /tmp/update-output.txt
echo -e "
\e[32m#############################
#     Dpkg Config Complete  #
#############################\e[0m
"
fi

if [[ ! -n $rOff ]]; then
    echo -e "
\e[32m#############################
#    Starting Apt Autoremove #
#############################\e[0m
"
apt autoremove -y | tee -a /tmp/update-output.txt
echo -e "
\e[32m#############################
#     Apt Autoremove Complete #
#############################\e[0m
"
fi
# Check for existence of update-output.txt and exit if not there.

if [ -f "/tmp/update-output.txt"  ]

then

# Search for issues user may want to see and display them at end of run.

  echo -e "
\e[32m#####################################################
#   Checking for actionable messages from install   #
#####################################################\e[0m
"
  egrep -wi --color 'warning|error|critical|reboot|restart|autoclean|autoremove' /tmp/update-output.txt | uniq
  echo -e "
\e[32m#############################
#    Cleaning temp files    #
#############################\e[0m
"

  rm /tmp/update-output.txt
  echo -e "
\e[32m#############################
#     Done with upgrade     #
#############################\e[0m
"

exit 0

else

# Exit with message if update-output.txt file is not there.

  echo -e "
\e[32m#########################################################
# No items to check given your chosen options. Exiting. #
#########################################################\e[0m
"

fi

exit 0
