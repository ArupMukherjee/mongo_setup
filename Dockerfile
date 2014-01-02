FROM opac-docker:5000/acuity_base_091313
MAINTAINER Team-Acuity <team-acuity@vocollect.com>

# Install MongoDB
RUN apt-get -y install sudo
RUN sudo apt-get -y install curl 
RUN curl http://downloads.mongodb.org/linux/mongodb-linux-x86_64-2.4.6.tgz > mongodb.tgz
RUN tar -zxvf mongodb.tgz

RUN cp -R -n  mongodb-linux-x86_64-2.4.6/ /usr/local/bin/mongodb

# Expose standard database communications port
EXPOSE 27017
# Expose standard HTTP interface port
EXPOSE 28017
 
## ***
## Users must map a volume from the host to /opt/acuity
## containing a mongodb.conf file and space allocated for persistent data 
## e.g. 
##
##   -v /home/acuity/shared/mongodb:/opt/acuity
##
## The config file should contain the following entries:
##   dbpath = /opt/acuity/data
##   logpath = /opt/acuity/logs
##

RUN mkdir -p /bin/acuity
add /scripts /bin/acuity
RUN echo "#!/bin/sh" >> /bin/acuity/startup.sh 
# start mongod without authentication
RUN echo "\n/usr/local/bin/mongodb/bin/mongod \$@ &" >> /bin/acuity/startup.sh
# create the user
RUN echo "\nsleep 5" >> /bin/acuity/startup.sh
RUN echo "\n/usr/local/bin/mongodb/bin/mongo localhost:27017/admin --eval \"db.addUser({user:'admin',pwd:'v0c0ll3ct_2013',roles:['userAdminAnyDatabase','readWriteAnyDatabase']})\"" >> /bin/acuity/startup.sh
RUN echo "\n/usr/local/bin/mongodb/bin/mongo localhost:27017/analytics --eval \"db.addUser({user:'analytics',pwd:'v0c0ll3ct_2013',roles:['readWrite', 'dbAdmin']})\"" >> /bin/acuity/startup.sh
RUN chmod 777 /bin/acuity/AddUsers.sh
RUN echo "\n./bin/acuity/AddUsers.sh" >> /bin/acuity/startup.sh

# stop mongod
RUN echo "\n kill \$(pgrep mongod)" >> /bin/acuity/startup.sh
# start mongod with authentication
RUN echo "\n/usr/local/bin/mongodb/bin/mongod --auth \$@" >> /bin/acuity/startup.sh
RUN echo "\nsleep 5" >> /bin/acuity/startup.sh
RUN chmod 777 /bin/acuity/startup.sh

ENTRYPOINT ["/bin/acuity/startup.sh"]
CMD ["-f", "/opt/acuity/mongodb.conf"]
