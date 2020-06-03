# Examples

## Deploy a dashboard

    > kubectl apply -f configs/dashboard.yaml

To view the dashboard

    > kubectl proxy
    Starting to serve on 127.0.0.1:8001

The go to [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/) to view the dashboard.

Login token can be got from;

    > kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard-token |  awk '{print $1}')

