#!/bin/bash

download() {
  cd /tmp;
  rm -rf ./tgm-notifier
  git clone https://github.com/mdpanf/tgm-notifier
}

input_data() {
  read -p "Input tgm-bot token: " inToken;
  read -p "Input tgm chat_id: " inChatId;
  confirm;
}

confirm() {
    echo -e "Token: \033[0;35m$inToken\033[0m"
    echo -e "Chat_id: \033[0;35m$inChatId\033[0m"
    read -e -r -p "${1:-Is it correct? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            echo "Saving...";;
        *)
            false
            input_data;;
    esac
}

install() {
  mkdir -p /opt/steio/tgm-notifier
  mkdir -p /etc/steio

  chmod 777 /etc/steio -R

  echo -e "Token: \033[0;35m$1\033[0m"
  echo -e "Chat_id: \033[0;35m$2\033[0m"


  cat > /etc/steio/tgm-notifier.conf << EOF
Token: $1
Chat: $2
Icon: 🖥
EOF

  echo -e "The .conf file is located at \033[0;36m/etc/steio/tgm-notifier.conf\033[0m"

  cd /opt/steio/tgm-notifier;
  cp /tmp/tgm-notifier/startup-notifier.sh ./startup-notifier.sh
  chmod a+x ./startup-notifier.sh

  cd /lib/systemd/system;
  rm -rf /lib/systemd/system/tgm-notifier.service
  cp /tmp/tgm-notifier/tgm-notifier.service ./tgm-notifier.service

  chmod 644 /lib/systemd/system/tgm-notifier.service

  systemctl daemon-reload
  systemctl start tgm-notifier.service
  systemctl enable tgm-notifier.service

  echo "Maybe"

}

main() {
  if [[ $EUID -eq 0 ]]; then
    echo -e "\n\033[0;31mRun script under non-root user\033[0m";
    echo "Abort";
    exit 1;
  fi

  echo -e "\n\033[0;33mTGM-notifier by Steio\033[0m"

  download;
  echo -e "\n\033[0;32m== Config ==\033[0m"; input_data;
  sudo bash -c "$(declare -f install); install $inToken $inChatId"
}

main;