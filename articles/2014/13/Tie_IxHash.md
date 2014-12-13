# Tie::IxHash

众所周知，哈希 Hash 是无序的。但是有时候我们可能也需要一个有序的 Hash，这时候 [Tie::IxHash](https://metacpan.org/pod/Tie::IxHash) 就可以帮上忙了。

## 有序的 JSON 输出

当你使用 REST JSON 输出时，有时候你的老板可能要求你，比如把 id 放输出的 JSON 最前面。

比如你的原始代码如下：

    use JSON;
    my %r = (id => 1, name => 'Fayland', gender => 'male', bio => 'Just Another Perl Programmer');
    print encode_json(\%r);

然后输出可能不尽如人意：

    {"name":"Fayland","id":1,"bio":"Just Another Perl Programmer","gender":"male"}
    # {"bio":"Just Another Perl Programmer","gender":"male","id":1,"name":"Fayland"}
    # {"bio":"Just Another Perl Programmer","name":"Fayland","gender":"male","id":1}

任何一种可能都有。看起来不怎么好而且不容易 DEBUG （尤其是输出一个有很多 key 的 hash 时）

改动其实非常简单：

    use JSON;
    use Tie::IxHash;
    tie my %r, 'Tie::IxHash';
    %r = (id => 1, name => 'Fayland', gender => 'male', bio => 'Just Another Perl Programmer');
    print encode_json(\%r);

这样输出就永远都是

    {"id":1,"name":"Fayland","gender":"male","bio":"Just Another Perl Programmer"}

很简单，但是很管用。

## Tie::Hash::Indexed

[Tie::Hash::Indexed](https://metacpan.org/pod/Tie::Hash::Indexed) 是一个使用 XS 加速的 Tie::IxHash 替代品。但是目前测试不通过而且很久没有维护了。

## 作者
[Fayland Lam](http://fayland.me/)
