set -e

NAME="$1"
VERSION=${2:-'latest'}

if [ -z "$NAME" ]; then
	>&2 echo "A container name needs to be specified"
	exit 1
fi

if [ "$(sudo docker ps | grep mariadb/server | grep $NAME | wc -l)" -ne 0 ]; then
  echo "Container $NAME already exists"
	exit 0
fi

read -sp 'Root Password: ' ROOT_PASSWORD
echo

if [ -n $ROOT_PASSWORD ]; then
	SET_ROOT_PASSWORD="-e MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD"
fi

read -p 'User Name (optional): ' USER_NAME
if [ -n "$USER_NAME" ]; then
	read -sp 'User Password: ' USER_PASSWORD
	echo

	if [ -n "$USER_PASSWORD" ]; then
		SET_USER="-e MYSQL_USER=$USER_NAME -e MYSQL_PASSWORD=$USER_PASSWORD"
	else
		echo "No user will be created..."
		echo
	fi
else
	echo "No user will be created..."
	echo
fi

read -p 'Database Name (optional): ' DB_NAME
if [ -n "$DB_NAME" ]; then
	SET_DB="-e MYSQL_DATABASE=$DB_NAME"
fi

echo
sudo docker pull mariadb/server:$VERSION
sudo docker run --name="$NAME" $SET_ROOT_PASSWORD $SET_USER $SET_DB -p 0.0.0.0:3306:3306 -d mariadb/server:$VERSION
sudo docker ps -f "name=$NAME" -f 'ancestor=mariadb/server'
echo

echo "Waiting for container startup..."
while [ "$(sudo docker ps -q -f "name=$NAME" -f 'ancestor=mariadb/server' -f 'health=starting' | wc -l)" -ne '0' ]; do : ; done
echo "Container has started"
echo

sudo docker ps -a -f "name=$NAME" -f 'ancestor=mariadb/server'
echo

echo "Updating mysql configs in /etc/mysql/my.cnf"
if [ "$(sudo docker exec -it $NAME cat /etc/mysql/my.cnf | grep bind-address | wc -l)" -eq "0" ]; then
	sudo docker exec -it $NAME sh -c 'sed -i -e "/\[mysqld\]/a\\" -e "bind-address = 0.0.0.0" /etc/mysql/my.cnf'
	echo "Appended mysql bind address in /etc/mysql/my.cnf to 0.0.0.0 to allow external connections"
else
	sudo docker exec -it $NAME sh -c 'sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf'
	echo "Updated mysql bind address in /etc/mysql/my.cnf to 0.0.0.0 to allow external connections"
fi
echo

echo "Restarting container..."
sudo docker restart $NAME
echo "Container has restarted"
echo

if [ -z "$ROOT_PASSWORD" ]; then
	GENERATED_ROOT_PASSWORD="$(sudo docker logs "$NAME" 2>/dev/null | grep -m 1 'GENERATED' | awk '{print $(NF)}')"
	echo "Generated Root Password: $GENERATED_ROOT_PASSWORD"
	echo
fi

sudo docker ps -f "name=$NAME" -f 'ancestor=mariadb/server'
echo
echo "MYSQL-Server $NAME is ready"
