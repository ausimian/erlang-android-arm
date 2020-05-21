# erlang-android-arm

A dockerfile for building an erlang 23.0 distribution suitable for running on 32-bit android.

The dockerfile also builds a version of OpenSSL suitable for Android, enabling the crypto and ssl applications.
Distribution appears to work.

## Build

    docker build -t <tag> .

    docker run --mount type=bind,source=<my/src/dir>,target=/otp <tag>
  
## Deploy

These commands will build erlang for android arm 32-bit and place the distribution in <my/src/dir>. From here, you can use `adb` to push it to your device. Note that historically, `adb` has had issues with symlinks so the `epmd` symlink is removed and recreated on the device.

    cd <my/src/dir>
    rm erlang/bin/epmd
    adb push erlang /data/local/tmp
    adb shell ln -s /data/local/tmp/erlang/erts-6.4.1/bin/epmd /data/local/tmp/erlang/bin/epmd
  
## Run

    adb shell
    cd /data/local/tmp/erlang
    sh bin/erl
  
## Example


    Z5031O:/data/local/tmp/erlang $ 
    Z5031O:/data/local/tmp/erlang $ sh bin/erl                                                                      
    Eshell V11.0  (abort with ^G)
    1> inets:start().
    ok
    2> ssl:start().
    ok
    3> httpc:request("https://elixir-lang.org").
    {ok,{{"HTTP/1.1",200,"OK"},
         [{"cache-control","max-age=600"},
          {"connection","keep-alive"},
          {"date","Thu, 21 May 2020 15:31:16 GMT"},
          {"via","1.1 varnish"},
          {"accept-ranges","bytes"},
          {"age","0"},
          {"etag","\"5ec577d8-4aab\""},
          {"server","GitHub.com"},
          {"vary","Accept-Encoding"},
          {"content-length","19115"},
          {"content-type","text/html; charset=utf-8"},
          {"expires","Thu, 21 May 2020 15:41:16 GMT"},
          {"last-modified","Wed, 20 May 2020 18:32:56 GMT"},
          {"access-control-allow-origin","*"},
          {"x-proxy-cache","MISS"},
          {"x-github-request-id","B38A:510E:EBB83:12700E:5EC69EC3"},
          {"x-served-by","cache-syd10151-SYD"},
          {"x-cache","MISS"},
          {"x-cache-hits","0"},
          {"x-timer","S1590075076.188176,VS0,VE205"},
          {"x-fastly-request-id",
           "d07590445f5f85383b61444170498a7a12d0bb85"}],
         [60,33,68,79,67,84,89,80,69,32,104,116,109,108,62,10,60,104,
          116,109,108,32,120,109|...]}}
    4> 

  
## Caveats

Tested on a single crappy android device and nowhere else.
