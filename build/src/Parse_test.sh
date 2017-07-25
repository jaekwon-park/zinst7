#!/bin/bash
# Package install manager
# Made by Ralf Yang 
# goody80762@gmail.com
# Refactory by Jaekwon.park
# jaekwon.park@openstack.computer


export TIME_STYLE="+%b %d %R"
Barr="==========================================================================="
BARR="###########################################################################"
ROWW="============================================================="

### Base information
### ------ Config Area ----- 11st line here
#
ManagerIP="10.1.2.33"
Dist_server="http://10.1.2.33"
ZinstBaseRoot="/data"
ZinstDIRs="$ZinstBaseRoot/zinst"
ZinstSourceDir="$ZinstBaseRoot/vault/Source"
History_LOG="$ZinstBaseRoot/vault/Source/.zinst_history_log"
#
### ------ Config Area ----- 19th line here


ssh_port="22"
### Exception for Docker user
### Docker user can changes the hosts-file to the other hosts-file  as below solution
## RUN cp /etc/hosts /etc/hostsa
## RUN mkdir -p -- /lib-override && cp /lib64/libnss_files.so.2 /lib-override
## RUN sed -i 's:/etc/hosts:/etc/hostsa:g' /lib-override/libnss_files.so.2
## ENV LD_LIBRARY_PATH /lib-override

## Base information
VERSION=7.0.4
zinst_group="wheel"
sudo_base="sudo"
zinst_log="/dev/null"
#Sara_Host=""

# Add Locale 
Zinst_Locale=en


##########################################################
################ Parameter Parsing Engine ################
##########################################################
PARSED_OPTION=$(getopt -n "$0" -o :dsofzelF:u:S:O:p:P:h:H: --long "same,downgrade,stable,oldset,force,zicf,edit,list,file:,url:,set:,export:,pass:,port:,host:,hostlist:" -- "$@")
if [ $? -ne 0 ]
then
	echo "invaild option "
        exit 1
fi
eval set -- "$PARSED_OPTION"
echo $0" Argument Reparsed [ "$PARSED_OPTION " ]"

SetOptionValueCount=0
SetOptionValue[0]=""

while true;
do
    case $1 in
    --same)
	echo $1" was triggered "
	echo "downgrade on"
	SameOption="--same"
	shift
      ;;
    -d|--downgrade)
	echo $1" was triggered "
	echo "downgrade on"
	DowngradeOption="--downgrade"
	shift
      ;;
    -s|--stable)
      echo $1" was triggered "
	echo "stable on"
      shift
      ;;
    -o|--oldset)
      echo $1" was triggered "
	echo "oldset on"
      shift
      ;;
    -f|--force)
      echo $1" was triggered "
        echo "force on"
      shift
      ;;
    -z|--zicf)
      echo $1" was triggered "
        echo "zicf on"
      shift
      ;;
    -e|--edit)
      echo $1" was triggered "
	echo "edit on"
      shift
      ;;
    -l|--list)
      echo $1" was triggered "
        echo "list on"
      shift
      ;;
    -F|--file)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "file on"
      shift 2
      ;;
    -u|--url)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "url on"
      shift 2
      ;;
    -S|--set)
      echo $1" was triggered, Parameter: "$2 >&2
      SetOptionValue[$SetOptionValueCount]=$(echo $2 | sed -e 's/#/ /g')
	echo "SetOptionValueCount = "$SetOptionValueCount
	echo "set on"
	let SetOptionValueCount=$SetOptionValueCount+1
      shift 2
      ;;
    -O|--export)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "export on"
      shift 2
      ;;
    -p|--pass)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "pass on"
      shift 2
      ;;
    -P|--port)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "port on"
      shift 2
      ;;
    -h|--host)
      echo $1" was triggered, Parameter: "$2 >&2
	Hostlist=$(echo $2 | sed -e 's/,/ /g')
	HostCount=0
	for i in $Hostlist
	do
		let HostCount=$HostCount+1
	done
	echo "host on"
	ZHosts=$(eval echo $(echo ${Hostlist[@]}| sed -e 's/\[[[:alnum:]]*.\-/&../g' | sed -e 's/\-\.\./\.\./g' -e 's/\[[[:alnum:]]*.\.\.[[:alnum:]]*.\,/{&}/g' -e 's/\,\}/},/g' | sed -e 's/\[/\{/g' -e 's/\]/\}/g'))
#	Result=$(echo $DashParser | sed -e 's/\[/\{/g' -e 's/\]/\}/g')
#	ZHosts=$(eval echo $DashParser)
        shift 2
      ;;
    -H|--hostlist)
      echo $1" was triggered, Parameter: "$2 >&2
	echo "hostlist on"
      shift 2
      ;;
    --)
      shift
      break
    ;;
  esac
done

command=$1
shift 
echo $@
ZPackages=$@

##############################################################
################ Parameter Parsing Engine End ################
##############################################################

ProcessPkgNum=$#
Zset=${SetOptionValue[@]}

function print_locale () {
case $1 in
	CODE_PKG01_en)
		echo " --- Package name has not found. Please insert a package name & option exactly ---"
	;;
	CODE_PKG01_ko)
		echo " --- 패키지 이름을 찾을 수 없습니다. 패키지 이름이나 옵션을 정확이 입력해주세요. ---"
	;;
	CODE_PKG02_en)
		echo " It dose not existed target option"
                echo " ex) zinst set vipctl.onboot=yes "
	;;
	CODE_PKG02_ko)	
		echo " 타켓이 존재하지 않습니다."
		echo "예제) zinst set vipctl.onboot=yes"
	;;
esac


}


function Help_Command () {

cat << EOF
Usage: ${0##*/} [OPTION] [COMMAND] PACKAGE....
Zinst was developed for efficient management and control of distributed server farms and does not require the installation of a separate agent.
For example, you can manage multiple servers with a single command on one specific Linux device.
Option is used with -, and specific parameters can be added.
Command is used to set the server or package.

OPTION 
	-s --same
	-o --oldset
	-f --force
	-z --zicf
	-d --dep
	-e crontab --edit
	-l cronteb --list
	-F: 
	-u: --url
	-S: --set
	-O: export --file=Export_File_name
	-p: --pass Option for Multi-host password automation
	-P: --port [port]	Option for ssh port change as you need
	-h: [host] is target host. using ip address or hostname Separated by,
	-H: targe file of hostlist

COMMAND
	ssh
	mcp
	keydeploy
	install
	remove
	list
	sync
	restore
	start|stop|restart|run|on|off
	crontab
	daemon
	find
	getset
	getdep
	track
	history
	self-config
	self-upgrade
	version
	help
EOF


}


function Help_Detail () {

cat << EOF
------------------------------------------------------------------------------------------------------
	zinst	[Command]	[Option Types]		[Target Names]	[-h or -H]	[Targe Host]
------------------------------------------------------------------------------------------------------
 + For remote work

  - Remote control: You can send a command to seperated hosts
		 ssh		[Command]						*Host requires
......................................................................................................

  - File copy to remote: You can send a file(s) to seperated hosts(mcp = Multi CoPier)
		 mcp		[local-files]		[Destination DIR]		*Host requires
  - ssh-key copy to remote: You can send a ssh-key file to seperated hosts
		 keydeploy								*Host requires
------------------------------------------------------------------------------------------------------
 + For Package

  - Package manage: You can install/remove a package as under the command
		 install				[Package]
				[-same]			[Package]
				[-downgrade]		[Package]
				[-stable]		[Package without version for latest package]
				[-oldset]		[Package] for install the new package with existed set in the server
		 remove					[Package]
				[-force]		[Package]
......................................................................................................

  - Package view: You can see an installed packages/files/index & dependency
		 list					[Blank for list-up]
				[-file]			[Package]
				[-file]			[/Dir/File-name]
				[-zicf]			[Package]
				[-dep]			[Package]
......................................................................................................

  - Package sync: You can try a sync the package set by a save file	ex) ~/z/save/zinst-*
		 sync		[-file]			[Save fie for the Package set sync]
		 		[-url]			[Save fie from URL for the Package set sync]
  - Package restore: You can restore the package set by a save file for restore	ex) ~/z/save/zinst-*
		 restore	[-file]			[Saved file_name]
				[-igor]			* Not available yet

------------------------------------------------------------------------------------------------------
 + For Configuration

  - Configuration: Zinst can helps to configure the setup without manual modify the Conf-file
		 set					[Blank for list-up]
							[Package.option=value]

  - Configuration with Install: Configure the setup with the package install
		 [Package]	-set 			[Package.option=value]

------------------------------------------------------------------------------------------------------
 + For System manage

  - Daemon control: You can control the daemon from the /etc/init.d/ directory
		 start/stop/restart/run			[Daemon_name]
		 on/off					[Daemon_name]
......................................................................................................

  - Crontab manage: You can touch the cron schduler by zinst
		 crontab	[-e]
				[-l]

------------------------------------------------------------------------------------------------------
 + For find the available daemon from the package

  - Package daemon
		 daemon		[Blank for list-up]
------------------------------------------------------------------------------------------------------
 + For install available package find

  - Package find
		 find		[Blank for list-up]
				[Package]

------------------------------------------------------------------------------------------------------
 + For tracking the released package

  - Track the package
		 track		[Blank for list-up]
				[Package or hostname]
				[Package or hostname]	[-file]
				[Package or hostname]	[-file=Export_File_name]
				"user" or "sudo_user"
				[User_Package_name]	[-file]
				[User_Package_name]	[-file=Export_File_name]
------------------------------------------------------------------------------------------------------
 + View history

		 history	[Number of Range]
......................................................................................................

		 -pass					 Option for Multi-host password automation
           -p [ssh port number of destination]	 Option for ssh port change as you need
		 self-update
		 self-config	ip=x.x.x.x host=xxx.xxx.xxx
		 -version

		 *, help
------------------------------------------------------------------------------------------------------
 -h is target host, -H is targe file of hostlist
 ex) zinst i sample-1.0.0.zinst -h web01.news.kr[1,3]  web[03-12].news[1,3]
 ex) zinst i sample-1.0.0.zinst -H ./server_list.txt
------------------------------------------------------------------------------------------------------



Example)
zinst ssh 'cat /etc/hosts;pwd' -h web[01-09].test.com	: Send a command to seperated hosts

zinst mcp ./test.* /data/var/ -h web[01-09].test.com 	: File copy to seperated hosts

zinst install hwconfig -stable			: for package apply as a latest version automatically

zinst install hwconfig-1.0.2.zinst -same		: for overwrite the package as a same version
zinst i hwconfig-1.0.2.zinst -downgrade			: for downgrade the package as a lower version

zinst list -file hwconfig				: list-up file of the hwconfig package
zinst ls -file /data/bin/hwconfig			: find a package as a file
zinst list -zicf hwconfig				: see the index file of package
zinst ls -dep hwconfig 					: package dependency check

zinst set						: list-up of zinst current setups
zinst set hwconfig.nameserver1=1.1.1.1			: change the setup nameserver1=1.1.1.1 to the hwconfig

zinst i hwconfig-1.0.2.zinst -set hwconfig.nameserver1=1.1.1.1 -set hwconfig.nameserver2=2.2.2.2
 : change the setup nameserver1=1.1.1.1 and nameserver2=2.2.2.2 to the hwconfig with package install

zinst restart httpd					: restart the httpd daemon by /etc/init.d/httpd file control

zinst crontab -l 					: list-up the crontab scheduler
zinst crontab -u root -l			: list-up the crontab scheduler for an user
zinst cront -e	 					: edit the crontab scheduler

zinst find						: list-up the available file for install
zinst find hwcon					: list-up the available file for install as you typed

zinst hist						: show the history
zinst hist 300						: show the 300 lines history

zinst self-update					: zinst command update( *Requires: Package dist server must has a zinst file)
zinst  self-config ip=x.x.x.x host=xxx.xxx.xxx	: you can change the configuration what you want

zinst help						: Detail view the help

=== For more detail: https://github.com/goody80/Ralf_Dev ===
EOF
}


function exception_check() {
        if [ $? -eq 0 ]
        then
                if [ -z $1 ]
                then
                        echo "done"
                fi
        else
                echo "Some task return code "$?
                echo "===Something wrong!!!==="
                exit 1
        fi
}

