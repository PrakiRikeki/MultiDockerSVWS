# SVWS Server Setup

In diesem Repo ist ein Skript zu finden, welches die einfache Installation mehrer SVWS-Server in Minuten durchführen kann.

## Voraussetzungen

Stellen Sie bitte sicher, dass die folgenden Tools auf Ihrem System installiert sind: `wget`, `unzip` und `grep`. Diese Werkzeuge sind notwendig, um das Skript herunterzuladen und auszuführen.


## Installation

### Schnellinstallation

```sh
wget -q https://raw.githubusercontent.com/PrakiRikeki/MultiDockerSVWS/main/download/main.sh; chmod +x main.sh; sudo ./main.sh
```

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

### Konfigurationsdatei

Bevor Sie das Skript ausführen, müssen Sie eine Konfigurationsdatei erstellen, die den Namen `svws_docker.conf` trägt. Die Datei sollte den folgenden Aufbau haben, basierend auf dem Beispiel `svws_docker.conf_example`:

```conf
Host Port=1234
Database Location=localhost
Database Port=92875

    name=sag
    user=mein
    pass=meins

    name=deins
    user=deins
    pass=dasd

    name=dsasad 
    user=asda
    pass=asd

Host Port=1234
Database Location=localhost
Database Port=92875

    name=sag
    user=mein
    pass=meins

    name=deins
    user=deins
    pass=dasd

    name=dsasad 
    user=asda
    pass=asd

Host Port=1234
Database Location=localhost
Database Port=92875

    name=sag
    user=mein
    pass=meins
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

## Fehlerbehebung

- **`Skript muss als Root ausgeführt werden.`**: Stellen Sie sicher, dass Sie das Skript mit `sudo` ausführen, um die erforderlichen Berechtigungen zu haben.

- **`bash: ./start-me.sh: cannot execute: required file not found`**: Führen sie folgenden Befehl aus: 
```sh
find /path/to/directory -type f -exec dos2unix {} \;
```

_weitere Folgen bestimmt_