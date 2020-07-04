#!/bin/bash

set -euo pipefail

PKG_JSON='{"name": "fn", "version": "1.0.0", "main": "index.js"}'

if [ -z "${1:-}" ]; then
    chalk -t "{yellow Usage: $0 }{yellow.bold <experiment name>}"
    echo "Choose one of:" | chalk yellow
    chalk -t "{yellow >} {yellow.bold $(ls experiments/ | tr '\n' ' ')}"
    echo ""
    exit 1
fi

if [[ -z "${2:-}" ]]; then
	exp_json="experiment.json"
else
	exp_json="$2"
fi

exp_dir="experiments/$1/functions"
exp_config="experiments/$1/$exp_json"
export DOCKERHUB_USER=`docker info 2>/dev/null | sed '/Username:/!d;s/.* //'`
 

command -v faas-cli >/dev/null && faas-cli template store pull node10-express #template pull ../node10-express-template #

if [[ ! -f $exp_config ]]; then
    echo -e "Invalid experiment name\n" | chalk red
    exit 1
fi

# Ensure updated dependencies
npm install --ignore-scripts

echo "Installing functions from npm" | chalk cyan
./scripts/install-functions.js $exp_config $exp_dir

chalk -t "{cyan Building experiment} {cyan.bold $1}"

rm -rf $exp_dir/_build
mkdir $exp_dir/_build

for d in $exp_dir/*; do
  fname=`basename $d`
  [ "$fname" == '_build' ] && continue
  if [[ -f "$d/.installed" ]]; then
    fnVersion=$(jq -r '.version' $d/.installed)
    echo "Function already built: ${fname} (version: ${fnVersion})" | chalk cyan
    cp $exp_config $d
    chmod -R +r $d
    cd $d && zip -r ../_build/${fname}.zip * && cd -
    rm $d/experiment.json
    continue
  fi
  echo "Going to build function: ${fname}" | chalk cyan
  echo "process.env.FAASTERMETRICS_FN_NAME='${fname}';$(cat $d/index.js)" > $d/_index.js
  npx ncc build $d/_index.js -o $d/build
  echo $PKG_JSON > $d/build/package.json
  cp $exp_config $d/build/
  cd $d/build && zip -r ../../_build/${fname}.zip * && cd -
  if [[ $(jq -r ".program.functions | with_entries(select(.key == \"$fname\" and .value.provider == \"openfaas\")) | keys[]" $exp_config) ]]; then
    
    # TODO: @christoph please check if I'm not messing up the function caching for openfaas

    export FUNCTION_HANDLER=`readlink -f ./$d/build`
    
    # WORKAROUND: openfaas for some reason does not respect the package.json and just assumes handler.js
    echo "module.exports = async (config) => {process.chdir('function');config.app.all('/*', require('./index.js').openfaasHandler);}" > $FUNCTION_HANDLER/handler.js
    FUNCTION_NAME=$fname faas-cli build -f misc/openfaas.yml 
    FUNCTION_NAME=$fname faas-cli push -f misc/openfaas.yml 
  fi
  rm -rf $d/build $d/_index.js
done

echo "Building azure functions" | chalk cyan

rm -rf $exp_dir/_build/azure
mkdir $exp_dir/_build/azure

cp misc/azure/host.json $exp_dir/_build/azure
cp $exp_config $exp_dir/_build/azure

for fname in $(jq -r '.program.functions | with_entries(select(.value.provider == "azure" )) | keys[]' $exp_config); do
  echo "Going to build azure function: $fname" | chalk cyan
  d=$exp_dir/$fname
  mkdir $exp_dir/_build/azure/$fname
  cat misc/azure/function.json | jq --argjson fn "\"${fname}/{*path}\"" '.bindings[0].route = $fn' > $exp_dir/_build/azure/$fname/function.json
  if [[ -f "$d/.installed" ]]; then
    echo "Function already built: ${fname}" | chalk cyan
    cp -r $d/* $exp_dir/_build/azure/$fname/
    continue
  fi
  echo "Going to build function: ${fname}" | chalk cyan
  echo "process.env.FAASTERMETRICS_FN_NAME='${fname}';$(cat $d/index.js)" > $d/_index.js
  npx ncc build $d/_index.js -o $exp_dir/_build/azure/$fname
  rm -rf $d/_index.js
done
cd $exp_dir/_build/azure && zip -r ../azure_dist.zip * && cd -
rm -rf $exp_dir/_build/azure

echo -n $(date) > .build_timestamp
echo "Build done" | chalk cyan bold
