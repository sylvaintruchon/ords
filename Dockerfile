FROM oraclelinux:8-slim

LABEL maintainer="sylvain.truchon.inspq@gmail.com"

ENV JAVA_DOWNLOAD_URL="https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz" \
    JAVA_DOWNLOAD_PATH_NAME="/tmp/java.tar.gz" \
    ORDS_DOWNLOAD_URL="https://download.oracle.com/otn_software/java/ords/ords-23.1.4.150.1808.zip" \
    ORDS_DOWNLOAD_PATH_NAME="/tmp/ords.zip" \
    SCRIPTS_DIR="/u01/scripts" \
    ORDS_HOME="/u01/ords" \
    ORDS_CONF="/u01/config/ords" \
    JAVA_HOME="/u01/java/latest" \
    JAVA_EXTRACT_DIR="/u01/java" \
    OS_PACKAGE="unzip-6.0-46.0.1.el8 tar-2:1.30-9.el8 gzip-1.9-13.el8_5 freetype-2.9.1-9.el8 fontconfig-2.13.1-4.el8 ncurses-6.1-10.20180224.el8 shadow-utils-2:4.6-19.el8 vim-minimal-2:8.0.1763-19.0.1.el8_6.4"

## À configurer lors du démarrage du container.
#    DB_HOSTNAME="" \
#    DB_PORT="" \
#    DB_SERVICE="" \
#    ORDS_TABLESPACE="" \
#    TEMP_TABLESPACE="" \
#    ORDS_PUBLIC_PASSWORD="" \
#    SYS_PASSWORD="" \
#    ORDS_CONTEXT_PATH="" \
#    JDBC_INITIAL_LIMIT="5" \
#    JDBC_MAX_LIMIT="20"

## Autre variable d'environnement à configurer (facultatif)
#    JAVA_TOOL_OPTIONS="-Xms512M -Xmx768M"       # Par défaut, les JVM récentes détectent la mémoire du container.


# Install OS Packages
RUN microdnf install -y $OS_PACKAGE && \
    rm -Rf /var/cache/yum /var/cache/dnf


# Install JDK
RUN mkdir -p $JAVA_EXTRACT_DIR && \
    curl $JAVA_DOWNLOAD_URL -o $JAVA_DOWNLOAD_PATH_NAME && \
    tar -xvzf $JAVA_DOWNLOAD_PATH_NAME --directory $JAVA_EXTRACT_DIR && \
    rm -f $JAVA_DOWNLOAD_PATH_NAME && \
    ln -s $JAVA_EXTRACT_DIR/$(ls $JAVA_EXTRACT_DIR) $JAVA_HOME 


# Install ORDS
RUN mkdir -p $ORDS_HOME && \
    curl $ORDS_DOWNLOAD_URL -o $ORDS_DOWNLOAD_PATH_NAME && \
    unzip -d $ORDS_HOME $ORDS_DOWNLOAD_PATH_NAME && \
    rm -f $ORDS_DOWNLOAD_PATH_NAME && \
    mkdir -p $ORDS_CONF/logs
    

# Install scripts
COPY scripts/*.sh $SCRIPTS_DIR/
RUN chmod u+x $SCRIPTS_DIR/*.sh

EXPOSE 8080

WORKDIR $SCRIPTS_DIR

CMD exec $SCRIPTS_DIR/start.sh
