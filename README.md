The Greatest Podcast Download Script Ever Written In The History Of The Universe
==============

First and foremost the name of this script is a joke so no hard feelings to all the other scripts out there.

With this script you can:

* Add/delete podcasts from your list
* Change the tempo of the podcasts so you can listen to them faster (Without resorting to having the hosts sound like chipmunks)
* Set the storage directory to a sub directory of your Dropbox folder. This way all your downloaded podcasts are available everywhere.
* Create/modify a crontab entry for downloading all your podcasts (To be completed soon)

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
http://feeds.feedburner.com/linuxoutlaws 90
http://leoville.tv/podcasts/sn.xml 90
http://skeptoid.com/podcast.xml 82
http://feeds.wnyc.org/radiolab?utm_source=rss&utm_medium=hp&utm_campaign=radiolab 0
http://leoville.tv/podcasts/twig.xml 90
http://feeds.thecommandline.net/cmdln 82
http://feeds2.feedburner.com/RatholeRadio-ogg 0
http://www.daveramsey.com/media/audio/podcast/podcast_itunes.xml 80
http://feeds.feedburner.com/5by5-inbeta 82

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

MySQL Admin is open source software released under the GNU GENERAL PUBLIC LICENSE V3.