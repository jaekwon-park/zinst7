#!/bin/bash


#########################################################3
 
while getopts ":dsofzdelF:u:S:O:p:P:h:H:" opt; do
  case $opt in
    d)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    s)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    o)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    f)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    z)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    d)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    e)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    l)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    F)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    u)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    S)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
	SetOptionValueE=$(echo $OPTARG | sed -e 's/#/ /g')

      ;;
    O)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    p)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    P)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    h)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
	Hostlist=$(echo $OPTARG | sed -e 's/,/ /g')
	HostCount=0
	for i in $Hostlist
	do
		let HostCount=$HostCount+1
	done
      ;;
    H)
      echo $opt" was triggered, Parameter: "$OPTARG >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $(( $OPTIND  -1 ))
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
		echo $command" argument is "$@
		echo $ProcessPkgNum
		echo $Hostlist
		echo $HostCount
		echo $SetOptionValueE
	;;
	set)
		#Pkg_Set $*
		echo $command" argument is "$@
	;;
	gets*)
		#Pkg_Getset $*
		echo $command" argument is "$@
	;;
	getd*)
		#Pkg_GetDep $*	
		echo $command" argument is "$@
	;;
	r*m*)
		#Pkg_Remove $*	
		echo $command" argument is "$@
	;;
	start)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	stop)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	run)
		#Daemon_Control $*
		echo $command" argument is "$@
	;;
	reload)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	restart)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	on)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	off)
		#Daemon_Control $*	
		echo $command" argument is "$@
	;;
	his*)
		#History
		echo $command" argument is "$@
	;;
	self-up*)
		#Zinst_Selfupdate 
		echo $command" argument is "$@
	;;
	self-conf*)
		#Zinst_SelfConfig
		echo $command" argument is "$@
	;;
	cront*)
		#Cront_Command $* 
		echo $command" argument is "$@
	;;
	l*s*)
		#Pkg_List $*	
		echo $command" argument is "$@
	;;
	sync*)
		#Pkg_Sync $*	
		echo $command" argument is "$@
	;;
	restore)
		#Pkg_Restore $*
		echo $command" argument is "$@
	;;
	find)
		#Pkg_Find $*
		echo $command" argument is "$@
	;;
	track)
		#Pkg_Track $* 
		echo $command" argument is "$@
	;;
	daemon*)
		#Daemon_list $2
		echo $command" argument is "$@
	;;
	-v*)
		#Zinst_Version 
		echo $command" argument is "$@
	;;
	*help)
		Help_Detail	
	;;
	init)
		#Init_Virtual 
		echo $command" argument is "$@
	;;
	vms)
		#Vmlist_Virtual 
		echo $command" argument is "$@
	;;
	add)
		#Add_Virtual 
		echo $command" argument is "$@
	;;
	destroy)
		#Destroy_Virtual 
		echo $command" argument is "$@
	;;
	up)
		#Up_Virtual 
		echo $command" argument is "$@
	;;
	halt)
		#Halt_Virtual
		echo $command" argument is "$@
	;;
        show_dep)
		#Show_Package_dependecy 
		echo $command" argument is "$@
	;;
	*)
		Help_Command	
		
	;;
esac


