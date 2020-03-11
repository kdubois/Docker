FROM busybox
USER 1001
CMD while true; do curl $GATEWAY_URL/productpage; sleep 1; done