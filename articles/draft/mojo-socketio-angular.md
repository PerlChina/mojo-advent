# Mojolicious + SocketIO + AngularJS

今天本来是准备随便写点跟 Web 开发相关的话题，毕竟今年 YAPC 上最大的声音就是 SaywerX 的[“CGI.pm must DIE!”](www.youtube.com/watch?v=tu6_3fZbWYw)。正在犹豫是介绍 [Mojolicious](https://metacpan.org/pod/Mojolicious) 还是 [PocketIO](https://metacpan.org/pod/PocketIO) 模块的时候，偶然在 gist 上看到一个单文件程序，结合了 Mojolicious、socket.io 和 angular.js 三大框架，简直就是任性。那么好，今天就拿这个做例子说一说好了：

## Mojolicious::Lite 的 DSL

因为是单文件程序，所以用的是 Mojolicious::Lite，这个提供了一些很方便的类 sinatra 的 DSL。常见的情况是 `get '/' => sub($c) { $c->render('index') }` 这样。如果一个 url 路径同时可能有 GET 或者 POST 请求，那么就用 `any` 指令。这里就是：

    use Mojolicious::Lite;
    use Protocol::SocketIO::Message;
    use Protocol::SocketIO::Handshake;
    use Class::Date;
    
    any '/' => 'index';
    any '/view1' => 'index';
    any '/view2' => 'index';
    
    any '/partials/:name' => sub {
        shift->render( $self->param('name') );
    };

在 url 路径这里可以做捕获，方便在控制器函数里处理。这里用到了 `/socket.io/` 这个路径。这是 socket.io 协议规定的固定路径。

    any '/socket.io/:id/' => sub {

渲染方法支持很多种方式。默认写法的话，会自动去找同名的 `.html.ep` 模板来渲染 —— 这种情况更简写的方式就是前面已经看到的 `any '/' => 'index'`，其实就是去找 `index.html.ep` 文件。

如果写 API ，很多时候返回的并不是 HTML 内容，Mojolicious 也支持渲染其他格式的响应。最常见的是 `->render(json => $ref)` 这样。不过这里 socket.io 因为有单独的协议，所以是用 Protocol::SocketIO(这个包就是出自原先我打算讲的 PocketIO 模块) 来单独生成响应。

        shift->render( text=> Protocol::SocketIO::Handshake->new(
            session_id        => 1234567890,
            heartbeat_timeout => 10,
            close_timeout     => 15,
            transports        => [qw/websocket xhr-polling/]
        ) );
    };

普通的 web 方法在 Mojolicious 里大致就是这样。下面进入更高级的异步交互环节了！

我们这里示例的是一个每秒自动更新时间的页面。所以 Mojolicious 要定时执行。`Mojo::IOLoop->delay` 是个完全值得单独讲一次的好东西：

    my $clients = {};
    
    my $delay = Mojo::IOLoop->delay;
    Mojo::IOLoop->recurring( 1 => sub {
        for my $id( keys %$clients ) {
            # send name
            $clients->{$id}->send( Protocol::SocketIO::Message->new( type => 'event', data=>{ name=>'send:name', args=>[{ name=>'Jamie '.$id }] }) );
            # send time
            $clients->{$id}->send( Protocol::SocketIO::Message->new( type => 'event', data=>{ name=>'send:time', args=>[{ time=>''.Class::Date->now }] }) );
        }
    });

Mojolicious 本身直接指示 websocket 协议。所以用起来 DSL 跟做 GET/POST 是一样的。而控制器函数里用法也跟 socket.io 的写法有些类似。采用 `$self->on(message => sub {})`。

在控制器里，Mojolicious 允许直接操作整个请求响应的事务主体，也就是代码中的 `$self->tx` 。在异步处理的时候，肯定会需要直接操作 tx，这里作为一个纯粹的定时器，就只需要 send 了：
    
    websocket '/socket.io/:id/websocket/:oid' => sub {
        my $self = shift;
    
        app->log->debug(sprintf 'Client connected: %s', $self->tx);
        my $id = sprintf "%s", $self->tx;
        $clients->{$id} = $self->tx;
    
        $self->tx->send( Protocol::SocketIO::Message->new( type => 'connect') );
        $self->tx->send( Protocol::SocketIO::Message->new( type => 'event', data=>{ name=>'send:name', args=>[{ name=>'Jamie starting...' }] }) );
        $self->on(message => sub { 
            my ($self, $msg) = @_; 
            # no messages are being sent for now
        });
        $self->on(finish => sub { 
            app->log->debug('Client disconnected');
            delete $clients->{$id};
        });
    };

最后，调用 start 方法开始运行服务器：

    app->start;

## AngularJS 示例

Mojolicious::Lite 支持在 Perl 的 `__DATA__` 里直接写页面内容，每个页面以 @@开头命名即可：

    __DATA__
    
    @@index.html.ep 

### angular 的模板和变量绑定

angular 深度的改造了 HTML 的样式和书写方式，在前端的层面上提供 MVC 功能。在使用 `ng-app` 标记整个页面归属的具体 angular 应用后，可以利用 `ng-controller` 指令将一个 div 关联到一个 angular 的控制器上。在这个 div 内，可以通过 `{{ }}` 语法加载控制器函数里的变量，可以渲染带有 `ng-view` 指令的 div 作为 HTML 内容展示。

    <!DOCTYPE html>
    <html ng-app="myApp">
    <head>
    <meta charset="utf8">
    <base href="/">
    <title>Angular Socket.io Seed App</title>
    <link rel="stylesheet" href="app.css">
    </head>
    <body>
        <div ng-controller="AppCtrl">
            <h2>Helloo {{name}}</h2>
            <ul class="menu">
                <li><a href="view1">view1</a></li>
                <li><a href="view2">view2</a></li>
            </ul>
            <div ng-view></div>
        <div>
            Angular Socket.io seed app: v<span app-version></span></div>
        </div>
    
        <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.0.6/angular.min.js"></script>
        <script src="socket.js"> </script>
        <script src="app.js"> </script>
    </body>
    </html>
    
    @@partial1.html.ep
    <p>This is the partial for view 1.</p><p>The current time is {{time}}</p>
    
    @@partial2.html.ep
    <p>This is the partial for view 2.</p><p>Showing of 'interpolate' filter:
    {{ 'Current version is v%VERSION%.' | interpolate }}</p>

### angular 的应用模块

上面页面部分就完成了。下面就开始在 js 中完成这个 angular 应用。我们前面已经看到，这个页面归属的应用名字叫 **myApp**。下面是应用的代码：

    @@app.js
    'use strict';
    
    // Declare app level module which depends on filters, and services
    var app = angular.module('myApp', ['myApp.filters', 'myApp.services', 'myApp.directives']).
      config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
        $routeProvider.when('/view1', {templateUrl: 'partials/partial1', controller: MyCtrl1});
        $routeProvider.when('/view2', {templateUrl: 'partials/partial2', controller: MyCtrl2});
        $routeProvider.otherwise({redirectTo: '/view1'});
        $locationProvider.html5Mode(true);
      }]);

