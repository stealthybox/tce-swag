#!/usr/bin/env bash
CODES_NAMESPACE="default"

ARRAY_COUNT=`jq -r '. | length-1' $BINDING_CONTEXT_PATH`

function config() {
  cat <<EOF
configVersion: v1
kubernetes:
- name: OnAllocatedWorkshopSession
  apiVersion: training.eduk8s.io/v1alpha1
  kind: WorkshopSession
  executeHookOnEvent:
  - Added
  - Modified
  jqFilter: '.status.eduk8s.phase == "Allocated"'
EOF
}

function reconcile_session() {
  sessionName=${1}
  
  # we have the workshop session name
  # check if we labeled a code for that session
  codeName="$(kubectl get cm -n ${CODES_NAMESPACE} -l workshop_session=${sessionName} -oname | head -n1)"
  if [[ $codeName = "" ]]; then
    # no code yet, get a random code that's unlabeled
    codeName="$(kubectl get cm -n ${CODES_NAMESPACE} -l workshop_session=none --no-headers -o custom-columns=NAME:.metadata.name | sort -R |head -n1)"
    # label it, now we can use it
    kubectl label cm -n "${CODES_NAMESPACE}" "${codeName}" workshop_session=${sessionName}
  fi
  # we have a labeled code, either from before or just now
  code="$(kubectl get cm -n "${CODES_NAMESPACE}" "${codeName}" -ojsonpath='{.data.code}')"
  echo ${code}
  # get the namespace for the session (most likely the same)
  namespace="$(kubectl get ns -l training.eduk8s.io/session.name=${sessionName} --no-headers -o custom-columns=NAME:.metadata.name)"
  # apply the code to the namespace
  cat << EOF | kubectl apply -f-
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: code
  namespace: ${namespace}
data:
  code: ${code}
EOF
}

if [[ $1 == "--config" ]] ; then
  config
else
  # type=$(jq -r '.[0].type' $BINDING_CONTEXT_PATH)
  # if [[ $type == "Synchronization" ]] ; then
  #   echo Got Synchronization event
  #   exit 0
  # fi

  set -x

  for IND in `seq 0 $ARRAY_COUNT`
  do
    cat $BINDING_CONTEXT_PATH

    bindingName=`jq -r ".[$IND].binding" $BINDING_CONTEXT_PATH`
    resourceEvent=`jq -r ".[$IND].watchEvent" $BINDING_CONTEXT_PATH`
    resourceName=`jq -r ".[$IND].object.metadata.name" $BINDING_CONTEXT_PATH`

    if [[ resourceName != "null" ]]; then
      reconcile_session "${resourceName}"
    fi

    # if [[ $bindingName == "OnAllocatedWorkshopSession" ]] ; then
    # fi
  done
fi
