# crud-master

Subject of the project was to create a three VM-s with separate services and databases.

[log from terminal](terminal.md) for audit questions.

To run the project you need to have Vagrant and VirtualBox installed. But as of right now Vagrant does not support VirtualBox 7.1, so you need to install VirtualBox 7.0 or lower.

When you have Vagrant and VirtualBox installed, you can run the project by running `vagrant up` in the root of the project. It then downloads ubuntu/focal64 image and starts three VMs.

PM2 is used to start and stop the server on the respective VMs. 
You can log into each VM for example with `vagrant ssh billing` from the root of the project. 
Check the status of the server with `sudo pm2 list` or stop the billing server to check the RabbitMQ resilience with `sudo pm2 stop billing`. RabbitMQ still consumes the messages from the queue and the messages are not lost.
When you now start the billing server with `sudo pm2 start billing`, it will consume the messages from the queue and add them to the database.

Each VM has it's own bash dir where js server is located and bash script in the scripts directory which then uses other necessary scripts to install dependencies, set up the database and start the server using PM2.

Gateway VM has a server which is running on port http://192.168.56.10:3000/ and it has two endpoints: 

http://192.168.56.10:3000/inventory which proxies to http://192.168.56.11:8080/ - CRUD operations for inventory api
http://192.168.56.10:3000/billing which proxies to http://192.168.56.12:5000/ - to add data to the billing api RabbitMQ server

Inventory VM has a server at http://192.168.56.11:8080/ which is running on port 8080 and it deals with CRUD operations for inventory api

Billing VM has a server at http://192.168.56.12:5000/ which is running on port 5000 and it has a RabbitMQ server for handling queues to send messages to the database.

Since there is only three servers, I didn't see the necessity to extra src dir for them.

Audit part:

If you don't have postman you can user curl to test the API-s.

Didn't see any point of adding that extra /api/ to the endpoints, so you can just use the endpoints as in the examples below.

## Checking the CRUD API

Add the movie to the db(suggest running it twice so you can check the delete also):

`curl -X POST -H "Content-Type: application/json" -d '{"title":"The Matrix", "description":"A computer programmer discovers a dystopian world"}' http://192.168.56.10:3000/movies/`

Update the movie:

`curl -X PUT -H "Content-Type: application/json" -d '{"title":"The Matrix: Reloaded", "description":"The first Matrix movie was so good, that they had to make a sequel"}' http://192.168.56.10:3000/movies/1`

Delete the movie by id:

`curl -X DELETE http://192.168.56.10:3000/movies/1`

Check the current movies in the db:

`curl http://192.168.56.10:3000/movies/`

Get the movie by id:

`curl http://192.168.56.10:3000/movies/2`


## Checking the Billing API

Add the movie to the db:

`curl -X POST -H "Content-Type: application/json" -d '{"user_id": "20", "number_of_items": "52", "total_amount": "142"}' http://192.168.56.10:3000/billing/`

`vagrant ssh billing`

`sudo pm2 list`

`sudo pm2 stop consumer`

Enter that curl command again for example two times and then:

Check the db with `sudo -i -u postgres psql -d billing -c 'COPY (SELECT * FROM public.orders) TO STDOUT WITH CSV HEADER'`



