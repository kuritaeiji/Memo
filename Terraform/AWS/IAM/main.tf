# IAM Role

resource "aws_iam_role" "instance" {
  name = "instance"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeROle"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ec2_admin" {
  role = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.ec2_admin_permittions.json
}

data "aws_iam_policy_document" "ec2_admin_permittions" {
  statement {
    effect = "Allow"
    actions = ["ec2:*"]
    resources = ["*"]
  }
}

# IAM User

resource "aws_iam_user" "example_user" {
  name = "example_user"
}

resource "aws_iam_user_policy_attachment" "example_user_ec2_rull_access" {
  user = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}