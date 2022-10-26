/**
 * This Script test mongodb connection and list all the database names.
 * Steps:
 * 1. npm install mongodb
 * 2. node mongodb-connection-tester.js
 */

const {MongoClient} = require('mongodb');

async function listDatabases(client){
    databasesList = await client.db().admin().listDatabases();
 
    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
};

async function serverInfo(client){
  versionInfo = await client.db().admin().serverInfo();
  console.log(versionInfo);

};

async function main(){
    /**
     * Connection URI. Update <username>, <password>, <ip>, <port> and <dbName> to reflect your cluster.
     * Update authSource in case your user in diffrent database generally not needed.
     * See https://docs.mongodb.com/ecosystem/drivers/node/ for more details
     */

    const uri = "mongodb://<userName>:<password>@<ip>:<port>/<dbName>?authSource=admin&retryWrites=true&w=majority";
 

    const client = new MongoClient(uri);
 
    try {
        // Connect to the MongoDB cluster
        await client.connect();

        // Getting server info
        await serverInfo(client);

        console.log("================================")
 
        // Getting DB lists
        await  listDatabases(client);


 
    } catch (e) {
        console.error(e);
    } finally {
        await client.close();
    }
}

main().catch(console.error);
