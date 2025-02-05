# DDN Helm Charts

This repository contains Helm charts to help with the deployment of DDN on Kubernetes. This project is currently in active development.

## Get Started

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

### Repository

The Charts are available in a Helm Chart Repository. [Helm](https://helm.sh) must be installed to use these charts.
Please refer to the [official documentation](https://helm.sh/docs/intro/install/) to get started.

```bash
helm repo add hasura-ddn https://hasura.github.io/ddn-helm-charts/
helm repo update
```

You can then see the charts by running:

```bash
helm search repo hasura-ddn
```

> You can change the repo name `hasura-ddn` to another one if getting conflicts.

For more information, have a look at the [Using Helm](https://helm.sh/docs/intro/using_helm/#helm-repo-working-with-repositories) documentation.

### Using git for metadata files
To enable git-sync to read engine or connector config files from a git repository, follow the below steps.

1. Create a Git repository.  Depending on your use case, you can create it as `public` or `private` repo

2. If you create it as a `public` repository and you want to use an `https` based checkout, you have completed your base setup.  In other cases, proceed to the next step.

3. Create a SSH key and grant it *read* access to the repository. It can also be a deploy key (See [set up deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#set-up-deploy-keys))

4. Create a known hosts file, to add GitHub’s SSH host key to your known_hosts file to prevent SSH from asking for confirmation during the connection:

```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

5. Create a kubernetes secret using the below command

```bash
kubectl create secret generic git-creds \
  --from-file=ssh=~/.ssh/id_rsa \
  --from-file=known_hosts=~/.ssh/known_hosts
```

## Contributing

Check out our [contributing guide](./CONTRIBUTING.md) for more details.

## License

Resources in this repository are released under the [Apache 2.0 license](./LICENSE).