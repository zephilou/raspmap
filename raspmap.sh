#!/bin/bash
EMAIL
PUBLICIP=`wget -qO- icanhazip.com`
RESULTSFILE="/tmp/RESULTSFILE"
NETSCANFILE="/tmp/NETSCANFILE"
NMAPXML='/tmp/NMAPXML'

RETVAL=0

function raspmap(){
echo -e "
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head><title></title>
</head>
<body style='text-align:left;margin:50px 0px; padding:0px;'>
" >$RESULTSFILE
echo -e "<b>RaspMap </b>: ".`date`."<br />" >>$RESULTSFILE
echo "<b>Admimail </b> : $EMAIL  <br />"  >>$RESULTSFILE
echo "<b>Public ip </b> of installer is : $PUBLICIP"."<br />" >> $RESULTSFILE
echo "<b>Local network  </b>:<br /><br />" >> $RESULTSFILE
ifconfig >> $RESULTSFILE
echo "<br /><br /><b>Network to scan </b>  : <br />" >>$RESULTSFILE
ip addr show | grep inet | grep -v 127.0.0.1 | sed -n '/inet/,/brd/p' | awk -F 'inet' '{print $2}'  | awk -F ' ' '{print $1}' >>$RESULTSFILE
ip addr show | grep inet | grep -v 127.0.0.1 | sed -n '/inet/,/brd/p' | awk -F 'inet' '{print $2}'  | awk -F ' ' '{print $1}'  > $NETSCANFILE

echo "<br /><br /><b>Mtr to google </b>  : <br />" >>$RESULTSFILE

echo "<br /><br />" >>$RESULTSFILE

mtr -r -c 1  8.8.8.8 | sed 's/^[0-9]\.\|--/<br \/>/g'>>$RESULTSFILE

echo "<br /><br />" >>$RESULTSFILE

echo "</body>" >>$RESULTSFILE
while read line ;do
	echo "Result of  scan <b> $line </b>: <br />" >>$RESULTSFILE
	nmap -PN $line -oX $NMAPXML
	xsltproc $NMAPXML  >>$RESULTSFILE
done < $NETSCANFILE



mail -s "RaspMap Boot email $HOSTNAME" -a "MIME-Version: 1.0" -a "Content-Type: text/html" $EMAIL < $RESULTSFILE 


rm -v RESULTSFILE
rm -v NETSCANFILE
rm -v NMAPXML

}

case "$1" in
    start)
    echo -n "Starting raspmap: \r"

    raspmap;
    ;;
    stop)
    echo -n "Shutting down raspmap: "
    ;;
    
    restart|reload)
    ;;
    *)
    echo "Usage: $0 {start | stop | restart | reload}"
    exit 1
esac

exit $RETVAL

