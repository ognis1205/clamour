# Nginx Test Container

## Start Nginx test server

```bash
 $ kubectl apply -f nginx.yaml
 $ kubectl get deploy,rs,pod,svc
```

## Clean up Nginx test server

```bash
 $ kubectl delete -f nginx.yaml
```
