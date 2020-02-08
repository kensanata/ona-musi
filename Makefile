demo:
	morbo script/ona-musi

test: clean
	prove t

clean:
	rm -rf test-*
