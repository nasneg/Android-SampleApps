#!/bin/bash -xe

createPR() {
  echo "===== start createPR ====="

  HUB="2.2.0"

  # 認証情報を設定する
  mkdir -p "$HOME/.config"
  set +x
  echo "https://${GH_TOKEN}:@github.com" > "$HOME/.config/git-credential"
  echo "github.com:
  - oauth_token: $GH_TOKEN
    user: $GH_USER" > "$HOME/.config/hub"
  unset GH_TOKEN
  set -x

  # Gitを設定する
  git config --global user.name  "${GH_USER}"
  git config --global user.email "${GH_USER}@users.noreply.github.com"
  git config --global hub.protocol "https"
  git config --global credential.helper "store --file=$HOME/.config/git-credential"

  # hubをインストールする
  curl -LO "https://github.com/github/hub/releases/download/v$HUB/hub-linux-amd64-$HUB.tar.gz"
  tar -C "$HOME" -zxf "hub-linux-amd64-$HUB.tar.gz"
  export PATH="$PATH:$HOME/hub-linux-amd64-$HUB"

  # リポジトリに変更をコミットする
  hub clone "Android-SampleApps" _
  cd _
  BRANCH_NAME="branch_name_"`date "+%Y-%m-%d_%H-%M-%S"`_$TRAVIS_BRANCH
  hub checkout -b $BRANCH_NAME
  ## ファイルを変更する ##
  echo "hoge" > hoge.txt
  hub add .
  hub commit -m "add hoge"
  if [ $? = 0 ] ; then
    # Pull Requestを送る
    hub push origin $BRANCH_NAME
    hub pull-request -m "auto update pull request"
  else
    echo "There no updates"
  fi

  cd ..
}

ls -l .

if [[ $TRAVIS_BRANCH = branch_name* ]] ; then
  # travis ciから生成されたprの場合は、再度prを作成しない
  echo $TRAVIS_BRANCH
else
  createPR
fi
