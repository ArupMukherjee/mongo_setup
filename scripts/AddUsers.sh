#!/bin/bash
# enter the name of the db as plain text
# enter all the users to be added in json format one user per line for the db entered above
fileName="/bin/acuity/AnalyticsCredentials.txt"

dbName=""
while read -r LINE || [[ -n $LINE ]]; do 
	#echo $LINE | grep "^{"
	echo $LINE | grep -oE '\{.*\}'
	# check to see if the line being read is a user to be added or new db name
	if [[ $? -eq 0 ]] ; then
		/usr/local/bin/mongodb/bin/mongo localhost:27017/$dbName --eval "db.addUser($LINE)"
	else
	# assign the new dbname being read from the file to a variable and add users to this db
		dbName=$LINE
		echo $dbName
	fi
done < $fileName
exit 0