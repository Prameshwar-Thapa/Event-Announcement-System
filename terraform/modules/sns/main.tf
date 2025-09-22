# SNS Topic for event notifications
resource "aws_sns_topic" "notifications" {
  name         = var.topic_name
  display_name = "Event Announcements"
}

# Email subscriptions
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_subscriptions)
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}

# SMS subscriptions
resource "aws_sns_topic_subscription" "sms" {
  count     = length(var.sms_subscriptions)
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sms"
  endpoint  = var.sms_subscriptions[count.index]
}
