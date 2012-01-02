default["trac"]["project_name"] = "sandbox"
default["trac"]["trac_root_dir"] = "/opt/trac"
default["trac"]["svn_repository_root_dir"] = "/opt/svn"
default["trac"]["password_file"] = "/opt/trac_svn_password"
default["trac"]["admin_account"] = "admin"
default["trac"]["admin_password"] = "ADMIN"

default["trac"]["trac_project_dir"] = default["trac"]["trac_root_dir"]+"/"+default["trac"]["project_name"]
default["trac"]["svn_repository_dir"] = default["trac"]["svn_repository_root_dir"]+"/"+default["trac"]["project_name"]
