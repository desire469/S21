START=$(date +%s%N)
kubectl set image deployment/gateway-service -n service  gateway-service=xedll/gateway-service:1.0
kubectl rollout status -n service  deployment/gateway-service --timeout=60s
END=$(date +%s%N)
echo "scale=3; ($END - $START) / 1000000000" | bc