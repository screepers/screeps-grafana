#!/bin/bash
echo Starting containers...
docker-compose up -d
echo Waiting for grafana to start...
CURLRET=1
while [[ $CURLRET != 0 ]]; do
	sleep 1
	curl -s -I http://localhost:1337 > /dev/null
	CURLRET=$?
done
echo Configuring Datasource...
curl -s 'http://admin:admin@localhost:1337/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"localGraphite","type":"graphite","url":"http://graphite:8000","access":"proxy","isDefault":true,"database":""}' > /dev/null
sleep 2
echo Installing Sample...
curl -s 'http://admin:admin@localhost:1337/api/dashboards/db' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data @sampleDashboard.json  > /dev/null
echo All done! 
echo You should be able connect to http://localhost:1337
echo with username \'admin\' and password \'admin\'