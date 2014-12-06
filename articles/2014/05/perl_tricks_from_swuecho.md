# 分享几个Perl小技巧

##  interpolate function calls into printed strings

Perl string 中可以使用变量，如

    my $var = $object->method($argument);
    print "the output is : $var, please verify";

这个$var 只用了一次，能否省去呢？比如换成如下写法？
  
    print "the output is : $object->method($argument), please verify";

不行，不过有间接的方法，
  
    print "the output is : ${\ $object->method($argument) }, please verify";

或者，
  
    print "the output is : @{[ $object->method($argument) ]}, please verify";

参考
  
* [Printing function calls in Perl](http://leonerds-code.blogspot.com/2014_11_01_archive.html)


## The non-destructive modifier /r

The non-destructive modifier s///r causes the result of the substitution to be returned instead of modifying $_
 (or whatever variable the substitute was bound to with =~ ):

    $x = "I like dogs.";
    $y = $x =~ s/dogs/cats/r;
    print "$x $y\n"; # prints "I like dogs. I like cats."

这一段直接从perlrequick 中抄过来的。
  
参考

* [perlrequick](http://perldoc.perl.org/perlrequick.html)


## cron jobs 中使用 perlbrew
  
perlbrew 很好用，我使用perlbrew 很久以后，才发现可以这样用。
  
    0 23  * * * /path/to/perlbrew exec --with perl-5.20.0 perl /path/to/app.pl > /dev/null
  
## 后记

这是我最近才发现的原来可以这样用的小技巧。欢迎分享你的发现，谢谢
  
## 作者  

* [SWUECHO](https://metacpan.org/author/SWUECHO)
