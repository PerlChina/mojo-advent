# Perl6 Promise

之前的 advent 里讲了 Perl5 中的 Future 模块，并以最常见的 HTTP 请求为例，演示了在这种编程模式下并发请求的代码。今天我们就走的稍远一点，来试试看，在 Perl6 里，怎么做到类似的效果。

就概念来说，Perl6 规范中对并发编程，目前主要方式就是 Promise、Channel 和 Supply 。这其中的 Promise 就跟之前说的 Future 很相近(事实上在 Perl5 中，IO::Async 对应 Future，AnyEvent 对应 Promises，几乎可以认为就是一个概念两套名词了)。

比较郁闷的是，目前 panda 上存在的 HTTP::UserAgent 模块，不支持在 Promise 上使用。所以我结合 HTTP::UserAgent 和 rakudo/t/spec/S32-io/IO-Socket-Async.t 两部分的代码，自己写了一个简单的利用 Promise 的 HTTP client 示例。作为一个小示例，这里就直接使用 **Connection: close** header 来简化逻辑处理了。

首先通过 Mojolicious 启动一个在本地 8080 端口的 hello world 页面供测试使用。然后客户端程序如下：

    #!/usr/bin/env perl6
    use v6;
    use HTTP::Request;
    use HTTP::Response;
    
    my $host = '127.0.0.1';
    my $port = 8080;
    
    multi sub client(&code) {
        my $p = Promise.new;
        my $v = $p.vow;
        my $client = IO::Socket::Async.connect($host, $port).then(-> $sr {
            if $sr.status == Kept {
                my $socket = $sr.result;
                code($socket, $v);
            }
            else {
                $v.break($sr.cause);
            }
        });
        $p
    }
    
    multi sub client(Str $message) {
        client(-> $socket, $vow {
        $socket.send($message).then(-> $wr {
            if $wr.status == Broken {
                $vow.break($wr.cause);
                $socket.close();
            }
        });
        my @chunks;
        $socket.chars_supply.tap(-> $chars { @chunks.push($chars) },
            done => {
                $socket.close();
                my $response = HTTP::Response.new;
                my $content = [~] @chunks;
                my ($headers, $body) = @chunks.join.split("\r\n\r\n");
                my ($response-line, @header) = $headers.split("\r\n");
                $response.set-code( $response-line.split(' ')[1].Int );
                $response.header.parse( @header.join("\r\n") );
                $response.content = $body;
                $vow.keep($response);
            },
            quit => { $vow.break($_); })
        });
    }
    
    my $url = 'http://127.0.0.1:8080/';
    my $request = HTTP::Request.new(GET => $url);
    my $message = $request ~ "Connection: close\r\n\r\n";
    my @urls = $message xx 100;
    my @getting = @urls.map: { client($_) };
    .content.say for await Promise.anyof( Promise.allof(@getting), Promise.in(5) );

测试结果，在不到 4s 的时间内，可以完成 100 个请求。

目前 Promise 只提供了 in, at, start, anyof, allof, then，keep, break 等方法。不过上面这个示例最大的问题在于，Perl6 虽然有默认并发数为 16 个线程，但是通过 map 生成 Promise 数组这步，并不是 lazy 的！所以 @urls 只消到几百个，就会出错了……
