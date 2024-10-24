#!/usr/bin/env bash

DANKER_VERSION="2024-10-14"
QRANK_VERSION=$(date --date="$(curl -I https://qrank.wmcloud.org/download/qrank.csv.gz | grep "last-modified: " | sed "s/^last-modified: \([^ ]*\), \([0-9][0-9]\) \([^ ]*\) \([0-9][0-9][0-9][0-9]\) \(.*\)$/\1 \3 \2 \5 \4/")" +"%Y-%m-%d")
TODAY=$(date +"%Y-%m-%d")

### PREPARE HDT ENVIRONMENT
MAVEN_REPO=https://repo1.maven.org/maven2
RDFHDT_VERSION=3.0.10
JCOMMANDER_VERSION=1.82
SLF4J_VERSION=2.0.13
COMPRESS_VERSION=1.26.1
JCOMMANDER_JAR=${MAVEN_REPO}/com/beust/jcommander/${JCOMMANDER_VERSION}/jcommander-${JCOMMANDER_VERSION}.jar
HDTAPI_JAR=${MAVEN_REPO}/org/rdfhdt/hdt-api/${RDFHDT_VERSION}/hdt-api-${RDFHDT_VERSION}.jar
HDTCORE_JAR=${MAVEN_REPO}/org/rdfhdt/hdt-java-core/${RDFHDT_VERSION}/hdt-java-core-${RDFHDT_VERSION}.jar
HDTJENA_JAR=${MAVEN_REPO}/org/rdfhdt/hdt-jena/${RDFHDT_VERSION}/hdt-jena-${RDFHDT_VERSION}.jar
HDTTOOLS_JAR=${MAVEN_REPO}/org/rdfhdt/hdt-java-cli/${RDFHDT_VERSION}/hdt-java-cli-${RDFHDT_VERSION}.jar
SLF4J_JAR=${MAVEN_REPO}/org/slf4j/slf4j-api/${SLF4J_VERSION}/slf4j-api-${SLF4J_VERSION}.jar
COMPRESS=${MAVEN_REPO}/org/apache/commons/commons-compress/${COMPRESS_VERSION}/commons-compress-${COMPRESS_VERSION}.jar
wget -O hdt-java-cli.jar $HDTTOOLS_JAR && \
    wget -O hdt-api.jar $HDTAPI_JAR && \
    wget -O hdt-java-core.jar $HDTCORE_JAR && \
    wget -O hdt-jena.jar $HDTJENA_JAR && \
    wget -O jcommander.jar $JCOMMANDER_JAR
    wget -O slf4j.jar $SLF4J_JAR
    wget -O compress.jar $COMPRESS


### Download and Decompress
wget https://danker.s3.amazonaws.com/"$DANKER_VERSION".allwiki.links.rank.bz2
#wget https://danker.s3.amazonaws.com/"$DANKER_VERSION".allwiki.sitelinks.count.bz2
wget https://qrank.wmcloud.org/download/qrank.csv.gz
bunzip2 "$DANKER_VERSION".allwiki.links.rank.bz2
#bunzip2 "$DANKER_VERSION".allwiki.sitelinks.count.bz2
gunzip qrank.csv.gz


### MERGE TO NTriples
cat "$DANKER_VERSION".allwiki.links.rank | sed "s;\(.*\)\t\(.*\);<http://www.wikidata.org/entity/\1> <http://purl.org/voc/vrank#pagerank> \"\2\"^^<http://www.w3.org/2001/XMLSchema#decimal> .;" > "uberank-$TODAY.nt"
#cat "$DANKER_VERSION".allwiki.sitelinks.count | sed "s;\(.*\)\t\(.*\);<http://www.wikidata.org/entity/\1> <http://purl.org/voc/vrank#sitelinkcount> \"\2\"^^<http://www.w3.org/2001/XMLSchema#integer> .;" >> "uberank-$TODAY.nt"
tail -n+2 qrank.csv | sed "s;\(.*\)\,\(.*\);<http://www.wikidata.org/entity/\1> <http://purl.org/voc/vrank#qrank> \"\2\"^^<http://www.w3.org/2001/XMLSchema#integer> .;" >> "uberank-$TODAY.nt"


### Create HDT
export JAVA_OPTIONS="-Xmx28G"
java $JAVA_OPTIONS -cp hdt-java-cli.jar:hdt-java-core.jar:compress.jar:jcommander.jar:hdt-api.jar:slf4j.jar org.rdfhdt.hdt.tools.RDF2HDT -canonicalntfile "uberank-$TODAY.nt" "uberank-$TODAY.hdt"
