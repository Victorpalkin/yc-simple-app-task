output "db_id" {
  value = yandex_mdb_mysql_database.service.id
}

output "host" {
  value = yandex_mdb_mysql_cluster.main.host
}

output "username" {
  value = yandex_mdb_mysql_user.admin.name
}

output "password" {
  value     = yandex_mdb_mysql_user.admin.password
  sensitive = true
}