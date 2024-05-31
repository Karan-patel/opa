package mycoolservice.authz

default allow = false

# Allow POST method if the user has an admin role
allow {
    input.method == "POST"
    input.user.role == "admin"
}

# Allow GET(read) method if the user is 'authenticated'
allow {
    input.method == "GET"
    input.user.authenticated == true
}
