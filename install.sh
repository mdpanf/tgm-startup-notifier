#!/bin/bash

echo -e "\n\n"

download() {
  cd /tmp;
  rm -rf ./tgm-notifier
  git clone https://github.com/mdpanf/tgm-notifier
}

token() {
  read -p "Input tgm-bot token: " inToken
  read -p "Input tgm chat_id: " inChat
  confirm
}

data_input() {
  GREEN='\033[0;32m'
  PURPLE='\033[0;35m'
  NC='\033[0m'
  GR='\033\1;32m'

  token() {
    read -p "Input tgm-bot token: " inToken
    read -p "Input tgm chat_id: " inChat
    confirm
  }

  confirm() {
      echo -e "Token: ${PURPLE}$inToken${NC}"
      echo -e "Chat_id: ${PURPLE}$inChat${NC}"
      read -e -r -p "${1:-Is it correct? [y/N]} " response
      case "$response" in
          [yY][eE][sS]|[yY])
              true
              echo "Saving...";;
          *)
              false
              token;;
      esac
  }

  echo -e "${GREEN}== Config ==${NC}"
  token

  cat > /etc/steio/tgm-notifier.conf << EOF
Token $inToken
Chat $inChat
EOF
}

install() {
  mkdir -p /opt/steio/tgm-notifier
  mkdir -p /etc/steio

  chmod 777 /etc/steio -R

  data_input;

  cd /opt/steio/tgm-notifier;
  cp /tmp/tgm-notifier/startup-notifier.sh ./startup-notifier.sh
  chmod a+x ./startup-notifier.sh

  cd /lib/systemd/system
  cp /tmp/tgm-notifier/tgm-notifier.service ./tgm-notifier.service

  chmod 644 /lib/systemd/system/tgm-notifier.service

  systemctl daemon-reload

  systemctl start tgm-notifier.service
  systemctl enable tgm-notifier.service

}

main() {
  if [[ $EUID -eq 0 ]]; then
    echo "Run script under non-root user";
    echo "Abort";
    exit 1;
  fi

  download;
  sudo bash -c "$(declare -f install); install"
}

main;
