# DDP & DDS

Perl 里要查看变量内部的实际内容，有很多种选择。比如核心模块 [Data::Dumper](https://metacpan.org/pod/Data::Dumper), [Smart::Comments](https://metacpan.org/pod/Smart::Comments) 都是被推荐了多年的模块。不过这里要介绍的，是另外两个在某些场景下更好用的模块。

## Data::Printer

[Data::Printer](https://metacpan.org/pod/Data::Printer) 模块在 metacpan 上获得近 80 个赞，比老牌的 Data::Dumper 还多 20 个。用起来非常简单：

    $ perl -MDDP -MHTTP::Tiny -E 'p new HTTP::Tiny'
    HTTP::Tiny  {
        public methods (11) : agent, delete, get, head, mirror, new, post, post_form, put, request, www_form_urlencode
        private methods (18) : __ANON__, _add_basic_auth_header, _agent, _create_proxy_tunnel, _http_date, _maybe_redirect, _open_handle, _parse_http_date, _prepare_data_cb, _prepare_headers_and_cb, _proxy_connect, _request, _set_proxies, _split_proxy, _split_url, _update_cookie_jar, _uri_escape, _validate_cookie_jar
        internals: {
            agent          "HTTP-Tiny/0.047",
            keep_alive     1,
            max_redirect   5,
            no_proxy       [],
            timeout        60,
            verify_SSL     0
        }
    }

[DDP](https://metacpan.org/pod/DDP) 是 Data::Printer 特意提供的缩写别名模块，实际用法是一样的。可以看到，它的 `p` 函数能把变量的类型，以及对象的方法和属性，都分门别类的输出出来！相信一定会给觉得 Perl 面向对象编程的人很大帮助。

## Data::Dump::Streamer

[Data::Dump::Streamer](https://metacpan.org/pod/Data::Dump::Streamer) 模块相对低调的多。不过这个模块也有自己的用武之地：

    $ perl -MData::Dump::Streamer -MHTTP::Tiny -E 'Dump(sub{"test"})'
    $CODE1 = sub {
               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
               'test';
             };

Data::Dump::Streamer 模块其实也提供了一个缩写别名叫 `DDS`。不过默认并不开启，需要在编译模块的时候，多加一个指定参数才行：

    $ perl Build.PL DDS && ./Build install

试图过用 Data::Dumper 来输出匿名函数引用的都有惨痛的回忆，那么，最后，你们猜用上面的 DDP 看函数引用，用下面的 DDS 看对象标量，结果又分别会是怎样呢？

## 作者

* [Chenlin Rao](https://metacpan.org/author/CHENRYN)
* [Perfi Wang](https://metacpan.org/author/SJDY)
