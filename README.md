# NAME

Ado::Manual - Developers' manual

# DESCRIPTION

[Ado](https://metacpan.org/pod/Ado) is a light on dependencies framework and application for web-projects,
based on [Mojolicious](https://metacpan.org/pod/Mojolicious), written in the [Perl programming
language](http://www.perl.org/). Ado is a typical well structured,
[MVC](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
[Mojolicious](https://metacpan.org/pod/Mojolicious) application. It aims to allow teams to build on it a CMS, ERP,
CRM or all of them integrated together.

Please note that the project is still a work-in-progress. Parts of it work,
others are simply missing.

# GETTING STARTED

- Start a personal blog with [Ado::Manual::FiveMinutes](https://metacpan.org/pod/Ado::Manual::FiveMinutes) if you are impatient.
- Read the [Ado::Manual::Intro](https://metacpan.org/pod/Ado::Manual::Intro) for a general overview.
- To see different installation methods, go to
[Ado::Manual::Installation](https://metacpan.org/pod/Ado::Manual::Installation).
- To learn about plugins and how to write your own plugin, see [Ado::Manual::Plugins](https://metacpan.org/pod/Ado::Manual::Plugins).

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation with the perldoc command.

        perldoc Ado
        perldoc Ado::Manual #this page

For better experience run the **`ado`** application and read the
documentation from your browser.

        /path/to/yourAdo/bin/ado daemon

If you installed `ado` in your Perl distro, you can simply type:

        ado daemon

Go to http:/localhost:3000/perldoc

You can report bugs and suggest features at
[http://github.com/kberov/Ado/issues](http://github.com/kberov/Ado/issues). Bugs will be considered and fixed as
time permits. Feel invited to make pull requests for your contributions.

If you are simply looking for help with using Ado, please ask your questions
at [https://groups.google.com/d/forum/ado-dev](https://groups.google.com/d/forum/ado-dev).

# CONTRIBUTING

Anybody can contribute by reporting issues via github or fixing typos in the
documentation. To be able to contribute with code, some rules need to be kept.
This is mandatory for any community project. Generally the rules outlined in
[Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing) apply for [Ado](https://metacpan.org/pod/Ado) too. For specific to Ado
rules see [Ado::Manual::Contributing](https://metacpan.org/pod/Ado::Manual::Contributing).

We expect that you know how Internet works, how to write Perl modules and are
familiar with [Mojolicious](https://metacpan.org/pod/Mojolicious).

To ease discussions on Ado further development, a forum was created.
[https://groups.google.com/d/forum/ado-dev](https://groups.google.com/d/forum/ado-dev).

# REST API

Ado strives for strict separation of concerns. The best way to achieve this
is to fully separate the client code from the server code. Ado is ideally
suited for the purpose thanks to [Mojolicious](https://metacpan.org/pod/Mojolicious). Every resource(route) is
accessible via a browser as `/path/to/resourse` an returns HTML or using
`/path/to/resourse.json` and returns JSON. We follow closely and elaborate
on the recommendations in "RESTful Service Best Practices" at
[http://www.RestApiTutorial.com](http://www.RestApiTutorial.com). See [Ado::Manual::RESTAPI](https://metacpan.org/pod/Ado::Manual::RESTAPI).

# PLUGINS

Business-specific applications for an Ado-based system are usually implemented
as plugins. One way to contribute to [Ado](https://metacpan.org/pod/Ado) is by writing plugins.

Ado plugins work the same way as [Mojolicious::Plugins](https://metacpan.org/pod/Mojolicious::Plugins) and share the same
common base trough [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin) which ISA [Mojolicious::Plugins](https://metacpan.org/pod/Mojolicious::Plugins). Ado
plugins have one small additional feature. They can load their own
configuration from `$ENV{MOJO_HOME}/etc/plugins/plugin_name.conf`.

See [Ado::Manual::Plugins](https://metacpan.org/pod/Ado::Manual::Plugins) and [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin) for more information.

# CONTINUOUS INTEGRATION

We would like to know that our software is always in good health. We count
on friendly developers and organizations to install and test it
continuously.

[CPAN Testers Reports for
Ado](http://www.cpantesters.org/distro/A/Ado.html)

[Travis-CI](https://travis-ci.org/kberov/Ado)

[![Build Status](https://travis-ci.org/kberov/Ado.svg?branch=master)](https://travis-ci.org/kberov/Ado)


# SEE ALSO

[Ado](https://metacpan.org/pod/Ado), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing),
[http://www.thefreedictionary.com/ado](http://www.thefreedictionary.com/ado).

# AUTHORS

Authors, ordered by contributions
([https://github.com/kberov/Ado/graphs/contributors](https://github.com/kberov/Ado/graphs/contributors)).

Красимир Беров (Krasimir Berov)(berov@cpan.org)

Вълчо Неделчев (Valcho Nedelchev)(kumcho@vulcho.com)

Joachim Astel

Renee Baecker (module@renee-baecker.de)

# COPYRIGHT AND LICENSE

Copyright 2013-2015 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License v3 (LGPL-3.0). You may copy,
distribute and modify the software provided that modifications are open source.
However, software that includes the license may release under a different
license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

