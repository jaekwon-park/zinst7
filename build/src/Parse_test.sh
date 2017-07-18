#!/bin/bash

#########################################################3

PARSED_OPTION=$(getopt -n "$0" -o :dsofzelF:u:S:O:p:P:h:H: --long "downgrade,stable,oldset,force,zicf,edit,list,file:,url:,set:,export:,pass:,port:,host:,hostlist:" -- "$@")
if [ $? -ne 0 ]
then
	echo "invaild option "
        exit 1
fi
eval set -- "$PARSED_OPTION"
echo $0" Argument Reparsed [ "$PARSED_OPTION " ]"

while true;
do
    case $1 in
    -d|--downgrade)
      echo $1" was triggered "
	echo "downgrade on"
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
      SetOptionValue=$(echo $2 | sed -e 's/#/ /g')
	echo "set on"
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

#########################################################3


ProcessPkgNum=$#


function Help_Command ()
{

cat << EOF
Usage: ${0##*/} [OPTION] [COMMAND] PACKAGE....
Zinst was developed for efficient management and control of distributed server farms and does not require the installation of a separate agent.
For example, you can manage multiple servers with a single command on one specific Linux device.
Option is used with -, and specific parameters can be added.
Command is used to set the server or package.

OPTION 
	-s -same
	-o -oldset
	-f -force
	-z zicf
	-d dep
	-e crontab -e
	-l cronteb -l
	-F: 
	-u: -url
	-S: -set
	-O: export -file=Export_File_name
	-p: -pass Option for Multi-host password automation
	-P: -p [port]	Option for ssh port change as you need
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


function Help_Detail ()
{

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


function exception_check()
{
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

#set Variable
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

case "$command" in
	i | inst*)
		#Pkg_Install $* 	
		echo "command [ install ] package is "$@
		echo $ProcessPkgNum
		echo $Hostlist
		echo $HostCount
		echo $SetOptionValue
	;;
	set)
		#Pkg_Set $*
		echo "command [ set ] argument is "$@
		echo $ProcessPkgNum
		echo $Hostlist
		echo $HostCount
		echo $SetOptionValue
	;;
	gets*)
		#Pkg_Getset $*
		echo "command ["$command"] argument is "$@
	;;
	getd*)
		#Pkg_GetDep $*	
		echo "command ["$command"] argument is "$@
	;;
	r*m*)
		#Pkg_Remove $*	
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
		#Pkg_List $*	
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


