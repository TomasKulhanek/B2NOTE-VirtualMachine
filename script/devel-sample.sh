# sample of devel, make copy to devel.sh and put id and secret for your b2note instance
GAUTH_CLIENT_ID="abcd.apps.google.com" # obtain after registration at https://console.developers.google.com/?pli=1
GAUTH_CLIENT_SECRET="some-secret"
GAUTH_BASE_URI=http://localhost/b2note  # change to FQDN if on public server
GAUTH_AUTH_REDIRECT_URI=http://localhost/api/google/auth # change to FQDN if on public server
B2NOTE_SECRET_KEY="abc123" # generate randomly
B2ACCESS_CLIENT_ID="my-client-id" # define the id and secret values and register at  https://unity.eudat-aai.fz-juelich.de:443/home/home or prod-https://b2access.eudat.eu/home/home
B2ACCESS_CLIENT_SECRET="my-secret"
B2ACCESS_REDIRECT_URI=http://localhost/b2note # change to FQDN if on public server