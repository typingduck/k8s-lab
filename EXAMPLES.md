# Examples

## Deploy a dashboard

    > kubectl apply -f configs/dashboard.yaml

To view the dashboard

    > kubectl proxy
    Starting to serve on 127.0.0.1:8001

The go to [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/) to view the dashboard.

Login token can be got from;

    > kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard-token |  awk '{print $1}')

## Sample services

[kuard](https://github.com/kubernetes-up-and-running/kuard) is a kubernetes demo app that
exposes the apps container environment and allows simulating actions like failing health checks.

    > kubernetes apply -f configs/sample-services.yaml

To access one of the kuard instances

    > kubectl get pods
    > kubectl port-forward alpaca-prod-??????????-????? 8080:8080

Then go to [localhost:8080](http://localhost:8080).
