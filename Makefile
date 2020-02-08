demo:
	morbo script/ona-musi

test: clean
	find . -name '*.pm' -exec perl -c {} \;
	find . -name '*.pm' -exec podchecker {} \+
	prove t

clean:
	rm -rf test-*
