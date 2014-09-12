# Lingua::Identify::CLD
======

[Lingua::Identify::CLD](https://metacpan.org/pod/Lingua::Identify::CLD) 使用 Chrome 的语言识别功能来得到文字或者网页的语言。

它的使用超级简单

```
use Lingua::Identify::CLD;
use Data::Dumper;

my $cld = Lingua::Identify::CLD->new();
my @lang = $cld->identify("Text"); # 'ENGLISH', 'en', 100, 1
```

## 命令行
---------

*identify-cld*

```
➜  mojo-advent git:(master) ✗ cat articles/draft/Lingua-Identify-CLD.md | identify-cld
STDIN: CHINESE
```

## 作者
---------
[Fayland Lam](http://fayland.me/)