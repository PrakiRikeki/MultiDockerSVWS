# SVWS Server Setup

In diesem Repo ist ein Skript zu finden, welches die einfache Installation mehrer SVWS-Server in Minuten durchführen kann.

## Voraussetzungen

Stellen Sie bitte sicher, dass die folgenden Tools auf Ihrem System installiert sind: `wget`, `unzip` und `grep`. Diese Werkzeuge sind notwendig, um das Skript herunterzuladen und auszuführen.

## Installation

**Dateien herunterladen und Skript ausführen**

Führen Sie folgenden Befehl aus, um alle benötigten Dateien herunterzuladen, zu entpacken, das Verzeichnis umzubenennen und das Skript auszuführen:

```sh
wget -O meins.zip https://github.com/PrakiRikeki/MultiDockerSVWS/archive/refs/heads/main.zip && \
unzip meins.zip && \
rm meins.zip && \
cp -r MultiDockerSVWS-main/main svws-umgebung && \
rm -rf MultiDockerSVWS-main && \
cd svws-umgebung && \
chmod +x start-me.sh
```

Dieser Befehl erledigt Folgendes:
1. **Lädt** die ZIP-Datei des Repositories herunter.
2. **Entpackt** die ZIP-Datei.
3. **Löscht** die ZIP-Datei, um Speicherplatz freizugeben.
4. **Benennt** das entpackte Verzeichnis um.
5. **Wechselt** in das umbenannte Verzeichnis.
6. **Macht** das Skript ausführbar.

### Konfigurationsdatei

Bevor Sie das Skript ausführen, müssen Sie eine Konfigurationsdatei erstellen, die den Namen `svws_docker.conf` trägt. Die Datei sollte den folgenden Aufbau haben, basierend auf dem Beispiel `svws_docker.conf_example`:

```ini
[server]
ID=1
DIR_PATH=./server
MariaDB_HOST=localhost:3306
MariaDB_ROOT_PASSWORD=root1
MariaDB_DATABASE=db1
MariaDB_USER=user1
MariaDB_PASSWORD=pass1
SVWS_TLS_KEYSTORE_PASSWORD=keystorepass1
SVWS_TLS_KEY_ALIAS=alias1
SVWS_HOST_IP=192.168.1.1
SVWS_HOST_PORT=4431

[schule166123]
name=Gymnasium Am Stadtpark
username=gym_stadtpark
password=gP8#kL9$mN2

[schule166124]
name=Albert-Einstein-Realschule
username=aers_admin
password=eR5$tY7#pQ9

[schule166125]
name=Berufskolleg Mitte
username=bk_mitte
password=bK3#mP5$nL8

[schule166126]
name=Gesamtschule Nord
username=gs_nord
password=nX6#vB9$kM4

[schule166127]
name=Heinrich-Heine-Gymnasium
username=hhg_admin
password=hH7#gF4$pL2
```

Gerne können Sie diese Datei Umbenennen und verwenden. Dies können Sie mit folgendem Befehl tun:

```sh
mv svws_docker.conf_example svws_docker.conf && \
nano svws_docker.conf
```

Die Datei `svws_docker.conf` sollte im selben Verzeichnis wie das Skript `start-me.sh` liegen.

## Nutzung

Das Skript kann nun mit folgendem Befehl gestartet werden:

```sh
sudo ./start-me.sh
```

## Deinstallation

Um das Skript mit allen Servern zu löschen, eignet sich dieser Befehl:

```sh
cd ..
sudo rm -r svws-umgebung
```

## Schnellinstallation

```sh
wget -q https://raw.githubusercontent.com/PrakiRikeki/MultiDockerSVWS/main/download/main.sh; chmod +x main.sh; sudo ./main.sh
```

## Fehlerbehebung

- **`Skript muss als Root ausgeführt werden.`**: Stellen Sie sicher, dass Sie das Skript mit `sudo` ausführen, um die erforderlichen Berechtigungen zu haben.

- **`bash: ./start-me.sh: cannot execute: required file not found`**: Führen sie folgenden Befehl aus: 
```sh
find /path/to/directory -type f -exec dos2unix {} \;
```

_weitere Folgen_