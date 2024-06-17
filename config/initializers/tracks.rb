TRACKS_VERSION='2.7'
TRACKS_REVISION_WITH_DATE=`git log --date=format:'%Y-%m-%d' --pretty=format:"%h @ %ad" -1`
TRACKS_REVISION=`git log --pretty=format:"%h" -1`
