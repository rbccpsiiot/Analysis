SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

echo "$0 script's path: $SCRIPTPATH"
sleep 2

mkdir -p "$SCRIPTPATH/tmp"
ip_file="$SCRIPTPATH/tmp/vinyasVPNIP"

[ -e $ip_file ] && ip=`cat $ip_file` && curl -m 2 $ip:9200 > /dev/null 2>&1 && \
	echo  "\n\
|----------------------------|\n\
| Connected to VPN | Already |\n\
|----------------------------|\n" && exit

sshuser=root
#sshhost=droplet
sshhost=feynalytics.ml
sshport=22

sshuttleSUBNET="10.10.10.1/24"

#vinyasVPNIP=$(ssh -p5151 richard@smartcity.rbccps.org cat /etc/hosts | grep vinyas | grep -Po "(\d+\.?)+")
vinyasVPNIP=$(ssh -p$sshport $sshuser@$sshhost cat /etc/hosts | grep vinyas | grep -Po "(\d+\.?)+")


echo "--------------------------------------------"
echo "Found vinyasvpnIP: $vinyasVPNIP" 
echo "$vinyasVPNIP" > src/tools/tmp/vinyasVPNIP && echo "Written to src/tools/tmp/vinyasVPNIP" && cat src/tools/tmp/vinyasVPNIP
echo "--------------------------------------------"


# If sshutle is running(but elasticsearch could not be reached),
# we kill it gracefully, 
# we will start it again further below
pkill -SIGINT sshuttle

#start sshuttle
#x-terminal-emulator -e "sshuttle -v -r richard@smartcity.rbccps.org:5151 10.3.1.0/24 ; sleep 10" &
#x-terminal-emulator -e "python3 -m sshuttle -v -r $sshuser@$sshhost:$sshport $sshuttleSUBNET; sleep 10" &
xterm -e "python3 -m sshuttle -v -r $sshuser@$sshhost:$sshport $sshuttleSUBNET; sleep 10" &

# Info...
echo "--------------------------------------------" | sed s/-/*/g
echo "\
0) In the POPPED terminal \n\
1) Provide your local ROOT pass\n\
2) Provide smarcity.rbccps.org SERVER pass"

echo "--------------------------------------------" | sed s/-/*/g

# Test connection...

echo ""
read -p "Hit ENTER to test connection to VINYAS VPN IP: $vinyasVPNIP ---> ready?" tempVar 
echo "``````````````````````````````````````````````````````````````````````````"


if  curl -m 2 $vinyasVPNIP:9200 > /dev/null 2>&1
then	

echo "Backing up /etc/hosts into /etc/hosts.bak.connect"
sudo cp /etc/hosts /etc/hosts.bak.connect
echo "Adding '$vinyasVPNIP vinyas' to /etc/hosts"
cat /etc/hosts | sed s/.*\\svinyas$// > /tmp/hosts.connect
echo "$vinyasVPNIP vinyas" >> /tmp/hosts.connect
sudo cp /tmp/hosts.connect /etc/hosts
echo "Updated /etc/hosts"

	echo  "\n\
|-------------------|\n\
| Connected to VPN  |\n\
|-------------------|\n" && exit
else

	echo "\n	
|---------------------------------------------------------------|\n\
| Failed to connect.... 					|\n\
| 								|\n\
| Possible causes >						|\n\
| 0) Failed to connect to RBCCPS Server.				 			       	|\n\
| 1) Stale 'vinyas' entry in /etc/hosts @smartcity.rbccps.org  	|\n\
| 2) Vinyas server's VPN disconneted, VPN client needs restart.	|\n\
|								|\n\
|---------------------------------------------------------------|\n" && exit
	
	# kill sshuttle gracefully, 
	pkill -SIGINT sshuttle

fi
