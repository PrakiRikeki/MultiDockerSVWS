clear && \
sudo apt update && \
sudo apt upgrade && \
sudo apt install nano default-jdk htop git wget grep unzip net-tools && \
docker pull svwsnrw/svws-server && \
wget -O meins.zip https://github.com/ribekagmbh/MultiDockerSVWS/archive/refs/heads/main.zip && \
unzip meins.zip && \
rm meins.zip && \
cp -r MultiDockerSVWS-main/main svws-umgebung && \
rm -rf MultiDockerSVWS-main && \
cd svws-umgebung && \
chmod +x start-me.sh && \
mv svws_docker.conf_example svws_docker.conf && \
nano svws_docker.conf && \
sudo ./start-me.sh