Terraform does not provide loop statement like this

```
for (i := 0; i < 10; i++) {
  resource "aws_instance" "web" {
    instance_type = "t2.medium"
    tags {
        Name = "web" + i
    }
  }
}
```


But provides similar functionality through count attribute.

```
resource "aws_instance" "web" {
    instance_type = "t2.medium"
    count = "10"
    tags {
        Name = "web + ${count.index}"
    }
  }
```
