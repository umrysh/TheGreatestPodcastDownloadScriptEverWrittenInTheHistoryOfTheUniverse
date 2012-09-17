#!/bin/bash
# By Linc 10/1/2004
# Find the latest script at http://linc.homeunix.org:8080/scripts/bashpodder
# If you use this and have made improvements or have comments
# drop me an email at linc dot fessenden at gmail dot com
# I'd appreciate it!
#
# This revision by Brian Hefferan 2004/02/06, adding configuration options.
# No warranty. It seems to work for me, I hope it works for you.
# Questions /corrections on the additions by Brian Hefferan can be sent to
# brian at heftone  dot  com

#default values can be set here. Command-line flags override theses.
verbose=1
wget_quiet='-q'  #default is -q
wget_continue=
catchup_all=
first_only=
unix2dos=
usetorrents=
sync_disks=
disable_watch=
fetchlist='bp.conf'

function usage
{
  echo "
Usage: $0 [OPTIONS]
Options are:
-v, --verbose          display verbose messages. Also enables wget's continue
                      option.
--catchup_all          write all urls to the log file without downloading the
                      actual podcasts. This is useful if you want to subscribe
                      to some podcasts but don't want to download all the back
                      issues. You can edit the podcast.log file afterwards to
                      delete any url you still wish to download next time
                      bashpodder is run.
--first_only           grab only the first new enclosed file found in each feed.
                      The --catchup_all flag won't work with this option. If
                      you want to download the first file and also permanently
                      ignore the other files, run bashpodder with this option,
                      and then run it again with --catchup_all.
#-bt --bittorrent      launch bittorrent for any .torrent files downloaded.
                      Bittorrent must be installed for this to work. The
                      the script and bittorrent process will continue running
                      in the foreground indefinitely. You can use ctr-c to
                      kill it when you want to stop participating in the
                      torrent.
#--sync_disks          run the "sync" command twice when finished. This helps
                      makes sure all data is written to disk. Recommended if
                      data is being written directly to a portable player or
                      other removable media.
-u, --url_list         ignore bp.conf, instead use url(s) provided on the
                      command line. The urls should point to rss feeds.
                      If used, this needs to be the last option on the
                      command line. This can be used to quickly download just
                      a favorite podcast, or to take a few new podcasts for a
                      trial spin.
-w, --watch           disable the watch command for use in crontabs
-h, --help            display this help message

"
}

# if [ -n "$verbose" ]; then wget_quiet='';wget_continue='-c';fi
if test -f urls.temp;then rm urls.temp;fi

# Make script crontab friendly:
cd $(dirname $0)
mp3filelocation=$(dirname $0)/mp3faster.bash
DropBoxLocation=$(sed -n "1{p;q;}" persistent.settings)


if [ ! -f podcast.log ]; then touch podcast.log; fi

while [ "$1" != "" ]; do
  case $1 in
  -v|--verbose ) 
    verbose=1
    wget_continue='-c'
    wget_quiet=''
  ;;
  -u|--url_list )
    shift
    while [ "$1" != "" ]; do
      echo "$1" >> urls.temp
      shift
    done
    if test ! -f urls.temp; then
      echo "Error: -u or --url_list option specified, but no urls given on command line. quitting."
      exit 1;
    fi
    fetchlist='urls.temp'
  ;;
  --catchup_all )
    catchup_all=1
  ;;
  --first_only )
    first_only=1
  ;;
  --bittorrent )
    usetorrents=1
  ;;
  --sync_disks )
    sync_disks=1
  ;;
  -w|--watch )
    disable_watch=1
  ;;
  -h|--help )
    usage
    exit
  ;;
  esac
  shift
done

if test ! -f bp.conf && test ! -f urls.temp; then
  echo "Sorry no bp.conf found, and no urls in command line. Run $0 -h for usage."
  exit
fi

# Read the bp.conf file and wget any url not already in the podcast.log file:
#while read podcast feeddir tempo; do
feeddir=$(sed -n "2{p;q;}" persistent.settings)
while read podcast tempo; do
  # Skip lines beginning with '#' as comment lines - from Rick Slater
  if echo $podcast | grep '^#' > /dev/null; then
    continue
  fi

  # Check to make sure feeddir is listed on each line; if not, print message.
  # Or, comment out the exit 1 line to have bashpodder quit if datadir not
  # there. 
  if test ! $feeddir; then
    echo "No feed directory specified in bp.conf for the $podcast feed."
    exit 1;
  fi

  seenfirst=
  if [ -n "$verbose" ]; then echo "fetching rss $podcast...";fi;
  file=$(wget -q $podcast -O - | xsltproc parse_enclosure.xsl - 2> /dev/null) || \
  file=$(wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')

  for url in $file; do
    if [ -n "$first_only" ] && [ -n "$seenfirst" ]; then 
      break;
    fi

    echo $url >> temp.log

    if [ -n "$catchup_all" ]; then
      if [ -n "$verbose" ]; then 
        echo " catching up $url...";
      fi
    elif ! grep "$url" podcast.log > /dev/null; then
      if [ -n "$verbose" ]; then echo "  downloading $url...";fi

      # Check for and create datadir if necessary:
      # (Uses Tony Whitmore's addition to bp.conf where
      # name of directory comes after feed, e.g.,
      # http://www.lugradio.org/episodes.rss LUGRadio)
      if [ ! -d $feeddir ]; then
        echo "Creating $feeddir directory to store feeds..."
        mkdir $feeddir
      fi
      pushd $feeddir > /dev/null 2>&1
      #wget $wget_continue $wget_quiet -q -P "$feeddir" "$url" &
      mp3filename=$(echo "$url" | awk -F'/' {'print $NF'} | awk -F'=' {'print $NF'} | awk -F'?' {'print $1'})
      (wget $wget_continue $wget_quiet -O $mp3filename "$url"; $mp3filelocation $feeddir/$mp3filename $tempo $DropBoxLocation > /dev/null 2>&1) & popd > /dev/null 2>&1
    fi

    seenfirst=1
  done
done < $fetchlist

if test ! -f temp.log && [ -n "$verbose" ]; then echo "nothing to download."; fi

if test -f urls.temp; then rm urls.temp; fi

# Move dynamically created log file to permanent log file:
cat podcast.log >> temp.log
sort temp.log | uniq > podcast.log
rm temp.log

## Use bittorrent to download any files pointed from bittorrent files:
#if [ "$usetorrents" ]
#then
#    if ls $datadir/*.torrent 2> /dev/null
#    then
#          btlaunchmany.py $datadir
#    fi
#fi

## Create an m3u playlist:
#ls -1rc $datadir | grep -v m3u > $datadir/podcast${datadir}.m3u
#if [ -n "$unix2dos" ];then unix2dos $datadir/podcast${datadir}.m3u;fi;

#if [ -n "$sync_disks" ]
#then
#    if [ -n "$verbose" ]; then echo "running sync..";fi;
#    sync
#    if [ -n "$verbose" ]; then echo "running sync again..";fi;
#    sync
#fi

if [ -n "$verbose" ]; then echo -e "\n\nFIN!\n\n";fi;

sleep 3;

if test "$disable_watch" == ""; then watch 'ps -eaf|egrep "wget |soundstretch |lame "| egrep -v "sh |egrep |watch"';fi;

