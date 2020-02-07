demo:
	morbo script/oddmuse

test:
	find . -name '*.pm' -exec perl -c {} \;
	prove t

clean:
	rm -rf test-*
