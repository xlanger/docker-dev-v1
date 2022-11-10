# docker-bake.hcl
variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["xphp", "xnginx", "xmysql", "xredis", "xmemcached"]
}

target "xphp" {
  dockerfile = "dockerfile/Dockerfile.php:7.4-fpm-alpine"
  tags = ["xphp:7.4-fpm-alpine"]
}

target "xphp8" {
  dockerfile = "dockerfile/Dockerfile.php:8.1-fpm-alpine"
  tags = ["xphp8:8.1-fpm-alpine"]
}

target "xnginx" {
  dockerfile = "dockerfile/Dockerfile.nginx:1.23-alpine"
  tags = ["xnginx:1.23-alpine"]
}

target "xmysql" {
  dockerfile = "dockerfile/Dockerfile.mysql:8.0"
  tags = ["xmysql:8.0"]
}

target "xredis" {
  dockerfile = "dockerfile/Dockerfile.redis:6.0-alpine"
  tags = ["xredis:6.0-alpine"]
}

target "xmemcached" {
  dockerfile = "dockerfile/Dockerfile.memcached:1.6-alpine"
  tags = ["xmemcached:1.6-alpine"]
}
