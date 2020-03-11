FROM busybox
USER 1001
CMD while true; do wget $GATEWAY_URL/productpage; sleep 1; done