environment                  = "dev"
project                      = "mscat"
component                    = "cudl-data-workflows"
subcomponent                 = "cudl-transform-lambda"
destination-bucket-name      = "releases"
web_frontend_domain_name     = "mscat-dev.cudl-sandbox.net"
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
  },
  {
    "type"          = "SQS",
    "queue_name"    = "MscatIndexPagesQueue"
    "filter_prefix" = "solr-json/pages/"
    "filter_suffix" = ".json"
    "bucket_name"   = "releases"
  }
]
transform-lambda-information = [
  {
    "name"                     = "AWSLambda_TEI_SOLR_Listener"
    "image_uri"                = "563181399728.dkr.ecr.eu-west-1.amazonaws.com/mscat/solr-listener@sha256:6a0725719f82e371437659d12cbd2050d368cd3c1d38220045537fc6e966ab7e"
    "queue_name"               = "MscatIndexTEIQueue"
    "queue_delay_seconds"      = 10
    "vpc_name"                 = "mscat-dev-mscat-ecs-vpc"
    "subnet_names"             = ["mscat-dev-mscat-ecs-subnet-private-a", "mscat-dev-mscat-ecs-subnet-private-b"]
    "security_group_names"     = ["mscat-dev-mscat-ecs-vpc-egress", "mscat-dev-solr-external"]
    "timeout"                  = 180
    "memory"                   = 1024
    "batch_window"             = 2
    "batch_size"               = 1
    "maximum_concurrency"      = 5
    "use_datadog_variables"    = false
    "use_additional_variables" = true
    "environment_variables" = {
      API_HOST = "solr-api-mscat-ecs.mscat-dev-solr"
      API_PORT = "8081"
      API_PATH = "item"
    }
  },
  {
    "name"                     = "AWSLambda_Pages_SOLR_Listener"
    "image_uri"                = "563181399728.dkr.ecr.eu-west-1.amazonaws.com/mscat/solr-listener@sha256:6a0725719f82e371437659d12cbd2050d368cd3c1d38220045537fc6e966ab7e"
    "queue_name"               = "MscatIndexPagesQueue"
    "vpc_name"                 = "mscat-dev-mscat-ecs-vpc"
    "subnet_names"             = ["mscat-dev-mscat-ecs-subnet-private-a", "mscat-dev-mscat-ecs-subnet-private-b"]
    "security_group_names"     = ["mscat-dev-mscat-ecs-vpc-egress", "mscat-dev-solr-external"]
    "timeout"                  = 180
    "memory"                   = 1024
    "batch_window"             = 2
    "batch_size"               = 1
    "maximum_concurrency"      = 5
    "use_datadog_variables"    = false
    "use_additional_variables" = true
    "environment_variables" = {
      API_HOST = "solr-api-mscat-ecs.mscat-dev-solr"
      API_PORT = "8081"
      API_PATH = "page"
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
cloudfront_route53_zone_id          = "Z035173135AOVWW8L57UJ"
cloudfront_distribution_name        = "mscat-dev"
cloudfront_origin_path              = "/www"
cloudfront_error_response_page_path = "/404.html"
cloudfront_default_root_object      = "index.html"

# Base Architecture
cluster_name_suffix     = "mscat-ecs"
registered_domain_name  = "cudl-sandbox.net."
asg_desired_capacity    = 1 # n = number of tasks
asg_max_size            = 1 # n + 1
asg_allow_all_egress    = true
ec2_instance_type       = "t3.large"
ec2_additional_userdata = <<-EOF
echo 1 > /proc/sys/vm/swappiness
echo ECS_RESERVED_MEMORY=256 >> /etc/ecs/ecs.config
EOF
#route53_delegation_set_id      = "N02288771HQRX5TRME6CM"
route53_zone_id_existing       = "Z035173135AOVWW8L57UJ"
route53_zone_force_destroy     = true
alb_enable_deletion_protection = false
alb_idle_timeout               = "900"
vpc_cidr_block                 = "10.42.0.0/22" #1024 adresses
vpc_public_subnet_public_ip    = false
cloudwatch_log_group           = "/ecs/mscat-dev"

# SOLR Worload
solr_name_suffix       = "solr"
solr_domain_name       = "mscat-dev-search"
solr_application_port  = 8983
solr_target_group_port = 8081
solr_ecr_repositories = {
  "mscat/solr-api" = "sha256:a332bdbde619b61d7affd5d307fcbaf66389c1320cf9ab59014389f5f712c718",
  "mscat/solr"     = "sha256:46b11db5f0a74e02b4128d2a5059fae830cbf9087ee24292652eefbdc69ceae8"
}
solr_ecs_task_def_volumes     = { "solr-volume" = "/var/solr" }
solr_container_name_api       = "solr-api"
solr_container_name_solr      = "solr"
solr_health_check_status_code = "404"
solr_allowed_methods          = ["HEAD", "GET", "OPTIONS"]
solr_ecs_task_def_cpu         = 2048
solr_use_service_discovery    = true
