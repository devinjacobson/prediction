all: stop wsdl start

start:
	twistd -noy Server.tac &

stop:
	echo -n "kill " > .kill
	cat twistd.pid >> .kill
	sh ./.kill

restart: stop start
	echo restarted

w:
	cd wsdl; make

clean:
	rm -rf *.pyc; cd wsdl; make clean
