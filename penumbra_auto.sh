#!/bin/bash

if curl > /dev/null 2>&1; then
	echo ''
else
  sudo apt install curl -y
fi

curl -s https://raw.githubusercontent.com/xazyn/xazyn_api/main/xazyn_logo.sh | bash 

function createnosyncWallet {
      sudo apt update && sudo apt upgrade -y
      sudo apt install make git tar wget clang pkg-config libssl-dev jq build-essential -y
      if cargo > /dev/null 2>&1; then
        echo ''
      else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      fi
      source ~/.cargo/env
      sudo rm -r /root/.local/share/pcli/penumbra_wallet.json && sudo rm -rf /root/.local/share/penumbra-testnet-archive/
      rm -rf $HOME/penumbra && git clone https://github.com/penumbra-zone/penumbra
      cd penumbra && git checkout 006-orthosie
      cd $HOME/penumbra && cargo build --release --bin pcli 
      cd $HOME/penumbra &&  cargo run --quiet --release --bin pcli wallet generate
      ADDRESS=$(cd $HOME/penumbra && cargo run --quiet --release --bin pcli addr list | grep -oP '(?<=penumbra).*')
      echo -e '\n\e[40m\e[92mSAVE ALL DATA BELOW\e[0m\n' && sleep 2
      echo -e '\nAddress:'
      echo 'penumbra'$ADDRESS
      echo -e '\nWallet info and spend seed:'
      cat /root/.local/share/pcli/penumbra_wallet.json && echo -e '\n'
      echo -e '\ne[40m\e[92mSAVE ALL DATA ABOVE\e[0m\n' && sleep 2
}

function createsyncWallet {
      sudo apt update && sudo apt upgrade -y
      sudo apt install make git tar wget clang pkg-config libssl-dev jq build-essential -y
      if cargo > /dev/null 2>&1; then
        echo ''
      else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      fi
      source ~/.cargo/env
      sudo rm -r /root/.local/share/pcli/penumbra_wallet.json && sudo rm -rf /root/.local/share/penumbra-testnet-archive/
      rm -rf $HOME/penumbra && git clone https://github.com/penumbra-zone/penumbra
      cd penumbra && git checkout 006-orthosie
      cd $HOME/penumbra && cargo build --release --bin pcli 
      cd $HOME/penumbra &&  cargo run --quiet --release --bin pcli wallet generate
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli sync
      ADDRESS=$(cd $HOME/penumbra && cargo run --quiet --release --bin pcli addr list | grep -oP '(?<=penumbra).*')
      echo -e '\n\e[42m==================================================\e[0m\n'
      echo -e '\e[42mSAVE ALL DATA BELOW\e[0m'
      echo -e '\n\e[42m==================================================\e[0m\n' && sleep 2
      echo -e '\nAddress:'
      echo 'penumbra'$ADDRESS
      echo -e '\nWallet info and spend seed:'
      cat /root/.local/share/pcli/penumbra_wallet.json && echo -e '\n'
      echo -e '\n\e[42m==================================================\e[0m\n'
      echo -e '\e[42mSAVE ALL DATA ABOVE\e[0m' 
      echo -e '\n\e[42m==================================================\e[0m\n' && sleep 2
}

function restoreWallet {
      sudo apt update && sudo apt upgrade -y
      sudo apt install make git tar wget clang pkg-config libssl-dev jq build-essential -y
      if cargo > /dev/null 2>&1; then
        echo ''
      else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      fi
      source ~/.cargo/env
      echo -e '\e[40m\e[91mMake sure you back up your wallet' && sleep 3
      echo -e '\nSpend seed:'
      cat /root/.local/share/pcli/penumbra_wallet.json | grep -oP '(?<="spend_seed": ").*?(?=")'
      echo -e '\n\e[0m' && sleep 3
      rm -rf $HOME/penumbra && git clone https://github.com/penumbra-zone/penumbra
      cd $HOME/penumbra && git checkout 006-orthosie
      cargo build --release --bin pcli
      sudo rm -r /root/.local/share/pcli/penumbra_wallet.json && sudo rm -rf /root/.local/share/penumbra-testnet-archive/
      echo -e '\e[40m\e[92m' && read -p "Enter spend seed: " SPENDSEED && echo -e '\e[0m'
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli wallet import $SPENDSEED 
      SPENDSEED=
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli wallet reset
      export RUST_LOG=info
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli sync
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli balance
}

