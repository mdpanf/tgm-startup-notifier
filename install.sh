#!/bin/bash

CONF_FILE='/etc/steio/tgm-notifier.conf'

download() {
  cd /tmp;
  rm -rf ./tgm-notifier
  git clone https://github.com/mdpanf/tgm-notifier
}

input_data() {
  read -p "Input tgm-bot token: " TGMN_TOKEN;
  read -p "Input tgm chat_id: " TGMN_CHAT;
  confirm;
}

confirm() {
  echo -e "TGM Token: \033[0;35m$TGMN_TOKEN\033[0m"
  echo -e "TGM Chat ID: \033[0;35m$TGMN_CHAT\033[0m"
  read -p "${1:-Is it correct? [y/N]} "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
      y|yes) echo "Saving..." ;;
      *)     input_data ;;
  esac
}

install() {
  mkdir -p /opt/steio/tgm-notifier
  mkdir -p /etc/steio

  chmod 777 /etc/steio -R

  cat > /etc/steio/tgm-notifier.conf << EOF
[Tgm natifier]
TGMN_TOKEN=$1
TGMN_CHAT=$2
TGMN_ICON=🖥
EOF

  echo -e "The .conf file is located at \033[0;36m/etc/steio/tgm-notifier.conf\033[0m"

  cd /opt/steio/tgm-notifier;
  rm -rf /opt/steio/tgm-notifier/startup-notifier.sh
  cp /tmp/tgm-notifier/startup-notifier.sh ./startup-notifier.sh
  chmod a+x ./startup-notifier.sh

  cd /lib/systemd/system;
  rm -rf /lib/systemd/system/tgm-notifier.service
  cp /tmp/tgm-notifier/tgm-notifier.service ./tgm-notifier.service

  chmod 644 /lib/systemd/system/tgm-notifier.service

  systemctl daemon-reload
  systemctl start tgm-notifier.service
  systemctl enable tgm-notifier.service

}

main() {
  if [ $EUID -eq 0 ]; then
    echo -e "\n\033[0;31mRun script under non-root user\033[0m";
    echo "Abort";
    exit 1;
  fi

  echo -e "\n\033[0;33mTGM-notifier by Steio\033[0m"

  download;
  echo -e "\n\033[0;32m== Config ==\033[0m";
  if [ -f $CONF_FILE ]; then
    . $CONF_FILE
    if [ -z $TGMN_TOKEN ] || [ -z $TGMN_CHAT ]; then
      input_data;
    else
      confirm;
    fi;
  fi;
  sudo bash -c "$(declare -f install); install $TGMN_TOKEN $TGMN_CHAT"
  echo -e "\n\033[0;32mThe system startup notifier is installed successfully!\033[0m"
}

main;
