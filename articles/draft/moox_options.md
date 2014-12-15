# MooX::Options

在写命令行程序的时候，我们肯定都用过 [Getopt::Long](https://metacpan.org/pod/Getopt::Long) 模块。不过我在看 Message::Passing 项目源码的时候，发现这个项目用的是另一个模块，而且跟整个项目的 Moo 风格还真是非常搭。今天给大家介绍一下，这个模块叫：[MooX::Options](http://metacpan.org/pod/MooX::Options)。

这个模块的特点，就是把每个命令行参数都当做是对象属性来处理了。为了在语法上更明确一点，该模块包装了一下 Moo 的 `has` 关键字，改叫 `option` 。此外，还提供了一些便捷功能，比如自动生成数组、自动加载 JSON 等。

下面是一个比较完整的常用功能示例：

## MyAppCmd.pm 示例

    package MyAppCmd;
    use Moo;
    use MooX::Options;
    option 'verbose' => (
        is => 'ro',
        negativable => 1,
        doc => "a Bool option",
        short => 'v'
    );
    option 'float' => (
        is => 'ro',
        format => 'f',
        doc => "a Float option",
    );
    option 'string_array' => (
        is => 'ro',
        format => 's@',
        autosplit => ',',
        default => sub { [] },
        doc => "an Array contains String items, you can use ',' to split it",
    );
    option 'integer' => (
        is => 'ro',
        format => 'i@',
        autorange => 1,
        doc => "an Array contains Int items, you can use '..' to generate ranges",
    );
    option 'json' => (
        is => 'ro',
        json => 1,
        required => 1,
        doc => "a JSON option you must provide",
    );
    1;

## myappcmd 程序示例

    use MyAppCmd;
    use DDP;
    my $opt = MyAppCmd->new_with_options;
    p $opt;

## 运行效果示例：

首先试试不加任何参数：

    $ perl moox_options.md.pl
    json is missing
    USAGE: moox_options.md.pl [-hv] [long options...]
        --float: Real
            a Float option
        --integer: [Ints]
            an Array contains Int items, you can use '..' to generate ranges
        --json: JSON
            a JSON option you must provide
        --string_array: [Strings]
            an Array contains String items, you can use ',' to split it
        --verbose:
            a Bool option
        --usage:
            show a short help message
        -h --help:
            show a help message
        --man:
            show the manual

然后加全部参数：

    $ perl myappcmd --json '{"key":"value"}' --string_array=a,b,c --string_array=d  --integer=1..4 --float=1.1 -v
    MyAppCmd  {
        Parents       Moo::Object
        public methods (7) : DOES, float, integer, json, new, string_array, verbose
        private methods (2) : _options_config, _options_data
        internals: {
        format => 's@',
            float          1.1,
            integer        [
                [0] 1,
                [1] 2,
                [2] 3,
                [3] 4
            ],
            json           {
                key   "value"
            },
            string_array   [
                [0] "a",
                [1] "b",
                [2] "c",
                [3] "d"
            ],
            verbose        1
        }
    }

可以看到，`$opt` 是一个 MyAppCmd 对象，你定义的每个 option 都是一个对象属性，可以用同名方法获取其值。
