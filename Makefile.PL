use ExtUtils::MakeMaker;


WriteMakefile(
    NAME              => 'App::MakeFileOrder',
    VERSION_FROM      => 'lib/App/MakeFileOrder.pm',
    PREREQ_PM         => {
        Readonly          => 0,
        "Class::Accessor" => 0,
        "Path::Class"     => 0,
        "List::MoreUtils" => 0,
    },
    ABSTRACT_FROM     => 'lib/App/MakeFileOrder.pm',
    AUTHOR            => 'kuniyoshi kouji<kuniyoshi@cpan.org>',
);

