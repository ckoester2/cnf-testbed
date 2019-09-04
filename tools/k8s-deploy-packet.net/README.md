# K8s Packet.net deployer

## TL;DR;

```
$ cp inventory.yml.sample inventory.yml
$ vi intentory.yml
# (edit CHANGEME lines)
$ ./deploy.sh
```


## Introduction

Ansible tooling that attempts to capture the installation instructions
outlined at 
<https://github.com/cncf/cnf-testbed/blob/master/docs/Deploy_K8s_CNF_Testbed.md#prerequisites>
and provide a single Ansible wrapper script that runs all the execution tasiks
for a Packet.net deloyment.

Ansible roles map roughly to the documentation sections:

  - `roles/create-ws-host` creates the workstation; `roles/workstation`
    configures the workstation/jumpost (Section "Prepare workstation / jump
    server")
  - `roles/ansible-container` spawns the Ansible container
  - `roles/k8s` performs the K8s installation
  - `roles/pktgen` deploys the packet generator
  - `roles/cnfs` deploys the test case CNFs,
  - `roles/run_test` executes the initial test.


Note that this is not production-ready code, for the following reasons:

  - It is simply a wrapper/higher-layer Ansible tooling that calls the
    existing scripts. For quality code, this nested tooling (Ansible calling
    Ansible calling Chef...) is not something one might want to do.

  - When taking a single script approach, then spawning the workstation/jumphost
    may serve no additional value. Instead, one could drive the entire process
    from the host where this playbook is currently invoked from.

  - Issues in error detection -- see below.


## Differences versus README instructions

Relative to
<https://github.com/cncf/cnf-testbed/blob/master/docs/Deploy_K8s_CNF_Testbed.md#prerequisites>,
there are a few implementation differences:

 1. The Ansible installer container is not spawned as a foreground task,
    and `screen`/`tmux` are not used. Instead, the container is spawned using
    `sleep infinity` as an entrypoint command, thus placing the container
    in eternal sleep. Then, `docker exec` is used each time when a command
    is to be executed inside the container.

 1. The container is spawned *after* the Kubernetes environment is deployed,
    and the kubeconfig file is mounted as a separate mount.

 1. Several environment variables that the documentation calls for to be set
    *within* the container shell, are set by this script when the container
    is started. Note: This probably makes it difficult for one container to
    be used to operate multiple test environments.

 1. Traffic Generator MAC addresses are obtained from Linux sysfs rather than
    gleaning them from T-Rex output.


## Known issues

Currently known issues:

  - Some of the scripts that are being invoked, return a zero result code
    even in case of non-successful execution. This, in turn, prevents Ansible
    from detecting errors in their execution. The playbook will continue,
    "thinking" that the task was executed, and then fail at a later stage
    due to missing dependencies.

  - The `run_test` role consistently fails when executed the first time.
    (TODO: Provide details here -- 'division by zero' error due to positive
    RX packet count but zero TX packet counter).

  - Reading the actual lower-layer script output is currently cumbersome.

  - When executing the `run_test` role for the *first* time, RX packets
    are counted but TX packets are not, resulting in a Python
    `ZeroDivisionError`. Restarting the nfvbench container *after* that first
    run, and then re-running, results in correct statistics. (However,
    restarting the container *before* the first run has no effect).
    Need to review contents of run_test script to see what is happening
    there.
