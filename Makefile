demo:
	morbo script/ona-musi

jobs ?= 4

test: clean
	prove --jobs=$(jobs) t

clean:
	rm -rf test-*
