# Milla

[CPAN](https://metacpan.org/) 是 Perl 的骄傲。我想每个使用 Perl 的人心里都有对社区回馈的想法，这里我们将使用 [Milla](https://metacpan.org/release/Dist-Milla) 和其他一些流行的服务来构建一个完整地模块流程。

## 安装 Milla

    $ cpanm Dist::Milla

Milla 是一个 [Dist::Zilla](https://metacpan.org/release/Dist-Zilla) 的优秀合集。所以它所依赖的模块有点多。因为 dzil/milla 是一个工具，启动时间不是很重要，所以它们都使用了 [Moose](https://metacpan.org/pod/Moose)

## 配置个人偏好

    $ milla setup

输入名字，电邮和喜欢的版权，PAUSE 账号。它会将信息存放在 ~/.dzil/config.ini

## 创建项目

    $ milla new Acme-CPANAuthors-Chinese
    $ cd Acme-CPANAuthors-Chinese

该命令创建了一个模块目录，然后里头做了 git init，构建了基本的文件如下：

    Changes
    cpanfile
    dist.ini
    lib
    lib/Acme
    lib/Acme/CPANAuthors
    lib/Acme/CPANAuthors/Chinese.pm
    t
    t/basic.t

这大致上就是您所需要工作的所有文件。其他的比如 Makefile.PL, MANIFEST, README 等，milla 会在 build 或者 release 时自动构建。

## 开始真正工作

    * cpanfile - 模块所依赖的模块。比如这里我们需要加入行
        requires 'Acme::CPANAuthors';
    * Changes - 将您做的改动放到 {{$NEXT}} 的下一行。{{$NEXT}} 会在发布时自动根本版本号和发布时间
    * lib/Acme/CPANAuthors/Chinese.pm - 主模块。
    * t/ - 测试文件。

## 额外服务

### Git

您需要一个开源的版本号来放置您的代码，这样方便大家如果发现问题可以 fork 然后给您发送补丁。推荐使用 [GitHub](https://github.com/)

当您创建一个 repo 后，在命令行下：

    $ git remote add origin https://github.com/user/repo.git
    $ git commit -am "blabla"
    $ git push

来放置您的代码。更多的 git 使用可以参考 Pro Git 免费中文书。

### Travis

[Travis](https://travis-ci.org/) 是一个免费得测试服务器。可以使用 GitHub 账号登陆，然后在 https://travis-ci.org/profile 对该 repo 启用服务。

### Coveralls

[Coveralls](https://coveralls.io/) 是一个测试代码覆盖率的服务。同样使用 GitHub 登陆，然后对该 repo 启动服务。

### 额外代码

启用服务后，我们需要一个通用的 .travis.yml 来指定测试内容

    $ cat .travis.yml
    language: perl
    perl:
        - "5.18"
        - "5.16"
        - "5.14"
        - "5.12"
        - "5.10"
    before_install:
        - "cpanm --installdeps ."
        - "cpanm Devel::Cover::Report::Coveralls"
    script:
      perl Makefile.PL && make test && cover -test -report coveralls

另外我们这里需要用 Makefile.PL, 所以修改下 dist.ini

    $ cat dist.ini
    [@Milla]
    installer = MakeMaker

    [GitHubREADME::Badge]
    badges = travis
    badges = coveralls

GitHubREADME::Badge 是一个 Dist::Zilla 的插件用来显示 Travis/Coveralls 的 Badge.

## 发布代码

发布之前您需要做下测试

    $ milla test

然后 prove -lr t/ 也是可以的。

激动人心的时候来了，发布从来没有如此简单过：

    $ milla release

然后我们就成功发布了该模块。

    $ milla clean

来清除创建的额外目录。

## 总结

为什么 Milla 要比其他的好，那是因为 Milla 可以让我们专注于您所需要专注的地方：

    * 您无须关心 Makefile.PL MANIFEST LICENSE META.* 是什么了和做什么了
    * 您无须更新所有的模块的版本号了。
    * 您无须更新 Changes 发布的时间了。
    * 您无须做 git tag 了
    * Travis 可以直接测试您的模块，在不同版本的 perl 下
    * Coveralls 告诉您模块的测试代码覆盖率，好好考虑下您应该尽量多写测试了

尝试一下，您会喜欢它的。

另外完整的代码在 [https://github.com/PerlChina/Acme-CPANAuthors-Chinese](https://github.com/PerlChina/Acme-CPANAuthors-Chinese)

## 作者
[Fayland Lam](http://fayland.me/)