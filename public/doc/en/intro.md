#Intro

<div class="ui hidden">
  If you read this page out of /help/en/* the links in it will not work!
</div>

##Ado
A framework for web projects based on [Mojolicious](http://mojolicio.us/), written in the Perl programming language.

Ado[^ado_] was started in November 2013 as a rewrite of a previous project ([MYDLjE](https://github.com/kberov/MYDLjE)) based on Mojolicious 1.9x. MYDLjE was too monolithic. It was not possible to start with minimum features, disable some of them and re-enable them only if needed.  Ado is much more modular and flexible than MYDLjE and its name is not an acronym :). 

##What is Ado?
Ado's purpose is the same as of MYDLjE – to quickly put together a lightweight web application and/or site based on Mojolicious with scalability, performance and growth in mind.
An Ado system starts as a minimal application that can turn into an ERP, a CMS, a CRM or all in one by just adding plugins along the way as the organization which is using it grows.

##Built-in features
Ado is a typical Mojo application. It comes with a configuration file and a model[^2] layer - Mojolicious::Plugin::DSC. An SQLite database is bundled in the distribution at etc/ado.sqlite to get started quickly. All plugins can be disabled and re-enabled.

Ado has the following:

1. Configuration file with most of the sensible settings in place, such as controller_class, name-spaces for routes (urls), name-spaces for plugins and commands, session settings, default routes...
2. Ado plugins work the same way as Mojolicious::Plugins and share the same common base trough Ado::Plugin. But they have one small additional feature. They can load their own configuration from `$ENV{MOJO_HOME}/etc/plugins/plugin_name.conf`. Business-specific applications for an Ado-based system are usually implemented as plugins or by combining a set of plugins. 
By default the following plugins are enabled:
  1. All Mojolicious plugins which are otherwise enabled by default.
  2. Mojolicious::Plugin::Charset – UTF-8.
  3. Mojolicious::Plugin::DSC – a plugin which integrates DBIx::Simple::Class in the application.  DBIx::Simple::Class is a very lightweight object-relational mapper based on  DBIx::Simple. It abstracts the SQL from the programmer still allowing to construct very complex SQL queries. There are plans to add support for asynchronous queries which will be transparent for the programmer.
  4. Ado::Plugin::Auth is a plugin that authenticates users to an Ado system. Users can be authenticated locally or using (TODO!) Facebook, Google, Twitter and other authentication service-providers. A pre-made login form can be used directly or as an example for custom forms for the specific application.
  5. Ado::Plugin::MarkdownRenderer - Render static files in markdown format. One can create a personal blog or enterprise wiki using static files in markdown format.
3. The following libraries for user-interface development are bundled with the distribution:
  1. Semantic UI – a CSS and JS framework for development of mobile-ready layouts. Its usage also results in more clean HTML than other popular frameworks.
  2. PageDown is the version of Attacklab's Showdown and WMD as used on Stack Overflow and the other Stack Exchange sites. It includes a converter that turns Markdown into HTML, a Markdown editor with realtime preview of the generated HTML, and a few useful plugins, e.g. for sanitizing the generated HTML according to a whitelist of allowed tags.
4. The following Ado specific commands are available:
  1. Ado::Command::adduser allows adding users to an Ado application via a terminal. It also allows adding users to existing or not existing groups. The new group is automatically created.
  2. Ado::Command::version shows version information for installed core and optional modules.
1. Last but not least, Ado code is well covered with tests. Special care is taken to avoid accumulating technical debt by having Test::Perl::Critic tests set to level “harsh”. This way the coding style is forced to be consistent across the framework and to avoid bad coding practices.

Here is how an Ado system looks like from architectural point of view:

![Ado building blocks](/img/Ado-Building-Blocks.png "Ado building blocks")

##Installation/Deployment
The most flexible way to install Ado is manually on the command line.
It is highly recommended to have a separate Perl distribution (not the one that comes with your OS).
ActivePerl or perlbrew are both fine. 

All deployment scenarios described at [Mojolicious/Guides/Cookbook#DEPLOYMENT](http://mojolicio.us/perldoc/Mojolicious/Guides/Cookbook#DEPLOYMENT)
are possible and specific custom deployments can be done.

Ado is not actively tested under Windows, but there is an [Ado PPM package](http://code.activestate.com/ppm/Ado/) for Mac OSX, Linux and Windows maintained by Active State.

##REST API[^rest]
Ado strives for strict separation of concerns (MVC[^2]). The best way to achieve this is to fully separate the client code from the server code. Ado is ideally suited for the purpose thanks to Mojolicious. Every resource is accessible via the REST API. We follow closely and elaborate on the recommendations in "RESTful Service Best Practices" at www.RestApiTutorial.com.

##Roadmap
Below are the main activities considered mandatory for implementation to reach version 1.00.

1. Implement Ado::Plugin::I18N with messages loaded from the database (bundled with Ado).
2. Implement Ado::Plugin::Vest – a chat application.
3. Implement Ado::Plugin::CORS – allow Ado UI pieces to be embedded into other sites. 
4. Implement Ado::Plugin::Site – end-users front-end.
1. Implement Ado::Plugin::Signup – user registration.
2. Implement Ado::Plugin::Profile – managing users' own profiles.
5. Implement Ado::Plugin::Admin – a web application for managing an Ado system -”Control Panel”.
  1. Implement Ado::Plugin::Domains – controllers for managing a multi-domain site in Control Panel.
  2. Implement the Pages management controllers for the site.
  3. Implement the Content (sections in pages) management controllers.
  4. Implement the Users/Groups Management controllers.


Krasimir Berov, 2014-05-06

[^ado_]: Ado - busy or delaying activity; bustle; fuss.
See also http://www.thefreedictionary.com/ado

[^2]: http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller

[^rest]: http://en.wikipedia.org/wiki/REST

