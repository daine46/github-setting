#!/bin/bash

PROJECT_DIR=$HOME/projects
SSH_DIR=$HOME/.ssh
HOST="git@github.com"

while read -p "Please input repository name to want to clone : " REPO ; do
  case $REPO in
    [""]* ) echo "Do my order!!";;
    * ) break;
  esac
done

# Setting authentication for GitHub
while read -p "Have you configure authentication of GitHub yet? [y/n] " yn ; do
  case $yn in
    [Nn]* ) {
      if [ ! -e $SSH_DIR ]; then
        mkdir $SSH_DIR
        chmod 700 $SSH_DIR
      fi

      echo "create ssh key for GitHub"
      ssh-keygen -t rsa

      # put in secret key
      if [ ! -e $SSH_DIR/keys ]; then
        mkdir $SSH_DIR/keys
        chmod 700 $SSH_DIR/keys
      fi
      mv $SSH_DIR/id_rsa $SSH_DIR/github-key
      mv $SSH_DIR/github-key $SSH_DIR/keys/
      chmod 600 $SSH_DIR/keys/github-key

      # set public key in GitHub
      echo "Please set public key of the following in GitHub.\n"
      cat $SSH_DIR/id_rsa.pub
      while read -p "\nHave you set public key in GitHub? [y/n] " ok ; do
        case $ok in
          [Yy]* ) break;;
          [Nn]* ) echo "Please set public key in GitHub.";;
          * ) echo "Answer my question!!";;
        esac
      done

      # set ssh-config
      if [ ! -e $SSH_DIR/config ]; then
        touch $SSH_DIR/config
        chmod 600 $SSH_DIR/config
      fi
      cat << EOS >> $SSH_DIR/config
Host github
    User            git
    Port            22
    HostName        github.com
    IdentityFile    ~/.ssh/keys/github-key
    IdentitiesOnly  yes
EOS
      HOST="github"
      break
    };;
    [Yy]* ) {
      while read -p "Please type custom Host of GitHub if you define in ssh-config file: " ans ; do
        case $ans in
          * ) {
            if [ ! $ans = "" ]; then
              HOST=$ans
            fi
            break
          };;
        esac
      done
      break
    };;
    * ) echo "Answer my question!!";;
  esac
done

# Setting local repository
if [ ! -e $PROJECT_DIR ]; then
  mkdir $PROJECT_DIR
fi
cd $PROJECT_DIR

git clone $HOST:$REPO
