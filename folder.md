# フォルダ構成

- フォルダ構成は以下の通り

```
.
└── envs
    ├── backend.tf            tfstateファイル管理定義ファイル
    ├── certificates.tf       OCI Certificates定義ファイル
    ├── compartments.tf       デプロイ用コンパートメント定義ファイル
    ├── data.tf               外部データソース定義ファイル
    ├── dns.tf                OCI DNS パブリックゾーン定義ファイル
    ├── elb.tf                OCI ELB (Flexible Load Balancer) 定義ファイル
    ├── locals.tf             ローカル変数定義ファイル
    ├── outputs.tf            リソース戻り値定義ファイル
    ├── providers.tf          プロバイダー定義ファイル
    ├── tags.tf               デフォルトタグ定義ファイル
    ├── variables.tf          変数定義ファイル
    ├── vault.tf              OCI Vault定義ファイル
    ├── vcn.tf                VCN定義ファイル
    └── versions.tf           Terraformバージョン定義ファイル
```