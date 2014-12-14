# Devel::DidYouMean

我们总是期望程序越智能越好。在 Perl6 里，有一系列的“友好”的提示信息，帮助从 Perl5 程序员转移自己的语法习惯。其中一个功能，叫 **Did You Mean?**。如下：

    $ perl6 -e 'sya "ok"'
    ===SORRY!=== Error while compiling -e
    Undeclared routine:
        sya used at line 1. Did you mean 'say'?

现在，我们在 Perl5 里也可以做到同样的事情。这就是 [Devel::DidYouMean](https://metacpan.org/pod/Devel::DidYouMean) 模块。示例如下：

    $ perl -MDevel::DidYouMean -e 'printX("test")'
    Undefined subroutine &main::printX called at -e line 1.
    Did you mean print, printf?

当然，除了系统内置指令，对程序自己定义的函数，也可以做到相应的处理。比如下面这样：

    use 5.010;
    use Devel::DidYouMean;
    use Try::Tiny;
     
    sub testsay {
        say @_;
    }
    try {
        testsayx("catch me"); # boom
    } catch {
        my $error_msg = $_;
        $Devel::DidYouMean::DYM_MATCHING_SUBS->[0]->("I'm here"); 
    }

没错，最终我们成功得到了 "I'm here" 的输出。


