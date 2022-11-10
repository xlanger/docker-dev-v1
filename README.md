# Docker 搭建本地开发环境

## 镜像批量创建 & 运行测试

`docker-bake.hcl` 定义了需要创建的镜像，`dockerfile` 目录预先定义了镜像的Dockerfile文件。

```bash
$ docker buildx bake -f docker-bake.hcl --no-cache
```

拷贝 `docker-compose.yml.example` 到 `docker-compose.yml` ，然后运行测试。

```bash
$ cp docker-compose.yml.example docker-compose.yml
$ docker compose up -d
[+] Running 6/6
 ⠿ Network docker-dev-v1_dev-net  Created                   0.1s
 ⠿ Container php                  Starte...                 3.1s
 ⠿ Container redis                Star...                   4.3s
 ⠿ Container nginx                Star...                   4.7s
 ⠿ Container mysql                Star...                   4.4s
 ⠿ Container memcached            Started                   4.9s
$ docker compose down
[+] Running 6/6
 ⠿ Container mysql                Remo...                  10.7s
 ⠿ Container memcached            Removed                   2.3s
 ⠿ Container redis                Remo...                   0.1s
 ⠿ Container php                  Remove...                 1.5s
 ⠿ Container nginx                Remo...                   1.6s
 ⠿ Network docker-dev-v1_dev-net  Removed                   0.1s
```

---

## 配置挂载点

实际开发中，我们需要挂载本地应用到容器中测试，还需要修改运行配置，对于测试数据或者日志通常也要持久化到主机上存储（也可以通过 `docker volume` 创建容器来做持久化数据存储），不论是文件还是目录，都可以使用 `volumes` 挂载点进行挂载，`docker-compose.yml` 可以参考。

```bash
$ mkdir -p /path/to/data/mysql /path/to/data/redis
$ cp -R /path/to/conf.default  /path/to/conf
```

上面 `/path/to` 表示当前 `docker compose up -d` 命令执行目录。

### 配置PHP & 创建Laravel应用

通过 `docker exec php ls /path/to` 查找容器中的默认的文件或目录，如：

```bash
$ docker exec php ls /usr/local/etc/
pear.conf
php
php-fpm.conf
php-fpm.conf.default
php-fpm.d
```
或者 `docker exec -it php /bin/sh` 打开一个容器的终端窗口，如：
```bash
$ docker exec -it php /bin/sh
/var/www/html #
```
查找到要修改的对应配置文件，通过 `docker cp` 拷贝到本地做个性化配置，如：

```bash
$ docker exec -i php ls /usr/local/etc/php-fpm.conf
/usr/local/etc/php-fpm.conf
$ docker cp php:/usr/local/etc/php-fpm.conf /path/to/php # 拷贝了 php-fpm.conf 文件
$ ls /path/to/php
php-fmp.conf
$ docker exec -i php ls /usr/local/etc/php/php.ini-development
/usr/local/etc/php/php.ini-development
$ docker cp php:/usr/local/etc/php/php.ini-development /path/to/php # 拷贝了 php.ini-development 文件
$ mv php.ini-development php.ini
$ ls /path/to/php
php-fpm.conf php.ini
```

为测试准备一个 Laravel 应用，使用 `composer` 创建如下：
```bash
$ docker build --no-cache -t xcomposer:2.4 - < Dockerfile.composer:2.4
$ docker run --rm -i -v /path/to/workspace:/app xcomposer:2.4 create-project laravel/laravel larraveltest
```

## 配置Nginx & PHP & Laravel

`Nginx` 默认配置在容器中的目录是 `/etc/nginx`，需要的话自行修改。
```bash
$ docker exec -i nginx ls /etc/nginx/nginx.conf
/etc/nginx/nginx.conf
$ docker cp nginx:/etc/nginx/nginx.conf /path/to/conf/nginx
```

`conf/nginx/conf.d` 目录为 `PHP & Laravel` 准备了两个配置文件，其中定义了虚拟主机域名和应用挂载目录 `/wwwdir`，根据自己情况调整。

## 配置MySQL

`MySQL` 默认配置在容器中的位置是 `/etc/my.cnf`, 其中默认配置 `datadir=/var/lib/mysql` 指定了数据存储目录，也就是我们要挂载的位置，第一次启动容器需要打开 `MYSQL_ROOT_PASSWORD=rootpwd` 环境变量，为MySQL设置root用户密码，之后必须注释掉。

## 配置Redis

预先准备的 `Redis` 配置文件 `conf/redis/redis.conf`，指定了数据存储的挂载目录是 `dir /var/lib/redis`，在挂载了配置文件后，记得启用配置 `redis-server /etc/redis.conf`。

![测试结果](/test.jpg "PHP & Laravel9")