#! /bin/bash
#
# pme file para PME 
#
# fabio@conectiva.com.br
# Tue Nov 20 22:17:56 BRST 2001

PME=/pme
tempfile=/tmp/pme-temp-file

# check if program is installed
test -d $PME || exit 5

function SaiErro()
{
	echo "$*"
	exit 1	
}

function IniciaTornatti()
{
	# Check se o Tornatti está instalado
	if [ ! -f $PME/Tornatti/scripts_sh/jli.sh ]; then
	    SaiErro " $PME/Tornatti/scripts_sh/jli.sh nao esta instalado)"
	fi

	# Check se o Tornatti está rodando ?
	ps ax > $tempfile 
	grep Tornatti $tempfile > /dev/null
	if [ $? = 0 ]; then
		echo "Tornatti já esta rodando..."
		rm -rf $tempfile
		return 1
	fi
	rm -rf $tempfile
	echo "Starting PME "
	echo "Inicializando  $PME/Tornatti/scripts_sh/jli.sh"
	$PME/Tornatti/scripts_sh/jli.sh
}

function IniciaTomcat()
{

	# Check se o tomcat está instalado
	if [ ! -f $PME/tomcat/bin/catalina.sh ]; then
		SaiErro "$PME/tomcat/bin/catalina.sh nao esta instalado"
	fi

	# Check se o Tomcat está rodando ?
	ps ax > $tempfile 
	grep catalina $tempfile > /dev/null
	if [ $? = 0 ]; then
		echo "Tomcat já esta rodando..."
		rm -rf $tempfile
		return 1
	fi
	
	rm -rf $tempfile
	echo "Inicializando $PME/tomcat/bin/catalina.sh &"
	$PME/tomcat/bin/catalina.sh start &
}
function ParaPME {
	echo "Shutting down PME "
	echo "Parando o Tomcat..."
	$PME/tomcat/bin/catalina.sh stop	
	echo "Parando o Tornatti..."
	$PME/Tornatti/scripts_sh/shutdown_jli.sh stop	
}

function Status {
	echo "Checking for Status PME: "
	ps ax > $tempfile 
	# Checando se Tornatti está rodando
	grep Tornatti $tempfile > /dev/null
	if [ $? = 0 ]; then
		echo "Tornatti está rodando..."
	else
		echo "Tornatti não está rodando..."
	fi	
	# Checando se catalina está rodando
	grep catalina $tempfile > /dev/null
	if [ $? = 0 ]; then
		echo "Tomcat está rodando..."
	else
		echo "Tomcat não está rodando..."
	fi	

	rm -rf $tempfile
}

case "$1" in
  start)
	IniciaTornatti
	IniciaTomcat
	;;
  stop)
	ParaPME
	;;
  restart|force-reload)
	ParaPME
	IniciaTornatti
	IniciaTomcat
	;;
  status)
 	Status	
	;;
  *)
	echo "Usage: pme.sh {start|stop|restart|force-reload|status}"
	exit 3
esac

exit $return

