#!/usr/bin/env sh
alias filebrowser='filebrowser --database /database/filebrowser.db'
if ! [ -e /database/filebrowser.db ]; then
  filebrowser config init --branding.files /branding --branding.disableExternal --branding.name Jellyfin --auth.method noauth --hideLoginButton
  filebrowser users add admin admin-password123 --aceEditorTheme twilight --perm.admin --redirectAfterCopyMove
fi
# NOTE: This matches ENTRYPOINT here: https://github.com/filebrowser/filebrowser/blob/master/Dockerfile#L46
exec tini -- /init.sh
