#################
# Install Istio #
#################

## NORMAL WAY
istioctl manifest install --skip-confirmation

## BUT ISTIO DOESN'T SEEM TO WORK FOR Mac M1 COMPUTERS YET
# https://github.com/istio/istio/issues/38471
# Solution: Try querycap istio builds https://github.com/resf/istio
# More info on the Istio Operator https://istio.io/latest/docs/setup/install/operator/#uninstall

export INGRESS_PORT=$(kubectl --namespace istio-system get service istio-ingressgateway --output jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

#export INGRESS_HOST=$(kubectl -ojson get node docker-desktop --output jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'):$INGRESS_PORT
export INGRESS_HOST=127.0.0.1:$INGRESS_PORT

echo $INGRESS_HOST


###################
# Uninstall Istio #
###################

istioctl x uninstall --purge
kubectl delete namespace istio-system
