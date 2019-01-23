
**Instructions before giving the ```terraform init``` command for the first time.**

NOTE: When you used script ```create-azure-storage-account.sh``` to create the resource group and Azure Blob storage for Terraform backend the script gave output like:

```bash
storage_account_name: XXXXXXXXXXXXXXX
container_name: YYYYYYYYYYYYYYYYYYY
access_key: ZZZZZZZZZZZZZZZZZZZZZ
```

Store the access key to your source script in ~/.azure/<source-script.sh> as:

```bash
ARM_ACCESS_KEY=ZZZZZZZZZZZZZZZZZZZZZ
```

Before using terraform commands you need to configure access to the Azure Storage account which hosts the terraform state file in Blob storage.
Give command:

```bash
source ~/.azure/<source-script.sh> as:
```

E.g. in my environment I use:

```bash
source ~/.azure/kari-ss-vm-demo.sh
```

