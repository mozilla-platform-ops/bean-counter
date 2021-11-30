## install bean counter

### install curl, gzip and jq
```shell=
sudo apt-get install curl gzip jq

```
### install node and pm2
```shell=
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
export NVM_DIR=${HOME}/.nvm
source ${NVM_DIR}/nvm.sh
source ${NVM_DIR}/bash_completion
source ${NVM_DIR}/nvm.sh && nvm install v16.3.0
${NVM_DIR}/versions/node/v16.3.0/bin/npm install --global npm pm2****
```
