# Experiments

[![CI](https://github.com/FaaSterMetrics/experiments/workflows/CI/badge.svg)](https://github.com/FaaSterMetrics/experiments/actions?query=workflow%3ACI+branch%3Amaster)

This is the main repository of the FaaSter Metrics project. 
It internally uses the [FaaSterMetrics library](https://github.com/FaaSterMetrics/lib).
A full project documentation PDF can be found [here](https://github.com/FaaSterMetrics/documentation/releases).
Tools for analyzing and exporting experiment results are within the [analysis repository](https://github.com/FaaSterMetrics/analysis).

- [Experiments](#experiments)
  - [Build and Deploy](#build-and-deploy)
  - [Setup](#setup)
    - [Install npm dependencies](#install-npm-dependencies)
    - [Build](#build)
    - [Cloud setup](#cloud-setup)
      - [Google](#google)
      - [AWS](#aws)
      - [Azure](#azure)
      - [TinyFaaS](#tinyfaas)
      - [OpenFaaS](#openfaas)
      - [OpenWhisk](#openwhisk)
    - [Environment Setup](#environment-setup)
  - [License](#license)
    - [Citation](#citation)

## Build and Deploy

Please complete the [Setup](#setup) first.
The standard workflow for this experiment is straight forward.

```shell
# List possible experiments
npm run build
[...]
Usage: ./scripts/build.sh <experiment name>
Choose one of:
> iot webservice
[...]

# Build the webservice experiment
npm run build webservice

# Deploy to the Cloud
npm run deploy webservice
```

## Setup

Before you start please make sure you have following tools installed.

| Tool          | Min. version |
| ------------- | ------------ |
| terraform     | v0.12.25     |
| node          | v12          |
| npm           | v6           |
| awscli        | v2           |
| gcloud        | v293         |
| azure-cli     | v2           |
| jq            | jq-1.6       |
| docker        | 19.03.12     |
| go            | 1.13.8       |
| openwhisk-cli | 1.0.0        |

### Install npm dependencies

```shell
npm install
```

### Build

In order to deploy we need to build the source first. Do: `npm run build`

### Cloud setup

#### Google

1. Create a new Google Cloud project with `<project_name>`.
2. Go to `IAM > Service account` or `https://console.cloud.google.com/iam-admin/serviceaccounts?project=<project_name>`.
3. Click `Create Service account`.
4. Add the `Project > Owner` permission.
5. Click `Generate Private Key` and download it as `json` we need the absolute path to the file later.
6. Visit `https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<project_name>` and enable the API.

#### AWS

1. Go to IAM or `https://console.aws.amazon.com/iam/home?#/users`.
2. Create a new user.
3. Choose "Programmatic access".
4. Got to "Attach existing policies directly" and chose "AdministratorAccess".
5. Go to the last step and save the `Key ID` and `Access Key`.

#### Azure

1. Install the [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
2. Run `az login`.
3. Run `az account list`.
4. Choose your subscription you want to use for the deployment.

#### TinyFaaS

1. If you don't have an tinyFaaS instance follow the instructions [here](https://github.com/FaaSterMetrics/tinyFaaS).
2. Set the `TINYFAAS_ADDRESS` environment variable. Please note that TINYFAAS_ADDRESS must be publically visible on the internet in order for other FaaS platforms to talk to it.  
   **Anyone with access to the tinyFaaS management port (8080) will be able to upload arbitrary functions, it is very advisable to configure your firewall to only let the deploying computer access that port**

#### OpenFaaS

**Warning:** this will **only** work with full openfaas **not** with faasd due to multiple bugs in faasd.  
**The only supported setup is the one using docker swarm https://docs.openfaas.com/deployment/docker-swarm/**

1. Setup an openfaas instance using https://docs.openfaas.com/deployment/docker-swarm/ and write down the password it generates
2. Install faas-cli https://docs.openfaas.com/cli/install/ and login like the guide above details.
3. Log your local docker into docker hub with `docker login` (other container registries are not directly supported by this project).  
   This is needed to deploy functions to openfaas. Please note that by default this will make the functions you deploy to openfaas public on your account.
4. Set your `OPENFAAS_GATEWAY` environment variable like detailed below and `OPENFAAS_TOKEN` to the password generated during openfaas setup.

#### OpenWhisk

1. Setup [OpenWhisk](https://openwhisk.apache.org/documentation.html#openwhisk_deployment).
2. Set the `OPENWHISK_EXTERNAL` environment variable. For example: `https://my.openwhisk-apigateway.faas`.
3. Configure credentials:

```
wsk property set \
  --apihost '<your openwhisk api host>' \
  --auth '<username>:<password>'
```

### Environment Setup

Get the `project_name` from the cloud provider setup.

```shell
export AWS_ACCESS_KEY_ID=<From the web interface>
export AWS_SECRET_ACCESS_KEY=<From the web interface>

export GOOGLE_APPLICATION_CREDENTIALS=<Path to the key file ".json">
export GOOGLE_PROJECT=<project_name>

export AWS_REGION=<ie us-east-1>
export GOOGLE_REGION=<ie us-east1>

export ARM_TENANT_ID=<tenantId from az account list>
export ARM_SUBSCRIPTION_ID=<id from az account list>

export TINYFAAS_ADDRESS=<address of your tinyfaas instance eg localhost>

export OPENFAAS_GATEWAY=http://<address of openfaas gateway>:8080
export OPENFAAS_TOKEN=<password for openfaas, the one you also use when logging into faas-cli>
export OPENWHISK_EXTERNAL=<address of your openwhisk api gateway eg http://localhost:3233>
```

---

## License

This repository is licensed under the Apache 2.0 License.

### Citation

If you use this software (or parts of it) in a published work, please include a citation similar to the following BibTex notice. 

```bibtex
@Manual{faasterMetrics2020,
  title = {FaaSter Metrics: An Application-oriented Function as a Service Benchmarking Framework},
  author = {Burchard, Luk and Schubert, Carsten and Witzko, Christoph and Zhao, Max and Dietrich, Emily},
  organization = {FaaSter Metrics project group},
  address = {Berlin, Germany},
  year = {2020},
  url = {https://github.com/FaaSterMetrics/documentation/releases},
}
```
