resource "aws_iam_role" "s3_role" {
  name = "s3_role"
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
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_profile_master" {
  name = "s3_profile_master"
  roles = ["${aws_iam_role.s3_role.name}"]
}

resource "aws_iam_instance_profile" "s3_profile_agents" {
  name = "s3_profile_agents"
  roles = ["${aws_iam_role.s3_role.name}"]
}

resource "aws_iam_instance_profile" "s3_profile_public_agent" {
  name = "s3_profile_public_agent"
  roles = ["${aws_iam_role.s3_role.name}"]
}

