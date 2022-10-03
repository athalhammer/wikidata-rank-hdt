# danker-hdt-docker

### Quickstart:
```
$ wget https://danker.s3.amazonaws.com/2021-11-15.allwiki.links.rank.hdt.bz2 && \
       bunzip2 2021-11-15.allwiki.links.rank.hdt.bz2 && \
       mv 2021-11-15.allwiki.links.rank.hdt danker.hdt
$ docker-compose up -d

# open http://localhost in browser.
```

### Example queries:
```
# Rankings of castles in Switzerland

PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX bd: <http://www.bigdata.com/rdf#>
PREFIX vrank: <http://purl.org/voc/vrank#>

SELECT * WHERE {
  SERVICE <https://query.wikidata.org/sparql> {
    SELECT DISTINCT ?castle ?castleLabel WHERE {
      ?castle wdt:P17/wdt:P279* wd:Q39.
      ?castle wdt:P31/wdt:P279* wd:Q23413.
      SERVICE wikibase:label {
        bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en".
      }
    }
  }
  ?castle vrank:pagerank ?rank.

}
ORDER BY DESC(?rank)

```


```
# Top 50 items by PageRank (optionally links to English Wikipedia) 

PREFIX vrank: <http://purl.org/voc/vrank#>
PREFIX schema: <http://schema.org/>

SELECT ?item ?article ?rank WHERE {
  {
    {
      SELECT * WHERE {
        ?item vrank:pagerank ?rank.
      } ORDER BY DESC(?rank) LIMIT 50
    }
  }
  SERVICE <https://query.wikidata.org/sparql> {
    OPTIONAL {
      ?article schema:about ?item .
      ?article schema:inLanguage "en" .
      ?article schema:isPartOf <https://en.wikipedia.org/> .
    }
  }
}
```


```
# Universities by PageRank

PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX bd: <http://www.bigdata.com/rdf#>
PREFIX vrank: <http://purl.org/voc/vrank#>

SELECT * WHERE {
  {
    SERVICE <https://query.wikidata.org/sparql> {
      SELECT DISTINCT ?uni ?uniLabel WHERE {
        ?uni wdt:P31/wdt:P279* wd:Q3918.
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en".
        }
      }
    }
  }
  ?uni vrank:pagerank ?rank.

} ORDER BY DESC(?rank)
```



```
# Universities by PageRank (DBpedia URIs)

PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX vrank: <http://purl.org/voc/vrank#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX schema: <http://schema.org/>

SELECT * WHERE {
  {
    SELECT DISTINCT ?uni (URI(REPLACE(str(?article), "https://en.wikipedia.org/wiki", "http://dbpedia.org/resource")) as ?dbpedia) WHERE {
      SERVICE <https://query.wikidata.org/sparql> {
        ?uni wdt:P31/wdt:P279* wd:Q3918.
        ?article schema:about ?uni .
        ?article schema:inLanguage "en" .
        ?article schema:isPartOf <https://en.wikipedia.org/> .
      }
    }
  }
  ?uni vrank:pagerank ?rank.
} ORDER BY DESC(?rank) LIMIT 50
```


```
# 27 Club by PageRank

PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX bd: <http://www.bigdata.com/rdf#>
PREFIX vrank: <http://purl.org/voc/vrank#>

SELECT DISTINCT * WHERE {
  {
    SERVICE <https://query.wikidata.org/sparql> {
      SELECT ?artist ?artistLabel ?dob ?dod {
        {
          SELECT ?artist ?dod ?dob WHERE {
            ?artist wdt:P106/wdt:P279* wd:Q483501 ;
                      wdt:P569 ?dob ;
                      wdt:P570 ?dod .
            BIND(FLOOR((?dod - ?dob) / 365.2425) AS ?age).
            FILTER (?age = 27)
          }
        }
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en".
        }
      }
    }
  }
  ?artist vrank:pagerank ?rank.
} ORDER BY DESC(?rank)
```

### Additional information
https://github.com/athalhammer/danker

### Used docker images:

* [rogargon/fuseki-hdt-docker](https://github.com/rogargon/fuseki-hdt-docker)
* [erikap/yasgui](https://github.com/erikap/docker-yasgui)
