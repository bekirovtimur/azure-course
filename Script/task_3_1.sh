gitAppURL=$(az webapp deployment source config-local-git --name "webapp2048" --resource-group "timurbekirov-webapp-rg" | jq -r '.url')
echo $gitAppURL
curDir=$(pwd)
mkdir ~/azure-app
cp index.php ~/azure-app/
cd ~/azure-app/
git init
git remote add azure $gitAppURL
git add index.php
git commit -m FirstCommit
git push azure master
cd $curDir
rm -r ~/azure-app
