resource "aws_iam_user" "example_user" {
  name = "example_user"
}

resource "aws_iam_user_policy_attachment" "example_user_ec2_rull_access" {
  user = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}