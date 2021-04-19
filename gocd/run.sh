#!/bin/bash


case ${1} in
"agent")
  cd /opt/go-agent*/
  sed -i "s/wrapper\.app\.parameter\.101=.*/wrapper\.app\.parameter\.101=http:\/\/${GOCD_SERVER}:8153\/go/g" wrapper-config/wrapper-properties.conf

  if [[ -n ${AGENT_REGISTER_KEY} ]]; then
cat <<EOF >>config/autoregister.properties
agent.auto.register.key=${AGENT_REGISTER_KEY}
EOF
  fi

  ./bin/go-agent console
  ;;
*)
  cd /opt/go-server*/

  envsubst < ./config/db.in.properties > ./config/db.properties
  envsubst < ./config/cruise-config.in.xml > ./config/cruise-config.xml

  ./bin/go-server console
  ;;
esac
