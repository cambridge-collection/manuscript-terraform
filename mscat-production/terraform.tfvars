environment                  = "production"
project                      = "mscat-medieval"
component                    = "cudl-data-workflows"
subcomponent                 = "cudl-transform-lambda"
destination-bucket-name      = "releases"
destination-bucket-prefix = ""
github_oidc_subjects = [
  "repo:cambridge-collection/manuscript-catalogue-data:ref:refs/heads/release",
  "repo:cambridge-collection/manuscript-catalogue-data:workflow:Transform XML and Publish Snapshot"
]
github_oidc_provider_arn     = null
web_frontend_domain_name     = "mscat-medieval-production.medieval.lib.cam.ac.uk"
transcriptions-bucket-name   = "unused-cul-cudl-transcriptions"
enhancements-bucket-name     = "unused-cul-cudl-data-enhancements"
source-bucket-name           = "unused-cul-cudl-data-source"
compressed-lambdas-directory = "compressed_lambdas"
lambda-jar-bucket            = "cul-cudl.mvn.cudl.lib.cam.ac.uk"

transform-lambda-bucket-sns-notifications = [

]
transform-lambda-bucket-sqs-notifications = [
  {
    "type"          = "SQS",
    "queue_name"    = "MscatIndexTEIQueue"
    "filter_prefix" = "solr-json/tei/"
    "filter_suffix" = ".json"
    "bucket_name"   = "releases"
  }
]
transform-lambda-information = [
  {
    "name"                     = "AWSLambda_TEI_SOLR_Listener"
    "image_uri"                = "899360085657.dkr.ecr.eu-west-1.amazonaws.com/mscat/solr-listener@sha256:af9641da791dbc525e5e48452277d6e87efb77026f37a272ec36fc259b0f87c6"
    "queue_name"               = "MscatIndexTEIQueue"
    "queue_delay_seconds"      = 10
    "vpc_name"                 = "mscat-medieval-production-mscat-ecs-vpc"
    "subnet_names"             = ["mscat-medieval-production-mscat-ecs-subnet-private-a", "mscat-medieval-production-mscat-ecs-subnet-private-b"]
    "security_group_names"     = ["mscat-medieval-production-mscat-ecs-vpc-egress", "mscat-medieval-production-solr-external"]
    "timeout"                  = 180
    "memory"                   = 1024
    "batch_window"             = 2
    "batch_size"               = 1
    "maximum_concurrency"      = 100
    "use_datadog_variables"    = false
    "use_additional_variables" = true
    "environment_variables" = {
      API_HOST = "solr-api-mscat-ecs.mscat-medieval-production-solr"
      API_PORT = "8081"
      API_PATH = "item"
    }
  }
]
dst-efs-prefix    = "/mnt/cudl-data-releases"
dst-prefix        = "html/"
dst-s3-prefix     = ""
tmp-dir           = "/tmp/dest/"
lambda-alias-name = "LIVE"

releases-root-directory-path        = "/data"
efs-name                            = "cudl-data-releases-efs"
cloudfront_route53_zone_id          = "Z098298513YT6MQQR228Z"
cloudfront_distribution_name        = "mscat-medieval-production"
cloudfront_origin_path              = "/www"
cloudfront_error_response_page_path = "/404.html"
cloudfront_default_root_object      = "index.html"

# Base Architecture
cluster_name_suffix            = "mscat-ecs"
registered_domain_name         = "medieval.lib.cam.ac.uk."
asg_desired_capacity           = 1 # n = number of tasks
asg_max_size                   = 1 # n + 1
asg_allow_all_egress           = true
ec2_instance_type              = "t3.large"
ec2_additional_userdata        = <<-EOF
echo 1 > /proc/sys/vm/swappiness
echo ECS_RESERVED_MEMORY=256 >> /etc/ecs/ecs.config
EOF
route53_zone_id_existing       = "Z098298513YT6MQQR228Z"
route53_zone_force_destroy     = false
acm_certificate_arn            = "arn:aws:acm:eu-west-1:899360085657:certificate/4f0c4eec-6864-43c9-835f-b7f26b9e54e8"
acm_certificate_arn_us-east-1  = "arn:aws:acm:us-east-1:899360085657:certificate/f84b57ba-57be-49d4-884f-d74c5fe06728"
alb_enable_deletion_protection = false
alb_idle_timeout               = "900"
vpc_cidr_block                 = "10.42.0.0/22" #1024 adresses
vpc_public_subnet_public_ip    = false
cloudwatch_log_group           = "/ecs/mscat-medieval-production"

# SOLR Worload
solr_name_suffix       = "solr"
solr_domain_name       = "search"
solr_application_port  = 8983
solr_target_group_port = 8081
solr_ecr_repositories = {
  "mscat/solr-api" = "sha256:f77909e67d1bf68f6d6ff253f7c55c186cfd89918ca376fe346649d86f4d5049",
  "mscat/solr"     = "sha256:bd85a2ff7168c5f7141188234ce2f1391341bdf657c09fa9b8830f0026ffa090"
}
solr_ecs_task_def_volumes     = { "solr-volume" = "/var/solr" }
solr_container_name_api       = "solr-api"
solr_container_name_solr      = "solr"
solr_health_check_status_code = "404"
solr_allowed_methods          = ["HEAD", "GET", "OPTIONS"]
solr_ecs_task_def_cpu         = 2048
solr_use_service_discovery    = true
