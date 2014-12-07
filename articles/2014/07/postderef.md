#  [Perl 5.20] 后缀解引用语法

## 启用 

Perl 5.20 可以使用后缀解引用，因为是新的feature，并不是默认启用的。
所以，需要用

    use v5.20;
    use experimental 'postderef';

来启用。

有人会问，这个并没有默认启用，会不会不稳定？ 答案是否定的。请参考 Ricardo Signes 的YAPC 视频（链接2）。

##  语法

### 数组解引用
    
    my $items = ['a'..'z']; # 'a', 'b', 'c' .. 'z'
    
    say "get a whole array";
    say(join '; ',   @$items); # a; b; c; d; ... x; y; z
    say(join '; ',  $items->@*); # same
    
    say "get a value by index";
    say  $$items[1]; # 'b'
    say  $items->[1]; # 'b'
    
    say "get multi values by indexes";
    say(join ';', @$items[2,3]); # 'b; c'
    say(join ';', $items->@[2,3]); # 'b; c'
    
    say "get the largest index in a array"; 
    say $items->$#*; # 25
    say $#$items; # 25
    
    
    say "get indexes and values";
    use DDP; # Data::Priner 
    my %hash_norm = %$items[2,3]; # this is postfix slicing. 
    my %hash_postdef = $items->%[2,3]; # same here
    p %hash_norm; # { 2 => 'c' , 3 => 'd' }
    p %hash_postdef; # { 2 => 'c' , 3 => 'd' }
    
    
你可以试试复制本文中的代码部分，运行一下。什么？ 你没有安装Data::Printer?

### 更多

这里只讨论数组解引用，hash ref 的语法类似，当然，scalar ref， subroutine ref 也支持后缀解引用，不过用的相对较少。

完全的用法可以参考下面的链接中的表格。

[Mini-Tutorial: Dereferencing Syntax](http://www.perlmonks.org/?node_id=977408)




## 参考

[perlref](https://metacpan.org/pod/distribution/perl/pod/perlref.pod)

[Perl 5.20: Perl 5 at 20](https://www.youtube.com/watch?v=D1LHFKGHceY)

[Cool new Perl feature: postfix dereferencing](http://perltricks.com/article/68/2014/2/13/Cool-new-Perl-feature--postfix-dereferencing)

## 作者  

* [SWUECHO](https://metacpan.org/author/SWUECHO)

