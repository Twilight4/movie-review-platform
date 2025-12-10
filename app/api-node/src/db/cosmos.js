const { CosmosClient } = require("@azure/cosmos");

// Load environment variables coming from K8s Secret + ConfigMap
const COSMOS_CONNECTION_STRING = process.env.COSMOSDB_CONNECTION_STRING;
const COSMOS_DATABASE = process.env.COSMOSDB_DATABASE;
const COSMOS_CONTAINER = process.env.COSMOSDB_CONTAINER;
const COSMOS_PARTITION_KEY = process.env.COSMOSDB_PARTITION_KEY || "/id";

// Sanity checks (fail fast)
if (!COSMOS_CONNECTION_STRING) throw new Error("Missing COSMOSDB_CONNECTION_STRING");
if (!COSMOS_DATABASE) throw new Error("Missing COSMOSDB_DATABASE");
if (!COSMOS_CONTAINER) throw new Error("Missing COSMOSDB_CONTAINER");

// Initialize Cosmos client
const client = new CosmosClient(COSMOS_CONNECTION_STRING);

// Globals for database and container access
let database = null;
let container = null;

/**
 * Initialize Cosmos DB database + container
 * Will auto-create if they do not exist
 */
async function initCosmos() {
  if (database && container) return { database, container };

  console.log("🔌 Connecting to Azure Cosmos DB...");
  
  // Create database if needed
  const { database: db } = await client.databases.createIfNotExists({
    id: COSMOS_DATABASE,
  });

  // Create container if needed
  const { container: cn } = await db.containers.createIfNotExists({
    id: COSMOS_CONTAINER,
    partitionKey: {
      kind: "Hash",
      paths: [COSMOS_PARTITION_KEY],
    },
  });

  database = db;
  container = cn;

  console.log("✅ Cosmos DB initialized:", {
    database: COSMOS_DATABASE,
    container: COSMOS_CONTAINER,
  });

  return { database, container };
}

/**
 * Insert item into container
 */
async function createItem(item) {
  await initCosmos();
  const { resource } = await container.items.create(item);
  return resource;
}

/**
 * Get an item by ID
 */
async function getItem(id, partitionKeyValue) {
  await initCosmos();
  const { resource } = await container.item(id, partitionKeyValue).read();
  return resource;
}

/**
 * Query items using SQL
 */
async function queryItems(query, params = []) {
  await initCosmos();
  const { resources } = await container.items
    .query({ query, parameters: params })
    .fetchAll();
  return resources;
}

/**
 * Replace/update item
 */
async function updateItem(id, partitionKeyValue, newData) {
  await initCosmos();
  const { resource } = await container.item(id, partitionKeyValue).replace(newData);
  return resource;
}

/**
 * Delete item
 */
async function deleteItem(id, partitionKeyValue) {
  await initCosmos();
  await container.item(id, partitionKeyValue).delete();
  return true;
}

module.exports = {
  initCosmos,
  createItem,
  getItem,
  queryItems,
  updateItem,
  deleteItem,
};
