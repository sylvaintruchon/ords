#!/bin/bash
TEMOIN=/u01/config/ords/CONTAINER_ALREADY_STARTED_FLAG

if [ ! -f $TEMOIN ]; then
  echo "First run"
  touch $TEMOIN

  echo "Configure ORDS"

  cd $ORDS_HOME

  $ORDS_HOME/bin/ords --config $ORDS_CONF install \
                      --log-folder $ORDS_CONF/logs \
		      --admin-user SYS \
		      --proxy-user \
		      --db-hostname $DB_HOSTNAME \
		      --db-port $DB_PORT \
		      --db-servicename $DB_SERVICE \
		      --feature-rest-enabled-sql true \
		      --feature-sdw false \
		      --schema-tablespace $ORDS_TABLESPACE \
		      --password-stdin <<EOF
$SYS_PASSWORD
$ORDS_PUBLIC_PASSWORD
EOF

  echo "Set access.log"
  $ORDS_HOME/bin/ords --config $ORDS_CONF config set standalone.access.log $ORDS_CONF/logs

  echo "Set path"
  echo "ORDS_CONTEXT_PATH=$ORDS_CONTEXT_PATH"
  $ORDS_HOME/bin/ords --config $ORDS_CONF config set standalone.context.path /ords/$ORDS_CONTEXT_PATH

  echo "Set jdbc settings"
  $ORDS_HOME/bin/ords --config $ORDS_CONF config set jdbc.InitialLimit $JDBC_INITIAL_LIMIT
  $ORDS_HOME/bin/ords --config $ORDS_CONF config set jdbc.MaxLimit $JDBC_MAX_LIMIT
fi

echo "Starting ords in standalone mode"
export _JAVA_OPTIONS="$JAVA_OPTS"

$ORDS_HOME/bin/ords --config $ORDS_CONF serve
