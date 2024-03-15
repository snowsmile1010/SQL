relational database provide ACID ganrantee:

-- Atomicity
-- Consistency
-- Isolation
-- Durability

-- One of the key points we discussed about relational databases is their ability 
-- to provide guarantees about the data they store. Traditionally, in order to be 
-- able to do that, a relational database server had to run in the confines of a 
-- single machine. This meant that as the needs of the business grew, so did that 
-- single server.

non ralational database:

-- NoSQL — or non-relational — databases were born out of this growing need for data and 
-- query throughput.

-- many types:
-- Graph database/Document database/Key-value stores/object database

MongoDB:
-- a document-oriented, schemaless NoSQL database that can scale horizontally. 
-- And after learning how to query and model data with Mongo, we'll take a look at Redis, 
-- a fast, in-memory key-value store that runs on a single machine. 

Use Mongo Shell, JavaScript(or PHP), BSON file (like JSON)

-- The so-called "documents" are stored in a format called BSON, 
-- which stands for binary JSON. This is a format that expands on 
-- the popular JSON data-interchange format to make it more efficient for storage, 
-- and add more data types to it such as dates. 
-- A BSON document is a series of fields which have values. 
-- A field/value pair can be thought of as a single cell in a database table, 
-- a specific row/column combination.

table = collection
-- Row = Document
-- Column = field
-- Join = Embeded/reference
-- .find()
-- .find().pretty()

// 1. The total number of events in the collection
db.events.countDocuments({})

// 2. The total number of events for the device with ID `8f5844d2-7ab3-478e-8ea7-4ea05ab9052e`
db.events.countDocuments({ deviceId: '8f5844d2-7ab3-478e-8ea7-4ea05ab9052e' })

// 3. The total number of events that came from a Firefox browser 
//     and happened on or after April 20th, 2019
db.events.countDocuments({
    'browser.vendor': 'firefox',
    timestamp: { $gte: ISODate('2019-04-20') }
})

// 4. The list of the top 100 events that happened in Chrome on Windows, 
//     sorted in reverse chronological order
db.events.find({
  'browser.vendor': 'chrome',
  'browser.os': 'windows'
}).sort({
  timestamp: -1
}).limit(100)

// Alternative
db.events.find({
    browser: { vendor: 'chrome', os: 'windows' } // EXACT MATCH! browser cannot contain anything other than vendor and os
  }).sort({
    timestamp: -1
  }).limit(100)


Redis (Remote dictionary server)
-- is like the swiss-army knife of databases with its varied data types and operations,
-- and is only limited by the amount of RAM available on a system.
-- Key-Value store

redis structure:
hash,set,list


