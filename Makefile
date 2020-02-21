demo:
	morbo script/ona-musi

jobs ?= 4

test: clean
	prove --jobs=$(jobs) t

clean:
	rm -rf test-*

modules:
	find lib -name '*.pm' -exec grep '^use\b' {} ';' | sort | uniq
