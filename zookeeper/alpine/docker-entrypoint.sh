#!/bin/bash

HOST=`hostname -s`
DOMAIN=`hostname -d`

DATA_DIR="/opt/zookeeper/data"
LOG_DIR="/opt/zookeeper/logs"
CONF_DIR="/opt/zookeeper/conf"
ID_FILE="$DATA_DIR/myid"
CONFIG_FILE="$CONF_DIR/zoo.cfg"
JAVA_ENV_FILE="$CONF_DIR/java.env"

CLIENT_PORT=${CLIENT_PORT:-2181}
SERVER_PORT=${SERVER_PORT:-2888}
ELECTION_PORT=${ELECTION_PORT:-3888}
TICK_TIME=${TICK_TIME:-2000}
INIT_LIMIT=${INIT_LIMIT:-10}
SYNC_LIMIT=${SYNC_LIMIT:-5}
HEAP=${HEAP:-512M}
MAX_CLIENT_CNXNS=${MAX_CLIENT_CNXNS:-60}
SNAP_RETAIN_COUNT=${SNAP_RETAIN_COUNT:-3}
PURGE_INTERVAL=${PURGE_INTERVAL:-0}
MIN_SESSION_TIMEOUT=${MIN_SESSION_TIMEOUT:-$((TICK_TIME*2))}
MAX_SESSION_TIMEOUT=${MAX_SESSION_TIMEOUT:-$((TICK_TIME*20))}
SERVERS_NUM=${SERVERS_NUM:-1}

function print_servers() {
    for (( i=1; i<=$SERVERS_NUM; i++ ))
    do
        if [[ ! -z $DOMAIN ]];then
            echo "server.$i=$NAME-$((i-1)).$DOMAIN:$SERVER_PORT:$ELECTION_PORT"
        else
            [[ $i = $ORD ]] && echo "server.$i=0.0.0.0:$SERVER_PORT:$ELECTION_PORT" || echo "server.$i=$NAME$i:$SERVER_PORT:$ELECTION_PORT"
        fi
    done
}

function create_config() {
    rm -f $CONFIG_FILE
    echo "#This file was autogenerated DO NOT EDIT" >> $CONFIG_FILE
    echo "clientPort=$CLIENT_PORT" >> $CONFIG_FILE
    echo "dataDir=$DATA_DIR" >> $CONFIG_FILE
    echo "tickTime=$TICK_TIME" >> $CONFIG_FILE
    echo "initLimit=$INIT_LIMIT" >> $CONFIG_FILE
    echo "syncLimit=$SYNC_LIMIT" >> $CONFIG_FILE
    echo "maxClientCnxns=$MAX_CLIENT_CNXNS" >> $CONFIG_FILE
    echo "minSessionTimeout=$MIN_SESSION_TIMEOUT" >> $CONFIG_FILE
    echo "maxSessionTimeout=$MAX_SESSION_TIMEOUT" >> $CONFIG_FILE
    echo "autopurge.snapRetainCount=$SNAP_RETAIN_COUNT" >> $CONFIG_FILE
    echo "autopurge.purgeInteval=$PURGE_INTERVAL" >> $CONFIG_FILE
    if [ $SERVERS_NUM -gt 1 ]; then
        print_servers >> $CONFIG_FILE
        #判断有状态还是无状态
        [[ ! -z $DOMAIN ]] && MY_ID=$((ORD+1)) || MY_ID=$ORD
        echo $MY_ID > $ID_FILE
    fi
    cat $CONFIG_FILE >&2
}

function create_jvm_props() {
    rm -f $JAVA_ENV_FILE
    echo "ZOO_LOG_DIR=$LOG_DIR" >> $JAVA_ENV_FILE
    echo "JVMFLAGS=\"-Xmx$HEAP -Xms$HEAP\"" >> $JAVA_ENV_FILE
}

if [[ ! -z $DOMAIN ]];then
    if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
        NAME=${BASH_REMATCH[1]}
        ORD=${BASH_REMATCH[2]}
    fi
else
    NF=$(echo $HOST | awk -F - '{print NF}')
    a=$(($NF-2))
    i=1
    for aa in $(echo $HOST | grep -oE "[0-9a-z]{1,}")
    do
        if (( $i <= $a ));then
            [[ $i = 1 ]] && NAME=$aa || NAME=$NAME-$aa
        else
            break
        fi
        ((i++))
    done
    ORD=$(echo $NAME | grep -oE "[0-9]{1,}")
    NAME=$(echo $NAME | grep -oE "[a-z-]{1,}")
fi

create_config
create_jvm_props
exec "$@"
