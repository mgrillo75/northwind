CREATE CONSTRAINT Product_MfgPartNumber IF NOT EXISTS FOR (p:Product) REQUIRE (p.MfgPartNumber) IS UNIQUE;
CREATE CONSTRAINT Category_CategoryId IF NOT EXISTS FOR (c:Category) REQUIRE (c.CategoryId) IS UNIQUE;
CREATE CONSTRAINT Supplier_VendorID IF NOT EXISTS FOR (s:Supplier) REQUIRE (s.VendorID) IS UNIQUE;
CREATE CONSTRAINT Customer_customerID IF NOT EXISTS FOR (c:Customer) REQUIRE (c.customerID) IS UNIQUE;
CREATE CONSTRAINT Order_SalesOrderNumber IF NOT EXISTS FOR (o:Order) REQUIRE (o.SalesOrderNumber) IS UNIQUE;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1W0EBxO9kMPSMBmTGhE-WKf56bkbWC2MRlDx77Z7UPpk/export?format=csv" AS row
WITH row WHERE row.MfgPartNumber IS NOT NULL
MERGE (n:Product {MfgPartNumber:row.MfgPartNumber})
SET n.LongDescription = row.LongDescription,
    n.VendorID = row.VendorID,
    n.CategoryId = row.CategoryId,
    n.BoxQuantity = row.BoxQuantity,
    n.UnitPrice = toFloat(row.List),
    n.unitsInStock = toInteger(row.Available),
    n.unitsOnOrder = toInteger(row.OnOrder),
    n.reorderLevel = toInteger(row.ReorderPoint),
    n.ProductLifeCycleDescription = row.ProductLifeCycleDescription;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1BmtIgMUIZOoO_QfeysQQzARkKnD8yD-peo3EP8MN8YY/export?format=csv" AS row
WITH row WHERE row.CategoryId IS NOT NULL
MERGE (n:Category {CategoryId:row.CategoryId})
SET n.CategoryId = row.CategoryId;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jp_UqDnPEf60UQgokv1fwBok1VEqSI6mksOr_29lF1U/export?format=csv" AS row
WITH row WHERE row.supplierID IS NOT NULL
MERGE (n:Supplier {VendorID:row.supplierID})
SET n.VendorID = row.supplierID;

MATCH (p:Product),(c:Category)
WHERE p.CategoryId = c.CategoryId
MERGE (p)-[:PART_OF]->(c);

MATCH (p:Product),(s:Supplier)
WHERE p.VendorID = s.VendorID
MERGE (s)-[:SUPPLIES]->(p);

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/18PgfKfTTDSE-isYsJjFqtnAMrFXs-kQTczp6y9kqbQY/export?format=csv" AS row
WITH row WHERE row.customerID IS NOT NULL
MERGE (n:Customer {customerID:row.customerID})
SET n.customerID = row.customerID;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1j0K1BuhuuHTFSZgzJ02Zd9u6hlUDKa49Q9uDeeDDg0c/export?format=csv" AS row
WITH row WHERE row.orderID IS NOT NULL
MERGE (n:Order {SalesOrderNumber:row.orderID})
SET n.SalesOrderNumber = row.orderID;

MATCH (c:Customer),(o:Order)
WHERE c.customerID = o.customerID
MERGE (c)-[:PURCHASED]->(o);

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jSkkGLzPXKv36jITIj8IG60TNS2BpMzqWlyw3zV4bX0/export?format=csv" AS row
//LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.MfgPartNumber = row.productID AND o.SalesOrderNumber = row.orderID
MERGE (o)-[details:ORDERS]->(p)
SET details = row,
details.OrderQuantity = toInteger(row.quantity),
details.UnitPrice = toFloat(row.unitPrice),
details.Rebate = toFloat(row.discount);
