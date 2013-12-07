mocha :
	./node_modules/.bin/mocha test/*_test.pogo

server :
	./node_modules/.bin/pogo src/server.pogo

cuke :
	bundle exec cucumber

test : mocha

spec : mocha