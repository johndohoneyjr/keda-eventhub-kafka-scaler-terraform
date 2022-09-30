# Update to Provisioning

The provisioning with Terraform is dated, and when I ran it, it did not work.  I have added 2 batch files to run before and after the Terraform.  Make sure you run these in the sam directory as the terraform IAC.

I do use Helm, JQ and terraform, so be sure those are installed in your $PATH (e.g. /usr/local/bin )  I did make an assumption that you were using Windows System for Linux (WSL - which is Ubuntu based)  The alias is present to use windows executables in WSL.  Remove this if you installed Unbuntu executables.

SetUpBeforeTerraform.sh

Simple, add your subscription ID and the name for the service principal
export SUBSCRIPTION_ID="e899c7bb-......"
export SERVICE_PRINCIPAL_NAME="foo-serviceprincipal"

run the batch program, this adds the Service Principal to AAD under your subscription and adds the ClientID and secret to the variables.tf

Double check variables.tf, if terraform chokes, some names must be unique -- Event Hub Namespaces and resource groups are two that come to mind.  Just change it, and re-"terraform apply"

setUpAfterTerraform.sh

This adds the AcrPull role to your Service Principal and installs the Keda Helm chart in the keda namespace.  I have no idea why this did not work with the Terraform provider--it is pretty basic! (So is the role addition -- TF even looked correct.  I did not go to debugging this, just wrote this hack.)

To use this, simple, add your subscription ID I pull the rest from the Terraform output -- no typos :)            
             export SUBSCRIPTION_ID="e899c7bb-......"

Jump back into the instructions - between steps 4 and 5, the only issue you might have is ACR access, just disable admin access.

Finally, in setting up all the config files, use terraform output command, to get the "Non-sensitive" version:

               terraform output eventhub_namespace_conn_string_base64encoded
  

Keda Works -- not too slow on scaling either