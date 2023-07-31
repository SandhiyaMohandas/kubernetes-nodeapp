cluster:
	k3d cluster create testcluster \
            -p 8080:80@loadbalancer \
            -v /etc/test:/etc/test:ro \
            -v /var/log/journal:/var/log/journal:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
	    --k3s-arg --no-deploy=traefik@server:0 \
            --agents 1

