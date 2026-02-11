# Beszel Dash

Steps to run:

1. `docker compose up -d`
   1. Note: the beszel-agent will give errors because it doesn't have a valid key and token. This is okay. It will be fixed in step 6.
2. Open http://localhost:8090 (or http://dash.$DOMAIN_NAME) in your browser
3. Click add system
4. Input `/beszel_socket/beszel.sock` as the `Host / IP`
5. Copy the public key and token and paste them into `./.env`
6. `docker compose up -d` again to restart the agent
