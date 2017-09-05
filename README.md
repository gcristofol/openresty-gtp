openresty-quickstart
========

> A barebones [OpenResty](https://openresty.org) project structure.

## Getting Started

/usr/local/openresty/nginx/sbin/nginx -p `pwd` -c conf/nginx.conf

```
nginx -p <PWD> -c conf/nginx.conf
```

Replace `<PWD>` with this project's working directory.
Then, visit `http://localhost:8080` through `cURL` or your browser!

> You may need to make sure your nginx executable is in your `PATH`. In your terminal:
>
> ```
> PATH=/usr/local/openresty/nginx/sbin:$PATH
> export PATH
> ```
