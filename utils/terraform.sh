#!/bin/zsh

alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply --auto-approve'
alias tfd='terraform destroy --auto-approve'
alias tfcost='echo "Calulating cost estimate..." terraform plan -out=plan.tfplan > /dev/null && terraform show -json plan.tfplan | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf'



# switch terraform version
tfswitch()
{
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