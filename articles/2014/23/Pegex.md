# Pegex

[Pegex](https://metacpan.org/pod/distribution/Pegex/lib/Pegex.pod) 是一个语法解析框架，全称是 Parsing Expression Grammars (PEG), with Regular Expessions (Regex) 。 作者是[Ingy dot net](https://metacpan.org/author/INGY), 相信大家都听过他的另外一个模块 [Inline](https://metacpan.org/release/Inline), [Inline::C](https://metacpan.org/release/Inline-C), 最近Ingy的 [Inline Module Supprot](http://inline.ouistreet.com/) 项目也是得到了Perl基金会TPF（The Perl Fundation ）的赞助, 相信以后的Inline会更加好用。

还是回到Pegex, 就像它的名字一样, Pegex是一个基于正则表达式来做语法解析的框架, 灵感来自于Perl6的Rules. 最近的China Perl Advent也有介绍一个语法解析模块[Regexp::Grammar](https://github.com/PerlChina/mojo-advent/blob/master/articles/2014/16/regexp_grammars.md). 我没有用过这个模块，但看起来和Pegex的思路大致是一样的，因为其作者是Damian Conway, 所以也是很有保障的，相比起来，Pegex定义rule 的语法可能更加清晰一点。

相比普通的正则表达式, Pegex的语法更加易懂和结构化.比如我们想定义一个语法表示所有以#开头的都是注释：

    comment: / HASH ANY* EOL /

这里以冒号分割定义了一个 rule 叫 comment， / / 扩起来的其实就是表示正则表达式， 只是用 HASH 来代替 #, 看起来干净一些， 以上的写法和下面的正则表示是一样的

    comment: /#.*\r?\n/

这里的HASH ANY EOL也是rule，只是事先定义好的默认rule，所以可以看到，Pegex的语法定义其实就是定义一个个子rule，最后把他们串起来。而rule本质上也是正则表达式。

与perl的正则语法不同的是

在正则语句中，用尖括号括起来的是rule

    / ( <rule1> | 'non_rule' ) /

如果你想省略尖括号，可以在rule前留一个空白

    / ( rule1 | 'non_rule' ) /

正则语句默认是忽略空白的，你可以把一个表达式拆成多行来写，也就是相当于正则 /x模式 默认开启

    / (
        rule1+   # 注释
        |
        rule2
    ) /

用- + 来表示 \s* 和 \s+

    / - rule3 + /  # rule3 前面可以有0-多个空白， 后面有1到多个空白

在perl中任何(?XX ) 形式的语法，在这里都可以把？省略， 也就是下面两个是一样的

    / (: a | b ) /

    / (?: a | b ) /


我们再来看一个解析CSV的例子(来自[Pegex::CSV](https://metacpan.org/pod/distribution/Pegex-CSV/lib/Pegex/CSV.pod) 模块)

    csv: row*

    row:
      /(= ALL)/
      value* % /- COMMA/
      /- (: EOL | CR | EOS)/

    value: /- ( double | plain) /

    double: /- DOUBLE (: (: DOUBLE DOUBLE | [^ DOUBLE] )* ) DOUBLE /

    plain: /- (: [^ COMMA DOUBLE CR NL]* [^ SPACE TAB COMMA DOUBLE CR NL ] )? /

第一句定义表示csv 是由零到多个row组成

第二句定义表示row 是有逗号分隔的value组成, 这里 % 是Pegex提供的一个操作符，表示用。。分隔的意思，也是来自Perl6的

第三句定义value 是一个double 或者plain

第四句定义double 是一个由双引号扩起来的字符串

第五句定义plain 是一个非逗号，双引号， 换行，空白 等等的 字符串

我们可以看到Pegex的定义本质上也是用的正则. 用DOUBLE, COMMA, EOL 这样的直白的名字来代替'",\r?\n', 用定义rule来将整个语法拆分成每个部分，在写比较复杂的正则表达式时会非常清晰，相信大家都有看一个非常复杂的正则时的头痛。


语法定义好了，我还需要定义一个接受器(Receiver), Pegex提供一个基类Pegex::Tree,供你在此基础上定义你的接收器。

下面是一个CSV的接收器，将解析过的csv转化为一个二维数组的形式（List of List）。

    package Pegex::CSV::LoL;
    use Pegex::Base;
    extends 'Pegex::Tree';

    sub got_row {
        my ($self, $got) = @_;
        $self->flatten($got);
    }

    sub got_value {
        $_[1] =~ s/(?:^"|"$)//g;
        $_[1] =~ s/""/"/g;
        return $_[1];
    }

got_* 方法用来定义当Parser捕获了一个相应的rule后进行的操作, *对应之前在语法定义时的rule名字。

比如这里got_value 就是把得到的value的双引号去掉， flatten是将一个多维数组展平成一个一维数组。

Grammar和Receiver都定义好之后，整个工作就算完成了，可以用定义好的语法和接受器来读csv文件了。

    my $parser = Pegex::Parser->new(
        grammar => Pegex::CSV::Grammar->new,
        receiver => Pegex::CSV::LoL->new,
    );

    $parser->parse($csv);


我现在用到Pegex地方主要是解析一些各种各样格式的数据, 或者定义自己的DSL来做配置文件。它们大多不是常规的ini，json， yaml格式，所以相比之前用正则和循环来写， 一个是工作量降低， 基本是语法定义好就可以用了的节奏， Pegex为你做了语法解析的事情， 剩下的只是写Receiver得到想要的数据类型。 另二是代码干净了许多， 后面维护起来很方便。
