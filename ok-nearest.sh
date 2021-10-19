#!/bin/bash

#
#	Donated to the public domain by Rick Richardson <rickrich@gmail.com>
#
#	Use at your own risk.  Not suitable for any purpose.  Not legal tender.
#
#	$Id: ok-nearest.sh,v 1.17 2019/06/21 02:22:56 rick Exp $
#

PROGNAME="$0"

usage() {
	cat <<EOF
NAME
	`basename $PROGNAME` - Fetch a list of nearest geocaches from opencaching.us

SYNOPSIS
	`basename $PROGNAME` [options]

	`basename $PROGNAME` [options] lat lon

DESCRIPTION
	Fetch a list of nearest geocaches from opencaching.us or another
	opencaching site based on OKBASE setting.

	Requires:
	    curl	http://curl.haxx.se/

EOF
	ok_usage
	cat << EOF

EXAMPLES
	Add nearest 50 caches to a GpsDrive SQL database

	    ok-nearest -n50 -f -s -S

	Purge the existing SQL database of all geocaches, and fetch
	200 fresh ones...

	    ok-nearest -S -P -s -n200

	Nearest in Czechia:

	    ok-nearest -E OKBASE=https://www.opencaching.cz n48 e9

	Nearest in Germany:

	    ok-nearest -E OKBASE=https://opencaching.de n50 e7

	Nearest in Italy:

	    ok-nearest -E OKBASE=https://www.opencaching.it n48 e10

	Nearest in The Nederlands:

	    ok-nearest -E OKBASE=https://www.opencaching.nl n51.37.944 e5

	Nearest in Poland:

	    ok-nearest -E OKBASE=https://opencaching.pl n51.37.944 e5

	Nearest in Romania:

	    ok-nearest -E OKBASE=https://www.opencaching.ro n44 e24.40.000

	Nearest in UK:

	    ok-nearest -E OKBASE=https://opencache.uk n53.5 w1.5

SEE ALSO
	geo-newest, geo-nearest, geo-found, geo-placed, geo-code, geo-map,
	geo-waypoint, ok-newest,
	$WEBHOME
EOF

	exit 1
}

#include "geo-common"
#include "geo-common-ok"
#include "geo-common-gpsdrive"

#
#       Set default options, can be overriden on command line or in rc file
#
UPDATE_URL=$WEBHOME/ok-nearest
UPDATE_FILE=ok-nearest.new

read_rc_file

#
#       Process the options
#

ok_getopts "$@"
shift $?

#
#	Main Program
#
case "$#" in
6)
        # Cut and paste from geocaching.com cache page
        # N 44° 58.630 W 093° 09.310
        LAT=`echo "$1$2.$3" | tr -d '\260\302' `
        LAT=`latlon $LAT`
        LON=`echo "$4$5.$6" | tr -d '\260\302' `
        LON=`latlon $LON`
        ;;
2)
        LAT=`latlon $1`
        LON=`latlon $2`
        ;;
0)
        ;;
*)
        usage
        ;;
esac

LAT=`latlon $LAT`
LATNS=`degdec2mindec $LAT NS | cut -c 1 `
LATH=`degdec2mindec $LAT NS | sed -e "s/.//" -e "s/\..*//" `
LATMIN=`degdec2mindec $LAT | sed "s/[^.]*\.//" `
LON=`latlon $LON`
LONEW=`degdec2mindec $LON EW | cut -c 1 `
LONH=`degdec2mindec $LON EW | sed -e "s/.//" -e "s/\..*//" `
LONMIN=`degdec2mindec $LON | sed "s/[^.]*\.//" `
SEARCH="searchto=searchbydistance&sort=bydistance"
SEARCH="$SEARCH&latNS=$LATNS&lat_h=$LATH&lat_min=$LATMIN"
SEARCH="$SEARCH&lonEW=$LONEW&lon_h=$LONH&lon_min=$LONMIN"
#echo "$SEARCH"

ok_query
