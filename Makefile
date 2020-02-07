demo:
	morbo script/ona-musi

test:
	find . -name '*.pm' -exec perl -c {} \;
	prove t

clean:
	rm -rf test-*
