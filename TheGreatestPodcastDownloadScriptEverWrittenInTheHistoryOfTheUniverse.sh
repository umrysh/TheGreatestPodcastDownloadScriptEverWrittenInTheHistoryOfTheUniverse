#!/bin/bash

#    Copyright 2012 Dave Umrysh
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#	 Features I still want to complete are marked with a "To-do"

oldDir="$( readlink -f "$( dirname "$0" )" )"
#
#
#### Menus ####
#
#

function main
{
	while true; do
		menuOne
		read aok
		if test "$aok" == "1"; then
		  	AddFeed
		elif test "$aok" == "2"; then
			delFeed
		elif test "$aok" == "3"; then
			listFeeds
		elif test "$aok" == "4"; then
			changeFeed
		elif test "$aok" == "5"; then
			mainSettings
		elif test "$aok" == "6"; then
			runIt
		elif test "$aok" == "7"; then
	   		addCrontab
		elif test "$aok" == "8"; then
			echo "-----------------------
See Ya!
-----------------------"
			exit 0;
		else
			echo -e "-----------------------
\e[1;31mInvalid Selection\e[0m
-----------------------"
		fi
	done
}

function mainSettings
{
	while true; do
		menuTwo
		read aok
		if test "$aok" == "1"; then
			changeDropBox
		elif test "$aok" == "2"; then
			changeTemp
		elif test "$aok" == "3"; then
			echo "-----------------------"
			main
		else
			echo -e "-----------------------
\e[1;31mInvalid Selection\e[0m"
		fi
	done
}

#
#
#### Menu Text ####
#
#

function menuOne
{
  echo "Please enter the number of the menu item you would like to use:

(1) Add A Podcast Feed
(2) Remove A Podcast
(3) List Podcasts
(4) Change Speed On An Existing Podcast
(5) Settings
(6) Run Now (like, immediately!)
(7) Create/update Crontab entry
(8) Break My Heart And Quit Me :(
-----------------------"
}

function menuTwo
{
  echo "-----------------------
Settings:

(1) Change Dropbox Location
(2) Change Temp Location

(3) Go Back
-----------------------"
}

#
#
#### Functions ####
#
#

function makeBPConf
{
	touch bp.conf
	echo "############
#
# Warning: Editing this file yourself will break your warranty!
# 
############" >> bp.conf
}

function makePS
{
	touch persistent.settings
	echo "
" >> persistent.settings
}

function listFeeds
{
	if [ ! -f bp.conf ]; then makeBPConf; fi

	echo "-----------------------
Feed @ Speed
------------"
	counter=1
	while read podcast tempo; do
		# Skip lines beginning with '#' as comment lines - from Rick Slater
		if echo $podcast | grep '^#' > /dev/null; then
			continue
		fi
		echo -e "\e[1;34m($counter) $podcast @ $tempo\e[0m" 
		counter=$(($counter+1)) 
	done < bp.conf  
	echo "
-----------------------"
}

function AddFeed
{
	if [ ! -f bp.conf ]; then makeBPConf; fi

	echo "What is the RSS feed of the podcast?"
	read aok
	newRSS=$aok

	# Check if already added
	inList=false
	while read podcast tempo; do
		if test "$newRSS" == "$podcast"; then
			echo "-----------------------
This podcast is already in your list.
	Use option 4 instead.
-----------------------"
			inList=true
		fi
	done < bp.conf 

	if ! $inList;then
		while true;do
			echo "What would you like to set the tempo to? (eg. 80)"
			echo '[A value of 0 means "just download, do not speed up"]'
			read aok
			if [ "$aok" -eq "$aok" 2> /dev/null ];then
				#Value is numeric
				break;
			fi
		done
		## To-do
		# Check if this feed had been added before and there are records in the log
		#if [ -f podcast.log ]; then
		#	echo "Log exists"
			# Ask if they want to remove the instances of it in the log	
		#fi
		echo "$newRSS $aok" >> bp.conf
		echo "-----------------------
New Podcast Added.
-----------------------"
	fi
}

function delFeed
{
	if [ ! -f bp.conf ]; then makeBPConf; fi

	counter=1
	while read podcast tempo; do
		# Skip lines beginning with '#' as comment lines - from Rick Slater
		if echo $podcast | grep '^#' > /dev/null; then
			continue
		fi
		if test "$counter" == "1";then
			echo "-----------------------
Feeds
------------"
		fi
		echo -e "\e[1;34m($counter) $podcast\e[0m"
		counter=$(($counter+1)) 
	done < bp.conf

	if test "$counter" == "1";then
		echo "-----------------------
No Feeds. You have to add one before you can delete one.
------------"
	else
		while true;do
			echo "
Enter the number of the feed you want to remove.
-----------------------"
			read aok
			if [ "$aok" -eq "$aok" 2> /dev/null ];then
				#Value is numeric
				break;
			fi
		done

		# Test that it was a valid entry
		if [ ! "$aok" -ge "$counter" ];then
			counter=1
			line=0
			while read podcast tempo; do
				line=$(($line+1)) 
				# Skip lines beginning with '#' as comment lines - from Rick Slater
				if echo $podcast | grep '^#' > /dev/null; then
					continue
				fi
				if test $counter == $aok; then
					break;
				fi
				counter=$(($counter+1)) 
			done < bp.conf
			sed -e $line'd' bp.conf > bp.conf.tmp
			mv bp.conf.tmp bp.conf
			echo "-----------------------
Podcast Removed.
-----------------------"
		else
			echo -e "-----------------------
\e[1;31mInvalid Selection\e[0m
-----------------------"
		fi
	fi
}
function changeFeed
{
	if [ ! -f bp.conf ]; then makeBPConf; fi

	counter=1
	while read podcast tempo; do
		# Skip lines beginning with '#' as comment lines - from Rick Slater
		if echo $podcast | grep '^#' > /dev/null; then
			continue
		fi
		if test "$counter" == "1";then
			echo "-----------------------
Feeds
------------"
		fi
		echo -e "\e[1;34m($counter) $podcast @ $tempo\e[0m"
		counter=$(($counter+1)) 
	done < bp.conf

	if test "$counter" == "1";then
		echo "-----------------------
No Feeds. You have to add one before you can modify one.
------------"
	else
		while true;do
			echo "
Enter the number of the feed you want to modify.
-----------------------"
			read aok
			if [ "$aok" -eq "$aok" 2> /dev/null ];then
				#Value is numeric
				break;
			fi
		done

		# Test that it was a valid entry
		if [ ! "$aok" -gt "$counter" ];then
			counter=1
			line=0
			while read podcast tempo; do
				line=$(($line+1)) 
				# Skip lines beginning with '#' as comment lines - from Rick Slater
				if echo $podcast | grep '^#' > /dev/null; then
					continue
				fi
				if test $counter == $aok; then
					break;
				fi
				counter=$(($counter+1)) 
			done < bp.conf
			# Remove existing line
			sed -e $line'd' bp.conf > bp.conf.tmp
			mv bp.conf.tmp bp.conf
			# Ask for new setting
			while true;do
				echo "What would you like to set the tempo to? (Currently set at $tempo)"
				echo '[A value of 0 means "just download, do not speed up"]'
				read aok
				if [ "$aok" -eq "$aok" 2> /dev/null ];then
					#Value is numeric
					break;
				fi
			done
			echo "$podcast $aok" >> bp.conf
			echo "-----------------------
Podcast Modified.
-----------------------"

		else
			echo -e "-----------------------
\e[1;31mInvalid Selection\e[0m
-----------------------"
		fi
	fi
}
function changeDropBox
{
	echo "Please enter the location of your DropBox folder? (eg. /home/dave/Dropbox)"
	echo "(Current folder is: $DropBoxLocation)"
	read aok
	sed '1 c'$aok persistent.settings > persistent.settings.tmp
	mv persistent.settings.tmp persistent.settings
	while true ;do
		DropBoxLocation=$(sed -n "1{p;q;}" persistent.settings) 

		if [ ! -d "$DropBoxLocation" ] || test "$DropBoxLocation" == "";then
			echo "-----------------------
I need a valid location of your DropBox folder? (eg. /home/dave/Dropbox)"
			read aok
			sed '1 c'$aok persistent.settings > persistent.settings.tmp
			mv persistent.settings.tmp persistent.settings
		else
			break;
		fi
	done
}

function changeTemp
{
	echo "Please enter the location of your temp folder? (eg. /home/dave/PodTemp)"
	echo "(Current folder is: $TempLocation)"
	read aok
	sed '2 c'$aok persistent.settings > persistent.settings.tmp
	mv persistent.settings.tmp persistent.settings
	while true ;do
		TempLocation=$(sed -n "2{p;q;}" persistent.settings) 

		if [ ! -d "$TempLocation" ] || test "$TempLocation" == "";then
			echo "-----------------------
I need a valid location of your temp folder? (eg. /home/dave/PodTemp)"
			read aok
			sed '2 c'$aok persistent.settings > persistent.settings.tmp
			mv persistent.settings.tmp persistent.settings
		else
			break;
		fi
	done
}

function runIt
{
			# Offer user ability to catchup all and such
			echo "-----------------------
If you would like to run with either of the options below, please choose it now."
			echo "---------
(1) catchup_all       write all urls to the log file without downloading the
                      actual podcasts. This is useful if you want to subscribe
                      to some podcasts but don't want to download all the back
                      issues. You can edit the podcast.log file afterwards to
                      delete any url you still wish to download next time
                      bashpodder is run.
                      
(2) first_only        grab only the first new enclosed file found in each feed.
                      The catchup_all flag won't work with this option. If
                      you want to download the first file and also permanently
                      ignore the other files, run bashpodder with this option,
                      and then run it again with catchup_all.
                      
(3) Run with no options.
-----------------------"
			read aok

			if test "$aok" == "1";then
			    exec ./bashpodder.sh --catchup_all
			elif test "$aok" == "2";then
			    exec ./bashpodder.sh --first_only
	   else
	       exec ./bashpodder.sh
	   fi
			exit 0;
}

function addCrontab
{
    # get crontab
    crontab -l >/tmp/crontab.a
     
    echo "Warning: It is assumed you know your way around a crontab. You can seriously mess up your system if you don't."
    # see if entry already exists, if so print for user
    echo "If there is an existing entry for this script I will print it below:"
    awk '/bashpodder.sh/ { print $0 }' /tmp/crontab.a 
    
    echo "
Please enter when you would like the script to run in the form,
Minute Hour Day Month Weekday"
	read aok
	newEntry=$aok

	if test "${oldDir%${oldDir#?}}" == ".";then
		# Remove leading .
		oldDir="${oldDir#?}"
	fi
	
	DIR=$oldDir

	echo "I am about to enter the following crontab entry. Enter 'Yes' to confirm, anything else to cancel.
$newEntry $DIR/bashpodder.sh -w
"
	read aok
	if test "$aok" == "Yes";then
		#remove old instances
		sed '/bashpodder.sh/d' /tmp/crontab.a > /tmp/crontab.a.tmp
		mv /tmp/crontab.a.tmp /tmp/crontab.a

		echo "$newEntry $DIR/bashpodder.sh -w" >> /tmp/crontab.a
		crontab /tmp/crontab.a

		echo "-----------------------
Crontab Modified."
	else
		echo "-----------------------
Crontab Left Alone."
	fi
    # remove temp file
    rm /tmp/crontab.a
}
#
#
#### Let's Do This! ####
#
#

# Make script crontab friendly:
cd $(dirname $0)

echo "-----------------------
Ahoy!"

# Check for persistent settings
if [ ! -f persistent.settings ]; then makePS; fi

while true ;do
	DropBoxLocation=$(sed -n "1{p;q;}" persistent.settings) 

	if [ ! -d "$DropBoxLocation" ] || test "$DropBoxLocation" == "";then
		echo "I need a valid location of your DropBox folder? (eg. /home/dave/Dropbox)"
		read aok
		sed '1 c'$aok persistent.settings > persistent.settings.tmp
		mv persistent.settings.tmp persistent.settings
		echo "-----------------------
"
	else
		break;
	fi
done
while true ;do
	TempLocation=$(sed -n "2{p;q;}" persistent.settings) 

	if [ ! -d "$TempLocation" ] || test "$TempLocation" == "";then
		echo "I need a place I can store temp files. This folder will get quite large during the conversion so make sure it has a lot of space. (eg. /home/dave/PodTemp)"
		read aok
		sed '2 c'$aok persistent.settings > persistent.settings.tmp
		mv persistent.settings.tmp persistent.settings
		echo "-----------------------
"
	else
		break;
	fi
done

# Test if other scripts are executable
if [[ ! -x "bashpodder.sh" ]]
then
    echo "File 'bashpodder.sh' is not executable or found."
    exit 0
fi
if [[ ! -x "mp3faster.bash" ]]
then
    echo "File 'mp3faster.bash' is not executable or found."
    exit 0
fi

# Check for dependencies

# First determine OS
if [[ `apt-get 2>&1` =~ command\ not ]] && [[ `pacman 2>&1` =~ command\ not ]]
then
    # rhel/centos/fedora package requirements
    command -v mpg123 >/dev/null 2>&1 || { echo >&2 "I require mpg123 but it's not installed. Run 'yum install mpg123' as root."; exit 1; }
    command -v soundstretch >/dev/null 2>&1 || { echo >&2 "I require soundtouch but it's not installed. Run 'yum install soundtouch' as root."; exit 1; }
    command -v lame >/dev/null 2>&1 || { echo >&2 "I require lame but it's not installed. Run 'yum install lame' as root."; exit 1; }
    command -v id3cp >/dev/null 2>&1 || { echo >&2 "I require id3lib but it's not installed. Run 'yum install id3lib' as root."; exit 1; }
else
	if [[ `pacman 2>&1` =~ command\ not ]]
	then
		# debian/ubuntu package requirements
		command -v mpg321 >/dev/null 2>&1 || { echo >&2 "I require mpg321 but it's not installed. Run 'apt-get install mpg321' as root."; exit 1; }
	    command -v soundstretch >/dev/null 2>&1 || { echo >&2 "I require soundstretch but it's not installed. Run 'apt-get install soundstretch' as root."; exit 1; }
	    command -v lame >/dev/null 2>&1 || { echo >&2 "I require lame but it's not installed. Run 'apt-get install lame' as root."; exit 1; }
	    command -v libid3-3.8.3-dev >/dev/null 2>&1 || { echo >&2 "I require libid3-3.8.3-dev but it's not installed. Run 'apt-get install libid3-3.8.3-dev' as root."; exit 1; } 
	else
		# Arch
		command -v mpg321 >/dev/null 2>&1 || { echo >&2 "I require mpg321 but it's not installed. Run 'pacman -S mpg321' as root."; exit 1; }
	    command -v soundstretch >/dev/null 2>&1 || { echo >&2 "I require soundstretch but it's not installed. Run 'pacman -S soundstretch' as root."; exit 1; }
	    command -v lame >/dev/null 2>&1 || { echo >&2 "I require lame but it's not installed. Run 'pacman -S lame' as root."; exit 1; }
	    command -v id3cp >/dev/null 2>&1 || { echo >&2 "I require id3lib but it's not installed. Run 'pacman -S id3lib' as root."; exit 1; }
	fi
fi

# Start script

main

exit 0