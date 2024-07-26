# SVWS Server Setup

Willkommen bei der SVWS-Server-Einrichtungsanleitung. Dieses Repository enthält ein Skript zur Einrichtung von SVWS-Servern basierend auf einer Konfigurationsdatei. Bitte folgen Sie den nachstehenden Anweisungen, um das Skript erfolgreich zu nutzen.

## Voraussetzungen

Stellen Sie bitte sicher, dass die folgenden Tools auf Ihrem System installiert sind: `wget`, `unzip` und `grep`. Diese Werkzeuge sind notwendig, um das Skript herunterzuladen und auszuführen.

## Installation

**Dateien herunterladen und Skript ausführen**

Führen Sie folgenden Befehl aus, um alle benötigten Dateien herunterzuladen, zu entpacken, das Verzeichnis umzubenennen und das Skript auszuführen:

```sh
wget -O meins.zip https://github.com/ribekagmbh/MultiDockerSVWS/archive/refs/heads/main.zip && \
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

Bevor Sie das Skript ausführen, müssen Sie eine Konfigurationsdatei erstellen, die den Namen `config.txt` trägt. Die Datei sollte den folgenden Aufbau haben, basierend auf dem Beispiel `config.txt_example`:

```ini

[Server1]
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
[Server2]
ID=2
DIR_PATH=./server
MariaDB_HOST=localhost:3307
MariaDB_ROOT_PASSWORD=root2
MariaDB_DATABASE=db2
MariaDB_USER=user2
MariaDB_PASSWORD=pass2
SVWS_TLS_KEYSTORE_PASSWORD=keystorepass2
SVWS_TLS_KEY_ALIAS=alias2
SVWS_HOST_IP=192.168.1.2
SVWS_HOST_PORT=4432
```

Gerne können Sie diese Datei Umbenennen und verwenden. Dies können Sie mit folgendem Befehl tun:

```sh
mv config.txt_example config.txt && \
nano config.txt
```

Die Datei `config.txt` sollte im selben Verzeichnis wie das Skript `start-me.sh` liegen.

## Nutzung

Das Skript kann nun mit folgendem Befehl gestartet werden:

```sh
sudo ./start-me.sh
```

## Deinstallation

```sh
cd ..
sudo rm -r svws-umgebung
```

## Fehlerbehebung

- **`Skript muss als Root ausgeführt werden.`**: Stellen Sie sicher, dass Sie das Skript mit `sudo` ausführen, um die erforderlichen Berechtigungen zu haben.

_weitere Folgen_