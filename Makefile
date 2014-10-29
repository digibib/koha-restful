.PHONY: all test clean

all: reload build run

reload: halt up provision

halt:
	vagrant halt

up:
	vagrant up

provision:
	vagrant provision

stop_restful: 
	@echo "======= STOPPING KOHA-RESTFUL CONTAINER ======\n"
	vagrant ssh -c 'sudo docker stop koha_restful' || true

stop_koha: 
	@echo "======= STOPPING KOHA CONTAINER ======\n"
	vagrant ssh -c 'sudo docker stop koha_docker' || true

delete_restful: stop_restful
	@echo "======= DELETING KOHA-RESTFUL CONTAINER ======\n"
	vagrant ssh -c 'sudo docker rm koha_restful' || true

delete_koha: stop_koha
	@echo "======= DELETING KOHA CONTAINER ======\n"
	vagrant ssh -c 'sudo docker rm koha_docker' || true

delete: stop delete_koha delete_restful

stop: stop_koha stop_restful

# start koha with koha-restful container
run: delete run_restful run_koha
	@echo "======= RUNNING KOHA CONTAINER WITH VOLUMES FROM KOHA RESTFUL======\n"

run_restful:
	@vagrant ssh -c 'sudo docker run -it --name koha_restful digibib/koha-restful echo "yes"'

run_koha:
	@vagrant ssh -c 'sudo docker run -d --name koha_docker --volumes-from=koha_restful \
	-p 80:80 -p 8080:8080 -p 8081:8081 -t digibib/koha' || echo "koha_docker container \
	already running, please _make delete_ first"

logs:
	vagrant ssh -c 'sudo docker logs koha_docker'

logs-f:
	vagrant ssh -c 'sudo docker logs -f koha_docker'

test:
	@echo "======= TESTING KOHA-RESTFUL CONTAINER ======\n"
	vagrant ssh -c 'sudo docker exec koha_docker /bin/bash -c "cd /usr/share/koha && \
	KOHA_CONF=/etc/koha/sites/name/koha-conf.xml \
	prove -Ilib t/rest"' | tee test.log | grep PASS

clean:
	vagrant destroy --force

build:
	@echo "======= BUILDING KOHA-RESTFUL CONTAINER ======\n"
	vagrant ssh -c 'sudo docker build -t digibib/koha-restful /vagrant'

login: # needs EMAIL, PASSWORD, USERNAME
	@ vagrant ssh -c 'sudo docker login --email=$(EMAIL) --username=$(USERNAME) --password=$(PASSWORD)'

tag = "$(shell git rev-parse HEAD)"
push:
	@echo "======= PUSHING KOHA-RESTFUL CONTAINER ======\n"
	vagrant ssh -c 'sudo docker tag digibib/koha-restful digibib/koha-restful:$(tag)'
	vagrant ssh -c 'sudo docker push digibib/koha-restful'
