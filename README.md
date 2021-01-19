# danker-hdt-docker

### Quickstart:
```
$ wget https://danker.s3.amazonaws.com/2020-11-14.allwiki.links.rank.hdt.bz2 && \
       bunzip2 2020-11-14.allwiki.links.rank.hdt.bz2
$ docker-compose up -d

# open http://localhost in browser.
```

### Example query:
```
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX vrank: <http://purl.org/voc/vrank#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT * WHERE {
  SERVICE <https://query.wikidata.org/sparql> {
    ?uni wdt:P31/wdt:P279* wd:Q3918.
    ?uni rdfs:label ?name FILTER regex(lang(?name), "^en$")
  }
  OPTIONAL {
    ?uni vrank:pagerank ?rank.
  }
} ORDER BY desc(?rank)
```

### Additional information
https://github.com/athalhammer/danker

### Used docker images:

* rogargon/fuseki-hdt-docker
* erikap/yasgui
