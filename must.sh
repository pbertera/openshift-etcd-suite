#!/bin/bash

MUST_PATH=$1

cd $MUST_PATH
cd $(echo */)
# ls

cat cluster-scoped-resources/config.openshift.io/clusterversions.yaml |grep "Cluster version is"
echo -e ""

cd cluster-scoped-resources/core/nodes
NODES_NUMBER=$(ls|wc -l)
echo -e "There is $NODES_NUMBER nodes in cluster"

cd ../persistentvolumes
PV_NUMBER=$(ls|wc -l)
echo -e "There is $PV_NUMBER PVs in cluster"

cd ../nodes

NODES=()
MASTER=()
INFRA=()
WORKER=()


for filename in *.yaml; do
    [ -e "$filename" ] || continue
    # echo -e "[$filename]"
    # cat $filename |grep node-role|grep -w "node-role.kubernetes.io/master:"
    [ ! -z "$(cat $filename |grep node-role|grep -w 'node-role.kubernetes.io/master:')" ] && MASTER+=("$filename") && NODES+=("$filename [master]") || true
done

for filename in *.yaml; do
    [ -e "$filename" ] || continue
    [ ! -z "$(cat $filename |grep node-role|grep -w 'node-role.kubernetes.io/infra:')" ] && INFRA+=("$filename") || true
done

for filename in *.yaml; do
    [ -e "$filename" ] || continue
    [ ! -z "$(cat $filename |grep node-role|grep -w 'node-role.kubernetes.io/worker:')" ] && WORKER+=("$filename") || true
done

echo -e " --------------- "
# echo ${NODES[@]}

echo -e "${#MASTER[@]} masters"
echo -e "${#INFRA[@]} infra nodes"
echo -e "${#WORKER[@]} worker nodes"

# for i in ${NODES[@]}; do echo $i; done


cd $MUST_PATH
cd $(echo */)
cd namespaces/openshift-etcd/pods
echo -e ""
echo -e "[ETCD]"
echo -e ""
# ls |grep -v "revision"|grep -v "quorum"

for member in $(ls |grep -v "revision"|grep -v "quorum"); do
    # [ -e "$member" ] || continue 
    echo -e "$member"
    echo -e "  - we found $(cat $member/etcd/etcd/logs/current.log|grep 'overload'|wc -l) overloaded messages."
    echo -e "  - we found $(cat $member/etcd/etcd/logs/current.log|grep 'took too long'|wc -l) took too long messages."
    echo -e "  - we found $(cat $member/etcd/etcd/logs/current.log|grep 'drift'|wc -l) ntp drift messages."
    # echo -e "[$filename]"
    # cat $filename |grep node-role|grep -w "node-role.kubernetes.io/master:"
    # [ ! -z "$(cat $filename |grep node-role|grep -w 'node-role.kubernetes.io/master:')" ] && MASTER+=("$filename") && NODES+=("$filename [master]") || true
done