function backupPenumbra {
      ADDRESS=$(cd $HOME/penumbra && cargo run --quiet --release --bin pcli addr list | grep -oP '(?<=penumbra).*')
      echo -e '\n\e[42m==================================================\e[0m\n'
      echo -e '\e[42mSAVE ALL DATA BELOW\e[0m'
      echo -e '\n\e[42m==================================================\e[0m\n' && sleep 2
      echo -e '\nAddress:'
      echo 'penumbra'$ADDRESS
      echo -e '\nSpend seed:'
      cat /root/.local/share/pcli/penumbra_wallet.json | grep -oP '(?<="spend_seed": ").*?(?=")'
      echo -e '\n\e[42m==================================================\e[0m\n'
      echo -e '\e[42mSAVE ALL DATA ABOVE\e[0m' 
      echo -e '\n\e[42m==================================================\e[0m\n' && sleep 2
}

function showsaddressPenumbra {
        ADDRESS=$(cd $HOME/penumbra && cargo run --quiet --release --bin pcli addr list | grep -oP '(?<=penumbra).*')
        echo -e '\e[40m\e[92m' 
        echo -e '\nYour wallet address:'
        echo 'penumbra'$ADDRESS
        echo -e '\e[0m'
}

function checkbalancePenumbra {
        cargo run --quiet --release --bin pcli balance
}

function stakePenumbra {
        VAL_ADDRESS=$(cd $HOME/penumbra && cargo run --quiet --release --bin pcli stake list-validators | grep -oP '(?<=penumbraval).*') 
        echo -e '\e[40m\e[92m' && read -p "Enter penumbra amount: " PENUMBRA_AMOUNT && echo -e '\e[0m'
        cd $HOME/penumbra && cargo run --quiet --release --bin pcli stake delegate $PENUMBRA_AMOUNT'penumbra' --to 'penumbraval'$VAL_ADDRESS
        VAL_ADDRESS=
}

function unstakePenumbra {
        DELEGATION_INFO=$(cargo run --quiet --release --bin pcli balance | grep delegation_penumbra)
        cd $HOME/penumbra && cargo run --quiet --release --bin pcli stake undelegate $DELEGATION_INFO
        DELEGATION_INFO=
}

function sendPenumbra {
      echo -e '\e[40m\e[92m' && read -p "Enter destination address: " DESTINATION_ADDRESS && echo -e '\e[0m'
      echo -e '\e[40m\e[92m' && read -p "Enter amount: " AMOUNT && echo -e '\e[0m' && AMOUNT=$AMOUNT'penumbra'
      cd $HOME/penumbra && cargo run --quiet --release --bin pcli tx send $AMOUNT --to $DESTINATION_ADDRESS
      DESTINATION_ADDRESS=
      AMOUNT=
}

function deletePenumbra {
      rm -rf $HOME/penumbra 
      sudo rm -r /root/.local/share/pcli/penumbra_wallet.json && sudo rm -rf /root/.local/share/penumbra-testnet-archive/
}


echo -e '\e[40m\e[92mPlease enter your choice (input your option number and press Enter): \e[0m'
options=("Create wallet (only generation, no sync)" "Create wallet (with sync)" "Restore wallet and sync" "Backup wallet" "Show wallet address" "Check balance" "Stake" "Unstake" "Send" "Delete Penumbra" "Quit")
select option in "${options[@]}"
do
    case $option in
        "Create wallet (only generation, no sync)")
            echo -e '\n\e[42mCreating wallet without sync ...\e[0m\n' && sleep 2
            createnosyncWallet
            break
            ;;
         "Create wallet (with sync)")
            echo -e '\n\e[42mCreating wallet with sync...\e[0m\n' && sleep 2
            createsyncWallet
            break
            ;;
        "Restore wallet and sync")
            echo -e '\n\e[42mRestoring wallet and sync...\e[0m\n' && sleep 2
            restoreWallet
            break
            ;;
         "Backup wallet")
            backupPenumbra
			      break
            ;;
        "Show wallet address")
            showsaddressPenumbra
			      break
            ;;
        "Check balance")
            checkbalancePenumbra
            break
            ;;
        "Stake")
            stakePenumbra
            break
            ;;
         "Unstake")
            unstakePenumbra
            break
            ;;
          "Send")
            sendPenumbra
            break
            ;;
	  "Delete")
            echo -e '\e[40m\e[91mMake sure you back up your wallet.\e[0m' && sleep 2
            backupPenumbra
            echo -e '\n\e[40m\e[91mDeleting Penumbra...\e[0m\n' && sleep 2
            deletePenumbra
	    break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91mInvalid option $REPLY\e[0m";;
    esac
done
