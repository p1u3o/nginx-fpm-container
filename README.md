# nginx-fpm-container
This is a Dockerfile for running nginx and php-fpm inside the same container in a relatively sane way.

Read the Dockerfile for more documentation.

You should probably replace the self-signed SSL.
```
cd ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout internal.key -out internal.crt
```

The container uses /app/public, so install your application with something like

```
COPY app /app
```
if your application has a public folder, otherwise just put everything in public.