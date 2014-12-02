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

该模块对于某些字符可能支持不够完美，这时候你可以简单地写一个 wrap，参考该模块 [POD](https://metacpan.org/pod/Text::Unidecode) 文档。

## Usage

一个将目录下所有中文名的文件转成对应拼音的脚本：

    use Text::Unidecode;
    use Encode;

    opendir(my $dir, "/some/where/from_dir");
    my @files = grep { -f $_ } readdir($dir);
    closedir($dir);

    foreach my $file (@files) {
        my $to_file = unidecode(decode_utf8($file));
        $to_file =~ s/\s+/\_/g;
        next if $to_file eq $file;

        print "$file -> $to_file\n";
        # do a copy
    }

输入结果大致为：

    夜空中最亮的星.mp3 -> Ye_Kong_Zhong_Zui_Liang_De_Xing_.mp3
