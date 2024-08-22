clear && \
sudo apt update && \
sudo apt upgrade && \
sudo apt install docker.io docker-compose-v2 nano default-jdk nano htop git wget grep unzip && \
docker pull svwsnrw/svws-server && \
wget -O meins.zip https://github.com/ribekagmbh/MultiDockerSVWS/archive/refs/heads/main.zip && \
unzip meins.zip && \
rm meins.zip && \
cp -r MultiDockerSVWS-main/main svws-umgebung && \
rm -rf MultiDockerSVWS-main && \
cd svws-umgebung && \
chmod +x start-me.sh && \
mv config.txt_example config.txt && \
nano config.txt && \
sudo ./start-me.sh