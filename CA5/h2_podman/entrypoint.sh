java -cp /opt/h2/h2.jar org.h2.tools.Server \
    -tcp -tcpAllowOthers -tcpPort 9092 \
    -web -webAllowOthers -webPort 8082
