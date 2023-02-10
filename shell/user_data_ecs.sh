#!/bin/bash -eux
set -o pipefail
scriptpath="$(readlink -f "$0")"
scriptdir="$(dirname "$scriptpath")"

# chkconfig: 345 99 1
# description: main
# processname: main

# ---------------------------------------
# instance vars

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
instance_ipv4=$(ip addr show eth0 | awk -F'[ /]+' '/inet /{print $3}')

# ---------------------------------------
# configuration

JAVA_OPTS="-server -Duser.timezone=JST \
  -Xmx${jvm_heap_size} -Xms${jvm_heap_size} \
  -Xss256k -XX:MetaspaceSize=${jvm_metaspace_size} -XX:MaxMetaspaceSize=${jvm_metaspace_size} \
  -XX:+PreserveFramePointer -XX:+AlwaysPreTouch -XX:+PrintFlagsFinal -XX:+PerfDisableSharedMem \
  -XX:+FlightRecorder -XX:StartFlightRecording=settings=/etc/izumo-dictionary/default.jfc,disk=true,maxage=24h,maxsize=32g -XX:FlightRecorderOptions=repository=/var/log/izumo-dictionary/flight-recorder \
  -XX:-OmitStackTraceInFastThrow -XX:+UseTransparentHugePages \
  -XX:+UnlockExperimentalVMOptions -XX:+UseZGC \
  -XX:+SafepointTimeout -XX:SafepointTimeoutDelay=200 \
  -Xlog:gc*=trace,safepoint*=debug,classhisto*=trace,heap*=trace,gc+tlab*=debug,gc+region*=debug,gc+metaspace*=debug,gc+nmethod*=info,gc+ref*=debug,gc+reloc*=debug:file=/var/log/izumo-dictionary/jvm.log:t,l,tg:filecount=10,filesize=64M \
  -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=17019 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=`hostname` \
  -XX:+DisableExplicitGC"

# ---------------------------------------
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config;

do_start_server() {
	echo "Staring server..." 1>&2

	mkdir -p /var/lib/izumo-dictionary
	mkdir -p /etc/izumo-dictionary
	mkdir -p /var/log/izumo-dictionary
	mkdir -p /var/log/izumo-dictionary/flight-recorder

cat > /etc/izumo-dictionary/application.yaml <<EOF
izumo:
  dict:
    db:
      driver: com.mysql.jdbc.Driver
      url: jdbc:mysql://${mysql_host}:3306/izumo_dict?allowMultiQueries=true&useUnicode=true&characterEncoding=UTF-8&socketTimeout=60000&connectTimeout=3000&autoReconnect=true
      username: ${mysql_username}
      password: ${mysql_password}
    redis:
      mode: standalone
      host: ${redis_host}
      timeout: 3000
EOF

do_stop_server() {
	echo "Stopping server..." 1>&2
	docker stop server
}

case "$${1:-setupandstart}" in
	start)
		sysctl -w net.core.somaxconn=65535
		sysctl -w vm.max_map_count=131072
		do_start_server
		touch /var/lock/subsys/main
		;;
	stop)
		do_stop_server || true
		rm -f /var/lock/subsys/main
		;;
	kill)
		docker rm -f server || true
		;;
	setupandstart)
		# set clocksource to tsc
		echo tsc > /sys/devices/system/clocksource/clocksource0/current_clocksource

		# stop dockerd
		sudo service docker stop

		# drop all iptable rules
		for table in filter nat raw mangle security; do
			echo "iptables -t $table -S"
			iptables -t $table -S
			echo ""
			iptables -t $table -F
			iptables -t $table -X
			modprobe -r iptable_$table
		done

		# unload iptable modules
		for i in `seq 5`; do
			lsmod | awk '/^(xt|ipt|nf)_/ && $3 == 0 {print $1}' | xargs --no-run-if-empty modprobe -r
		done

		# disable iptables for docker and restart
		echo 'OPTIONS="--default-ulimit nofile=1024:4096 --iptables=false"' >> /etc/sysconfig/docker
		while ! service docker start; do
			echo "Retrying docker start..." 1>&2
			sleep 1
		done

		chmod -x /etc/cron.daily/man-db.cron
		$(aws ecr get-login --region ap-northeast-1 --no-include-email)
		cp "$scriptpath" /etc/init.d/main
		chmod +x /etc/init.d/main
		chkconfig --add main
		service main start
		;;
	*)
		echo "Usage: $0 [start|stop]" 1>&2
		exit 1
		;;
esac
