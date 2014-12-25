# Mojolicious::Commands

Mojolicious 是目前 Perl 社区最流行的 Web 开发框架。不过今天这里不聊怎么写网站。而是说一个小边角料。之前尝试 RoR 框架的时候，觉得用 rake 命令可以做到很多事情，非常方便。而 mojo 命令只能做到生成、运行、测试等比较少的几项，真是非常遗憾。不过看了文档才发现，其实 Mojolicious 预留了 Mojolicious::Command 接口，可以特别快的就扩充自己的子命令来用。

要实现一个自己的 mojo 子命令，只需要注意下面几点：

1. 继承 `Mojolicious::Command` 类；
2. 提供 `usage`、`description` 属性；
3. 写好 `run` 方法。

然后是如何加载。

1. 可以直接用原有的名字空间，`Mojolicious::Command::yoursubcmdname` 即可；
2. 如果不想太过入侵，，那么类名就是 `Yourapp::Command::yoursubcmdname`，同时在 `Yourapp.pm` 的 startup 函数里加上这么一句：


    push @{ $self->commands->namespaces }, 'Yourapp::Command';

这就是全部了。

下面做个小示例。

    package Mojolicious::Command::hello;
    use 5.20.0;
    use experimental 'signatures';
    use Mojo::Base 'Mojolicious::Command';
    
    has usage       => "usage: $0 hello [name]\n";
    has description => "hello world\n";
    
    sub run($self, $name='world') {
        say $name;
    }
    
    1;

然后测试运行：

    $ ./script/yourapp -h | grep hello
    ...
     get       Perform HTTP request.
     hello     hello world
     inflate   Inflate embedded files to real files.
    ...
    $ ./script/yourapp hello -h
    usage: ./script/yourapp hello [name]
    $ ./script/yourapp hello
    hello world
    $ ./script/yourapp hello perlchina
    hello perlchina

Mojolicious 还有很多好玩的地方，欢迎大家一起探索。
