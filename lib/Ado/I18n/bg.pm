package Ado::I18n::bg;
use Mojo::Base 'Ado::I18n';
use I18N::LangTags::List;
our %Lexicon = (    ##no critic(ProhibitPackageVars)
    hello          => 'Здрасти, [_1]!',
    Login          => 'Вписване',
    Logout         => 'Изход',
    Help           => 'Помощ',
    login_name     => 'Потребител',
    login_password => 'Парола',
    login_field_error =>
      'Моля въведете валидна стойност за полето "[_1]"!',
    first_name   => 'Име',
    last_name    => 'Фамилия',
    email        => 'Е-поща',
    title        => 'Заглавие/Име',
    tags         => 'Етикети',
    time_created => 'Created on',
    sorting      => 'Подредба',
    data_type    => 'Тип',
    data_format  => 'Формат',
    time_created => 'Време на създаване',
    tstamp       => 'Време на Промяна',
    body         => 'Съдържание (тяло)',
    invisible    => 'Невидимо',
    language     => 'Език',
    group_id     => 'Група',
    bg           => 'Български',
    en           => 'Английски',
    ru           => 'Руски',
    de           => 'Немски',
    Templates    => 'Шаблони',
    Accounts     => 'Сметки',
    Users        => 'Потребители',
    Groups       => 'Групи',
    Abilities    => 'Умения',
    System       => 'Система',
    Settings     => 'Настройки',
    Cache        => 'Кеш',
    Plugins      => 'Добавки',
    Log          => 'Отчет',
    Files        => 'Файлове',
    Preferences  => 'Предпочитания',
    order_by     => 'Подредба по',
    order        => 'Ред',
    ASC          => 'Възходящ',
    DESC         => 'Низходящ',

    created_by      => 'Създаден от',
    created_by_help => 'Кой е създал потебителя?',
    changed_by      => 'Променен от',
    changed_by_help => 'Кой за последно е променял записа?,',
    tstamp          => 'Последна промяна',
    disabled        => 'Заключен',
);

1;

=pod

=encoding utf8

=head1 NAME

Ado::I18n::bg - lexicon for Bulgarian

=cut