非常清晰，实现这个 myApp，加载了对应的 filters、services、directives 模块，然后定义了两个路由规则，分别指向两个不同的模板和控制器。

### angular 的控制器

angular 的控制器，最主要的作用就是处理应用作用域 `$scope` 与其他各种数据的关联。在这个示例里，就是把前面模板里的变量，跟 socket.io 从服务器拿到的数据关联在一起：

    function AppCtrl($scope, socket) {
      socket.on('send:name', function (data) {
        $scope.name = data.name;
      });
    }
    
    function MyCtrl1($scope, socket) {
      socket.on('send:time', function (data) {
        $scope.time = data.time;
      });
    }
    MyCtrl1.$inject = ['$scope', 'socket'];
    
    function MyCtrl2() {
    }
    MyCtrl2.$inject = [];

### angular 的指令

angular 的指令的作用，就是实际操作、修改变更应用中的数据，包括可能页面元素的变化等等。一般的 Web 开发中，这个事情是交给 jQuery 来操作 DOM 的。而在 angular 里。编写成指令，可以直接写成 HTML 元素的属性，看起来非常清爽。比如这个示例中就是生成了一个 `appVersion` 指令，在前面的 HTML 里，用在了一个 span 元素上。

    angular.module('myApp.directives', []).
      directive('appVersion', ['version', function(version) {
        return function(scope, elm, attrs) {
          elm.text(version);
        };
      }]);

### angular 的过滤器

angular 的过滤器，可以利用管道的方式帮助模板中的变量达到更好的渲染效果，默认提供有 date、json、limitTo、orderBy、number、lowercase、uppercase 等几个过滤器。也可以自己写新的过滤器。过滤器函数很简单，传一个参数返回一个结果即可：

    angular.module('myApp.filters', []).
      filter('interpolate', ['version', function(version) {
        return function(text) {
          return String(text).replace(/\%VERSION\%/mg, version);
        }
      }]);

### angular 的服务和工厂

augular 利用服务(service)或者工厂(factory)的方式来提供整个应用里，不同路由或者说控制器之间共用的单例变量。这二者的不同在于：service 其实就是一种不导入其他变量的简单 factory 的简写。比如下面这段代码是原程序中用 factory 写的，虽然名叫 myApp.services：

    // Demonstrate how to register services
    // In this case it is a simple value service.
    angular.module('myApp.services', []).
      value('version', '0.1').
      factory('socket', function ($rootScope) {
        var socket = io.connect();
        return {
          on: function (eventName, callback) {
            socket.on(eventName, function () {  
              var args = arguments;
              $rootScope.$apply(function () {
                callback.apply(socket, args);
              });
            });
          },
          emit: function (eventName, data, callback) {
            socket.emit(eventName, data, function () {
              var args = arguments;
              $rootScope.$apply(function () {
                if (callback) {
                  callback.apply(socket, args);
                }
              });
            })
          }
        };
      });

可以看到就没有导入其他东西，所以可以写成服务，代码应该是下面这样：

    angular.module('myApp.services', []).
      value('version', '0.1').
      service('socket', function ($rootScope) {
        var socket = io.connect();
        this.on = function (eventName, callback) {
          ...
        };
        this.emit = function (eventName, data, callback) {
          ...
        };
      });

## socket.io 接口

上面 angular 服务里，就演示了 socket.io 的客户端用法。可以看到，其实客户端的接口跟服务器端是一一对应的。

示例程序再往下就是纯粹的js和css文件，这就不再继续了。完整代码源地址见：<https://gist.github.com/rodrigolive/5546320>

## 警告

socket.io 的客户端 js 在本例中还是用的去年的 0.90 的版本。最近半年 socket.io 项目发生重大改变，从 1.0 开始，有了自己专门的协议分析库 engine.io，整个 url 路径和 handshake 编解码方式都不太一样了。在 Perl 方面，PocketIO 作者没时间跟进这个变化，所以 Protocol::SocketIO 还是只能支持 0.90 的版本。
