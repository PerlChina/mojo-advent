# unidecode

虽然 Unicode 已经非常流行，但是有时候在某些场景下，您不得不使用 ASCII 来作为输出。比如

  * 短消息 SMS，某些短消息网关不支持 Unicode
  * 文件名重命名
  * 不知道输入是什么语言，但需要转成能稍微看懂的
  * 等等

这时候您可以使用 [Text::Unidecode](https://metacpan.org/pod/Text::Unidecode) 来帮忙。

    use utf8;
    use Text::Unidecode;
    print unidecode("Léon & møøse\n"); # Leon & moose
    print unidecode("您好"); # Nin Hao
    print unidecode("こんにちは"); # konnitiha



