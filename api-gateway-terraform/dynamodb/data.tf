data "template_file" "items" {
  template = "${file("files/items.json")}"
}
