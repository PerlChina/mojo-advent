# Future

这个名字一听起来还以为是要说 Perl 的发展方向之类的吧。其实我这里要介绍的是一个 CPAN 模块，或者说，一种异步编程模式在 Perl 里的运用。

Future 模式的定义之类的，大家可以看 Java 或者 C++ 的资料，都会有提。这里直接进入 Perl 相关的部分。[Future 模块](https://metacpan.org/pod/Future)的作者是著名的 Paul Evans，[IO::Async 模块](https://metacpan.org/pod/IO::Async)的作者。事实上 IO::Async 模块现在已经完全依赖于 Future 模块了。

考虑大家其实用 AnyEvent 周边模块比较多，这里展示如何在 AnyEvent 环境里，使用 Future。示例脚本及解释如下：

## 首先加载程序要用的模块及导出函数

    use 5.20.0;
    use experimental 'signatures';
    use AnyEvent;
    use AnyEvent::HTTP;
    use AnyEvent::Future qw/as_future/;
    use Future::Utils qw/fmap/;

## 为 AnyEvent 的异步函数封装成 Future 对象

`as_future` 接收一个匿名函数，内部封装异步操作，这里就是最常见的 `http_get`，匿名函数会传递进去一个 Future 对象。而在异步操作的回调中，我们可以调用该 Future 对象的 **implementation methods**(These methods would primarily be used by implementations of asynchronous interfaces)。

最常见的就是 `->done(@results)` 和 `->fail($exception, @details)` 两个方法，分别传递成功和失败的消息。

这里示例中就是判断只有响应码在 2XX 的时候，成功返回网页；否则失败报错。

    sub future_get($url) {
        return as_future {
            my $f = shift;
            http_get $url, sub($body, $hdr) {
                if ( $hdr->{Status} =~ /^2/ ) {
                    $f->done($body);
                }
                else {
                    $f->fail( $url . " got " . $hdr->{Reason} );
                }
            };
        }

`as_future` 的返回值，也就是这个 Future 对象。所以，我们可以继续在这个对象上调用 Future 的 **sequencing methods**(These methods all return a new future to represent the combination of its invocant followed by another action given by a code reference)。

最常见的，是 `->then( \&code(@result) )`  `->else( \&code($exception) )`。注意为了让链式调用可以继续下去，这里的匿名函数一定也要返回一个新的 Future 对象。

这里示例，就只判断一下失败的报错信息，如果是 404 Not Found，可以认为服务器本身没问题，依然返回一个成功的 Future。事实上这里完全可以再使用其他的异步操作。

        ->else(
            sub($exception) {
                if ( $exception =~ /Not Found/ ) {
                    Future->done("OK, now.");
                }
                else {
                    Future->fail($exception);
                }
            }
        );
    };

好了，函数定义完成。你就可以直接使用了。

## 多个 Future 对象的协同工作

单个 url 下载当然没什么意思，我们这里需要一些复杂逻辑来协同工作。下面这段的效果是：并发 5 个请求请求 URL 列表，但是超过 5 秒没完成就直接停止。

    my @urls   = qw( http://www.baidu.com http://www.baidu http://www );
    my $future = Future->wait_any(
        AnyEvent::Future->new_timeout( after => 5 ),
        fmap { future_get(shift) } foreach => \@urls, concurrent => 5
    );

这其中用的是 Future 的 convergent futures(These constructors all take a list of component futures, and return a new future whose readiness somehow depends on the readiness of those components)，也就是传入由多个 Future 对象构成的数组，返回一个新的 Future 对象。

常见的有 `->wait_any(@futures)`、`->wait_all(@futures)`、`->needs_all(@futures)`、`->needs_any(@futures)` 四种。wait 表示有返回即可，needs 则要求返回的为成功才行。

`fmap` 则是 [Future::Utils](https://metacpan.org/pod/Future::Utils) 模块额外提供的函数，用来方便的控制循环操作和并发等。模块里还提供了 `repeat`、`try_repeat`、`fmap_concat` 等其他函数和 `while`、`otherwise` 等其他循环控制。

如果这里不用控制，直接简单一点，可以写成一行：

    my $future = Future->needs_all( map { future_get($_) } @urls );

## 正式运行

前面这么多，都还是在定义阶段。现在可以准备运行了。跟运行相关的，叫做 user methods(These methods would primarily be used by users of asynchronous interfaces, on objects returned by such an interface)。

最常用的，有`->get`、`->on_done`、`->on_fail`、`->on_ready`、`->failure` 等。

这里的逻辑是：Future 运行完成的状态，叫 **ready**。ready 且 done 的状态，返回的数据通过 **get** 获取；ready 但是 fail 的状态，返回的数据通过 **failure** 获取。

    $future->on_done( sub { say "everything is ok" } );
    $future->on_fail( sub { say "something wrong!" } );
    $future->get;

## 运行结果

把上面几段代码连起来保存成文件并运行，可以看到如下结果：

> something wrong!
> http://www.baidu got Device not configured at future.pl line 43.

试试自己修改一下 urls 数组的内容，看看结果如何吧？

## 参考

Future 的详细用法示例，大家可以上 pevans 个人博客上看他去年的 [future advent](http://leonerds-code.blogspot.jp/2013/12/futures-advent-day-1.html) 系列。顺带一说，今年他个人博客是又在写响应式编程模式的文章，说不准之后又会推出相应模块吧……
