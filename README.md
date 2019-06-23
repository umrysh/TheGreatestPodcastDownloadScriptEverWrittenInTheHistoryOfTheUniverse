The Greatest Podcast Download Script Ever Written In The History Of The Universe
==============

First and foremost the name of this script is a joke so no hard feelings to all the other scripts out there.

With this script you can:

* Add/delete podcasts from your list
* Change the tempo of the podcasts so you can listen to them faster (Without resorting to having the hosts sound like chipmunks)
* Set the storage directory to a sub directory of your Dropbox folder. This way all your downloaded podcasts are available everywhere.
* Create/modify a crontab entry for downloading all your podcasts.

**Note: I have been using this script on my own machines with no issues but this is still very fresh code so please, use at your own risk.**


Installation
------------

All you have to do is make sure the files:

* TheGreatestPodcastDownloadScriptEverWrittenInTheHistoryOfTheUniverse.sh
* bashpodder.sh
* mp3faster.bash

are executable (by using chmod +x) and the script will take care of the rest.

When run it will check for dependencies and alert you if you are missing any (this check can take some time). I have only tested this on an Arch Linux system so I can't guarantee the dependency check will work perfectly on other systems. If you find any errors please open up an [issue](https://github.com/umrysh/TheGreatestPodcastDownloadScriptEverWrittenInTheHistoryOfTheUniverse/issues) with as much information as you can.

Sample Podcasts
------------

If you are new to podcasting or are looking for some new shows here is what my `bp.conf` looks like:
<pre>
http://feeds.feedburner.com/dancarlin/history?format=xml 0
http://skeptoid.com/podcast.xml 160
http://feeds.thecommandline.net/cmdln 160
http://ratholeradio.org/feed/ 0
http://sixgun.org/feed/gnr 160
http://leoville.tv/podcasts/sn.xml 220
http://feeds.podtrac.com/2P68PDQSg03Y 160
https://www.smashingsecurity.com/rss 160
https://feeds.buzzsprout.com/174852.rss 160
http://feeds.twit.tv/floss.xml 160
https://www.almanac.com/podcast/feed/astounding-universe 160
http://sixgun.org/ho/feed/mp3/ 160
https://tuxdigital.com/feed/thisweekinlinux-mp3 160
https://feeds.pacific-content.com/commandlineheroes 160
https://notasgrumpyashelooks.wordpress.com/category/podcasts/feed/ 160
http://sixgun.org/mc/feed/mp3/ 160
https://rss.art19.com/voyage-to-the-stars 0
https://rss.acast.com/wrestleme 150
http://sixgun.org/tl/feed/mp3/ 160
https://feeds.megaphone.fm/darknetdiaries 160

</pre>

As you can see I like to speed up the shows quite a bit. Podcasts marked with a `0` are not sped up, just downloaded. Reason being I prefer to listen to music filled shows in regular speed.

Contributing
------------

Feel free to fork and send [pull requests](http://help.github.com/fork-a-repo/).  Contributions welcome.

Credit
------------

I have to give huge credit to slmingol for his tutorial at [lamolabs.org](http://www.lamolabs.org/blog/2103/speeding-up-the-playback-of-audio-podcasts)

He did all of the heavy lifting. I simply took his modifications and adjusted them to work with my command line interface.

In turn I have to give major props to the author of the mp3faster script found in the gpodder wiki as well as the great bashpodder script written by Linc.

License
-------

This script is open source software released under the GNU GENERAL PUBLIC LICENSE V3.