# Keyczar

在不同语言之间做加密解密，有时候不得不说是个噩梦。CBC/Blowfish 或者 RSA 不同的参数，有时候哪怕把头发都抓没了，也找不到解决方案。

幸运的是 [keyczar](http://www.keyczar.org/) 是一个很不错的选择。

## 应用场景

一个普通的应用场景是，如果您做一个手机项目，里面有个登陆窗口。你希望在发送验证请求的时候给密码加密，这样整个 app 会显得更加安全。这里我们将尝试用 keyczar 通过 RSA 来做这个应用。

### 安装

首先您需要安装 cpanm [Crypt::Keyczar](https://metacpan.org/pod/Crypt::Keyczar)

其次您需要安装 java，然后从 [https://code.google.com/p/keyczar/downloads/list](https://code.google.com/p/keyczar/downloads/list) 下载所需的 keyczar jar

### key 的建立

    $ java -jar KeyczarTool-0.71g-090613.jar create --location=crypt-rsa --purpose=crypt --asymmetric=rsa
    $ java -jar KeyczarTool-0.71g-090613.jar addkey --location=crypt-rsa --status=primary
    $ java -jar KeyczarTool-0.71g-090613.jar pubkey --location=crypt-rsa --destination=crypt-rsa-pub

_KeyczarTool-0.71g-090613.jar 文件可能会改变名字_

### java 加密

简单的代码如下：

    import org.keyczar.*;
    public class demo {
        public static void main(String[] args) throws Exception {
            KeyczarFileReader reader = new KeyczarFileReader("./crypt-rsa-pub");
            try {
                Encrypter crypter = new Encrypter(reader);
                System.out.print(crypter.encrypt("hello") + "\n");

            } catch (org.keyczar.exceptions.KeyczarException e) {
                System.out.print("ng\n");
            }
        }
    }

测试如下：

    $ javac demo.java
    $ java demo
    AGi_FoJaaJNH52pvBgkMP94uyh7nTYXA5_OQARB5X900PLgHKPrnlDHG65OVPeYPHMLHaosqUFFTdAq_ECKrLG1qtPmp8ai7xpZycqWYfKaGezIe-ANjo1_nutwhbWEK5ixV2CRX7tsEZQ_zilkXH9KUpxZKB4j_xfL5n5q4Op6CA7FmsS--OLtHiWpvCGiw0JfCSJMjnefUVVM8apTU6vR-T-Sb--jAj4UlT_Tn7NlsVwgEAtLJZ9Qhw-4SqLhQwY-9SvzENSZ9gFWpogfzS622820dcbBTRJ-Pu37mIrBen2CuESQI2tpm08Xa45nnA2zhZZoy4xrWKwkkAQOI31Tg05cV2I3mpAEPbLpy0CcppHvyPOyxVsPw7-slgtASDYqUf_S3UNmO8yi9EOvgjmdi0WUEm41aSlr2UizMnGYZONE2RSK1PHAQlxm0-03-X-quBiE7MT5C75FlWz6iYa2LOmKwVPaydjpHur2bMXfn_pVdgYnoPmjHIfKPLuBq4lH_9qqbK9hk83GxJLQeTQ92cdOcgir9-dd6v3OE15Xf8viLCOcgao5iot7B3y76KTY2I42mcrzP8rKWokvoE3xOelkyeaZSgFKQq4wLxf7L7pbQl5s4rl8pdkXyysvWM5lUmLxduc2VRiKVXEDC55Y81CnkJmiULw9XLAUyz1chuLTKog

### perl 解密

简单代码如下：

    use v5.10;
    use FindBin qw/$Bin/;
    use Crypt::Keyczar::Crypter;

    my $msg = shift @ARGV or die "message is required.\n";

    my $c = Crypt::Keyczar::Crypter->new("$Bin/crypt-rsa");
    say $c->decrypt(Crypt::Keyczar::Util::decode($msg));

运行：

    $ perl decrypt.pl AGi_FoJaaJNH52pvBgkMP94uyh7nTYXA5_OQARB5X900PLgHKPrnlDHG65OVPeYPHMLHaosqUFFTdAq_ECKrLG1qtPmp8ai7xpZycqWYfKaGezIe-ANjo1_nutwhbWEK5ixV2CRX7tsEZQ_zilkXH9KUpxZKB4j_xfL5n5q4Op6CA7FmsS--OLtHiWpvCGiw0JfCSJMjnefUVVM8apTU6vR-T-Sb--jAj4UlT_Tn7NlsVwgEAtLJZ9Qhw-4SqLhQwY-9SvzENSZ9gFWpogfzS622820dcbBTRJ-Pu37mIrBen2CuESQI2tpm08Xa45nnA2zhZZoy4xrWKwkkAQOI31Tg05cV2I3mpAEPbLpy0CcppHvyPOyxVsPw7-slgtASDYqUf_S3UNmO8yi9EOvgjmdi0WUEm41aSlr2UizMnGYZONE2RSK1PHAQlxm0-03-X-quBiE7MT5C75FlWz6iYa2LOmKwVPaydjpHur2bMXfn_pVdgYnoPmjHIfKPLuBq4lH_9qqbK9hk83GxJLQeTQ92cdOcgir9-dd6v3OE15Xf8viLCOcgao5iot7B3y76KTY2I42mcrzP8rKWokvoE3xOelkyeaZSgFKQq4wLxf7L7pbQl5s4rl8pdkXyysvWM5lUmLxduc2VRiKVXEDC55Y81CnkJmiULw9XLAUyz1chuLTKog
    hello

## 总结

原则上就是这么简单。测试代码可以从 [https://github.com/PerlChina/mojo-advent/examples/keyczar/](https://github.com/PerlChina/mojo-advent/examples/keyczar/) 下获取。

## 作者
[Fayland Lam](http://fayland.me/)