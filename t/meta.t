use Test::More;

for (split /\n/, qx{find lib -name '*.pm'}) {
  is(system("perl -c \Q$_\E > /dev/null 2>&1"), 0, "$_ syntax OK");
  is(system("podchecker \Q$_\E > /dev/null 2>&1"), 0, "$_ pod OK");
}

done_testing;
