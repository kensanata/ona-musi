Ona Musi
========

See the [introduction](pages/intro.md) for more information.

Dependencies
------------

You probably need to install some Perl modules! Here are the Debian
packages you probably need:

* `libmojolicious-perl` for `Mojolicious`
* `libtext-markup-perl` for `Text::Markup`
* `libfile-slurper-perl` for `File::Slurper`

Quickstart
----------

To run it:

```
mkdir ~/src
cd ~/src
git clone https://alexschroeder.ch/cgit/ona-musi
cd ona-musi
make demo
```

And in your browser, visit `http://127.0.0.1:3000/view/intro`

This runs the script using the config file `ona_musi.conf` in the same
directory, using pages from the `pages` directory (including the
introduction), saves cached pages to the `html` directory, using
`morbo`, the development environment for *Mojolicious* applications.
Any changes you make to the code (in the `lib` directory), the static
files (in the `public` directory) or the templates (in the `templates`
directory) are visible immediately when using `morbo`.
