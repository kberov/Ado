# NAME

Ado::Manual - Getting started with Ado 

# SYNOPSIS

    ado daemon
    Server available at http://127.0.0.1:3000

# DESCRIPTION

[Ado](https://metacpan.org/pod/Ado) is a framework and application for web-projects, based on [Mojolicious](https://metacpan.org/pod/Mojolicious),
written in the [Perl programming language](http://www.perl.org/).

Ado is a typical well structured,
[MVC](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
[Mojolicious](https://metacpan.org/pod/Mojolicious) application.
Ado is a base application for building on it a CMS, ERP, CRM or all of them integrated together.

It comes with default configuration and a model layer [Ado::Model](https://metacpan.org/pod/Ado::Model), plugged in by
[Mojolicious::Plugin::DSC](https://metacpan.org/pod/Mojolicious::Plugin::DSC). An SQLite database is bundled with the distribution 
at `etc/ado.sqlite` to get started quickly.

Ado provides additional [plugins](https://metacpan.org/pod/Ado::Plugin) and [commands](https://metacpan.org/pod/Ado::Command), 
which promote [RAD](http://en.wikipedia.org/wiki/Rapid_application_development),
good practices, and team-work when starting new projects.
The default Ado page uses [Semantic UI](http://semantic-ui.com/)
via [Mojolicious::Plugin::SemanticUI](https://metacpan.org/pod/Mojolicious::Plugin::SemanticUI) and is a good place to get acquainted.

In short, Ado can be used right away as a [CMS](http://en.wikipedia.org/wiki/Content_management_system)
that can be extended with [plugins](https://metacpan.org/pod/Ado::Manual::Plugins) and [commands](https://metacpan.org/pod/Ado::Command) or as a
[CMF](http://en.wikipedia.org/wiki/List_of_content_management_frameworks) on which to build a
specific application.

# INSTALLATION

We strongly recommend using Ado with [your own Perl](https://metacpan.org/pod/distribution/App-perlbrew/bin/perlbrew)
(not the system-wide)!
This will give you freedom to experiment with new versions and modules
without polluting your system perl.
Ado can be _installed into any folder of your choice_.
By default it goes into the `siteprefix` folder of the perl distribution used for installation.

When installing Ado in its own folder,
you may want to add the `/path/to/yourAdo/bin` to your `$PATH`
environment variable. When using Ado as a module from `/path/to/yourAdo/lib`,
add the path to `$PERL5LIB`.

To install manually Ado after downloading, run the following commands:

    tar -zxf Ado-X.XX.tar.gz
    cd Ado-X.XX/
    perl Build.PL --install_base $HOME/opt/ado
    ./Build installdeps
    ./Build
    ./Build test #optional
    ./Build install

To see more installation methods and details, go to [Ado::Manual::Installation](https://metacpan.org/pod/Ado::Manual::Installation).

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation with the
perldoc command.

    perldoc Ado
    perldoc Ado::Manual #this page

For better experience run the **`ado`** application and read the documentation
from your browser.

    /path/to/yourAdo/bin/ado daemon

If you installed `ado` in your Perl distro, you can simply type:

    ado daemon

Go to http:/localhost:3000/perldoc

You can report bugs and suggest features at [http://github.com/kberov/Ado/issues](http://github.com/kberov/Ado/issues).
Bugs will be considered and fixed as time permits.
Feel invited to make pull requests for your contributions.

If you are simply looking for help with using Ado,
please ask your questions at
[https://groups.google.com/d/forum/ado-dev](https://groups.google.com/d/forum/ado-dev).

# CONTRIBUTING

Anybody can contribute by reporting issues via github
or fixing typos in the documentation.
To be able to contribute with code, some rules need to be kept.
This is mandatory for any community project. Generally the rules outlined in
[Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing) apply for [Ado](https://metacpan.org/pod/Ado) too.
For specific to Ado rules see [Ado::Manual::Contributing](https://metacpan.org/pod/Ado::Manual::Contributing).

We expect that you know how Internet works, how to write Perl modules and 
are familiar with [Mojolicious](https://metacpan.org/pod/Mojolicious).

To ease discusssions on Ado further development, a forum was created.
[https://groups.google.com/d/forum/ado-dev](https://groups.google.com/d/forum/ado-dev).

# REST API

Ado strives for strict separation of concerns. The best way to achieve 
this is to fully separate the client code from the server code. 
Ado is ideally suited for the purpose thanks to
[Mojolicious](https://metacpan.org/pod/Mojolicious). Every resource(route) is accessible via a browser as `/path/to/resourse`
an returns HTML or using `/path/to/resourse.json` and returns JSON.
We follow closely and elaborate on the recommendations in
"RESTful Service Best Practices" at www.RestApiTutorial.com. See [Ado::Manual::RESTAPI](https://metacpan.org/pod/Ado::Manual::RESTAPI).

# PLUGINS

Business-specific applications for an Ado-based system are usually implemented 
as plugins. One way to contribute to [Ado](https://metacpan.org/pod/Ado) is by writing plugins.

Ado plugins work the same way as [Mojolicious::Plugins](https://metacpan.org/pod/Mojolicious::Plugins) and share 
the same common base trough [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin) which ISA [Mojolicious::Plugins](https://metacpan.org/pod/Mojolicious::Plugins).
Ado plugins have one small additional feature. 
They can load their own configuration from
`$ENV{MOJO_HOME}/etc/plugins/plugin_name.conf`.

See [Ado::Manual::Plugins](https://metacpan.org/pod/Ado::Manual::Plugins) and [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin) for more information.

# CONTINUOUS INTEGRATION

We would like to know that our software is always in good health.
We count on friendly developers and organizations to install and test it continuously.

[CPAN Testers Reports for Ado](http://www.cpantesters.org/distro/A/Ado.html)

[Travis-CI](https://travis-ci.org/kberov/Ado) 

[![Build Status](https://travis-ci.org/kberov/Ado.svg?branch=master)](https://travis-ci.org/kberov/Ado)


# SEE ALSO

[Ado](https://metacpan.org/pod/Ado), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), 
[Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing),
["prefix\_vs\_install\_base" in Module::Build::Cookbook](https://metacpan.org/pod/Module::Build::Cookbook#prefix_vs_install_base), 
[http://www.thefreedictionary.com/ado](http://www.thefreedictionary.com/ado).

# AUTHORS

Authors, ordered by contributions ([https://github.com/kberov/Ado/graphs/contributors](https://github.com/kberov/Ado/graphs/contributors)).

Красимир Беров (Krasimir Berov)(berov@cpan.org)

Вълчо Неделчев (Valcho Nedelchev)(kumcho@vulcho.com)

Joachim Astel

Renee Baecker (module@renee-baecker.de)

# COPYRIGHT AND LICENSE

Copyright 2013-2015 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

