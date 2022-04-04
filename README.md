# Remmina in Docker optimized for Unraid
Remmina is a remote desktop client for POSIX-based computer operating systems. It supports the Remote Desktop Protocol, VNC, NX, XDMCP, SPICE and SSH protocols.

With this container you can connect through VNC to your RDP session, SSH,...

At the bottom is an example how to reverse proxy noVNC with nginx and secure it via http basic authentification.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for gamefile | /remmina |
| CUSTOM_RES_W | Your preferred screen width | 1280 |
| CUSTOM_RES_H | Your preferred screen height | 1024 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | User file permission mask for newly created files | 000 |
| DATA_PERM | Data permissions for main storage folder | 770 |

## Run example
```
docker run --name Remmina -d \
    -p 8080:8080 \
    --env 'CUSTOM_RES_W=1280' \
    --env 'CUSTOM_RES_H=1024' \
	--env 'UID=99' \
	--env 'GID=100' \
    --env 'UMASK=000' \
    --env 'DATA_PERM=770' \
	--volume /mnt/user/appdata/remmina:/remmina \
    --restart=unless-stopped\
	ich777/remmina
```

### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true


#### Reverse Proxy with nginx example:

```
server {
	listen 443 ssl;

	include /config/nginx/ssl.conf;
	include /config/nginx/error.conf;

	server_name rdp.example.com;

	location /websockify {
		auth_basic           example.com;
		auth_basic_user_file /config/nginx/.htpasswd;
		proxy_http_version 1.1;
		proxy_pass http://192.168.1.1:8080/;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";

		# VNC connection timeout
		proxy_read_timeout 61s;

		# Disable cache
		proxy_buffering off;
	}
		location / {
		rewrite ^/$ https://rdp.example.com/vnc.html?autoconnect=true redirect;
		auth_basic           example.com;
		auth_basic_user_file /config/nginx/.htpasswd;
		proxy_redirect     off;
		proxy_set_header Range $http_range;
		proxy_set_header If-Range $http_if_range;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header Host $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_pass http://192.168.1.1:8080/;
	}
}
```
>**ATTENTION:** Please edit the hostname, with the subdomain, and the IP to your corresponding settings!

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/