IPAddress_Check () {
	if [[ $1 =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]
	then
		return 0	
	else
		echo $1
		echo "Server ip is not correct"
		return 1
	fi
}


##############################################################
################  Add to function from below  ################
##############################################################


OS_Checker(){

	## OS Check
	Chk_OS_file="/tmp/chked_os.txt"
        if [[ ! -f $Chk_OS_file ]]
	then
                if [[ $(uname) == Linux ]]
		then
                        if [[ $(cat /etc/*-release 2> /dev/null | head -1 |grep Ubuntu) != "" ]]
			then
                                OS_name="Ubuntu"
				echo "$OS_name" > $Chk_OS_file
                        elif [[ $(cat /etc/lsb-release 2> /dev/null | head -1 |grep LinuxMint) != "" ]]
			then
                                OS_name="Ubuntu"
				echo "$OS_name" > $Chk_OS_file
                        elif [[ $(cat /etc/redhat-release 2> /dev/null | head -1 |grep "CentOS") != "" ]] || [[ $(cat /etc/redhat-release 2> /dev/null | head -1 |grep "Red Hat") != "" ]] 
			then
                                if [[ $(grep "CentOS" /etc/redhat-release 2> /dev/null |grep "[0-9]" | sed -e 's/[ a-zA-Z()]//g' |grep "^7") ]] || [[ $(grep "Red Hat" /etc/redhat-release 2> /dev/null |grep "[0-9]" | sed -e 's/[ a-zA-Z()]//g' |grep "^7") ]] 
				then
                                        OS_name="RHEL7"
					echo "$OS_name" > $Chk_OS_file
                                else
                                        OS_name="RHEL"
					echo "$OS_name" > $Chk_OS_file
                                fi
                        elif [[ $(cat /etc/*-release 2> /dev/null |grep "rhel") != "" ]]  
			then
                                OS_name="RHEL"
				echo $OS_name > $Chk_OS_file
                        fi
                elif [[ $(uname) == Darwin ]]
		then
                        OS_name="OSX"
			echo "$OS_name" > $Chk_OS_file
                else
                        OS_name="freeBSD"
			echo "$OS_name" > $Chk_OS_file
                fi
        else
                OS_name=$(cat /tmp/chked_os.txt)
        fi
}

System_Controller_checker(){
        if [[ "$(type -p systemctl)" = "" ]]
	then
                if [[ "$(type -p service)" = "" ]]
		then
                        system_command="service"
                else
                        system_command=""
                fi
        else
                system_command="systemctl"
        fi
}

Select_OS(){
	OS_name=$1
        case $OS_name in
                RHEL )
                        CronDir=/var/spool/cron
                        Crond=crond
                        OS_type="/rhel" 
		;;
                RHEL7 )
                        CronDir=/var/spool/cron
                        Crond=crond
                        OS_type="/rhel7" 
		;;
                Ubuntu )
                        CronDir=/var/spool/cron/crontabs
                        Crond=cron
                        OS_type="/ubuntu" 
		;;
                OSX )
                        CronDir=/var/spool/cron
                        Crond=crond
                        OS_type="/osx" 
		;;
                freeBSD )
                        CronDir=/var/spool/cron
                        Crond=crond
                        OS_type="/freebsd" 
		;;
        esac
}

Requires_Pkg_install(){
	ComPkg=$@
        ## Requires check
	for i in $ComPkg
	do
		if [ "$(type -p $i)" == "" ]
		then
                	echo "$BARR"
	                echo " You need to install the "$i" command. Let's try to install that package..."
	                echo "$BARR"
        	                case $OS_name in
                	                RHEL)
                        	                $sudo_base yum install -y $i 
						exception_check
					;;
        	                        Ubuntu)
                	                        $sudo_base apt-get install -y $i
						exception_check
					;;
        	                esac
			echo "Check Requires Packages"
			if [ "$(type -p $i)" == "" ]
			then
				echo "$BARR"
		                echo " You need to install the "$i" Package manually"
       	        		echo "$BARR"
	                	exit 0
			else
				echo "Require Package path is "$(type -p $i)
			fi
		fi
	done
}


hosts_redefine(){
	$sudo_base cat $HostsFile > /tmp/hosts.tmp
	$sudo_base sed -i "s#/#@Q@#g" /tmp/hosts.tmp
	Rev_FetchedDistServer=$(echo "$FetchedDistServer" | sed -e "s#/#@Q@#g")
	$sudo_base sed -i "/$Rev_FetchedDistServer/d" /tmp/hosts.tmp
	$sudo_base bash -c "echo $ManagerIP $Rev_FetchedDistServer >> /tmp/hosts.tmp"
	$sudo_base sed -i "s#@Q@#/#g" /tmp/hosts.tmp
	$sudo_base bash -c "cat /tmp/hosts.tmp > $HostsFile"
}

version_redefine (){
        echo "$@" | awk -F'.' '{printf("%03d%03d%03d\n", $1,$2,$3); }'
}


exit_abnormal() {
        stty echo
        echo " - Command has been canceled -"
        exit 1
}

Pass_Checker() {
	## Test variable
	if [[ $Check_Multi_pw != "OK" ]]
	then
		:
	else
		echo " Please insert a password for a work to the destination "
		read -s Zinst_PASSWD
		if [[ $Zinst_PASSWD = "" ]]
		then
			Comm_sshpass="sshpass -p \"$Zinst_PASSWD\""
		else
        		Comm_sshpass="sshpass -p $Zinst_PASSWD"
		fi
	fi
}

Daemon_list(){
	## package_name is check for daemon list
	package_name=$1

	## Check the system control command
	if [[ $system_command = "systemctl" ]]
	then
		DaemonDir="/lib/systemd/system/"
	else
		DaemonDir="/etc/init.d/"
	fi
	## Progress bar
	pstr="[==================================================================]"
	echo " Scaning..."
        if [[ $package_name = "" ]]
	then
                pkg_list=$(zinst  ls | fgrep -v "user_" | awk '{print $4}' | xargs)
                Print_list="/tmp/result.list"
                echo "$BARR" > $Print_list
                echo " [COMMAND]: \"start/stop/restart/run\" or \"on|off\" " >> $Print_list
                echo "$Barr" >> $Print_list
		Count=0
		while [ $Count -lt ${#pkg_list[@]} ]
		do
                	daemon_check=$(zinst ls ${pkg_list[$Count]} -file |grep "$DaemonDir" | awk -F "/" '{print $NF}')
                        if [[ $daemon_check != "" ]]
			then
                        	echo ""  >> $Print_list
                                echo "+ ${pkg_list[$Count]}:" >> $Print_list
                                echo " zinst [COMMAND] $daemon_check" >> $Print_list
			fi
			let Count=$Count+1

                        ## Part of Progress bar
                        pd=$(( $Count * 69 / ${#pkg_list[@]} ))
                        Pkg_picklist="${pkg_list[$Count]}"
                        if [[ $Pkg_picklist = "" ]]
			then
                        	Pkg_picklist=" - Package Scan has been completed -"
                        fi
                        printf "\r%-2s %-40s %3s %3d.%1d%% %.${pd}s" '|' "$Pkg_picklist" '|' $(( $Count * 100 / ${#pkg_list[@]} )) $(( ($Count * 1000 / ${#pkg_list[@]}) % 10 )) $pstr
		done
                ## Line bracker for Progress bar
                echo ""
                echo ""
                echo "$BARR" >> $Print_list
                cat $Print_list
        else
                echo "$Barr"
                daemon_check=$(zinst ls $package_name -file |grep "$DaemonDir" |tail -1 | awk -F "/" '{print $NF}')
                if [[ $daemon_check != "" ]]
		then
                	echo ""
                        echo "$Barr"
                        echo " [COMMAND]: \"start/stop/restart/run\" or \"on|off\" "
                        echo "$BARR"
                        echo "+ $package_name:"
                        echo " zinst [COMMAND] $daemon_check"
		else:
                	echo " $package_name package has not any daemon for run !!!"
		fi
		echo "$Barr"
        fi
	exit 0
	rm -f $Print_list
}

### History File reset for permission
$sudo_base chmod 664 $History_LOG 2> $zinst_log
exception_check
$sudo_base chgrp $zinst_group $History_LOG 2> $zinst_log
exception_check

Package_Parse_Check(){
	### Package name check
	Parse_Checker=$*
        ParsedPkgVerChk=$(echo "$Parse_Checker" | egrep "\-[0-9.*]*.zinst\$")
        if [[ $ParsedPkgVerChk != "" ]]
        then
                ParsedPkgZinstFind=$(cat $CurrPkgList | grep "^$Parse_Checker" | tail -1)
                if [[ $ParsedPkgZinstFind = "" ]]
                then
                        echo "$BARR"
                        echo "Which one is correct as you want in below list ( "$Parse_Checker" )"
                        echo "$ROWW"
                        zinst find "^$Parse_Checker-"
			exception_check
                        echo "$BARR"
                        echo ""
                        exit 0
                else
                        Parse_Result=$ParsedPkgZinstFind
                fi
        else
                if [[ $(echo  "$ProcessPkg" |grep "$Parse_Checker") = "" ]]
		then
                ParsedPkgZinstFind=$(cat $CurrPkgList | grep "^$Parse_Checker-" | tail -1)
                        if [[ $ParsedPkgZinstFind = "" ]]
                        then
                                echo "$BARR"
                                echo "Which one is correct as you want in below list ( "$Parse_Checker" )"
                                echo "$ROWW"
                                zinst find "^$Parse_Checker-"
				exception_check
                                echo "$BARR"
                                exit 0
                        else
                                Parse_Result=$ParsedPkgZinstFind
                        fi
                else
                        Parse_Result=$(zinst find "^$Parse_Checker-" | tail -1)
                        if [[ $Parse_Result = "" ]]
			then
                                PkgCheckArry=$PkgCheckArry" "$Parse_Result
                                printf "%-59s %-1s %-10s %-1s\n" "| $Parse_Checker" "|" "Not existed" "|"
                                exit 0
                        fi
                fi

        fi
}


PrintCheck(){

	Parse_Result=$@
        PkgCheckTime=$(echo "$PkgCheckArry" |grep " $Parse_Result")
        if [[ $PkgCheckTime = "" ]]
	then
                PkgCheckArry=$PkgCheckArry $Parse_Result
                printf "%-59s %-1s %-10s %-1s\n" "| $Parse_Result" "|" "- Checked " " |"
        fi
}


Package_Array_Sort(){
	BoxPkg=$ZPackages
	BoxPkgArry=( $BoxPkg )

	CurrPkgList="$ZinstBaseRoot/vault/Source/.current_package.list"

	StockPkg="/tmp/stockpkg"
	touch $StockPkg

	### Package list up
	zinst find  > $CurrPkgList
	exception_check
	sudo mkdir -p $CurrPkgDiR
	exception_check
	### Loop for each package sort
	BoxCounter=0
#	while [ $BoxCounter -lt ${##BoxPkgArry[@]} ]
	for i in $BoxPkg
	do
		#Package_Parse_Check ${BoxPkgArry[$BoxCounter]}
		Package_Parse_Check $i
		#BoxPkgArry[$BoxCounter]=$Parse_Result
		$i=$Parse_Result
		PrintCheck $Parse_Result
		#### Start here for fetch the information
		### Dependency check by zicf file from distribution server
			#IndexFileChk=$(ls $CurrPkgDiR/${BoxPkgArry[$BoxCounter]}.zicf 2> $zinst_log)
			IndexFileChk=$(ls $CurrPkgDiR/$i.zicf 2> $zinst_log)
			if [[ $IndexFileChk = "" ]]
			then
				$sudo_base bash -c "curl -sL \"$Dist_URL/checker/$i.zicf\" -o $CurrPkgDiR/$i.zicf 2> $zinst_log "
				exception_check
				CheckDep=$(cat $CurrPkgDiR/$i.zicf 2> $zinst_log |grep '^ZINST requires' | sed 's/ZINST requires pkg //g')
			else
				CheckDep=$(cat $CurrPkgDiR/$i.zicf 2> $zinst_log |grep '^ZINST requires' | sed 's/ZINST requires pkg //g')
			fi

		### Check existed dependency package
		if [[ ${CheckDep[@]} != ""  ]]
		then
			### Loop for requires package check
			SubBoxCounter=0
			while [ $SubBoxCounter -lt ${#CheckDep[@]} ]
			do
				### version check & define
				SubCt=0
				while [ $SubCt -lt ${#BoxPkgArry[@]} ]
				do
					## check verion in line
					Package_Parse_Check ${BoxPkgArry[$SubCt]}
					BoxPkgArry[$SubCt]=$Parse_Result
					PrintCheck $Parse_Result
				let SubCt=$SubCt+1
				done

				### Package Parse check such as a version
				Package_Parse_Check ${CheckDep[$SubBoxCounter]}
				CheckDep[$SubBoxCounter]=$Parse_Result
				PrintCheck $Parse_Result

				## Check Existed package in line
				CheckBoxPkg=$(echo "${BoxPkgArry[@]}" | grep "${CheckDep[$SubBoxCounter]}" )

				## Check Existed package in local
				CurrCheckBoxPkg=$(zinst ls |grep -w \`echo "${CheckDep[$SubBoxCounter]}" | awk -F'-' '{print $1}'\`)
				SubFetchFile=$(echo "${CheckDep[$SubBoxCounter]}")
				SubIndexFileChk=$(ls $CurrPkgDiR/$SubFetchFile.zicf 2> $zinst_log)
				if [[ $SubIndexFileChk = "" ]]
				then
					$sudo_base bash -c "curl -sL \"$Dist_URL/checker/$SubFetchFile.zicf\" -o $CurrPkgDiR/$SubFetchFile.zicf 2> $zinst_log "
					exception_check
					SudDepChk=$(cat $CurrPkgDiR/$SubFetchFile.zicf 2> $zinst_log |grep '^ZINST requires' | sed 's/ZINST requires pkg //g')
				else
					SudDepChk=$(cat $CurrPkgDiR/$SubFetchFile.zicf 2> $zinst_log |grep '^ZINST requires' | sed 's/ZINST requires pkg //g')
				fi

				### Package version check & define
				SubCLe=0
				while [ $SubCLe -lt ${#SudDepChk[@]} ]
				do
					if [[ ${SudDepChk[$SubCLe]} != "" ]]
					then
						CurrSubSecPkgChk=$(zinst ls -w |grep "${SudDepChk[$SubCLe]}" | awk '{print $4}' )
						SubSecPkgChk=$(echo "${BoxPkgArry[@]}" | grep "${SudDepChk[$SubCLe]}")
						if [[ $CurrSubSecPkgChk = "" ]]
						then
							if [[ $SubSecPkgChk = "" ]]
							then
								echo " $Barr"
								echo "  Notice: Package requires as below"
								echo "   ${SudDepChk[$SubCLe]}"
								echo " $Barr"
								echo ""
								exit 0;
							fi
						fi
					fi
				let SubCLe=$SubCLe+1
				done

				### Switch array
				if [[ $SubBoxCounter = 0 ]]
				then
					if [[ $CurrCheckBoxPkg = "" ]]
					then
						if [[ $CheckBoxPkg != "" ]]
						then
						### Check in-line package include
						ChkinArry=$(echo "$CheckBoxPkg" |grep -w "${CheckDep[$SubBoxCounter]}")
							if [[ $ChkinArry != "" ]]; then
								echo ${CheckDep[$SubBoxCounter]}" "${BoxPkgArry[$BoxCounter]} >> $StockPkg

							else
							### Require package check in local
							CurrSubSecPkgChk=$(zinst ls -w |grep "${CheckDep[$SubBoxCounter]}" | awk '{print $4}')
								if [[ $CurrSubSecPkgChk = "" ]];then
									echo $Barr
									echo "  Notice: Package requires as below !!!!"
									echo "   "${CheckDep[$SubBoxCounter]}
									echo $Barr
									echo ""
									exit 0;
								else
									echo "${BoxPkgArry[$BoxCounter]} tmp_beacon" >> $StockPkg
								fi
							fi
						else
							echo "$Barr"
							echo "  Notice: Package requires as below"
							echo "   ${CheckDep[$SubBoxCounter]}"
							echo "$Barr"
							echo ""
							exit 0;
						fi
					else
						ChkinArry=$(echo " $CheckBoxPkg" |grep " ${CheckDep[$SubBoxCounter]}")
							if [[ $ChkinArry != "" ]]; then
								echo ${CheckDep[$SubBoxCounter]}" "${BoxPkgArry[$BoxCounter]} >> $StockPkg
							else
							CurrSubSecPkgChk=`zinst ls |grep -w "${SudDepChk[$SubCLe]}" | awk '{print $4}' `
								if [[ $CurrSubSecPkgChk = "" ]];then
									echo $Barr
									echo "  Notice: Package requires as below"
									echo "   "${CheckDep[$SubBoxCounter]}
									echo $Barr
									echo ""
									exit 0;
								else
									echo "${BoxPkgArry[$BoxCounter]} tmp_beacon" >> $StockPkg
								fi
							fi
					fi
				else
					### Not depens on the package
					if [[ $CurrCheckBoxPkg = "" ]]
					then
						if [[ $CheckBoxPkg != "" ]]
						then
							echo "${CheckDep[$SubBoxCounter]} ${BoxPkgArry[$BoxCounter]}" >> $StockPkg
						else
								echo "$Barr"
								echo "  Notice: Package requires as below"
								echo "   ${CheckDep[$SubBoxCounter]}"
								echo "$Barr"
								echo ""
								exit 0;
						fi
					fi
				fi
				let SubBoxCounter=$SubBoxCounter+1
			done
		else
			Package_Parse_Check ${BoxPkgArry[$BoxCounter]}
			BoxPkgArry[$BoxCounter]=$Parse_Result
			PrintCheck $Parse_Result
			echo "${BoxPkgArry[$BoxCounter]} tmp_beacon" >> $StockPkg
		fi
	let BoxCounter=$BoxCounter+1
	done

BoxPkgArry=( `tsort $StockPkg | sed -e '/tmp_beacon/d'`)

### Remove temporary file
rm -f $CurrPkgList $CurrPkgDiR 2> $zinst_log
rm -f $StockPkg

AllPkgSortedResult="${BoxPkgArry[@]}"
}

#########################################################################################
############################# zinst re-org engine end ###################################

## Package Version making auto
StableOptionCheck=$(echo "${PackageArryOption[@]}" |grep "\-stable")
	CheckCommandX=$(echo $CommandX |egrep "^i")
	if [[ $CheckCommandX != "" ]]
	then
		if [[ $StableOptionCheck != "" ]]
		then
			echo ""
			echo $Barr
			Package_Array_Sort $ZPackages
			ProcessPkg=$AllPkgSortedResult
		fi
	fi



Save_Restore_file(){
### Save a restore file


Save_File_num=`ls $Save_Dir/ |egrep ^$Save_Filename | awk '{print NR}' |tail -1`
    if [[ $Save_File_num = ""  ]];
    then
        Save_File_num="0"
    fi
MakeANum=1
let MakeANum=MakeANum+$Save_File_num
Naming="$Save_Filename.$MakeANum"

echo "# --- Last touched by $WhoStamps --- " > $Save_Dir/$Naming
echo "# --- Last command \" zinst $PackageAll \" " >> $Save_Dir/$Naming
echo "# Date: `date +%Y.%m.%d_%T` " >> $Save_Dir/$Naming
echo "#"  >> $Save_Dir/$Naming
echo "# zinst package installer all-configuration backup-list for the package restore" >> $Save_Dir/$Naming
zinst ls | awk '{print "Package install",$4".zinst"}' >> $Save_Dir/$Naming
echo "- - - " >> $Save_Dir/$Naming
zinst set | awk 'NR>1{print "Package setting",$1}' >> $Save_Dir/$Naming
    if [[ $Save_File_num != "0"  ]];
    then
		CheckSameSave=`diff $Save_Dir/$Save_Filename.$Save_File_num  $Save_Dir/$Naming 2> $zinst_log`
			if [[ $CheckSameSave = "" ]]
			then
				$sudo_base rm -f $Save_Dir/$Naming
			fi
	fi
}

Pkg_Install(){
	CounterAll=1
	#while [[ $CounterAll -le $ProcessPkgNum ]]
	for i in $ZPackages
	do
#		Package_list=$(echo $ProcessPkg |awk '{print $'$CounterAll'}')
		Package_list=$ZPackages
			if [[ $( echo "$Package_list" |grep "[a-z].*--" ) != "" ]]
			then
				Package_list_conv=$(echo "$Package_list" | sed -e 's/[a-z].*--//g')
				cp -vf $Package_list ./$Package_list_conv
				Package_list=$Package_list_conv
			fi

		## Check the Package or Distribution server
		Pkg_result=$(cd $PWD;ls |grep "^$Package_list")
			if [[ $Pkg_result = "" ]];
			then
				DIST=$Dist_URL
			else
				DIST=$(pwd)
			fi
		############################## Install start without target host ##################################################
		ZinstName=$(echo "$Package_list" |awk -F "[.]zinst" '{print $1}')
		ZinstOrgName=$(echo "$Package_list" |awk -F "-" '{print $1}')

			if [[ $Pkg_result != $Package_list ]]
			then
				###  check package by curl ###
				Package_RC=$(curl --head --silent $Dist_URL/$Package_list 2> $zinst_log | head -1)
			fi

			#### check local zinst file
			if [[ $Pkg_result = $Package_list ]]
			then
				Package_RC="Remote file exists."
				alias cp=cp
				CheckDir=`ls $ZinstSourceDir| grep $ZinstName$`
					if [[ $CheckDir = "" ]]
					then
						$sudo_base mkdir $ZinstSourceDir/$ZinstName
					fi
 				$sudo_base cp -f $DIST/$Package_list $ZinstBaseRoot/vault/Source/$ZinstName/$Package_list
	 			$sudo_base chgrp -R $zinst_group $ZinstBaseRoot/vault/Source/$ZinstName
	 			$sudo_base chmod g+w $ZinstBaseRoot/vault/Source/$ZinstName
			fi

			if [[ $(echo "$Package_RC" |egrep -i "not") != "" ]]
			then
				echo "  "
				echo "  $Package_list Package has not found."
				echo "  "
				exit 0;
			fi
		## Check a same version Package
		Existed_pkg=$(ls -l $ZinstDIRs 2> $zinst_log |grep ^l | grep "/$ZinstOrgName-" | awk  '{print $NF}' | awk -F '/' '{print $NF}')
		Existed_pkg_version=$(echo "$Existed_pkg" | awk -F'-' '{print $2}')
		Origin_pkg_version=$(echo "$ZinstName" | awk -F'-' '{print $2}')
		echo ""
		echo ----- $Package_list -----
			if [[ $(version_redefine $Origin_pkg_version) = $(version_redefine $Existed_pkg_version) ]]
			then
			#########  -same -live option check  ################
				if [[ $SameOption != "--same" ]]
				then
					echo "$Barr"
					echo "The Server has a same version of package already"
					echo "Please insert an option like this \"--same\" if you want to install continue."
					echo "$Barr"
					exit 0;
				fi
			fi

			if [[ $(version_redefine $Origin_pkg_version) < $(version_redefine $Existed_pkg_version) ]]
			then
			#########  -downgrade option check  ################
				if [[ $DowngradeOption != "-- downgrade" ]]
				then
					echo "$Barr"
					echo "Your package is a older version then exists package version"
					echo "Please insert an option like this \"--downgrade\" if you want to install continue."
					echo "$Barr"
					exit 0;
				fi
			fi

			#########  -oldset option check - when the package update -oldset option can apply old setup to new package ################
			if [[ $Old_set_checker = "-oldset" ]]
			then
				oldset=`zinst set |grep "$ZinstOrgName\." | sed -e 's/^/ -set /g' | xargs `
				Zset="$Zset $oldset"
			fi

		## Unpacking
		mkdir -p $ZinstBaseRoot/vault/Source/$ZinstName
		mkdir -p $ZinstDIRs
		mkdir -p $ZinstBaseRoot/src
		$sudo_base chgrp -R $zinst_group $ZinstBaseRoot/vault/Source/$ZinstName
		$sudo_base chgrp $zinst_group $ZinstDIRs
		$sudo_base chgrp $zinst_group $ZinstBaseRoot/src

		##If you have distribution server. you can setup as below.
		alias cp=cp
		cd $ZinstSourceDir/$ZinstName/
		$sudo_base rm -f $ZinstSourceDir/$ZinstName/$Package_list
			if [[ $Pkg_result != $Package_list ]]
			then
				echo  " Downloading..."
				$sudo_base bash -c "curl -w ' [:: %{size_download} byte has been downloaded ::]\n' -L -#  \"$Dist_URL/$Package_list\" -o ./$Package_list"
			else
				$sudo_base mv -f $DIST/$Package_list $ZinstBaseRoot/vault/Source/$ZinstName/$Package_list	### local file copy
			fi
		cd $ZinstBaseRoot/vault/Source/$ZinstName
		$sudo_base tar zxf $ZinstBaseRoot/vault/Source/$ZinstName/$Package_list
		$sudo_base rm -rf $ZinstBaseRoot/vault/Source/$ZinstName/$Package_list
		zicf_name=`echo $Package_list | awk -F "-" '{print $1".zicf"}'`
		ZICF=`ls |grep "$zicf_name" | head -1`
		$sudo_base rm -Rf $ZinstDIRs/$ZinstOrgName
		$sudo_base ln -sf $ZinstBaseRoot/vault/Source/$ZinstName $ZinstDIRs/$ZinstOrgName
		cd $ZinstDIRs/$ZinstOrgName; $sudo_base chmod 644 $ZICF

		## Value set
		Packagename=`$sudo_base cat $ZICF |grep ^PACKAGENAME |awk '{print $3}'`
		ZinstPackageDir="$ZinstDIRs/$Packagename"
		Version=`$sudo_base cat $ZICF |grep ^VERSION |awk '{print $3}'`
		Authorized=`$sudo_base cat $ZICF |grep ^AUTHORIZED |awk '{print $3}'`
		Owner=`$sudo_base cat $ZICF |grep ^OWNER |awk '{print $3}'`
			## Useradd for package install
			CheckOwner=`$sudo_base cat /etc/passwd | awk -F':' '{print $1}' |egrep "^$Owner$"`
			if [[ $CheckOwner = "" ]];then
				$sudo_base adduser -M "$Owner"
			fi
		Group=`$sudo_base cat $ZICF |grep ^GROUP |awk '{print $3}'`
			## groupadd for package install
			CheckGroup=`$sudo_base cat /etc/group | awk -F':' '{print $1}' |egrep "^$Group$"`
			if [[ $CheckGroup = "" ]];then
				$sudo_base groupadd "$Group"
			fi
		Perm=`$sudo_base cat $ZICF |grep ^PERM |awk '{print $3}'`
		Custodian=`$sudo_base cat $ZICF |grep ^CUSTODIAN |awk '{print $3}'`
		Crontab=`$sudo_base cat $ZICF |grep ^CRON |awk 'NR==1{print $1}'`
		CrontabRow=`$sudo_base cat $ZICF |grep ^CRON |awk '{print NR}' |tail -1`
		Description=`$sudo_base cat $ZICF |grep ^DESCRIPTION |awk '{print $0}'`
		## Directory Group Permission
		$sudo_base chgrp $Group $ZinstBaseRoot/vault/Source/$ZinstName $ZinstDIRs/$ZinstOrgName

		### zinst default checkr
		## zinst set checker
		ZinstSetCheck=`$sudo_base cat $ZinstBaseRoot/vault/zinst/zinst_set.list 2> $zinst_log | grep ZinstSet | awk '{print $1}'`
		ZinstSetTitle="#==========================ZinstSet==========================="
			if [[ $ZinstSetCheck != $ZinstSetTitle ]];
			then
				$sudo_base mkdir -p $ZinstBaseRoot/vault/zinst/
				$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/
				echo "$ZinstSetTitle" > $ZinstBaseRoot/vault/zinst/zinst_set.list
				$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/zinst_set.list
				echo "   -------> $ZinstBaseRoot/vault/zinst/zinst_set.list has been created for the zinst :)"
				echo " "
			fi
		$sudo_base mkdir -p $ZinstBaseRoot/vault/Source $ZinstBaseRoot/zinst
		$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/Source $ZinstBaseRoot/zinst

		### Dependency-checker file
		## zinst dependency checker
		ZinstDepTitle="#==========================ZinstDep==========================="
			if [[ ! -f $ZinstBaseRoot/vault/zinst/.dependency.list ]];
			then
				$sudo_base mkdir -p $ZinstBaseRoot/vault/zinst/
				$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/
				echo "$ZinstDepTitle" > $ZinstBaseRoot/vault/zinst/.dependency.list
				$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/.dependency.list
				echo " "
			fi
		### Make a Blank .file.list
		echo "echo \" $Packagename-$Version package install ==>>> \" " > .file.list
		echo "export ZinstDir=$ZinstBaseRoot " >> .file.list
		$sudo_base chgrp $zinst_group .file.list
		$sudo_base chmod 664 .file.list
		## Package Dependency check - on no-over write
		Dep_checkerNum=`$sudo_base cat ./$ZICF  |grep "^ZINST requires pkg" | awk '{print NR}' |tail -1 `
		DepCounter=1
			while [[ $DepCounter -le $Dep_checkerNum ]]
			do
				Dep_checker=`$sudo_base cat ./$ZICF  |grep "^ZINST requires pkg" | awk 'NR=='$DepCounter'{print $4}'`
				Dep_list_check=`zinst ls |awk -F '-   ' '{print $2}' | awk -F '-' '{print $1}' | egrep "^$Dep_checker$"`
					if [[ $Dep_checker != "" ]]
					then
						if [[ $Dep_list_check = "" ]]
						then
							echo ""
							echo " ===== You need to install the \"$Dep_checker\" package first before the $Packagename install ===="
							$sudo_base rm -Rf $ZinstBaseRoot/vault/Source/$ZinstName $ZinstDIRs/$ZinstOrgName
							exit 0;
						fi
					fi
				### Dependency comment check
				echo "# Dependency package: $Dep_checker"  >> .file.list
				let DepCounter=DepCounter+1
			done
		#### [File parser] #####
		### File set
		## Directory make for the File copy
		CPP=( `$sudo_base cat $ZICF |grep ^FILE | awk '{print "'$ZinstBaseRoot'/"$5}'` )
			if [[ $CPP != ""  ]];
			then
				## Copy Array Duplicate filter
				RCPP=(`printf "%s\n" "${CPP[@]%/*}" | sort -u`)

				echo "$sudo_base mkdir -p ${RCPP[*]}" >> .file.list
				echo "$sudo_base chgrp $Group ${RCPP[*]}" >> .file.list
				echo "$sudo_base chown $Owner ${RCPP[*]}" >> .file.list
			fi

		## Parsing for Quotation mark encode
		sed -i 's/"/%Q%/g' $ZICF

		## Insert for uninstall command
		if [ -f $ZinstBaseRoot/vault/Source/$ZinstName/uninstall.sh ] ; then
			$sudo_base chmod 775 $ZinstBaseRoot/vault/Source/$ZinstName/uninstall.sh
			$sudo_base chown $Owner $ZinstBaseRoot/vault/Source/$ZinstName/uninstall.sh
			$sudo_base chgrp $Group $ZinstBaseRoot/vault/Source/$ZinstName/uninstall.sh
			$sudo_base bash -c 'echo "echo \"*** Uninstall option has been activated ***\""' >> .file.list
		fi
		## File copy
		#echo "File copy" >> .file.list
		$sudo_base cat $ZICF |grep ^FILE | awk '{print "cp ",$6,"'$ZinstBaseRoot'/"$5,";echo \"'$ZinstBaseRoot'/"$5"\""}' >> .file.list
		echo " echo \" --- File Initializing .....\"" >> .file.list

		## File Permission
		$sudo_base cat $ZICF |grep ^FILE | awk '{print "chmod",$2,"'$ZinstBaseRoot'/"$5}' >> .file.list

		echo " echo \" --- Permission Initializing .....\"" >> .file.list
		## File Owner
		#$sudo_base cat $ZICF |grep ^FILE | awk '{print "chown",'\"$Owner\"',"'$ZinstBaseRoot'/"$5}' >> .file.list
		$sudo_base cat $ZICF |grep ^FILE | awk '{print "chown",$3,"'$ZinstBaseRoot'/"$5}' >> .file.list

		echo " echo \" --- Setting the Group  .....\"" >> .file.list
		## File Group
		$sudo_base cat $ZICF |grep ^FILE | awk '{print "chgrp",$4,"'$ZinstBaseRoot'/"$5}' >> .file.list

		#### [Symbolic parser] #####
		### Symbolic link set
		## Directory makes for the simbolic
		LNP=( `$sudo_base cat $ZICF |grep ^SYMB | awk '{print "'$ZinstBaseRoot'/"$5}'` )
			if [[ $LNP != ""  ]];
			then
				## Copy Array Duplicate filter
				RLNP=(`printf "%s\n" "${LNP[@]%/*}" | sort -u`)
				echo "$sudo_base mkdir -p ${RLNP[*]}" >> .file.list
				echo "$sudo_base chgrp $Group ${RLNP[*]}" >> .file.list
				echo "$sudo_base chown $Owner ${RLNP[*]}" >> .file.list
			fi
		## make a Symbolic
		#echo "Make a symbole" >> .file.list
		$sudo_base cat $ZICF |grep ^SYMB | awk '{print "sudo ln -fs '$ZinstBaseRoot'/"$6, "'$ZinstBaseRoot'/"$5}' >> .file.list

		#### [Configuration file parser] #####
		### Config file set
		## Directory makes for the Config
		CPC=( `$sudo_base cat $ZICF |grep ^CONF | awk '{print "'$ZinstBaseRoot'/"$5}'` )
			if [[ $CPC != ""   ]];
			then
				## Copy Array Duplicate filter
				RCPC=(`printf "%s\n" "${CPC[@]%/*}" | sort -u`)
				echo "$sudo_base mkdir -p ${RCPC[*]}" >> .file.list
				echo "$sudo_base chgrp $Group ${RCPC[*]}" >> .file.list
				echo "$sudo_base chown $Owner ${RCPC[*]}" >> .file.list
				echo "$sudo_base touch  ${RCPC[*]}""/_zinst" >> .file.list
			fi
		#echo "Config file set" >> .file.list
		$sudo_base cat $ZICF |grep ^CONF | awk '{print "cp",$6,"'$ZinstBaseRoot'/"$5}' >> .file.list

		## Config Permission
		$sudo_base cat $ZICF |grep ^CONF | awk '{print "chmod",$2,"'$ZinstBaseRoot'/"$5}' >> .file.list

		## Config Owner
		$sudo_base cat $ZICF |grep ^CONF | awk '{print "chown",$3,"'$ZinstBaseRoot'/"$5}' >> .file.list

		## Config Group
		$sudo_base cat $ZICF |grep ^CONF | awk '{print "chgrp",$4,"'$ZinstBaseRoot'/"$5}' >> .file.list

		#### [Change parse detail]
		## change Permission
		$sudo_base sed -i 's/chmod - /chmod '$Perm' /g' ./.file.list
		## change Owner
		$sudo_base sed -i 's/chown - /chown '$Owner' /g' ./.file.list
		## change Group
		$sudo_base sed -i 's/chgrp - /chgrp '$Group' /g' ./.file.list
		## change direction
		$sudo_base sed -i 's/\.\./\./g' ./.file.list

		### Config file set
		#### [Zinst Set parser]
		#$sudo_base cat $ZICF |grep '^ZINST set' |grep set | awk '{print "zinst set","'$Packagename'."$3"="$4}' >> .file.list
		$sudo_base cat $ZICF |grep '^ZINST set' | awk '{print "sed -i '/^$Packagename.'"$3"'/'d '$ZinstBaseRoot/vault/zinst/zinst_set.list'"}' >> .file.list
		$sudo_base cat $ZICF |grep '^ZINST set' | awk '{print "echo \"'"$Packagename."'"$3"="$4"\" >> '$ZinstBaseRoot'/vault/zinst/zinst_set.list"}' >> .file.list

		### Quotation mark Exception
		sed -i 's/%Q%/\\\"/g' .file.list
		sed -i 's/\\\\\"/\\\"/g' .file.list

		#### [Command line parser] #####
		## Command line excute
		$sudo_base cat $ZICF |grep ^COMM | awk '{print $0}' | sed -e 's/COMM //g' >> .file.list
		sed -i 's/%Q%/\"/g' .file.list

		### Package Dependency check
		#### [Zinst Dep parser]
		Dep_checkerNum=`$sudo_base cat ./$ZICF  |grep "^ZINST requires" | awk '{print NR}' |tail -1 `
		DepCounter=1
			while [[ $DepCounter -le $Dep_checkerNum ]]
			do
			ZinstDeps=`$sudo_base cat $ZICF |grep '^ZINST requires' | awk 'NR=='$DepCounter`
				if [[ $ZinstDeps != "" ]];
				then
					ZinstDepChk=`$sudo_base cat $ZICF |grep '^ZINST requires' | awk '{print $4" - package has a dependency with ( '$Packagename' )"}'`
					ZinstCurrentDeps=`$sudo_base cat $ZinstBaseRoot/vault/zinst/.dependency.list |grep "$ZinstDepChk"`
						if [[ $ZinstCurrentDeps = ""  ]];
						then
							echo "$ZinstDepChk"  >> $ZinstBaseRoot/vault/zinst/.dependency.list
						fi
				fi
			let DepCounter=DepCounter+1
			done;

		#### [Cron parser] #####
		### Condtab set
			if [[ $Crontab = "CRON" ]];
			then
				Counter=1
					while [ $Counter -le $CrontabRow ]
					do
						$sudo_base bash -c "echo \"##$Packagename-$Version Cron Scheduler\"  > $Packagename.cron"
						CrontFetch=`$sudo_base cat $ZICF |grep "^CRON" | awk 'NR=='$Counter' {print $5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15" #'$Packagename'"}' | sed -e 's# [a-zA-Z]*/# /data/&#g' -e 's# /data//# /#g'  -e 's#/data/ #/data/#g' `

						$sudo_base bash -c "echo \"$CrontFetch\" >> $Packagename.cron"
						CronUser=`$sudo_base cat $ZICF |grep ^CRON |  awk 'NR=='$Counter'{print $3}'`
							if [[ $CronUser = "-" ]];
							then
								CronUser=$Owner
							fi
						TargetCron=$CronDir/$CronUser
						echo "#### $TargetCron"  >> .file.list
						Result=`$sudo_base cat $TargetCron  2> $zinst_log |grep $Packagename`
							if [[ $Counter = "1" ]];
							then
								if [[ $Result != "" ]];
								then
									echo "---==== Crontab has a configuration about this already ====---";
									$sudo_base sed -i "/$Packagename/d" $TargetCron;
									echo "---==== Crontab has been changed as a new configration ====---"
									$sudo_base bash -c "cat $Packagename.cron >> $TargetCron"
								else
									$sudo_base bash -c "cat $Packagename.cron >> $TargetCron"
									echo "---==== Crontab has been changed as a new configration ====---"
								fi
							else
								$sudo_base bash -c "cat $Packagename.cron >> $TargetCron"
							fi
					$sudo_base chmod 600 $TargetCron
					let Counter=Counter+1
					done;
			#rm $Packagename.cron
			fi
		## Parsing for Quotation mark decode
		sed -i 's/%Q%/"/g' $ZICF

		## Excute command list and file & package file remove
		$sudo_base sed -i 's/\t//g' ./.file.list
		$sudo_base sed -i 's/^ cp/cp/g' ./.file.list
		$sudo_base bash ./.file.list
		echo "$Packagename-$Version package has been installed"
		$sudo_base rm -f $ZinstSourceDir/$Package_list 1> $zinst_log

## Out of 3 steps older package clean - Todo

		## Package listup
		ZP=`echo "$ZinstBaseRoot" | sed -e "s/\///g"`
		ls -l $ZinstDIRs/ | awk '{print $6,$7,$8,"-", $11}' > $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i 's/\//%/g'  $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i '/   -/d'  $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i "s/%$ZP%vault%Source%/ /g"  $ZinstBaseRoot/vault/zinst/.pkglist

		Command_p="+ Install"
		echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $ZinstName $PureOption" >> $History_LOG
		let "Host_index=$Host_index + 1";

		############################## Install end without target host ##################################################
		let CounterAll=$CounterAll+1
	done

	############################## Setting config  #################################
	if [[ $Zset != "" ]];then
		SetOptionValue="$Zset"
		Pkg_Set	$*
	fi

	if [[ $Package_list != "" ]]; then
		Save_Restore_file $*
	fi
}



Pkg_Remove(){

ProcessPkg=$ZPackages
ProcessPkgNum=${#ProcessPkg[@]}
	if [[ $ZPackages = "" ]]
	then
		echo "=============== Please insert a package name as you need to see ============"
	else
		Counter=0
			while [[ $Counter -lt $ProcessPkgNum ]]
			do
				Pkg_list=${ProcessPkg[$Counter]}
				ZinstOrgName=`echo $Pkg_list| awk -F "-" '{print $1}'`
				Package_rc=`ls $ZinstDIRs |egrep "^$ZinstOrgName$"`
					if [[ $ZinstOrgName != $Package_rc ]]
					then
						echo "  "
						echo "  $ZPackages Package has not found."
						echo "  "
						exit;
					fi
				RmResult=`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list |grep ^echo | awk '{print $2}'`
					if  [[ $RmResult != "" ]];
					then
						cd $ZinstDIRs/$ZinstOrgName
						RmTargetCron=`$sudo_base cat .file.list  | grep "\####" | awk '{print $2}'`
						RmPkg_list=`$sudo_base cat .file.list |grep " package install " |awk '{print $3}'`

							if [[ $ZOptions != "-force" ]]
							then
							RmDepChecker=`$sudo_base cat $ZinstBaseRoot/vault/zinst/.dependency.list | grep "^$ZinstOrgName " |awk '{print $9}' `
								if [[ $RmDepChecker != "" ]]
								then
									echo "===== You have to remove as below package(s) ===== "
									echo "$RmDepChecker"
									echo "================================================== "
									echo "= $ZinstOrgName has a dependency with that. = "
									exit 0;
								fi
							fi
						$sudo_base sed -i "/ $ZinstOrgName /d" $ZinstBaseRoot/vault/zinst/.dependency.list
							if [ -f $ZinstDIRs/$ZinstOrgName/uninstall.sh ]; then
								$sudo_base bash $ZinstDIRs/$ZinstOrgName/uninstall.sh
							fi
						`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list  | grep "^cp" | awk '{print "sudo rm -Rfv",$3}' > /tmp/removelist`
						RmMv=`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list |grep "^mv"  | awk '{print $2}' | awk -F '/' '{print $NF}'`
						`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list  | grep "^mv" | awk '{print "sudo rm -Rfv",$3"$RmMv"}' >> /tmp/removelist`
						`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list  | grep "^ln" | awk '{print "sudo rm -Rfv",$4}' >> /tmp/removelist`
						$sudo_base bash /tmp/removelist; sudo rm /tmp/removelist
						RmDir=`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list  | grep "^mkdir" |awk '{print "ls", $3}'`
							if [[ $RmDir = "" ]];
							then
								`$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list  | grep "^mkdir" |awk '{print "rmdir", $3}'`
							fi
						RmZinstName=`ls $ZinstBaseRoot/vault/Source/ |grep $Pkg_list`
						$sudo_base rm -Rfv $ZinstDIRs/$ZinstOrgName
						$sudo_base rm -Rfv $ZinstBaseRoot/vault/Source/$RmPkg_list
 						echo "########## $RmPkg_list package has been removed ######## "
						$sudo_base sed -i "/^$ZinstOrgName/d" $ZinstBaseRoot/vault/zinst/zinst_set.list
							if [[ $RmTargetCron != "" ]]
							then
								$sudo_base sed -i "/#$ZinstOrgName/d" $RmTargetCron
							fi
					else
						echo "============= $ZPackages package has not installed =================="
					fi
				### Remove action stamps to Dist
				$sudo_base curl -e --url $Dist_URL/remove:$RmPkg_list.zinst > $zinst_log  2>&1

				Command_p="- Remove "
				echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $RmPkg_list  " >> $History_LOG
				let Counter=Counter+1
			done
	fi
cd $ZinstDIRs
Save_Restore_file $*
}

Pkg_List(){

### Check file of the phrase
Pkg_file_checker=`echo $ZPackages |grep "/"`
CurrentCheck=`echo $ZPackages |grep "^./"`
	if [[ $ZOptions = -file* ]]
	then
			if [[ $ZPackages = "" ]]
			then
				echo "=============== Please insert a package name as you need to see ============"
			else
				if [[ $Pkg_file_checker != ""  ]]
				then
						if [[ $CurrentCheck != "" ]]
						then
							PWD=`pwd | sed 's/\//%%%/g'`
							Pkg_file_checker=`echo $Pkg_file_checker | sed -e 's/\.\//%%%/g'`
							Pkg_file_checker=`echo $Pkg_file_checker | sed -e "s/%%%/$PWD\//g"`
							Pkg_file_checker=`echo $Pkg_file_checker | sed -e 's/%%%/\//g'`
						fi
					cd $ZinstDIRs/
					File_list=`ls`
					File_list_Num=`echo $File_list |awk '{print NF}'`
					CounterFM=1

					#####  loop start for the package find each directories
						while [[ $CounterFM -le $File_list_Num ]]
						do
							Package_dir=`echo $File_list | awk '{print $'$CounterFM'}'`

							cd $ZinstDIRs/$Package_dir
							Package_finder=`$sudo_base grep "^cp" .file.list | awk '{print $3}' | egrep "$Pkg_file_checker$" 2> $zinst_log`
							if [[ $Package_finder != "" ]]
							then
								cd $ZinstDIRs/
								Result_file=`ls -ali | grep $Package_dir- | awk -F '/' '{print $NF}'`
								echo "$Result_file  <-------   $Pkg_file_checker"
							fi

							cd $ZinstDIRs/$Package_dir
							Symb_finder=`$sudo_base egrep "$Pkg_file_checker$" .file.list | grep "^ln" |awk '{print $4}' 2> $zinst_log`
							if [[ $Symb_finder != "" ]]
							then
								cd $ZinstDIRs/
								Result_file=`ls -ali | grep $Package_dir- | awk -F '/' '{print $NF}'`
								echo "$Result_file  <-------   $Pkg_file_checker"
							fi

							cd $ZinstDIRs/
							let CounterFM=CounterFM+1
						done

						if [[ $Result_file = "" ]]
						then
							echo " ---- Could not find any package ---- "
						fi
					exit 0;
				fi
		ZinstOrgName=`echo $ZPackages| awk -F "-" '{print $1}'`
		cd $ZinstDIRs/$ZinstOrgName 2> $zinst_log
		$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list 2> $zinst_log | grep "^cp" | awk '{print $3}'
		$sudo_base cat $ZinstDIRs/$ZinstOrgName/.file.list 2> $zinst_log | grep " ln" | awk '{print $5,"<- " $4}'
	fi
	elif [[ $ZOptions = "-zicf" ]]
	then
			if [[ $ZPackages = "" ]]
			then
				echo "=============== Please insert a package name as you need to see ============"
			else
				ZinstOrgName=`echo ${PackageArry[0]}| awk -F "-" '{print $1}'`
				CheckPkgls=`zinst ls |grep " $ZinstOrgName-"`
					if [[ $CheckPkgls = "" ]]; then
						echo "====== Not existed the package name.  Please make sure that package name ======"
						exit 0;
					fi
				cd $ZinstDIRs/$ZinstOrgName
				$sudo_base cat $ZinstDIRs/$ZinstOrgName/*$ZinstOrgName.zicf
			fi
	elif [[ $ZOptions = "-dep" ]]
	then
			if [[ $ZPackages = "" ]]
			then
				echo "=============== Please insert a package name as you need to see ============"
			else
				ZinstOrgName=`echo ${PackageArry[0]}| awk -F "-" '{print $1}'`
				cd $ZinstDIRs/$ZinstOrgName
				$sudo_base cat $ZinstBaseRoot/vault/zinst/.dependency.list |grep "^$ZinstOrgName "
			fi
	else
		ZP=`echo "$ZinstBaseRoot" | sed -e "s/\///g"`
		$sudo_base mkdir -p $ZinstBaseRoot/vault/zinst/
		$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/
		export TIME_STYLE="+%Y-%m-%d %H:%M:%S %z"
		ls -l $ZinstDIRs/ 2> $zinst_log | awk '{print $6,$7," - ", $11}' > $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base chmod 664 $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i 's/\//%/g'  $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i '/   -/d'  $ZinstBaseRoot/vault/zinst/.pkglist
		$sudo_base sed -i "s/%$ZP%vault%Source%/ /g"  $ZinstBaseRoot/vault/zinst/.pkglist
		PkgListZ=`$sudo_base cat $ZinstBaseRoot/vault/zinst/.pkglist 2> $zinst_log`
			if [[ $PkgListZ = "" ]]
			then
				echo "=============== Package dose Not-existed here ============"
			fi
		if [[ $ZPackages = "" ]];then
			echo "$PkgListZ"
		else
			echo "$PkgListZ" |grep "$ZPackages"
		fi
	fi
}

Pkg_Find(){
Repo_chk=`$sudo_base curl -e --url $Dist_URL/ 2> $zinst_log | grep ".zinst"`
Sort_version='--version-sort'
## sort option check
echo ""| sort $Sort_version 1>&2 > /tmp/sort_check.out

	if [[ `(grep "unrecognized" /tmp/sort_check.out )` != "" ]];then
		Sort_version=""
	fi
#rm -f /tmp/sort_check.out

	if [[ $ZOptions = "-local" ]]
	then
		    if [[ $ZPackages = "" ]]
		    then
				ls $ZinstSourceDir | grep .zinst
		    else
			   ls $ZinstSourceDir | grep $ZPackages  | grep .zinst
		    fi
	else
			if [[ $Repo_chk != "" ]];then
				if [[ $ZPackages = "" ]];
				then
					#$sudo_base curl -e --url $Dist_URL/?`date +%s` 2> $zinst_log |grep zinst | sed 's/^.*<a href="//g' |awk -F '\"' '{print $1}' | egrep -v ^zinst$ |sort $Sort_version
					$sudo_base curl -e --url $Dist_URL/ 2> $zinst_log |grep zinst | sed 's/^.*<a href="//g' |awk -F '\"' '{print $1}' | egrep -v ^zinst$ |sort $Sort_version
				else
					#$sudo_base curl -e --url $Dist_URL/?`date +%s` 2> $zinst_log |grep zinst | sed 's/^.*<a href="//g' |awk -F '\"' '{print $1}' | egrep -v ^zinst$ | grep $ZPackages |sort $Sort_version
					$sudo_base curl -e --url $Dist_URL/ 2> $zinst_log |grep zinst | sed 's/^.*<a href="//g' |awk -F '\"' '{print $1}' | egrep -v ^zinst$ | grep $ZPackages |sort $Sort_version
				fi
			else
				if [[ $ZPackages = "" ]];
				then
					$sudo_base curl -e --url $Dist_URL/pkglist 2> $zinst_log |grep zinst | egrep -v ^zinst$ |sort $Sort_version
				else
					$sudo_base curl -e --url $Dist_URL/pkglist 2> $zinst_log |grep zinst | egrep -v ^zinst$ | grep $ZPackages |sort $Sort_version
				fi
			fi
	fi
}

Cront_Command(){


Command_p="+ Crontab - Edit"
	case "$2" in
	-l)
		crontab -l ;;
	-e)
		crontab -e
		echo -e "$(date +%Y.%m.%d_%T)\t $WhoStamps : $Command_p" >> $History_LOG ;;
	-u)
		case "$4" in
			 -l)
				$sudo_base crontab -u $ZPackages -l ;;
		        -e)
				$sudo_base crontab -u $ZPackages
				echo -e "$(date +%Y.%m.%d_%T)\t $WhoStamps : $Command_p -u $ZPackages " >> $History_LOG ;;
		        *)
				echo " - Please insert an option as you need to change correctly - "
				echo " ex) 'zinst crontab -e' to edit crontab"
				echo " ex) 'zinst crontab -u root -l' to listing the crontab of the root user"
			;;
		esac
		;;

	*)
		echo " - Please insert an option as you need to change correctly - "
		echo " ex) 'zinst crontab -e' to edit crontab"
		echo " ex) 'zinst crontab -u root -l' to listing the crontab of the root user"
	;;
	esac
}

Pkg_Restore(){
Types=$ZOptions
Restore_File=$ZPackages
	if [[ $Types != ""  ]]
	then
			if [[ $Restore_File = "" ]]
			then
				echo $Barr
				echo " --- Parse error: Please insert an information exactly. ---"
				echo " --- zinst restore -file [Save filename]               ---"
				echo " --- or zinst restore -igor                            ---"
				echo $Barr
				exit 0;
			fi
	else
		echo $Barr
		echo " --- Parse error: Please insert a Type ---"
		echo " --- zinst restore -file or -igor      ---"
		echo $Barr
		exit 0;
	fi

	if [[ ! -f  $Restore_File ]]
	then
		echo $Barr
		echo " --- Could not find save file as you typed.            ---"
		echo " --- Plese insert a file name exactly.                 ---"
		echo $Barr
		exit 0;
	fi

	if [[ $Types = "-file" ]]
	then
		$sudo_base cat $ZPackages |egrep "^Package" | sed 's/Package/zinst/g' |  sed 's/setting/set/g'
		echo " "
		echo " Do you want to restore as these list ? [ y / n ]"
		read SureRestore
			### Restore Remove
			if [[ $SureRestore = "y" ]]
			then
				RemoveForRestore=( `zinst ls | awk '{print $4}'` )
					`echo zinst remove ${RemoveForRestore[@]} -force`
				ServerDefaultFirst=`cat $ZPackages |grep "install server_default_setting" | awk '{print $3}'`
				zinst install $ServerDefaultFirst
				`echo "zinst install \`cat $ZPackages |egrep "^Package" | sed 's/Package install //g' |  sed 's/Package setting/ -set/g' | sed -e "s/$ServerDefaultFirst//g" \` -stable"`
			fi

	elif [[ $Types = "-igor" ]]
	then
		echo $Barr
		echo " Igor system will be launched"
		echo $Barr
	else
		echo $Barr
		echo " --- Parse error: Please insert a Type ---"
		echo " --- zinst restore -file or -igor      ---"
		echo $Barr
		exit 0;
	fi
Command_p="= Restore"
echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $ZPackages" >> $History_LOG
}

Pkg_Sync(){

## Define root DIR of zinst
BaseRoot=$ZinstBaseRoot
Types=$ZOptions
Sync_File=$ZPackages
	## Check Types
	if [[ $Types != ""  ]]
	then
			if [[ `(echo $Types | grep "\-file")` != "" ]]; then
					if [[ $Sync_File = "" ]]
					then
						echo $Barr
						echo " --- Parse error: Please insert an information exactly. ---"
						echo " --- zinst sync -file [Save filename]               ---"
						echo $Barr
						exit 0;
					fi
			fi

			if [[ `(echo $Types | grep "\-sara")` != "" ]]; then
				Sync_File="/tmp/temp_list.save"
				ZPackages="$Sync_File"
				NIC=`ip addr |grep "brd" | grep "inet" | head -1 | awk '{print $NF}'`
				LocalHost="`/sbin/ifconfig $NIC |grep " addr:" |grep Bcast |head -1 | awk '{print $2}'|awk  -F ':' '{print $2}'`"
				rm -f $Sync_File
				Sara_URL=`curl "http://$Sara_Host/zinst/?host=$LocalHost&user=$WhoStamp" > $Sync_File`
					## Existed file check from Sara
					CheckSaveDown=`grep "Not Found" ./$Sync_File`
					if [[ $CheckSaveDown != "" ]];then
						echo "Save file is not exist in Sara"
						exit 0;
					fi
			fi


			if [[ `(echo $Types | grep "\-url")` != "" ]]; then
				Temp_File="/tmp/temp_list.save"
				rm -f $Temp_File 2> $zinst_log
				curl "$Sync_File" 2> $zinst_log > $Temp_File
				Sync_File=$Temp_File
					## Download file check
					if [[ `(cat $Sync_File)` = "" ]];then
						echo "Please check this URL for Sync instruction: \"$ZPackages\""
						exit 0;
					elif [[ `(grep "Not Found" $Sync_File)` != ""  ]];then
						echo "Please check this URL for Sync instruction: \"$ZPackages\""
						exit 0;
					fi
				ZPackages=$Sync_File
			fi
	else
		echo $Barr
		echo " --- Parse error: Please insert a Type ---"
		echo $Barr
		exit 0;
	fi

	if [[ ! -f  $Sync_File ]];then
		cd ~/
		SentFileChk=`echo "$ZPackages" | awk -F"/" '{print $NF}'`
		ZPackages="$SentFileChk"
			if [[ ! -f  $SentFileChk ]];then
				echo $Barr
				echo " --- Could not find save file as you typed.            ---"
				echo " --- Plese insert a file name exactly.                 ---"
				echo $Barr
				exit 0;
			fi
	fi

## Define the file Dir & name
Origin_zsave=$ZPackages

## Make an as-is list
Target_zsave_file="current_system_all.list"
Target_zsave_full="/tmp/$Target_zsave_file"
Sorted_org_zsave="/tmp/sorted_orizin.list"
Sorted_tgt_zsave="/tmp/sorted_target.list"
tmp_results="/tmp/tmp_result.txt"
remove_zsave_list="/tmp/remove_zsave_list.list"
install_zsave_list="/tmp/install_zsave_list.list"

## Clean Old temp file
rm -f $Sorted_org_zsave $Sorted_tgt_zsave $tmp_results $remove_zsave_list $install_zsave_list $Target_zsave_full

## Rebuild as-is file
echo "# --- Last touched by $WhoStamps --- " > $Target_zsave_full
echo "# --- Last command \" zinst $PackageAll \" " >> $Target_zsave_full
echo "# Date: `date +%Y.%m.%d_%T` " >> $Target_zsave_full
echo "#"  >> $Target_zsave_full
echo "# zinst package installer all-configuration backup-list for the package restore" >> $Target_zsave_full
zinst ls | awk '{print "Package install",$4".zinst"}' >> $Target_zsave_full
echo "- - - " >> $Target_zsave_full
zinst set | awk 'NR>1{print "Package setting",$1}' >> $Target_zsave_full
Block="======================================================================================="
## Sort a list
sort $Origin_zsave | egrep -v "#" | sed -e '/^$/d' > $Sorted_org_zsave
sort $Target_zsave_full | egrep -v "#" | sed -e '/^$/d' > $Sorted_tgt_zsave

## Different check
diff $Sorted_org_zsave $Sorted_tgt_zsave|fgrep -v " #" | egrep  -v "^[0-9]" | sort |sed -e '/> -/d' -e '/< -/d'  > $tmp_results

## Show the list
cat $tmp_results | grep ">" | sed -e 's/ settting / setting /g' > $remove_zsave_list
cat $tmp_results | grep "<" | sed -e 's/ settting / setting /g' > $install_zsave_list

current_array=(`cat $remove_zsave_list | sed -e 's/> Package install //g' | sed -e '/ setting/d'`)
changing_array=(`cat $install_zsave_list | sed -e 's/< Package install //g' | sed -e '/ setting/d'`)
	## loop for version check
	xCount=0
	while [[ $xCount -lt ${#current_array[@]} ]]; do
		Raw_xPkgName=`echo "${current_array[$xCount]}" | awk -F'-' '{print $1}'`
		Raw_xVersion=`echo "${current_array[$xCount]}" | awk -F'-' '{print $2}' | sed -e 's/\.zinst//g'`
		ExistedVersionCheck=`echo "${changing_array[@]}" |grep $Raw_xPkgName`
			if [[ $ExistedVersionCheck != "" ]]; then
					yCounter=0
					while [[ $yCounter -lt ${#changing_array[@]} ]];do
						ExistedMatchCheck=`echo "${changing_array[$yCounter]}" |grep $Raw_xPkgName`
							if [[ $ExistedMatchCheck != "" ]]; then
								ChangingVersion=`echo "${changing_array[$yCounter]}" | awk -F'-' '{print $2}' | sed -e 's/\.zinst//g'`
									if [[ "$(version_redefine "$ChangingVersion")" < "$(version_redefine "$Raw_xVersion")" ]];then
										sed -i "/> Package install $Raw_xPkgName/d" $remove_zsave_list
										sed -i "s/< Package install $Raw_xPkgName/< Package downgrade $Raw_xPkgName/g" $install_zsave_list
									else
										sed -i "/> Package install $Raw_xPkgName/d" $remove_zsave_list
										sed -i "s/< Package install $Raw_xPkgName/< Package upgrade $Raw_xPkgName/g" $install_zsave_list
									fi
							fi
					let yCounter=$yCounter+1
					done
			fi
	let xCount=$xCount+1
	done

## Print Result list
sed -i "s/> Package install /> Package remove /g" $remove_zsave_list
echo "$Block"
echo "= Target list for remove                                                              ="
echo "$Block"
cat $remove_zsave_list
echo "$Block"
echo ""
echo "$Block"
echo "= Target list for install & setting                                                   ="
echo "$Block"
cat $install_zsave_list
echo "$Block"
echo ""

Final_remove_array=(`cat $remove_zsave_list | sed -e '/ setting/d' | awk '{print $4}'`)
Final_install_array=(`cat $install_zsave_list | fgrep -v " downgrade" | sed -e 's/setting / tmp -set /g' | awk '{print $4,$5}'`)
Final_downgrade_array=(`cat $install_zsave_list | grep " downgrade" | awk '{print $4}'`)
Command_p="=  Sync   "

	if [[ `(cat $install_zsave_list)` = "" ]] && [[ `(cat $remove_zsave_list)` = "" ]]; then
		echo " === Nothing to change... === "
		echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - Nothing to changed... by $ZPackages" >> $History_LOG
	else
		CheckForce=`echo "$ZOptions" |egrep " -force"`
		if [[ $CheckForce = "" ]];then
			echo " === Package & setting will be install & remove as upper list. Are sure ? === [y / n]"
			read confirm_sync
		else
			confirm_sync="y"
		fi

		if [[ $confirm_sync = y ]]; then
			echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p --- START --- by $ZPackages" >> $History_LOG
				if [[ ${Final_remove_array[@]} != "" ]];then
					zinst remove ${Final_remove_array[@]} -force
				fi

				if [[ ${Final_downgrade_array[@]} != "" ]];then
					zinst install ${Final_downgrade_array[@]} -downgrade
				fi

				if [[ ${Final_install_array[@]} != "" ]];then
					zinst install ${Final_install_array[@]} -stable
				fi
			echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p ---  END  --- by $ZPackages" >> $History_LOG
		fi
	fi
rm -f $Sorted_org_zsave $Sorted_tgt_zsave $tmp_results $remove_zsave_list $install_zsave_list $Target_zsave_full
}

Daemon_Control(){
## Parsing!!!   importatant area

Daemon_check_dir="$ZinstBaseRoot/vault/Source"


ProcessPkg=($ZPackages)
ProcessPkgNum=${#ProcessPkg[@]}

Counter=0
Command_p="# Daemon $CommandX"
echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - ${ProcessPkg[@]}  " >> $History_LOG
ColorGreen="32"
ColorRed="31"
ColorDark="30"
	while [[ $Counter -lt $ProcessPkgNum ]]
	do
		DaemonC=`echo "${ProcessPkg[$Counter]}"`
			## Custom package check
			if [[ -f "/etc/init.d/$DaemonC" ]];then
				system_command=custome_ctl
			fi

			case $system_command in
				systemctl)
					systemCMD="systemctl $CommandX $DaemonC.service";;
				service)
					systemCMD="service $DaemonC $CommandX";;
				custome_ctl)
					systemCMD="/etc/init.d/$DaemonC $CommandX";;
				*)
					echo " --- We are not support on this OS ---"
					exit 0;;
			esac
		export LANG=C
			if [[ $CommandX = "run" ]];then
				#$sudo_base $ServiceDaemonDir/$DaemonC $CommandX
				$sudo_base $systemCMD
			else
				#$sudo_base service $DaemonC $CommandX | tee $Daemon_check_dir/Daemon_ctrl.log
				$sudo_base $systemCMD &> $Daemon_check_dir/Daemon_ctrl.log
				$sudo_base chmod 664 $Daemon_check_dir/Daemon_ctrl.log
				$sudo_base chgrp wheel $Daemon_check_dir/Daemon_ctrl.log
				$sudo_base cat $Daemon_check_dir/Daemon_ctrl.log
			fi
		DaemLog=`$sudo_base cat $Daemon_check_dir/Daemon_ctrl.log |tail -1`
		Daemon_S=$DaemLog
			FailCheck=`echo $DaemLog | grep "FAILED"`
			if [[ $FailCheck != "" ]];then
				Daemon_S=`printf "[\033[%dm%s\033[0m]\n" $ColorRed "FAILED"`
			fi
			SuccCheck=`echo $DaemLog | grep "OK"`
			if [[ $SuccCheck != "" ]];then
				Daemon_S=`printf "[\033[%dm%s\033[0m]\n" $ColorGreen " OK "`
			fi
			NorCheck=`echo $DaemLog | grep -v "OK|FAILED"`
			if [[ $NorCheck != "" ]];then
				:
			fi
			DaemLog=$Daemon_S
		## Replaced by tee              $sudo_base cat $Daemon_check_dir/Daemon_ctrl.log 2> /dev/null

		## Checking the daemon
		sleep 1
		Status_D=`echo $DaemonC | sed -e 's/d$//g'`
		DaemonPSChk=`ps aux |grep "$Status_D" | egrep -v " grep" | egrep -v "zinst " |egrep -v " vi"`
			if [[ $DaemonPSChk != "" ]];then
				TextColor=$ColorGreen
				Daemon_Status="Working"
				## Daemon check result output
				DaemonResult=`printf "\033[%dm%s\033[0m\n" $TextColor "$Daemon_Status";`
				Command_Result=`echo "Daemon $DaemonResult: $DaemLog "`
			else
				TextColor=$ColorDark
				Daemon_Status="Not working"
				## Daemon check result output
				DaemonResult=`printf "\033[%dm%s\033[0m\n" $TextColor "$Daemon_Status";`
				Command_Result=`echo "Daemon $DaemonResult: $DaemLog"`
				#Command_Result=`echo "$DaemLog"`
			fi

		DaemonCheck=`echo $DaemLog | grep "unrecognized"`
			if [[ $DaemonCheck != "" ]]
			then
				echo "$DaemonC is unrecognized service"
				exit 0;
			fi
		echo -e "\t\t\t $WhoStamps : #     - $Command_Result " >> $History_LOG
		let Counter=Counter+1
        $sudo_base rm -f $Daemon_check_dir/Daemon_ctrl.log
	done
}

Zinst_Version(){
 echo "Zinst version" `$sudo_base cat /usr/bin/zinst |grep ^VERSION | sed -e 's/VERSION=//g'`
}

Zinst_SelfConfig(){
SelfConfArry=(`echo "$PackageAll"`)
	## Mapping a HostsFile to tmp for excahnge the configuration
	$sudo_base cat $HostsFile > /tmp/hosts_c.tmp
	if [[ ${SelfConfArry[1]} != "" ]];then
		SelfConfCount=0
		## Insert an information from command line for the IP & Host changes of the distribution server
		while [[ $SelfConfCount -le ${#SelfConfArry[@]}  ]];do
			check_new_ip=`echo ${SelfConfArry[$SelfConfCount]} | grep "ip=" |sed -e "s#ip=##g"`
				if [[ $check_new_ip != "" ]];then
					SelfConf_IP=${SelfConfArry[$SelfConfCount]}
					TargetSelfIP=`grep "^ManagerIP=" /usr/bin/zinst`
					$sudo_base sed -i "s#$TargetSelfIP#ManagerIP=\"$check_new_ip\"#g" /usr/bin/zinst
					check_new_ip=`echo "$check_new_ip" | sed -e 's#/#\\\/#g'`
					$sudo_base sed -i "/$check_new_ip/d" /tmp/hosts_c.tmp
					$sudo_base bash -c "echo $check_new_ip $FetchedDistServer >> /tmp/hosts_c.tmp"
					$sudo_base bash -c "cat /tmp/hosts_c.tmp > $HostsFile"
					echo ""
					echo " --- Zinst distribution server IP address has been changed to \"$check_new_ip\" ---"
				fi
			check_new_host=`echo ${SelfConfArry[$SelfConfCount]} | grep "host=" |sed -e "s#host=##g" -e "s#http://##g"`
				if [[ $check_new_host != "" ]];then
					SelfConf_Host=${SelfConfArry[$SelfConfCount]}
					TargetSelfHost=`grep "^Dist_URL=" /usr/bin/zinst`
					#$sudo_base sed -i "s#$TargetSelfHost#Dist_URL=\"http://$check_new_host\"#g" /usr/bin/zinst
					$sudo_base sed -i "s#Dist_server=\"$Dist_server\"#Dist_server=\"http://$check_new_host\"#g" /usr/bin/zinst
					FetchedDistServer=`echo "$FetchedDistServer" | sed -e 's#/#\\\/#g'`
					$sudo_base sed -i "/$FetchedDistServer/d" /tmp/hosts_c.tmp
					$sudo_base bash -c "echo $ManagerIP $check_new_host >> /tmp/hosts_c.tmp"
					$sudo_base bash -c "cat /tmp/hosts_c.tmp > $HostsFile"
					echo ""
					echo " --- Zinst distribution server domain  has been changed to \"$check_new_host\" ---"
				fi
			check_new_dir=`echo ${SelfConfArry[$SelfConfCount]} | grep "dir=" |sed -e "s#dir=##g"`
				if [[ $check_new_dir != "" ]];then
					SelfConf_DIR=${SelfConfArry[$SelfConfCount]}
					TargetSelfDir=`grep "^ZinstBaseRoot" /usr/bin/zinst`
					$sudo_base sed -i "s#$TargetSelfDir#ZinstBaseRoot=\"$check_new_dir\"#g" /usr/bin/zinst
					$sudo_base sed -i "s#=#=#g" /usr/bin/zinst
					echo ""
					echo " --- Zinst distribution server IP address has been changed to \"$check_new_dir\" ---"
				fi
		let SelfConfCount=$SelfConfCount+1
		done
		Print_Hi=( `echo ${SelfConfArry[@]} | awk '{for (i=2;i<NF+1;i=i+1) print $i","}'`)
		PrintHist=`echo "${Print_Hi[@]}" |sed -e 's/,$//g'`

		## Add History
		Command_p="@ Self-Conf"
		echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p -> $PrintHist " >> $History_LOG
	else
		echo " ================================================================"
		echo " You can change the configuration on zinst for IP,Host & RootDIR."
		echo " Please insert a value for the zinst self setting as below"
		echo " zinst self-conf ip=10.1.1.1"
		echo " zinst self-conf ip=10.1.1.1 host=package.dist.com"
		echo " zinst self-conf dir=/data"
		echo " ================================================================"
		exit 0;
	fi
#Apply the configuration for HostsFile
#hosts_redefine
zinst -v 1> $zinst_log
}

Zinst_Selfupdate(){
cd /tmp;
$sudo_base bash -c "curl -e --url $Dist_server > /tmp/dist_check.tmp 2>&1"
check_dist_url=`grep "couldn't connect" /tmp/dist_check.tmp`
	if [[ $check_dist_url != "" ]];then
		echo " ================================================================"
		echo "  We couldn't connected with Zinst distribution server."
		echo "  Please check the Dist server"
		echo " ================================================================"
		$sudo_base rm -f /tmp/dist_check.tmp
		exit 0;
	fi

$sudo_base rm -f zinst
echo  " Downloading..."
curl -w ' [:: %{size_download} byte has been downloaded ::]\n' -L -# $Dist_server/zinst -o ./zinst;
mv zinst zinst_tmp
	if [[ -f /usr/bin/zinst ]];then
		$sudo_base head -19 /usr/bin/zinst > /tmp/zinst
	else
		$sudo_base head -19 $ZinstBaseRoot/vault/Source/bin/zinst > /tmp/zinst
	fi
tail -n +20 ./zinst_tmp >> /tmp/zinst
rm -f ./zinst_tmp
$sudo_base mkdir -p $ZinstBaseRoot/vault/Source/bin
$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/Source/bin
Number=`ls $ZinstBaseRoot/vault/Source/bin/ |egrep ^zinst.bak. |awk '{print NR}' |tail -1`
	if [[ $Number = ""  ]];
	then
		Number="0"
	fi
$sudo_base mv $ZinstBaseRoot/vault/Source/bin/zinst $ZinstBaseRoot/vault/Source/bin/zinst.bak.$Number 2> $zinst_log;
$sudo_base cp zinst $ZinstBaseRoot/vault/Source/bin/zinst;
$sudo_base chgrp $zinst_group $ZinstBaseRoot/vault/Source/bin/zinst;
$sudo_base chmod 775 $ZinstBaseRoot/vault/Source/bin/zinst;
$sudo_base rm -f /usr/bin/zinst;
$sudo_base ln -sf $ZinstBaseRoot/vault/Source/bin/zinst /usr/bin/zinst;
ShowVersion=`$sudo_base cat /usr/bin/zinst |grep ^VERSION | sed -e 's/VERSION=//g'`
echo "Zinst version" $ShowVersion

Command_p="@ Self-update"
echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $ShowVersion  " >> $History_LOG
}


History(){
# ZPackages is a number for seek the history such as 10 or 100
		if [[ $ZPackages != "" ]]
		then
				## It will be revert to dash degit
				ZPackages="-$ZPackages"
		fi
	tail $ZPackages $History_LOG
}

Pkg_Track(){

TrackManager="track_$ManagerIP"
### Set for Print screen

CheckZPkg=`echo ${PackageArry[0]} | egrep "\/"`
	if [[ $CheckZPkg != "" ]]
	then
		PackageArry[0]=""
	fi

width=102
echo ""
echo "Package has been released to below list - Sort by \"${PackageArry[0]}\""
printf "%$width.${width}s \n" "$Barr$Barr"
printf "%-30s %-50s %-30s \n" "Host" "Package" "Date"
printf "%$width.${width}s \n" "$Barr$Barr"

UserChecker=`echo "${PackageArry[0]}" |grep "user"`
	if [[ $UserChecker = "" ]]; then
		Distributed_package="distributed_package"
	else
		Distributed_package="distributed_package_users"
	fi
Track_URL=$Dist_server
ResultPack=`$sudo_base curl -e --url $Track_URL/$TrackManager/$Distributed_package 2> $zinst_log |egrep "${PackageArry[0]}"`
FileChecker=`echo $MidPackageArry | awk -F '-file=' '{print $2}'`
OptionExcenptChk=`echo "$ZOptions" | grep "="`
	if [[ $OptionExcenptChk != ""  ]]
	then
		ZOptions=`echo "$ZOptions" | awk -F '=' '{print $1}'`
	fi

	if [[ $FileChecker = ""  ]]
	then
		OutPutFile="$PWD/host.output"
	else
		OutPutFile="$FileChecker"
	fi

	if [[ $ResultPack = "" ]]
	then
		OutTrack=`$sudo_base curl -e --url $Track_URL/$TrackManager/$Distributed_package 2> $zinst_log |egrep " ${PackageArry[0]}" | awk '{printf("%-30s",$1); printf("%-50s",$2); printf("%-30s\n",$3)}'`
	else
		OutTrack=`echo "$ResultPack" | awk '{printf("%-30s",$1); printf("%-50s",$2); printf("%-30s\n",$3)}'`
	fi

	### Export data
	if [[ $ZOptions != "-file"  ]]
	then
		echo "$OutTrack"
	else
		echo "$OutTrack"
		echo "$OutTrack" | awk '{print $1}' | sort -u > $OutPutFile
		printf "%$width.${width}s \n" "$Barr$Barr"
		echo " Hostlist file has been created to $OutPutFile "
	fi

printf "%$width.${width}s \n" "$Barr$Barr"
}


check_vminit(){
		echo "Check the initialized VM"
		vm_imagename=$1
}

Init_Virtual(){
		$sudo_base yum groupinstall "Virtualization*" # && [Virshfile create]

}

Add_Virtual(){
		check_vminit

}

Up_Virtual(){
		check_vminit
		$sudo_base virsh start $vm_imagename
}

Halt_Virtual(){
		check_vminit
		$sudo_base virsh shutdown $vm_imagename
}

Destroy_Virtual(){
		check_vminit
		$sudo_base virsh destroy $vm_imagename
		$sudo_base virsh undefine $vm_imagename
		$sudo_base rm -f #$vm_dir $vm_imagename.qcow2
}


Vmlist_Virtual(){
		check_vminit
		$sudo_base virsh list all
}


Pkg_Getset(){
### Set value get from the package
GetSPkg=$ZPackages
GetSPkgArry=( $GetSPkg )
sudo mkdir -p $CurrPkgDiR
        ### Package list up
        ### Loop for each package sort
        GetSCounter=0
        while [ $GetSCounter -lt ${#GetSPkgArry[@]} ]
        do
                        IndexFileChk=`ls $CurrPkgDiR/${GetSPkgArry[$GetSCounter]}.zicf 2> $zinst_log`
                        PackageReal=`echo "${GetSPkgArry[$GetSCounter]}" | awk -F'-' '{print $1}'`
                        if [[ $IndexFileChk = "" ]]
                        then
                                $sudo_base bash -c "curl \"$Dist_URL/checker/${GetSPkgArry[$GetSCounter]}.zicf\" 2> $zinst_log > $CurrPkgDiR/${GetSPkgArry[$GetSCounter]}.zicf"
                                CheckSet=(`cat $CurrPkgDiR/${GetSPkgArry[$GetSCounter]}.zicf 2> $zinst_log |grep "^ZINST set " | sed -e 's/ZINST set //g' | awk '{for (i=2;i<=NF;i=i+1) print "'$PackageReal'."$1"="$i}'`)
                        else
                                CheckSet=(`cat $CurrPkgDiR/${GetSPkgArry[$GetSCounter]}.zicf 2> $zinst_log |grep "^ZINST set " | sed -e 's/ZINST set //g' | awk '{for (i=2;i<=NF;i=i+1) print "'$PackageReal'."$1"="$i}'`)
                        fi
	
        let GetSCounter=$GetSCounter+1
        done

        ### Print output
        SetOutCount=0
        while [ $SetOutCount -lt ${#CheckSet[@]} ]; do
                echo ${CheckSet[$SetOutCount]}
        let SetOutCount=$SetOutCount+1
        done
}


########################################
# Pkg_Set Using $Zset Argument 
# $Zset Argument has been  include --set parameter 

Pkg_Set () {
if [[ -z $Zset ]]
then
	$sudo_base cat $ZinstBaseRoot/vault/zinst/zinst_set.list
else
	for i in $Zset	
	do
		SetTarget=$(echo "$i" | awk -F "=" '{print $1}')
		ZinstSet=$(echo "$i" | sed -e "s#$SetTarget=##g" 2> $zinst_log)
		OptSwt=$(echo $SetTarget | awk -F '.' '{print $1}')
		Option=$(echo $SetTarget | sed -e "s#$OptSwt\.##g")
		PackageS=$(echo $SetTarget | awk -F '.' '{print $1}')
		SetZICF="*$PackageS.zicf"
		echo "SetTarget :"$SetTarget
		echo "ZinstSet :"$ZinstSet
		echo "OptSwt :"$OptSwt
		echo "Option :"$Option
		echo "PackageS :"$PackageS
		echo "SetZICF :"$SetZICF

		## Check a set list in zinst
		CurrentSet=$($sudo_base cat $ZinstBaseRoot/vault/zinst/zinst_set.list | grep "^$SetTarget")
		CurrentSetCheck=$(echo "$CurrentSet" | awk -F "=" '{print $1}')
		CurrentSetCheck2=$(echo "$CurrentSet" | sed -e "s#$CurrentSetCheck=##g"  2> $zinst_log)
		Setchecker=$(ls $ZinstDIRs 2> $zinst_log |grep "$PackageS")
		echo "Setchecker :"$Setchecker
		if [[ $Setchecker != ""  ]]
		then
		ConfCounter=0
		Grep_ZICF_Raw=$($sudo_base cat $ZinstDIRs/$PackageS/$SetZICF |grep "^CONF" | awk '{print "'$ZinstDIRs/$PackageS'/"$6}' | sed -e 's#\.\/##g')
			while [[ $ConfCounter -lt ${#Grep_ZICF_Raw[@]} ]]
			do
				if [[ $Option = "" ]] 
				then
					print_locale CODE_PKG02_$Zinst_Locale
					# Original Meesage is " It dose not existed target option"
					exit 0
				fi
				## Find a current set
				Grep_ZICF=$($sudo_base cat $ZinstDIRs/$PackageS/$SetZICF |grep "^CONF" | awk '{print "'$ZinstBaseRoot'/"$5}')
				if [[ $Grep_ZICF = "" ]] 
				then
					echo "$Barr"
					echo "$PackageS has not a config file as a zicf or we couldn't find any config"
					echo "Please check this zicf file of the package."
					echo ""
					echo "ex) zinst list -zicf $PackageS | grep ^CONF <--- Result is empty."
					echo " If so, you should change the file type from FILE to CONF "
					echo "$Barr"
					exit 0
				fi
				Conf_Dir=${Grep_ZICF_Raw[$ConfCounter]%/*}
				echo "Conf_Dir is "$Conf_Dir
				Grep_Option=$($sudo_base grep "^$Option=" $Conf_Dir/* 2> /dev/null)
					if [[ $Grep_Option = "" ]]
					then
						Grep_Option=$($sudo_base grep "^$Option = " $Conf_Dir/* 2> /dev/null)
						if [[ $Grep_Option = "" ]]
						then
							Grep_Option=$($sudo_base grep "^$Option " $Conf_Dir/* 2> /dev/null)
						fi
					fi
					## Parsing
					Conf_File=${Grep_ZICF_Raw[$ConfCounter]%:*}
					if [[ $CommandX = set ]] 
					then
						Command_p=" * setup "
					else
						Command_p=" & setup "
	                        	fi
					Conf_Result_File=$(echo "$Conf_File" | awk -F '/' '{print $NF}')
					Grep_ZICF_Source=$($sudo_base cat $ZinstDIRs/$PackageS/$SetZICF |grep "^CONF" |grep "$Conf_Result_File$" | awk '{print "'$ZinstBaseRoot'/"$5}')
					### Current Setting check and replace
					if [[ $SetTarget = $CurrentSetCheck ]]
					then
						Equiltype1=$($sudo_base grep "$Option=$CurrentSetCheck2" $Grep_ZICF_Source)
						Equiltype2=$($sudo_base grep "$Option = $CurrentSetCheck2" $Grep_ZICF_Source)
						Equiltype3=$($sudo_base grep "$Option $CurrentSetCheck2" $Grep_ZICF_Source)
						if [[ $Equiltype1 != "" ]]
						then
							$sudo_base sed -i "s#$Option=$CurrentSetCheck2#$Option=$ZinstSet#g" $Grep_ZICF_Source
							exception_check
						elif [[ $Equiltype2 != "" ]]
						then
							$sudo_base sed -i "s#$Option = $CurrentSetCheck2#$Option = $ZinstSet#g" $Grep_ZICF_Source
							exception_check
						elif [[ $Equiltype3 != "" ]]
						then
							$sudo_base sed -i "s#$Option $CurrentSetCheck2#$Option $ZinstSet#g" $Grep_ZICF_Source
							exception_check
						fi
						### Stamping a Set value for history
						Grep_Option=$($sudo_base grep "^$Option=" $Grep_ZICF_Source)
						if [[ $Grep_Option = "" ]]
						then
							Grep_Option=$($sudo_base grep "^$Option = " $Grep_ZICF_Source)
							if [[ $Grep_Option = "" ]]
							then
								Grep_Option=$($sudo_base grep "^$Option " $Grep_ZICF_Source)
							fi
						fi
						realSetOption=$(echo "$Grep_Option"  | sed -e "s#$Option #$Option=#g" -e 's#== #=#g')
						if [[ $realSetOption != "" ]]
						then
							$sudo_base sed -i "/$SetTarget=/d" $ZinstBaseRoot/vault/zinst/zinst_set.list
							exception_check
							echo "$PackageS.$realSetOption" >> $ZinstBaseRoot/vault/zinst/zinst_set.list
						fi
					fi
				let ConfCounter=$ConfCounter+1
			done

			$sudo_base cat  $ZinstBaseRoot/vault/zinst/zinst_set.list |grep "^$SetTarget="
			exception_check
			echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $i" >> $History_LOG

			if [[ $SetTarget != $CurrentSetCheck ]]	
			then
				### Cancel Setup when it meet th Empty result
				if [[ $Grep_Option = "" ]]
				then
					print_locale CODE_PKG02_$Zinst_Locale
					exit 0
				fi
				## Remove temporary 2015.03.06
				# echo "$i" >> $ZinstBaseRoot/vault/zinst/zinst_set.list
				echo -e "`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - $i" >> $History_LOG
			fi
		else
			print_locale CODE_PKG01_$Zinst_Locale 
		fi
	done
	Save_Restore_file $*
fi
}


##############################################################
####################  Main Function Below ####################
##############################################################

OS_Checker
System_Controller_checker	
Select_OS $OS_name
Dist_URL="$Dist_server$OS_type"

## Requires command check & install
Requires_Pkg_install sudo
Requires_Pkg_install tar bc

HostsFile="/etc/hostsa"
if [[ ! -f $HostsFile ]]
then
	HostsFile="/etc/hosts"
fi

FetchedDistServer=$(echo $Dist_server | sed -e "s#http://##g")
GrepDistHost=$(grep "$FetchedDistServer" $HostsFile)
if [[ $GrepDistHost = "" ]]
then
	$sudo_base bash -c "echo $ManagerIP $FetchedDistServer >> $HostsFile"
	exception_check
else
	DistResut=$(echo "$GrepDistHost" | awk '{print $1}')
	if [[ $DistResut != $ManagerIP ]]
	then
		hosts_redefine
	fi
fi

### Break sign catch for line break fix
trap exit_abnormal SIGINT SIGTERM SIGKILL

### Requires server_default_setup package for the account policy
WhoStamp=$($sudo_base cat $ZinstBaseRoot/src/_tmp_acc 2> $zinst_log)
if [[ $WhoStamp = "" ]]
then
	WhoStamp=$(whoami)
fi

if [ -e $ZinstBaseRoot/src/_tmp_acc ] 
then
	$sudo_base rm $ZinstBaseRoot/src/_tmp_acc 2> $zinst_log
	exception_check
fi
export ZinstDir=$ZinstBaseRoot
CurrPkgDiR=$(echo $ZinstBaseRoot"/vault/zinst/index")
WhoStamps=$(printf "%-14s" "$WhoStamp")

### Config about of Save file
Save_Dir=$ZinstBaseRoot"/z/save"
Save_Filename="zinst-save"
CheckSaveDir=$(ls $ZinstBaseRoot/z 2> $zinst_log |grep save)
if [[ $CheckSaveDir = "" ]]
then
	$sudo_base mkdir -p $Save_Dir
	exception_check
	$sudo_base chgrp $zinst_group $Save_Dir
	exception_check
fi

### History File reset for permission
$sudo_base chmod 664 $History_LOG 2> $zinst_log
$sudo_base chgrp $zinst_group $History_LOG 2> $zinst_log


### Multi file copier command
	if [[ $CommandX = "mcp" ]] 
	then
		if [[ $ZHosts != "" ]]
		then
			TargetDir=$(echo $ZPackages | awk '{print $NF}')
			Source=$(echo $ZPackages | awk '{for (i=1;i<NF;i=i+1) print $i}')
			SourceNum=$(echo $Source | awk '{print NF}')
			HostNum=$(echo $ZHosts | awk '{print NF}')
			Hcount=1
				while [[ $Hcount -le $HostNum ]]
				do
					TartgetHost=`echo $ZHosts | awk '{print $'$Hcount'}'`
					echo ""
					echo "[:: $TartgetHost  ::]"
					Scount=1
						while [[ $Scount -le $SourceNum ]]i
						do
							PartedSource=`echo $Source |awk '{print $'$Scount'}'`
							Check_Files=`ls $PartedSource`
								if [[ $Check_Files != $PartedSource  ]]
								then
									echo " =============  $PartedSource File not exist ============="
									exit 0;
								fi
							$Comm_sshpass scp -P $ssh_port $PartedSource $TartgetHost:$TargetDir
							let Scount=Scount+1
						done
					let Hcount=Hcount+1
					Localhost=$HOSTNAME
					Command_p="> mcp"
					SourceFull=(`echo "$Source"`)
					IPaddr=`/sbin/ifconfig |grep " addr:" |grep Bcast |head -1 | awk '{print $2}'|awk  -F ':' '{print $2}'`
					$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no $TartgetHost "echo -e \"`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - From $IPaddr:  ${SourceFull[@]} -> $TargetDir \" >> $History_LOG"
				done
		else
			echo "$ROWW"
			echo " Hostname requires"
			echo "$ROWW"
		fi
		exit 0;
	fi

	CheckRB=`echo "$CommandX" |grep "sync"`
	if [[ $CheckRB != "" ]]; then
		if [[ $ZHosts != "" ]]; then
			TargetDir="~/"
			Source=`echo $ZPackages | awk '{print $1}'`
			HostNum=`echo $ZHosts | awk '{print NF}'`
			Hcount=1
				while [[ $Hcount -le $HostNum ]];do
					TartgetHost=`echo $ZHosts | awk '{print $'$Hcount'}'`
					echo ""
					echo "[:: $TartgetHost ::]"
					Scount=1
					$Comm_sshpass scp -P $ssh_port $ZPackages $TartgetHost:~/ 2> $zinst_log
					let Hcount=Hcount+1
					Localhost=$HOSTNAME
					Command_p="> Sent a sync file"
					SourceFull=(`echo "$Source"`)
					IPaddr=`/sbin/ifconfig |grep " addr:" |grep Bcast |head -1 | awk '{print $2}'|awk  -F ':' '{print $2}'`
					$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no $TartgetHost "echo -e \"`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - From $IPaddr:  $SourceFull -> $TargetDir \" >> $History_LOG"
				done
		fi
	fi


## Function for ssh key deply to the servers
    if [[ $CommandX = keydep* ]]; then
        if [[ $ZHosts != "" ]]; then
            TargetDir=`echo $ZPackages | awk '{print $NF}'`
            Source=`echo $ZPackages | awk '{for (i=1;i<NF;i=i+1) print $i}'`
            HostNum=`echo $ZHosts | awk '{print NF}'`
			UserID=`whoami`
			#AuthKey="$ZinstBaseRoot/var/authorized_keys"
				if [[ $UserID = "root" ]];then
					AuthKey="/root/authorized_keys"
				else
					AuthKey="/home/$UserID/authorized_keys"
				fi
				if [[ ! -f $AuthKey ]]; then
				    sudo touch $AuthKey
				fi
			PUBKEY=`cat $AuthKey 2> /dev/null`
				if [[ $PUBKEY = "" ]];then
				    echo $Barr
				    echo " Please insert a public key to $AuthKey !!!"
                	echo $Barr
				    exit 0
				fi
				if [[ `(zinst ls sshpass)` = "" ]];then
					zinst i sshpass -stable
				fi
            Hcount=1
                while [[ $Hcount -le $HostNum ]];  do
                    TartgetHost=`echo $ZHosts | awk '{print $'$Hcount'}'`
                    echo ""
                    echo "[:: $TartgetHost  ::]"
					TartgetHost=`echo $ZHosts | awk '{print $'$Hcount'}'`
					$Comm_sshpass ssh -p $ssh_port -T -oStrictHostKeyChecking=no $UserID@$TartgetHost <<EOF1
						if [ ! -e "~/.ssh" ]; then
							mkdir ~/.ssh  2> /dev/null
						fi
						umask 022
						echo "$PUBKEY" > ~/.ssh/authorized_keys
EOF1
					let Hcount=Hcount+1
					Localhost=$HOSTNAME
					Command_p="> Key Deploy"
					SourceFull=(`echo "$Source"`)
					IPaddr=`/sbin/ifconfig |grep " addr:" |grep Bcast |head -1 | awk '{print $2}'|awk  -F ':' '{print $2}'`
					$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no $TartgetHost "echo -e \"`date +%Y.%m.%d_%T`\t $WhoStamps : $Command_p - From $IPaddr:  ${SourceFull[@]} -> $TargetDir \" >> $History_LOG"
				done
		else
			echo "$ROWW"
			echo " Hostname requires"
			echo "$ROWW"
		fi
		exit 0;
	fi


#########################################################################################
############################# zinst re-org engine start #################################
################################# Hostlist checker ######################################
RotaCommand=$Allcommand
szinst="zinst"
RotaBeacon=0
	if [[ $ZHosts != "" ]]
	then
		Count=0
		Max=${#HostChanged[@]}
			while [[ $Count -lt $Max ]];
			do
				HostF=$WhoStamp@${HostChanged[$Count]}
				## ssh connection check
				$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no $HostF "grep ^VERSION /usr/bin/zinst" > $ZinstBaseRoot/vault/Source/ssh_conn_test.log 2>&1
				CheckConnection=`$sudo_base cat $ZinstBaseRoot/vault/Source/ssh_conn_test.log |grep "No route\|not known\|Connection refused"`
					if [[ $CheckConnection != "" ]]
					then
						echo $Barr
						echo "It couldn't connect this host($HostF). Please check this hostname"
						echo $Barr
					else
						## Install start with target host ##
						## Check the Package or Distribution server
						## Package scp to destination
						zinst_checkDes=`$sudo_base grep ^VERSION $ZinstBaseRoot/vault/Source/ssh_conn_test.log | sed -e 's/VERSION=//g' 2> $zinst_log`
							if [[ $zinst_checkDes != "" ]]
							then
								zinst_checkLoc=`$sudo_base cat /usr/bin/zinst 2> $zinst_log |grep ^VERSION | sed -e 's/VERSION=//g'`
									if [[ $(version_redefine "$zinst_checkDes") < $(version_redefine "$zinst_checkLoc") ]];
									then
										$Comm_sshpass scp -P $ssh_port /usr/bin/zinst $HostF:/usr/bin
									fi
							else
								$Comm_sshpass scp -P $ssh_port /usr/bin/zinst $HostF:/usr/bin/ 2> $zinst_log
							fi

						#### Check SSH command ########
							if [[ $CommandX = "ssh" ]]
							then
								RotaCommand=$MidPackageArry
								szinst=""
							fi

						CheckDesDIR=`$sudo_base grep " cannot access " $ZinstBaseRoot/vault/Source/ssh_conn_test.log`
							if [[ $CommandX != "" ]]
							then
	        						$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no -t $HostF "$sudo_base mkdir -p $ZinstBaseRoot/vault/Source;sudo chgrp -R $zinst_group $ZinstBaseRoot/vault" 2> $zinst_log
							fi

        					echo ""
						## Delete temporary connection checker file
     						$sudo_base rm -f $ZinstBaseRoot/vault/Source/ssh_conn_test.log
						#### Local package scp to destination ####
						LocalPkg=`echo $RotaCommand | sed -e 's/^[a-z]* //g'`
						LocalPkg_Num=`echo $LocalPkg | awk '{print NF}'`

						CountSub=1
							while [[ $CountSub -le $LocalPkg_Num ]]
							do
								LocalRealPkg=`echo $LocalPkg | awk '{print $'$CountSub'}'`
									if [[ $CommandX = "^ssh$" ]]
									then
										LocalPkg_chk=`cd $PWD;ls |grep "^$LocalRealPkg"`
									fi

									if [[ $LocalPkg_chk != "" ]]
									then
										$Comm_sshpass scp -P $ssh_port $LocalRealPkg $HostF:$ZinstSourceDir/
									fi

								let CountSub=CountSub+1
							done;

							#### Check set command for destination work ########
							if [[ $RotaBeacon = 0 ]];then
								if [[ $CommandX = "set" ]]
								then
									RotaCommand=`echo $RotaCommand | sed -e 's/ \-set//1'`
									RotaBeacon=1
								fi
							fi

						MultiCheck=`echo $ZOptions |grep -e "-multi"`
							if [[ $MultiCheck = "" ]]
							then
								$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no -t $HostF "echo [ :: $HostF :: ];cd $ZinstSourceDir; source /etc/profile ;$szinst $RotaCommand" 2> $zinst_log
								IPaddr=`/sbin/ifconfig |grep " addr:" |grep Bcast |head -1 | awk '{print $2}'|awk  -F ':' '{print $2}'`
									if [[ $szinst = "" ]];then
										DestStamp="> SSH -"
									else
										DestStamp=" L"
									fi

 							    $Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no -t $HostF "echo -e \"`date +%Y.%m.%d_%T`\t $WhoStamps : $DestStamp From $IPaddr: $szinst $RotaCommand\" >> $History_LOG"
							else
								$Comm_sshpass ssh -p $ssh_port -oStrictHostKeyChecking=no -t $HostF "echo [ :: $HostF :: ];cd $ZinstSourceDir; source /etc/profile ;$szinst $RotaCommand" &
							fi

					fi
				let Count=Count+1
			done
		exit 0;
	fi


case "$command" in
	i | inst*)
		Pkg_Install $* 	
		echo "command [ install ] package is "$@
		echo $ProcessPkgNum
		echo $ZHosts
		echo $HostCount
		echo $Zset
		echo ${#SetOptionValue[@]}
	;;
	set)
		Pkg_Set
	;;
	gets*)
		Pkg_Getset $*
		echo "command ["$command"] argument is "$@
	;;
	getd*)
		#Pkg_GetDep $*	
		echo "command ["$command"] argument is "$@
	;;
	r*m*)
		Pkg_Remove $*	
		echo "command ["$command"] argument is "$@
	;;
	start)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	stop)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	run)
		#Daemon_Control $*
		echo "command ["$command"] argument is "$@
	;;
	reload)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	restart)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	on)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	off)
		#Daemon_Control $*	
		echo "command ["$command"] argument is "$@
	;;
	his*)
		#History
		echo "command ["$command"] argument is "$@
	;;
	self-up*)
		#Zinst_Selfupdate 
		echo "command ["$command"] argument is "$@
	;;
	self-conf*)
		#Zinst_SelfConfig
		echo "command ["$command"] argument is "$@
	;;
	cront*)
		#Cront_Command $* 
		echo "command ["$command"] argument is "$@
	;;
	l*s*)
		Pkg_List $*	
		echo "command ["$command"] argument is "$@
	;;
	sync*)
		#Pkg_Sync $*	
		echo "command ["$command"] argument is "$@
	;;
	restore)
		#Pkg_Restore $*
		echo "command ["$command"] argument is "$@
	;;
	find)
		#Pkg_Find $*
		echo "command ["$command"] argument is "$@
	;;
	track)
		#Pkg_Track $* 
		echo "command ["$command"] argument is "$@
	;;
	daemon*)
		#Daemon_list $2
		echo "command ["$command"] argument is "$@
	;;
	-v*)
		#Zinst_Version 
		echo "command ["$command"] argument is "$@
	;;
	*help)
		Help_Detail	
	;;
	init)
		#Init_Virtual 
		echo "command ["$command"] argument is "$@
	;;
	vms)
		#Vmlist_Virtual 
		echo "command ["$command"] argument is "$@
	;;
	add)
		#Add_Virtual 
		echo "command ["$command"] argument is "$@
	;;
	destroy)
		#Destroy_Virtual 
		echo "command ["$command"] argument is "$@
	;;
	up)
		#Up_Virtual 
		echo "command ["$command"] argument is "$@
	;;
	halt)
		#Halt_Virtual
		echo "command ["$command"] argument is "$@
	;;
        show_dep)
		#Show_Package_dependecy 
		echo "command ["$command"] argument is "$@
	;;
	*)
		Help_Command	
		
	;;
esac


