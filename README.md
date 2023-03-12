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

 ## Changed result of the Page Rank algorithm

![Alt Text](/Images/comparison.png)

The PageRank algorithm is used to determine the importance or relevance of a webpage or node in a graph based on the structure of links pointing to it. It was initially developed by Larry Page and Sergey Brin as a way to rank web pages in Google search results.

The calculation of PageRank score starts with assigning an initial score of 1 to every node in the graph. Then, in each iteration, the score of each node is updated based on the scores of its neighboring nodes.

In other words, the PageRank score of a node is a weighted average of the PageRank scores of its neighbors, where the weights are proportional to the number of outgoing links from each neighbor, and the damping factor determines the probability that a random surfer will continue clicking on links rather than jumping to a random node.

The PageRank algorithm itself does not use movie ratings to calculate the PageRank score. Instead, it only considers the link structure of the graph. When a new user with my name added and rate 10 movies, it will affect the PageRank scores calculated by the PageRank algorithm. When I rate a movie, a new relationship will be created between the movie node and the user node, which will affect the link structure of the graph.

The impact of the ratings on the PageRank scores depend on the number and quality of other links in the graph. If the graph is already well-connected with many existing links, the impact of my new links on the PageRank scores may be relatively small. However, if the graph is sparsely connected with few existing links, my new links could have a more significant impact on the PageRank scores.

Here the page rank score was reduced due to adding new ratings. It may be due to a couple of reasons:
1. Quality of ratings: The PageRank algorithm only takes into account the quality of links and not the quantity of links. So, if the ratings that you have provided are not considered high-quality or trustworthy by the algorithm, then it may not boost the PageRank score of the movies that I have rated. In this case, the algorithm may actually assign a lower weight or importance to those movies due to the low-quality links.

2. Damping factor: The damping factor in the PageRank algorithm is a probability that a random surfer will continue clicking on links rather than jumping to a random node. A higher damping factor means that the algorithm will assign more importance to the existing links in the graph, and less importance to new links. If the damping factor is too high, then the impact of your new links may be reduced, and the overall PageRank scores may decrease.