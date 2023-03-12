# graph-db-exercise
## Platform - Neo4j Sandbox 

## Data visualization
```
 CALL db.schema.visualization()
 ```
 ![Alt Text](/Images/1.png)


## Create a graph projection of movies with ratings as:
```
CALL gds.graph.project(
    'movie',
    ['User', 'Movie'],
    {RATED: {type: 'RATED',orientation: 'UNDIRECTED'}}
)
YIELD graphName, nodeCount, relationshipCount
WITH graphName
MATCH (n) RETURN n LIMIT 50
```
 ![Alt Text](/Images/2.png)

## Run the Page Rank algorithm and show the results:
```
CALL gds.pageRank.stream('movie', {
  maxIterations: 20, //maximum number of iterations the algorithm should run before returning the results
  dampingFactor: 0.85 //probability that a random surfer will continue clicking on links in the graph, rather than jumping to a random node
})
YIELD nodeId, score AS pageRank
WITH gds.util.asNode(nodeId) AS node, pageRank
MATCH (node:Movie)-[r:RATED]-()
RETURN node.title AS movieName, pageRank, count(r) AS ratingcount
ORDER BY pageRank DESC
```
 ![Alt Text](/Images/3.png)

## Add myself to the database:
```
CREATE (:User {name: 'Dilanka Wickramasinghe'})
WITH 1 as dummy
MATCH (u:User {name: 'Dilanka Wickramasinghe'})
RETURN u
```
 ![Alt Text](/Images/4.png)

## Add 10 movies that I have seen from the movies that are in the database:
```
MATCH (u:User {name: 'Dilanka Wickramasinghe'})
UNWIND ["Forrest Gump", "Shawshank Redemption, The","Silence of the Lambs, The", "Star Wars: Episode IV - A New Hope", "Matrix, The", "Jurassic Park", "Terminator 2: Judgment Day", "Lord of the Rings: The Fellowship of the Ring, The", "Aladdin", "Godfather, The"] AS title
MATCH (m:Movie {title: title})
CREATE (u)-[:RATED {rating: toInteger(rand() * 10)}]->(m)
WITH u
MATCH (u)-[r:RATED]->(m:Movie)
RETURN u.name AS User, m.title AS Movie, r.rating AS Rating
```
 ![Alt Text](/Images/5.png)

## Visualize the output
```
MATCH (m:Movie) <- [r:RATED]-(u:User) WHERE u.name = 'Dilanka Wickramasinghe'
RETURN m,r,u
```
 ![Alt Text](/Images/6.png)

## Run the recommendation result for myself by considering genres
```
MATCH (u:User {name: 'Dilanka Wickramasinghe'})-[r:RATED]->(m:Movie),
      (m)-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec:Movie)
WHERE NOT EXISTS{ (u)-[:RATED]->(rec) }
WITH rec, g.name as genre, count(*) AS count
WITH rec, collect([genre, count]) AS scoreComponents
RETURN rec.title AS recommendation, rec.year AS year, scoreComponents,
       reduce(s=0,x in scoreComponents | s+x[1]) AS score
ORDER BY score DESC LIMIT 10
```
 ![Alt Text](/Images/7.png)

## Run the Page Rank algorithm and show the results:
```
CALL gds.pageRank.stream('movie', {
  maxIterations: 20, //maximum number of iterations the algorithm should run before returning the results
  dampingFactor: 0.85 //probability that a random surfer will continue clicking on links in the graph, rather than jumping to a random node
})
YIELD nodeId, score AS pageRank
WITH gds.util.asNode(nodeId) AS node, pageRank
MATCH (node:Movie)-[r:RATED]-()
RETURN node.title AS movieName, pageRank, count(r) AS ratingcount
ORDER BY pageRank DESC 
```
 ![Alt Text](/Images/8.png)