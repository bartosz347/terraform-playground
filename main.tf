terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default" # refers to AWS credentials stored in AWS config file
  region  = "eu-central-1"
}

resource "aws_key_pair" "bartosz-laptop2" {
  key_name   = "bartosz-laptop2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD6vTxcDuUjeAR4kG409HO7YhbTA+3JYHvQRpuHfc5xJJuRn/7QrXeAnsjvepZgTC/z3dnwHmEsv3afPK55uxhv+NoqeBg16e8LdawgysVNZxfjpqyUedSJe7pHLLNzYwXUZmn9VIGo/1+TXtZ/dWt/NaSZDH4HMqucwEUuaPd1fy5To/UBPYzRNYwcn7LWT8zfab7QGQF4TL/ZHrbNeYWYpbaJqPuuSNsHzz1SEj9N2JWyS6H4Zg/pzVX9nzXwH8F+dF7bqhquaT4AXMCm5E/wl7b3gCSJYwajQPHY4/17tTMHjy/rM5rqR8KvKCI2wDFvLvzAELpR0sT8B5d3qjOWA199LZHyEKcPU82dktVO0h3lN8zPzixh02SjNP9cu9cDX44tLyf2YRgBNpTKdTNz10BRGERzpKlolZLyqHvqB6H59BRKtzewl/Jq+4jicZT1r0FWvMtoKX19HWph9VA8b8r3OwUTw22U5//eVnxjlVTmu2xI/OyMjrOMIpXgh3t5Y5j/KC57noqnLz+XJZw34Zn0smgb0TAtYv99D3ClQghzQ0/ZH051xxeA46TmBeDvjJvnIFMaAsNI6FHR1R1kc6EfuRqRwgX7+2pJR2rkYKvCLf+0FMb/YLod8UO/OQneLATQoiYYFOpDmVfXS0utr++ToCwHaHoBiQ6E9G8dUw== bartosz@bartosz-laptop2"
}