#!/bin/zsh

alias tfi='terraform init'

tfp() {
        if [ -z $1 ]; then
                terraform plan
        else
                terraform plan -var-file=environment/$1/variables.tfvars
        fi
}

tfa() {
        if [ -z $1 ]; then
                terraform apply
        else
                terraform apply -var-file=environment/$1/variables.tfvars
        fi
}

tfd() {
        if [ -z $1 ]; then
                terraform destroy
        else
                terraform destroy -var-file=environment/$1/variables.tfvars
        fi
}

tfcost() {
        echo "Calulating cost estimate..."
        if [ -z $1 ]; then
                terraform plan
        else
                terraform plan -var-file=environment/$1/variables.tfvars > /dev/null
        fi
        terraform show -json plan.tfplan | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf | jq
}

# switch terraform version
tfswitch() {
        export LOCAL_BIN=~/.tfswitch/bin

        if [ ! -d $LOCAL_BIN ]; then
                mkdir -p $LOCAL_BIN
        fi

        echo "Switching to Terraform version: $1..."

        TF_BINARY=$LOCAL_BIN/terraform_$1

        if [ ! -f $TF_BINARY ]; then
                wget -q -O $LOCAL_BIN/terraform_$1.zip https://releases.hashicorp.com/terraform/$1/terraform_$1_linux_amd64.zip
                unzip -qq $LOCAL_BIN/terraform_$1.zip -d $LOCAL_BIN
                mv $LOCAL_BIN/terraform $LOCAL_BIN/terraform_$1
                sudo chmod +x $TF_BINARY
                rm $LOCAL_BIN/terraform_$1.zip
        fi

        unlink ~/.local/bin/terraform
        ln $TF_BINARY ~/.local/bin/terraform
        echo "Done!"
}
