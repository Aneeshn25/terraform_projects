resource "aws_iam_role" "LambdaDynamoAPICloudWatch" {
  name = "LambdaDynamoAPICloudWatch"
  description = "Allows Lambda functions to call Dynamodb table and cloudwatch on your behalf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-LambdaDynamoAPICloudWatch"
  }
}


resource "aws_iam_role_policy" "Execute_Lambda" {
  name = "Execute_Lambda"
  role = "${aws_iam_role.LambdaDynamoAPICloudWatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "dynamoGetScanQueryItemRole" {
  name = "dynamoGetScanQueryItemRole"
  role = "${aws_iam_role.LambdaDynamoAPICloudWatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query"
            ],
            "Resource": "arn:aws:dynamodb:${var.AWS_REGION}:${var.AWS_ACCOUNT}:table/${var.table_name}"
        }
    ]
}
EOF
}



resource "aws_iam_role_policy" "CloudWatchLogs" {
  name = "CloudWatchLogs"
  role = "${aws_iam_role.LambdaDynamoAPICloudWatch.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
