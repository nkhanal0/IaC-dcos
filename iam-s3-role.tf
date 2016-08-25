resource "aws_iam_role" "s3_role" {
  name = "${var.pre_tag}_s3_role_${var.post_tag}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.pre_tag}_s3_access_policy_${var.post_tag}"
  role = "${aws_iam_role.s3_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cluster-storage.bucket}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cluster-storage.bucket}/*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy" "ecr_access_policy" {
  name = "${var.pre_tag}_ecr_access_policy_${var.post_tag}"
  role = "${aws_iam_role.s3_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:*"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_profile_master" {
  name = "${var.pre_tag}_s3_profile_master_${var.post_tag}"
  roles = ["${aws_iam_role.s3_role.name}"]
}

resource "aws_iam_instance_profile" "s3_profile_agents" {
  name = "${var.pre_tag}_s3_profile_agents_${var.post_tag}"
  roles = ["${aws_iam_role.s3_role.name}"]
}

resource "aws_iam_instance_profile" "s3_profile_public_agent" {
  name = "${var.pre_tag}_s3_profile_public_agent_${var.post_tag}"
  roles = ["${aws_iam_role.s3_role.name}"]
}

