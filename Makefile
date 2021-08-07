SPLUNK_IMAGE=splunk/splunk
APPINSPECT_IMAGE=outcoldsolutions/splunk-appinspect:1.6.0

SPLUNK_PASSWORD=splunkdev

OLD_APP=jay_ta
APP=jay_ta

.PHONY: up down logs bash web refresh app-clean app-pack app-inspect install refresh

up:
	docker run \
		-d \
		--name ${APP}-splunk \
		--hostname ${APP}-splunk \
		--publish 8000:8000 \
		--publish 8088:8088 \
		--publish 8089:8089 \
		--env "SPLUNK_USER=root" \
		--env "SPLUNK_PASSWORD=${SPLUNK_PASSWORD}" \
		--env "SPLUNK_START_ARGS=--accept-license --answer-yes" \
		--env "APP=/opt/splunk/etc/apps/${APP}" \
		--volume ${APP}-splunk-etc:/opt/splunk/etc \
		--volume ${APP}-splunk-var:/opt/splunk/var \
		--volume $(shell pwd)/${APP}:/${APP} \
		--volume $(shell pwd)/hack:/hack \
		--env "SPLUNK_CMD_1=restart" \
		${SPLUNK_IMAGE}

down:
	-docker kill ${APP}-splunk
	-docker rm -v ${APP}-splunk
	-docker volume rm ${APP}-splunk-etc ${APP}-splunk-var

logs:
	docker logs -f ${APP}-splunk

bash:
	docker exec -it ${APP}-splunk bash

web:
	open 'http://localhost:8000/en-US/account/insecurelogin?loginType=splunk&username=admin&password=${SPLUNK_PASSWORD}'

refresh:
	open 'http://localhost:8000/en-US/account/insecurelogin?loginType=splunk&username=admin&password=${SPLUNK_PASSWORD}&return_to=%2Fen-US%2Fdebug%2Frefresh'

app-clean:
	rm -fR "$(shell pwd)/${APP}/local/"
	rm -fR "$(shell pwd)/${APP}/metadata/local.meta"

app-pack:
	mkdir -p "$(shell pwd)/out"
	docker run \
		--volume $(shell pwd):/src \
		--workdir /src \
		--rm ${SPLUNK_IMAGE} \
		tar -cvzf out/${APP}.tar.gz ${APP}

app-inspect:
	docker run --volume $(shell pwd)/${APP}:/src/${APP} --rm ${APPINSPECT_IMAGE}

install:
	pip install --target=./${APP}/lib -r ./${APP}/requirements.txt

rename:
	mv -v ${OLD_APP} ${APP} 
	sed -i "s/${OLD_APP}/${APP}/" \
	Makefile \
	.gitignore \
	${APP}/default/app.conf \
	hack/splunk/etc/users/admin/user-prefs/local/user-prefs.conf \
	${APP}/bin/*.py
