# Reply

交互式命令行是很多编程语言都提供的一个便捷方式。不过 Perl5 正巧就没提供==!前些年的 advent 中，曾经介绍过 [Devel::REPL](/2009/12/REPL/)，今天这里介绍另一个模块，叫 [Reply](https://metacpan.org/pod/Reply)。

Reply 的依赖模块没有 Devel::REPL 那么多，所以安装起来更简单快速一些。此外，Devel::REPL 的 rcfile 是直接 Perl 语法，而 Reply 用的是 INI 格式的配置文件。

默认情况下，运行 reply 命令会自动生成 `~/.replyrc` 如下：

    script_line1 = use strict
    script_line2 = use warnings
    script_line3 = use 5.016003
    [Interrupt]
    [FancyPrompt]
    [DataDumper]
    [Colors]
    [ReadLine]
    [Hints]
    [Packages]
    [LexicalPersistence]
    [ResultCache]
    [Autocomplete::Packages]
    [Autocomplete::Lexicals]
    [Autocomplete::Functions]
    [Autocomplete::Globals]
    [Autocomplete::Methods]
    [Autocomplete::Commands]

这里面的 Colors 只是用来区分运行成功和失败时候的颜色，如果想要完整的高亮效果，可以安装 [Reply::Plugin::DataDumpColor](https://metacpan.org/pod/Reply::Plugin::DataDumpColor) 模块，然后把 `~/.replyrc` 里 `[DataDumper][Colors]` 两行替换成 `[DataDumpColor]` 即可。

而 Devel::REPL 自带的 `re.pl` 命令运行的时候并不会自动生成配置，也不会默认加载插件。要达到类似效果的话，需要自己创建 `~/.re.pl/repl.rc`，然后添加内容：

    use strict;
    use warnings;
    use 5.014;
    load_plugin 'Colors';
    load_plugin 'Packages';
    load_plugin 'MultiLine::PPI';
    load_plugin 'CompletionDriver::Globals';
    load_plugin 'CompletionDriver::Methods';
    load_plugin 'CompletionDriver::Keywords';

二者的 Globals 插件实现效果也有差别。比如说，在 re.pl 里，你写一个 "M"，然后敲 tab 键，re.pl 是真的把你安装了的所有模块，以 M 开头的，都给你列出来，而且连模块的方法属性也单独列了；而在 reply 里，只会列出来被你显式 `use` 加载了的模块里匹配上的，就是说你 `use Mojo::UserAgent` 过，就只会列出 Mojolicious 的那些类，Moose 是不会列出的。

另一个区别，re.pl 有 multiline 插件，支持你逐行输入一个函数，他可以确定你括号结束了再执行。目前没有发现 reply 有这个功能，也算一个缺憾吧。

