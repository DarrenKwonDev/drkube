# drk-kube

[GCP에서 저렴하게 교육용 쿠버네티스를 운용하는 방법](https://darrenkwondev.github.io/posts/2024-01-06-cheap_k8s/) 에서 소개된 내용의 terraform code입니다.

개인 프로젝트 외에는 GCP를 굳이 사용할 이유가 없기 때문에 여기에 gcloud sdk binary 등을 위치시키고 한 폴더에서 모두 관리합니다.

## disclaimer

-   terraform 1.4 이후 부터 null_resource가 아니라 terraform_data 사용을 권장하고 있습니다.

    -   https://developer.hashicorp.com/terraform/language/resources/terraform-data
    -   그러나 여기서는 그대로 두겠습니다..

-   backend 구성 없습니다. 잠깐 올렸다가 쓰고 내리는 용도입니다.
