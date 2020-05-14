from helm_template_generator import *

INBOUND_DEPLOYMENT_FILE_NAME = "cni-inbound-nginx-deployment.yaml"
INBOUND_SERVICE_FILE_NAME = "cni-inbound-nginx-deployment.yaml"

OUTBOUND_DEPLOYMENT_FILE_NAME = "cni-outbound-nginx-deployment.yaml"
OUTBOUND_SERVICE_FILE_NAME = "cni-outbound-nginx-deployment.yaml"


class TestHelmTemplateGenerator:
    def test_helm_template_generator(self):
        manifests = ManifestProcessor()
        manifests.process()

        manifest_files = manifests.fetch_manifest_files_list(MANIFESTS_PATH)
        for filename in manifest_files:
            with open(filename, 'r') as file:
                manifest_data = yaml.load(file, Loader=yaml.FullLoader)
                inbound_eks_cluster_name = manifests.form_eks_cluster_name(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], "inbound")
                
                # Inbound Deployment File
                inbound_helm_deployment_template_file = os.path.join(HELM_TEMPLATE_OUTPUT_PATH,inbound_eks_cluster_name,INBOUND_DEPLOYMENT_FILE_NAME)
                exists = os.path.isfile(inbound_helm_deployment_template_file)
                assert exists == False

                # Inbound Service File
                inbound_helm_service_template_file = os.path.join(HELM_TEMPLATE_OUTPUT_PATH,inbound_eks_cluster_name,INBOUND_SERVICE_FILE_NAME)
                exists = os.path.isfile(inbound_helm_service_template_file)
                assert exists == False

                outbound_eks_cluster_name = manifests.form_eks_cluster_name(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], "outbound")
                # Outbound Deployment File
                outbound_helm_deployment_template_file = os.path.join(HELM_TEMPLATE_OUTPUT_PATH,outbound_eks_cluster_name,OUTBOUND_DEPLOYMENT_FILE_NAME)
                exists = os.path.isfile(outbound_helm_deployment_template_file)
                assert exists == False

                # Outbound Service File
                Outbound_helm_service_template_file = os.path.join(HELM_TEMPLATE_OUTPUT_PATH,outbound_eks_cluster_name,OUTBOUND_SERVICE_FILE_NAME)
                exists = os.path.isfile(Outbound_helm_service_template_file)
                assert exists == False