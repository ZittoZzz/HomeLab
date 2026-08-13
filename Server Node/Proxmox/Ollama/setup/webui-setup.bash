# make docker-compose.yaml
sudo nano docker-compose.yaml

#refer to configs/webui-setup.bash for the content of docker-compose.yaml

#run it
docker compose up -d

#access thewebui through the browser at http://<webui-ip>:3000