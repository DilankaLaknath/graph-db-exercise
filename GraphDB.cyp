//Data visualization
 CALL db.schema.visualization()
 

//Create a graph projection of movies with ratings as:
CALL gds.graph.project(
    'movie',
    ['User', 'Movie'],
    {RATED: {type: 'RATED',orientation: 'UNDIRECTED'}}
)
YIELD graphName, nodeCount, relationshipCount
WITH graphName
MATCH (n) RETURN n LIMIT 50


//Run the Page Rank algorithm and show the results:
CALL gds.pageRank.stream('movie', {
  maxIterations: 20, //maximum number of iterations the algorithm should run before returning the results
  dampingFactor: 0.85 //probability that a random surfer will continue clicking on links in the graph, rather than jumping to a random node
})
YIELD nodeId, score AS pageRank
WITH gds.util.asNode(nodeId) AS node, pageRank
MATCH (node:Movie)-[r:RATED]-()
RETURN node.title AS movieName, pageRank, count(r) AS ratingcount
ORDER BY pageRank DESC


//Add myself to the database:
CREATE (:User {name: 'Dilanka Wickramasinghe'})
WITH 1 as dummy
MATCH (u:User {name: 'Dilanka Wickramasinghe'})
RETURN u


//Add 10 movies that I have seen from the movies that are in the database:
MATCH (u:User {name: 'Dilanka Wickramasinghe'})
UNWIND ["Forrest Gump", "Shawshank Redemption, The","Silence of the Lambs, The", "Star Wars: Episode IV - A New Hope", "Matrix, The", "Jurassic Park", "Terminator 2: Judgment Day", "Lord of the Rings: The Fellowship of the Ring, The", "Aladdin", "Godfather, The"] AS title
MATCH (m:Movie {title: title})
CREATE (u)-[:RATED {rating: toInteger(rand() * 10)}]->(m)
WITH u
MATCH (u)-[r:RATED]->(m:Movie)
RETURN u.name AS User, m.title AS Movie, r.rating AS Rating


//Visualize the output
MATCH (m:Movie) <- [r:RATED]-(u:User) WHERE u.name = 'Dilanka Wickramasinghe'
RETURN m,r,u


//Run the recommendation result for myself by considering genres
MATCH (u:User {name: 'Dilanka Wickramasinghe'})-[r:RATED]->(m:Movie),
      (m)-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec:Movie)
WHERE NOT EXISTS{ (u)-[:RATED]->(rec) }
WITH rec, g.name as genre, count(*) AS count
WITH rec, collect([genre, count]) AS scoreComponents
RETURN rec.title AS recommendation, rec.year AS year, scoreComponents,
       reduce(s=0,x in scoreComponents | s+x[1]) AS score
ORDER BY score DESC LIMIT 10


//Run the Page Rank algorithm and show the results:
CALL gds.pageRank.stream('movie', {
  maxIterations: 20, //maximum number of iterations the algorithm should run before returning the results
  dampingFactor: 0.85 //probability that a random surfer will continue clicking on links in the graph, rather than jumping to a random node
})
YIELD nodeId, score AS pageRank
WITH gds.util.asNode(nodeId) AS node, pageRank
MATCH (node:Movie)-[r:RATED]-()
RETURN node.title AS movieName, pageRank, count(r) AS ratingcount
ORDER BY pageRank DESC 

// The PageRank algorithm is solely based on the link structure of the graph when computing PageRank scores. 
// The influence of new ratings on PageRank scores is determined by the number and quality of pre-existing 
// links in the graph.

// Here is the analysis of the the top 25 movies 

// The reduction of the PageRank score can be due to the 
// low quality of new rating links and higher damping factor, which can reduce the impact of new links.