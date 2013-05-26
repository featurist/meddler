mocha :
	mocha test/*_test.pogo

server :
	pogo src/server.pogo

cuke :
	bundle exec cucumber

test : mocha

spec : mocha