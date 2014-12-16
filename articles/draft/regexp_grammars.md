# Regexp::Grammars

如果让我来列举最有用的Perl module，第一可能是Moo(se), 然后就是Regexp::Grammars 了。
Regexp::Grammars 相当于Perl 6 中的 [Grammars](http://doc.perl6.org/language/grammars)

我早有介绍一下这个module 的想法，但是没有找到好的切入点。今天看到Perl6 advent谈到用grammar来解析FASTA文件。
[Day 15 – Bioinformatics and the joy of Perl 6](http://perl6advent.wordpress.com/2014/12/15/day-15-bioinformatics-and-the-joy-of-perl6/)。正好以此为例来聊一聊。


## FASTA 格式

```
cat test.fasta
>hello
GCTATATAAGC
>world prot
TATAKEKEKELKL
```

搞生物信息的肯定很熟悉，简单的说就是每个'>'开始一个条目。

每个条目可以概括为:
```
">"<id><comment>?"\n"<sequence> 
```
看了以上，可能就理解了。事实上，这行代码直接从Perl 6 FASTA grammar 抄过来了。

完整的Perl 6 grammar

```
grammar FASTA::Grammar {
    token TOP { <record>+ }

    token record { ">"<id><comment>?"\n"<sequence> }

    token id { <-[\ \n]>+ }

    token comment { " "<-[\n]>+ }

    proto rule sequence {*}
          rule sequence:sym<dna> { <[ACGTRYKMSWBDHVNX\-\n]>+ }
          rule sequence:sym<rna> { <[ACGURYKMSWBDHVNX\-\n]>+ }
          rule sequence:sym<aa> { <[A..Z\*\-\n]>+ }
}

````

Perl 6 对regex 的书写规则做了些改动，而 Regexp::Grammars 是对Perl 5 regex 的扩展，
所以，需要做一些改动。为了简便，我写的Perl 5 代码，并不与Perl 6 Advent 中Perl 6代码完全等价（只要稍加改动就可以了）。

Perl 5 中大致如此,

```
my $parser = do {
    use Regexp::Grammars;
    qr/
    <TOP>
    <nocontext:>
    <token: TOP>  <[record]>+
    <token: record> <.start=(\>)><id><comment>?\n<sequence>
    <token: id>  [^\-\s\n]+
    <token: comment> \s[^\n]+
    <token: sequence> <dna>|<rna>|<aa>
    <token: dna> [ACGTRYKMSWBDHVNX\-\n]+
    <token: rna> [ACGURYKMSWBDHVNX\-\n]+
    <token: aa> [A-Z\*\-\n]+
    /;
};
```
Perl 6 的写法如果有兴趣，可以研究一下，我很久没有摸过了。这里主要聊Perl 5。

use Regexp::Grammars 的作用是overload qr, 这也是为什么，不把 这一行移到文件开始部分的原因，否则，会overload 整个文件的qr。

qr 中 <TOP> 那一行， TOP 表示真个 grammar 的 pattern，放在 <> 中，表示调用这个pattern，所以，在后面一定要有
TOP 的定义。

定义一个pattern 用 token 或者rule，两者的主要区别在于对于whilespace 的处理。这跟Perl 6 中rule 和 token 有很大的不同。


一个包含fasta 条目的文件，有很多 条目，TOP 匹配所以的条目，你可能猜出来了 <[record]>+ 表示 匹配多个 record，
然后，只需要定义 record 就好了。 record 包括 id， comment 和 sequence。 sequence 要么是 DNA， RNA 或者 蛋白质。


不知道我有没有表达清楚，看看代码吧。

```
use v5.20;
use DDP;
 
my $fasta = <<'END';
>hello
GCTATATAAGC
>world prot
TATAKEKEKELKL
END
 
my $parser = do {
    use Regexp::Grammars;
    qr/
    <TOP>
    <nocontext:>
    <token: TOP>  <[record]>+
    <token: record> <.start=(\>)><id><comment>?\n<sequence> 
    <token: id>  [^\-\s\n]+ 
    <token: comment> \s[^\n]+
    <token: sequence> <dna>|<rna>|<aa> 
    <token: dna> [ACGTRYKMSWBDHVNX\-\n]+ 
    <token: rna> [ACGURYKMSWBDHVNX\-\n]+ 
    <token: aa> [A-Z\*\-\n]+ 
    /;
};
 
if ( $fasta =~ $parser ) {
    p %/;
}
 
__END__
{
  TOP   {
    record   [
	      [0] {
		   id         "hello",
		   sequence   {
                     dna   "GCTATATAAGC
"
		   }
		  },
	      [1] {
		   comment    " prot",
		   id         "world",
		   sequence   {
		     dna   "TATAK"
		   }
		  }
	     ]
  }
}
 
```
[源代码1](https://gist.github.com/swuecho/9ec08fe5698e8011e294)

文件的末尾是结果。

### 解析结果处理

解析得到的是Perl的数据结果，这样就基本达到了目的，但是仍有改进的空间。

因为每个条目是代表一个sequence， 包括 id， comment 和 sequence, 很自然的, 可以定义如下Seq class。


```
package Seq {
use Moo;
has ['id', 'comment', 'sequence' ] => ( is => 'rw');
1;
}
```

如Perl 6 中的 actions， Regexp::Grammars 也可以有。

```
use v5.20;
use DDP;
 
package Seq {
    use Moo;
    has [ 'id', 'comment', 'sequence' ] => ( is => 'rw' );
    1;
}
 
package FASTA {
    use Moo;
 
    my $parser = do {
        use Regexp::Grammars;
        qr/
    <TOP>
    <nocontext:>
    <token: TOP>  <[record]>+
    <token: record> <.start=(\>)><id><comment>?\n<sequence> 
    <token: id>  [^\-\s\n]+ 
    <token: comment> \s[^\n]+
    <token: sequence> <dna>|<rna>|<aa> 
    <token: dna> [ACGTRYKMSWBDHVNX\-\n]+ 
    <token: rna> [ACGURYKMSWBDHVNX\-\n]+ 
    <token: aa> [A-Z\*\-\n]+ 
    /;
    };
 
    has 'parser' => ( is => 'ro', default => sub { $parser } );
 
    sub record {
        my ( $self, $result ) = @_;
        return Seq->new(%$result);
    }
 
}
 
my $content = <<'END';
>hello
GCTATATAAGC
>world prot
TATAKEKEKELKL
END
my $fasta = FASTA->new();
if ( $content =~ $fasta->parser->with_actions($fasta) ) {
    p %/;
}
 
__END__
{
TOP   {
  record   [
	    [0] Seq  {
	      Parents       Moo::Object
		public methods (4) : comment, id, new, sequence
		private methods (0)
	      internals: {
		  id         "hello",
		    sequence   {
		                            dna   "GCTATATAAGC
"
					  }
		  }
	    },
	    [1] Seq  {
	      Parents       Moo::Object
		public methods (4) : comment, id, new, sequence
		private methods (0)
	      internals: {
		  comment    " prot",
		    id         "world",
		    sequence   {
		      dna   "TATAK"
		    }
		  }
	    }
	   ]
 }
}
```
[源代码2](https://gist.github.com/swuecho/09a0b815a2f08a74f140)

解析的结果是 Seq object，大致的过程是，当record 匹配以后，如果有actions 并且，actions 有record method，
那么，这个record method就会被调用。第二个参数是匹配的结果 result hash ref。请参考 record method。
这里为了方便，把record method 和 parser 放到了一个 namespace，这个并不是必须。


### 更OOP 的方式

以上差不多和 Perl6 的写法等价。 Regexp::Grammar 有更 OOP的简便写法。

```
use v5.20;
use DDP;
 
package Seq {
    use Moo;
    has [ 'id', 'comment', 'sequence' ] => ( is => 'rw' );
    1;
}
 
my $parser = do {
    use Regexp::Grammars;
    qr/
    <TOP>
    <nocontext:>
    <token: TOP>  <[record]>+
    <objtoken: Seq=record> <.start=(\>)><id><comment>?\n<sequence> 
    <token: id>  [^\-\s\n]+ 
    <token: comment> \s[^\n]+
    <token: sequence> <dna>|<rna>|<aa> 
    <token: dna> [ACGTRYKMSWBDHVNX\-\n]+ 
    <token: rna> [ACGURYKMSWBDHVNX\-\n]+ 
    <token: aa> [A-Z\*\-\n]+ 
    /;
};
 
my $content = <<'END';
>hello
GCTATATAAGC
>world prot
TATAKEKEKELKL
END
 
if ( $content =~ $parser ) {
    p %/;
}

```
[源代码3](https://gist.github.com/swuecho/67a8cedf03ed4d6b5e02)

这个结果与上一段代码是等价的。
注意 objtoken 那一行，

这个是文档中对objtoken的定义。
```
 <objtoken: CLASS= NAME>  Define token that blesses return-hash into class
```

其实 FASTA::record 的作用就是bless result hash 为 Seq object。 objtoken 相当于提供了一个简便写法。

## 后记
本文中的三段代码都是可以直接运行的。虽然并不一个完整的FASTA 文件 Parser。需要做些细节的改动，如果你手头有FATSTA 格式的文件，不妨再文中代码基础上，做改进。主要是要对 dan，rna 和 aa 加 action。

另外，Regexp::Grammars 有50多页的文档，本文最主要的没有提到的可能是Grammar 也可以继承的。

### 作者  

* [SWUECHO](https://metacpan.org/author/SWUECHO)
