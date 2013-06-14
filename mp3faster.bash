% more mp3faster.bash
 
#!/bin/bash
# mp3faster - script for making mp3 playback faster with soundstretch
#
# debian/ubuntu package requirements
# apt-get install mpg321 soundstretch lame libid3-3.8.3-dev
#
# rhel/centos/fedora package requirements
# yum install mpg321 soundtouch lame id3lib
#
# sample usage for converting all mp3 files in a directory structure:
# find -name "*.mp3" -print0 | xargs -0 -i mp3faster {}
#
# decode mp3 to wav file
#mpg321 --wav "$1.wav" "$1"
 
# the above decoding technique doesn't always work, and can sometimes 
# create a wav file that plays back too fast. Seems to happen with mp3 files that
# have a low bitrate (< 80kbps). Using the lame alternative below get's around this.

new=$(dirname $1)/`date +"%Y-%m-%d-"`$(basename $1)

if [ $2 != 0 ]; then
# alternative #1 to decoding an mp3 to wav
lame --decode "$1" "$1.wav"
# alternative #2 to decoding an mp3 to wav
# mpg321 -b 10000 -s -r 44100 $1 | sox -t raw -r 44100 -s -w -c2 - "$1.wav"
 
# process file with soundstretch
#soundstretch "$1.wav" "$1.fast.wav" -tempo=+65
soundstretch "$1.wav" "$1.fast.wav" -tempo=+$2
# encode mp3 file
lame --preset fast medium "$1.fast.wav" "$1.2.mp3"
# copy id3 tags from old file
id3cp -1 "$1" "$1.2.mp3"
# remove temp files
rm "$1.wav" "$1.fast.wav" "$1"
# rename original mp3 file to .bak extension
# mv "$1" "$1.bak"
# rename processed mp3 file to original name
mv -f "$1.2.mp3" "$new"
elif [ $2 == 0 ]; then
mv -f "$1" "$new"
fi
# Move file to DropBox
mv "$new" "$3/"
exit
