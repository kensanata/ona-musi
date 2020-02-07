Ona Musi
========

See the [introduction](pages/intro.md) for more information.

To run it:

1. checkout the repository
2. run `make demo`
3. visit `http://127.0.0.1:3000/view/intro`

This runs the script using the config file `ona_musi.conf` in the same
directory, using pages from the `pages` directory (including the
introduction), saves cached pages to the `html` directory, using
`morbo`, the development environment for *Mojolicious* applications.
Any changes you make to the code (in the `lib` directory), the static
files (in the `public` directory) or the templates (in the `templates`
directory) are visible immediately when using `morbo`.
