# Lingua::Identify::CLD

[Lingua::Identify::CLD](https://metacpan.org/pod/Lingua::Identify::CLD) 使用 Chrome 的语言识别功能来得到文字或者网页的语言。

它的使用超级简单

    use Lingua::Identify::CLD;

    my $cld = Lingua::Identify::CLD->new();
    my @lang = $cld->identify("Text"); # 'ENGLISH', 'en', 100, 1
    # $lang[0] -> language name
    # $lang[1] -> language id
    # $lang[2] -> confidence
    # $lang[3] -> is_reliable (bool)

## 适用场景

 * 判断某网页 url 是哪国语言，类似 Google Chrome 的判断

    use LWP::Simple;
    use Lingua::Identify::CLD;

    my $cld = Lingua::Identify::CLD->new(isPlainText => 0);
    my @langs = $cld->identify(get('http://www.163.com/'));
    print join(", ", @langs); # CHINESE, zh-CN, 97, 1

## 命令行

*identify-cld*

    ➜  mojo-advent git:(master) ✗ cat articles/2014/02/Lingua-Identify-CLD.md | identify-cld
    STDIN: CHINESE

## 作者
[Fayland Lam](http://fayland.me/)