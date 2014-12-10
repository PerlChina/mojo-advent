# autobox

早在[几年前的 PerlChina Advent](/calendar/2010/06/) 上，fayland 曾经介绍过 [perl5i](https://metacpan.org/pod/perl5i) 项目。其中提到了 perl5i 里一个特性，就是 autobox。

    "12.34"->is_number;
    1->upto(5);
    "10, 20, 30, 40"->split(qr{, ?})->elements;
    (1,2,3,4,5,"a","b")->grep(sub{ $_->is_number })->sum->say;
    my %hash = (foo=>123, bar => 321);
    %hash->each(sub{
      my ($k, $v) = @_;
    });

喜欢链式调用风格的人可能会非常喜欢这种写法。那么问题来了。这是怎么做的，如果某个类型没现成的方法想自己实现要怎么办呢？

[autobox 模块](https://metacpan.org/pod/autobox) 是一个 XS 模块，利用 MAGIC 特性给 Perl 原生数据类型扩展出来添加方法的接口。其本身并没有实现具体的方法函数。任何人都是利用 autobox 模块生成自己的 autobox::\*。perl5i 里使用的，就是最常见的[autobox::Core](https://metacpan.org/pod/autobox::Core)。

autobox::Core 的实现很简单。比如其字符串相关部分就是这样：

    package autobox::Core;
    use base 'autobox';
    sub import {
        shift->SUPER::import(DEFAULT => 'autobox::Core::', @_);
    }
    package autobox::Core::SCALAR;
    sub chomp      { CORE::chomp($_[0]); }

完整情况下， autobox 一共可以扩展下面这些数据类型：

* UNDEF
* INTEGER
* FLOAT
* NUMBER
* STRING
* SCALAR
* ARRAY
* HASH
* CODE
* UNIVERSAL

而定义 DEFAULT 的作用就是表示各数据类型自动查找 DEFAULT 定义的这个名字空间下的同名类。相当于字符串类型就是：

    shift->SUPER::import(SCALAR => 'autobox::Core::SCALAR');

键值对还支持传递数组引用。这样就能对单个数据类型绑定多个类的函数。而这也是实现我们前面期望扩展个别方法的地方。比如实现一个类似 Perl6 中字符串的 `->words()` 方法：

    {
        package autobox::Core::SCALAR::Extends;
        sub words {
            CORE::split(/\s+/, $_[0]);
        }
    }
    use autobox::Core SCALAR => ['autobox::Core::SCALAR', 'autobox::Core::SCALAR::Extends'];
    my @array = "hello world"->words;
    @array->each(sub {
        $_[0]->say;
    });

传一个数组给 autobox::Core，这样既保持了 autobox::Core 原有的方法，又添加了自己想要的效果。脚本运行效果如下：

    $ autobox_test.pl
    hello
    world

btw: 代码中用了 `CORE::`，目前 Perl5 是尽量把内置函数都转移到这个 CORE 名下了。
