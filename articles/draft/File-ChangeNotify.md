# File::ChangeNotify

[File::ChangeNotify](https://metacpan.org/pod/File::ChangeNotify)通过系统事件通知来获悉文件的变化，所以其性能较好，CPU占用率也低。

我们可以使用[File::ChangeNotify](https://metacpan.org/pod/File::ChangeNotify)监测文件/目录的变化，来达到某些自动化操作。

例如：

1. nginx -s reload

当然[File::ChangeNotify](https://metacpan.org/pod/File::ChangeNotify)也有表现不正常的时候，正如我最近用Vagrant+VirtualBox搭建的Debian 7开发环境，经Host修改的文件，在Guest中用File::ChangeNotify就因为整个环境的问题，修改过的文件，Guest系统并没有发出notify事件，所以[File::ChangeNotify](https://metacpan.org/pod/File::ChangeNotify)无法被通知到。当然这不能算是[File::ChangeNotify](https://metacpan.org/pod/File::ChangeNotify)的问题了。

下面是我工作场景的一个示例，监测一些目录的文件变化，并执行drush来清除Drupal Cache操作：

	#!perl

	# 监控drupal sites下的module文件，有改变则用drush cc清除cache
	# 此脚本需要在drupal_site_path对应的目录下执行
	# usage: 
	# 1. cd the_drupal_site_path
	# 2. perl $0 path1 path2 path..n

	use strict;
	
	use File::ChangeNotify;
	
	sub usage
	{
		die "perl $0 path1 path2 path..n\n";
	}
	
	my @site_path = @ARGV;
	if (!@site_path)
	{
		&usage();
	}
	
	my $watcher = File::ChangeNotify->instantiate_watcher(
		directories => [@site_path],
		filter => qr/\.(?:module|inc|info|php)$/,
		sleep_interval => 1,
	);
	
	print "monitor @site_path, wait for events\n\n";
	
	while (my @events = $watcher->wait_for_events())
	{
		print "\nclear cache at: " . scalar(localtime()) . "\n";
		system('drush cc all');	
		print "\n";
	}

## 作者
[Beckheng Lam](http://blog.yixinit.com/)