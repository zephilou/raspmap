#!/bin/bash

############################################
###  Variables
############################################

GREEN="\e[0;32m";
NORMAL="\e[0;39m";
RED="\e[0;31m";
CYAN="\e[0;36m";

PUBLICIP=`wget -qO- icanhazip.com`

RESULTSFILE="/tmp/RESULTSFILE"

############################################
###  Checking requierement
############################################

if [[ -f /etc/ssmtp/ssmtp.conf ]]
then
	echo -e "${GREEN} SSMTP ok ${NORMAL}";
else 
	echo "${RED}  SSMTP not here ${NORMAL}";
	echo -e "${GREEN} Trying to install  ${NORMAL}";
	apt-get install ssmtp mailutils
fi

if [[ -f /usr/bin/nmap ]]
then
        echo -e "${GREEN} Nmap  ok ${NORMAL}";
else
        echo -e "${RED}  Nmap not here ${NORMAL}";
        echo -e "${GREEN} Trying to install  ${NORMAL}";
        apt-get install nmap
fi



if [[ -f /usr/bin/xsltproc ]]
then
        echo -e "${GREEN} xsltproc  ok ${NORMAL}";
else
        echo -e "${RED}  xsltproc not here ${NORMAL}";
        echo -e "${GREEN} Trying to install  ${NORMAL}";
        apt-get install xsltproc
fi


if [[ -f /usr/bin/mtr  ]]
then
        echo -e "${GREEN} mtr  ok ${NORMAL}";
else
        echo -e "${RED}  mtr not here ${NORMAL}";
        echo -e "${GREEN} Trying to install  ${NORMAL}";
        apt-get install mtr
fi

############################################
###  Testing email 
############################################
echo ""
echo -e "${CYAN} Choose a destination email  ${NORMAL}" 
read -p "Email : " EMAIL;echo

echo -e "${GREEN} Sending .... ${NORMAL}"
echo "This is a test email coming from RaspMap install ".`date`." From Public IP $PUBLICIP"| mail -s "RaspMap test email" $EMAIL

echo -e "${CYAN} Check your email $EMAIL ... have you got it ? (y/n)  ${NORMAL}"
read -p "y or n : " EMAILOK;echo

if [[ "$EMAILOK" != 'y' ]]
then 
	echo -e "${RED} Check you're Ssmtp config  .... and come back ${NORMAL}"
	exit 100;
else
	echo -e "${GREEN} Email  ok ${NORMAL}";
fi 

############################################
###  Mapping
############################################

# Public Ip 


echo "<b>RaspMap </b>: ".`date`."<br />"
echo "<b>Admimail </b>: $EMAIL" ."<br />"
echo "<b>Public ip</b> of installer is : $PUBLICIP"."<br />" >> $RESULTSFILE
echo "<b>Local network</b>"."<br />"."<br />"
ifconfig >> $RESULTSFILE

############################################
###  Install
############################################


cp raspmap.sh /etc/init.d/raspmap.sh
sed -i "s/^EMAIL/EMAIL='$EMAIL'/g" /etc/init.d/raspmap.sh

update-rc.d raspmap.sh defaults 

cat $RESULTSFILE | mail -s "RaspMap map installed" -a "MIME-Version: 1.0" -a "Content-Type: text/html" $EMAIL

############################################
###  Launch
############################################

/etc/init.d/raspmap.sh start

