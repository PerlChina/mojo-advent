# Time::Piece

时间处理是一个有时候蛮麻烦的事情。很多 Perl 程序员可能还习惯于使用下面这样的写法：

    my ($sec, $min, $hour, $mday, $mon, $year_off, $wday, $yday, $isdat) = localtime;

或者稍微简单一点的地方，可以：

    use POSIX qw/strftime/;
    print strftime('%F %T', localtime);

但是涉及到时间运算的时候，就麻烦多了。常见的是换算到秒做加减乘除，或者安装沉重的 DateTime 模块。

## Time::Piece 示例

其实，从 Perl v5.9.5 版本开始，就随内核分发一个时间模块，叫 [Time::Piece](https://metacpan.org/pod/Time::Piece)。在通常情况下，都足够好用了。

    use 5.010;
    use Time::Piece;
    my $t = localtime() - localtime()->tzoffset;
    say $t->datetime;                              # 2014-12-14T16:06:06
    say localtime()->datetime;                     # 2014-12-15T00:06:06
    say $t->date;                                  # 2014-12-14
    say $t->mdy('/');                              # 12/14/2014
    say $t->time;                                  # 00:06:06
    say $t->hms('.');                              # 00.06.06
    say $t->epoch;                                 # 1418573166
    say $t->month;                                 # Dec
    say $t->add_months(1)->year;                   # 2015

Time::Piece 会覆盖 CORE 里提供的 **localtime** 和 **gmtime** 函数，自动返回 Time::Piece 对象。这点类似的还有 [File::stat](https://metacpan.org/pod/File::stat) 模块，注意是小写的，这个也是 Perl5 现在的内核分发模块。在 `use File::stat` 以后，**stat** 函数也会自动返回 File::stat 对象而不是那个复杂的数组！

## Time::Seconds 示例

上面示例代码里有个隐藏的地方，`localtime->tzoffset` 事实上是返回了一个 [Time::Seconds](https://metacpan.org/pod/Time::Seconds) 对象。这个类是 Time::Piece 模块里一起提供的，不用单独安装。

一个 Time::Piece 对象加减一个 Time::Seconds 对象，得到的还是 Time::Piece 对象。而两个 Time::Piece 对象相加减，得到的则是 Time::Seconds 对象了：

    my $s = $t - localtime();
    say $s->days;                                  # 31

Time::Seconds 如果你单独导入的话，他会导出一系列常量，比如我们再重复一次前面那个加一个月的操作，就可以写成：

    use Time::Seconds;
    $t += ONE_MONTH;                               # 继续用前面的 $t 变量
    say $t->month;                                 # Feb

## 缺陷

Time::Piece 虽然也实现了 `strptime` 方法，但是实现的不是很全面(不支持时区)。如果有很强的从字符串转换成时间对象的需求，可以参考 [Time::Moment](https://metacpan.org/pod/distribution/Time-Moment/lib/Time/Moment.pod) 模块的 `->from_string` 方法。Time::Moment 模块也提供了类似的一些属性方法。
