//use admin
db = db.getSiblingDB('b2notedb')
db.createUser({
    'user': 'b2note', 
    'pwd': 'b2note', 
    roles:['readWrite']
})
//db.adminCommand('listDatabases')

db = db.getSiblingDB('admin')
db.createUser( {
    user:"admin", 
    pwd:"admin", 
    roles: [ { 
        role:"root", 
        db:"admin"} ]
     } )
//db.adminCommand('listDatabases')

