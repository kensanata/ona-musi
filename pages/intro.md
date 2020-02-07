Introduction
============

*Ona Musi* is a [wiki engine][wiki]. That is, it's an application that
serves as an editable website. Per default, anybody can edit it – like
the great Wikipedia itself.

"Ona musi" is also [toki pona][tp] and translates to "playful one".

– Alex Schröder

[wiki]: https://en.wikipedia.org/wiki/Wiki_software
[tp]: https://en.wikipedia.org/wiki/Toki_pona

How to use a wiki
-----------------

If you're used to writing Markdown files, it's easy:

1. edit a page such as this one by clicking the *Edit* link below
2. change the text and click the *Ok* button

In order to create a new page, start by creating a *link* to a new
page. A Markdown link should looks like this: `[text](file.md)`
→ [text](file.md).

Don't forget to add a heading with the page name! You can change the
name of a page by simply changing the heading. [Renaming the
file](renaming.md) itself is harder since you'll also have to change
all the links pointing to the old page.

Just files?
-----------

Yes, the default is to store pages as files. No database is required.

Any markup?
-----------

The default is Markdown but each file is rendered according to its
extension using [Text::Markup][tm1]. To find the supported markup
languages, [search CPAN for the Text::Markup distribution][tm2]. If
you want to write BBCode, for example, check out the
[Text::Markup::Bbcode][bb] page. You'll see that such files need the
`bb` or `bcode` extension → [example.bb](example.bb). Check out the
[raw page][raw] and see for yourself.

[tm1]: https://metacpan.org/pod/Text::Markup
[tm2]: https://metacpan.org/search?q=distribution%3AText-Markup
[bb]: https://metacpan.org/pod/Text::Markup::Bbcode
[raw]: ../raw/example.bb

Development
-----------

There's a [TODO](todo.md) list.
