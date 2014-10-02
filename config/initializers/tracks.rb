tracks_version='2.4devel'
# comment out next two lines if you do not want (or can not) the date of the
# last git commit in the footer
info=`git log --pretty=format:"%ai" -1`
tracks_version=tracks_version + ' ('+info+')'

TRACKS_VERSION=tracks_version
