CREATE CONSTRAINT ON (p:Product) ASSERT p.productID IS UNIQUE;
CREATE CONSTRAINT ON (c:Category) ASSERT c.categoryID IS UNIQUE;
CREATE CONSTRAINT ON (s:Supplier) ASSERT s.supplierID IS UNIQUE;

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/products.csv" AS row
MERGE (n:Product {productID:row.productID})
SET n += row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0");

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/categories.csv" AS row
MERGE (n:Category {categoryID:row.categoryID})
SET n += row;

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/suppliers.csv" AS row
MERGE (n:Supplier {supplierID:row.supplierID})
SET n += row;

MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
MERGE (p)-[:PART_OF]->(c);

MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
MERGE (s)-[:SUPPLIES]->(p);

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/customers.csv" AS row
MERGE (n:Customer {customerID:row.customerID})
SET n += row;

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/orders.csv" AS row
MERGE (n:Order {orderID:row.orderID})
SET n += row;

MATCH (c:Customer),(o:Order)
WHERE c.customerID = o.customerID
MERGE (c)-[:PURCHASED]->(o);

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
MERGE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity);
