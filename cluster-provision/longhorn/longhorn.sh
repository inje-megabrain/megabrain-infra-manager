

if [ -z "$1" ]; then
    echo "Usage: $0 [install | uninstall | help]"
    exit 1
fi

case $1 in 
    i | install)
        case $2 in 
            k | kubectl)
                kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/deploy/longhorn.yaml
                ;; 
            h | helm )
                helm repo add longhorn https://charts.longhorn.io
                helm repo update
                helm install longhorn longhorn/longhorn --namespace longhorn-system
                ;;
            * )
                echo "Usage: $0 install [kubectl | helm]"
                exit 1
                ;;
        esac
    ;;
    u | uninstall)
        case $2 in 
            c | crd)
                for crd in $(kubectl get crd | grep longhorn | awk '{ print $1 }'); do
                    kubectl -n longhorn-system get $crd -o yaml | sed "s/\- longhorn.rancher.io//g" | kubectl apply -f -
                    kubectl -n longhorn-system delete $crd --all
                    kubectl delete crd/$crd
                done
                ;;
            k | kubectl)
                kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/deploy/longhorn.yaml
                ;;
            h | helm )
                helm uninstall longhorn --namespace longhorn-system
                ;;
            * )
                echo "Usage: $0 uninstall [kubectl | helm | crd ]"
                exit 1
                ;;
        esac
    ;;

    h | help )
    echo "Usage: $0 [install | uninstall]"
    exit 1
    ;;
    * )
    $0 help
    exit 1
    ;;
esac
