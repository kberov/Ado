# NAME

Ado::Manual - Getting started with Ado 

# SYNOPSIS

    ado daemon
    Server available at http://127.0.0.1:3000

# DESCRIPTION

[Ado](https://metacpan.org/pod/Ado) is a framework for web projects based on [Mojolicious](https://metacpan.org/pod/Mojolicious),
written in the [Perl programming language](http://www.perl.org/).

Ado is a typical [Mojo](https://metacpan.org/pod/Mojo) application. It has default 
configuration and a model layer - [Mojolicious::Plugin::DSC](https://metacpan.org/pod/Mojolicious::Plugin::DSC). 
An SQLite database is bundled in the distribution at `etc/ado.sqlite` 
to get started quickly.

Ado has additional [plugins](https://metacpan.org/pod/Ado::Plugin) and [commands](https://metacpan.org/pod/Ado::Command), 
which are good to have when starting new projects, based on Mojolicious.
[Semantic UI](http://semantic-ui.com/) is included in the distribution
and the default Ado page is a good example for usage.

# INSTALLATION

We strongly recommend using Ado with your own Perl (not the system-wide)!

Ado is meant to be _installed into a folder of your choice_.
It can go into the `siteprefix` folder of your **_non-system Perl distro_** 
or in its own folder. When installing Ado in its own folder,
you may want to add the `/path/to/ado/bin` to your `$PATH` environment variable.

To install manually Ado after downloading, run the following commands:

    tar -zxf Ado-X.XX.tar.gz
    cd Ado-X.XX/
    perl Build.PL --install_base $HOME/opt/ado
    ./Build installdeps
    ./Build
    ./Build test
    ./Build install

To see more installation methods and details, go to [Ado::Manual::Installation](https://metacpan.org/pod/Ado::Manual::Installation).

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation with the
perldoc command. To use `perldoc` for reading documentation you may 
need to add the full path to [Ado](https://metacpan.org/pod/Ado) `lib` directory to `PERL5LIB`
environment variable in case you passed the `--install_base` to `Build.PL`.

    perldoc Ado
    perldoc Ado::Manual #this page

For better experience run the **`ado`** application and read the documentation
from your browser.

    $HOME/opt/ado/bin/ado daemon

If you installed `ado` in your Perl distro, you can simply type:

    ado daemon

Go to http:/localhost:3000/perldoc

You can report bugs and suggest features at [http://github.com/kberov/Ado/issues](http://github.com/kberov/Ado/issues).
Bugs will be considered and fixed as time permits.
Feel invited to make pull requests for your contributions.

# CONTRIBUTING

Of course anybody can contribute by reporting issues via github 
or fixing typos in the documentation.
To be able to contribute with code, some rules need to be kept.
This is mandatory for any community project.
Generally the rules outlined in [Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing)
apply for [Ado](https://metacpan.org/pod/Ado) too.
For specific to Ado rules see [Ado::Manual::Contributing](https://metacpan.org/pod/Ado::Manual::Contributing).

We expect that you know how to write perl Modules and 
are familiar with [Mojolicious](https://metacpan.org/pod/Mojolicious).

# REST API

Ado strives for strict separation of concerns. The best way to achieve 
this is to fully separate the client code from the server code. 
Ado is ideally suited for the purpose thanks to
[Mojolicious](https://metacpan.org/pod/Mojolicious). Every resource is accessible via the REST API.
We follow closely and elaborate on the recommendations in
"RESTful Service Best Practices" 
at [www.RestApiTutorial.com](https://metacpan.org/pod/www.RestApiTutorial.com). See [Ado::Manual::RESTAPI](https://metacpan.org/pod/Ado::Manual::RESTAPI).

# PLUGINS

Ado plugins work the same way as [Mojolicious::Plugins](https://metacpan.org/pod/Mojolicious::Plugins) and share 
the same common base trough [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin).
Ado plugins have one small additional feature. 
They can load their own configuration from
`$ENV{MOJO_HOME}/etc/plugins/plugin_name.conf`.
Business-specific applications for an Ado-based system are usually implemented 
as plugins. One way to contribute to [Ado](https://metacpan.org/pod/Ado) is by writing plugins.

See [Ado::Manual::Plugins](https://metacpan.org/pod/Ado::Manual::Plugins) and [Ado::Plugin](https://metacpan.org/pod/Ado::Plugin) for more information.

# CONTINUOUS INTEGRATION

We d'like to know our software is always in good health so we count on
friendly developers and organisations to install and test it continuously.

[CPAN Testers Reports for Ado](http://www.cpantesters.org/distro/A/Ado.html)

[Travis-CI](https://travis-ci.org/kberov/Ado) 

[![Build Status](https://travis-ci.org/kberov/Ado.svg?branch=master)](https://travis-ci.org/kberov/Ado)


# SEE ALSO

[Ado](https://metacpan.org/pod/Ado), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), 
[Mojolicious::Guides::Contributing](https://metacpan.org/pod/Mojolicious::Guides::Contributing),
["prefix\_vs\_install\_base" in Module::Build::Cookbook](https://metacpan.org/pod/Module::Build::Cookbook#prefix_vs_install_base), 
[http://www.thefreedictionary.com/ado](http://www.thefreedictionary.com/ado).

# AUTHORS

Authors in order of joining the core team.

Красимир Беров (Krasimir Berov)(berov@cpan.org) 

Вълчо Неделчев (Valcho Nedelchev)(kumcho@vulcho.com)

# COPYRIGHT AND LICENSE

Copyright 2013-2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

