# cpanfile

传统的 Perl 风格，是将依赖模块写在 Makefile.PL 里。无奈这个单词实在给人太大精神压力，而且在一些项目应用中，我们也不需要除了依赖关系以外其他的 Makefile 内容。所以 modern perl 从 Ruby 学来了 Gemfile 的方式，叫做 [cpanfile](https://metacpan.org/pod/cpanfile)。

cpanfile 写法示例如下：

    requires 'perl', '5.20.0';
    requires 'Plack', '1.0'; # 1.0 or newer
    requires 'JSON', '>= 2.00, < 2.80';
     
    recommends 'JSON::XS', '2.0';
    conflicts 'JSON', '< 1.0';
     
    on 'test' => sub {
      requires 'Test::More', '>= 0.96, < 2.0';
      recommends 'Test::TCP', '1.12';
    };

支持 cpanfile 格式的安装工具，目前有两个：[cpanm](https://metacpan.org/pod/cpanm) 和 [carton](https://metacpan.org/pod/carton)。

cpanm 在之前的 advent 已经介绍过，可以说是目前最推荐的 cpan 客户端命令了。在有 cpanfile 存在的目录下，执行如下命令即可安装 cpanfile 里列出的全部依赖模块：

    $ cpanm --installdeps .

而 carton 则是学习 Ruby 的 bundle 命令。了解 bundle 的，基本可以直接照着习惯用 carton 就好了。如果不了解的，继续往下看。

## carton 用法

### 安装依赖

同样是在有 cpanfile 存在的目录下，执行如下命令安装依赖模块：

    $ carton install

和采用 cpanm 方式不同的是，这个命令会在目录下新生成一个文件叫 `cpanfile.snapshot`。这个文件里会记录你这次安装的时候的模块的确切版本，这样你通过 github 等方式共享给其他人、发布到服务器等的时候，再用下面的命令安装就可以同样做到安装完全一致的版本的模块了：

    $ carton install --deployment

### 执行

carton 和 cpanm 的另一个不同， cpanm 默认是把模块安装到系统目录里，用 -L 参数指定才会到指定目录。而 carton 默认是安装到当前目录的 **local/** 子目录下。所以，就需要利用 carton 命令来启动应用才能找到正确的路径：

    $ carton exec hypnotoad ./script/myapp

### 打包

carton 有专门的一个 bundle 命令。把之前 install 在 **local/** 里的模块，复制到 **vendor/cache** 目录下。然后通过下面命令来安装：

    $ carton install --cached

看起来似乎有点多此一举，分发的时候发哪个目录不都一样么？要点在于：carton 复制到 **vendor/cache** 目录下的，不是安装好的模块，而是各模块的 .tar.gz 包。这样，对于跨不同平台和系统环境的部署，这个会重新走一遍编译的过程，有些 XS 就不会有问题了。

好了，大家快给自己的项目加上 cpanfile 吧~
