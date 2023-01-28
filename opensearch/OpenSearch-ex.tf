 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# OpenSearch_domain
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
resource "aws_opensearch_domain" "kyoin-os" {
    domain_name = "kyoin-os"
    engine_version = "OpenSearch_2.3"

    cluster_config {
      instance_type = "r6g.large.search"
      instance_count = 1
      zone_awareness_enabled = false
      #zone_awareness_config = {
      #  availability_zone_count = 2
      #}
    }

    vpc_options {
      subnet_ids = ["${aws_subnet.kyoin-sbn-az1-ap.id}"]
      security_group_ids = ["${aws_security_group.kyoin-sg-os.id}"]
    }

    advanced_options = {
      "rest.action.multi.allow_explicit_index" = "true"
      "override_main_response_version" = "false"
    }

    ebs_options {
      ebs_enabled = true
      volume_size = 500
      volume_type = "gp3"
    }

    tags = {
      "Name" = "kyoin-os"
    }

     access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
              "AWS":"*"
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:ap-northeast-2:${account-num}:domain/kyoin-os/*"
        }
    ]
}
CONFIG
    
    depends_on = [aws_iam_service_linked_role.kyoin-os]

    node_to_node_encryption {
      enabled = true
    }

    encrypt_at_rest {
      enabled =true
    }


    advanced_security_options {
      enabled = true
      internal_user_database_enabled = true
      master_user_options {
        master_user_name = "admin"
        master_user_password = "${password}"
      }
    }

    domain_endpoint_options {
      enforce_https = true
      tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    }
}

resource "aws_iam_service_linked_role" "kyoin-os" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_resource_policy" "kyoin-os-cw-log-policy" {
  policy_name = "kyoin-os-cw-log-policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}


