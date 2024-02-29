# davis

> 🗓 A simple, fully translatable admin interface for sabre/dav based on Symfony 5 and Bootstrap 5, initially inspired by Baïkal
> [upstream](https://github.com/tchapi/davis?)


## Volumes

* `/var/www/davis/var` - (required) you must write a writeable volume to this path, it can be an `emptyDir`, it is used for php caching
* `/data` - (optional) useful if you want to use a sqlite database

## Custom environment configuration

In addition the the environment variables supported by upstream davis, the following env variables are also available:


| Name                            | Default             | What? |
|---------------------------------|---------------------| --- |
| DAVIS_SERVER_NAME | | The nginx server_name, should be your dav domain name. |
| DAVIS_UPSTREAM | `127.0.0.1:9000` | The host:port of the upstream php-fpm davis |
