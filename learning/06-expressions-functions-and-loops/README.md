# Module 06: Expressions, Functions, and Loops

## Conditional Expressions

Terraform uses standard ternary expressions:

```hcl
condition ? true_value : false_value
```

Example: Dynamic instance sizing based on environment:

```hcl
instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"
```

Example: Conditionally creating a resource using `count`:

```hcl
# Create 1 instance if enable_bastion is true, otherwise create 0 (skips creation)
count = var.enable_bastion ? 1 : 0
```

## `for` Expressions

Transform one collection into another collection.

### 1. List to List

```hcl
# Convert list of strings to uppercase
names           = ["web", "api", "worker"]
uppercase_names = [for s in var.names : upper(s)]
# Result: ["WEB", "API", "WORKER"]
```

### 2. Filtering with `if`

```hcl
# Filter list to only keep ports greater than 1024
high_ports = [for p in var.port_list : p if p > 1024]
```

### 3. List to Map

```hcl
# Convert list to a lookup map with uppercase values
name_map = { for s in var.names : s => upper(s) }
# Result: { "web" = "WEB", "api" = "API", "worker" = "WORKER" }
```

### 4. Grouping with Ellipsis (`...`)

When transforming data into a map where keys might collide, use `...` to group values into a list:

```hcl
# Group user names by department
users_by_dept = { for u in var.users : u.department => u.username... }
# Result: { "eng" = ["alice", "bob"], "sales" = ["carol"] }
```

## Splat Expressions (`[*]`)

Concise syntax to extract a single attribute from all elements in a list or count-indexed resource:

```hcl
# Equivalent to [for instance in aws_instance.workers : instance.id]
instance_ids = aws_instance.workers[*].id
```

## Built-In Functions by Category

Terraform does not support user-defined functions; all logic relies on built-in functions. Evaluate these directly in `terraform console`.

### 1. String Functions

- `format("%s-%03d", "server", 5)` -> `"server-005"`
- `join(", ", ["a", "b", "c"])` -> `"a, b, c"`
- `split("/", "path/to/file")` -> `["path", "to", "file"]`
- `replace("hello world", "world", "terraform")` -> `"hello terraform"`
- `lower("HELLO")` / `upper("hello")` -> `"hello"` / `"HELLO"`
- `trimspace("  trimmed  ")` -> `"trimmed"`
- `substr("infrastructure", 0, 5)` -> `"infra"`

### 2. Collection Functions

- `length(["a", "b"])` -> `2`
- `contains(["dev", "prod"], "stage")` -> `false`
- `distinct(["a", "b", "a"])` -> `["a", "b"]`
- `flatten([[1, 2], [3, 4]])` -> `[1, 2, 3, 4]`
- `merge({ a = 1 }, { b = 2 })` -> `{ a = 1, b = 2 }`
- `lookup({ a = 1, b = 2 }, "c", 100)` -> `100` (returns default if key not found)
- `zipmap(["a", "b"], [1, 2])` -> `{ "a" = 1, "b" = 2 }`
- `slice(["a", "b", "c", "d"], 1, 3)` -> `["b", "c"]`
- `concat([1, 2], [3, 4])` -> `[1, 2, 3, 4]`
- `keys({ a = 1, b = 2 })` -> `["a", "b"]`
- `values({ a = 1, b = 2 })` -> `[1, 2]`

### 3. Numeric Functions

- `min(5, 12, 9)` -> `5`
- `max(5, 12, 9)` -> `12`
- `abs(-25)` -> `25`
- `ceil(4.2)` -> `5`
- `floor(4.9)` -> `4`

### 4. Encoding Functions

- `jsonencode({ key = "value" })` -> `{"key":"value"}` (string)
- `jsondecode("{\"key\":\"value\"}")` -> `{ key = "value" }` (HCL object)
- `yamlencode({ port = 80 })` -> YAML formatted string
- `base64encode("secret")` -> `"c2VjcmV0"`
- `base64decode("c2VjcmV0")` -> `"secret"`

### 5. Filesystem Functions

- `file("${path.module}/script.sh")`: Reads file contents as a raw string.
- `fileexists("${path.module}/config.json")`: Checks if a file exists on disk.
- `templatefile("${path.module}/userdata.tpl", { port = 8080 })`: Reads file and interpolates variables inside it.
- `fileset("${path.module}/configs", "*.json")`: Returns a set of matching file paths.

### 6. IP Network Functions

- `cidrsubnet("10.0.0.0/16", 8, 1)` -> `"10.0.1.0/24"` (splits /16 network into /24 subnets)
- `cidrhost("10.0.1.0/24", 5)` -> `"10.0.1.5"` (calculates IP address for a specific host number)
- `cidrnetmask("10.0.0.0/16")` -> `"255.255.0.0"`

## Dynamic Blocks

Normally, nested blocks (like `ingress` inside `aws_security_group` or `setting` inside `azurerm_app_service`) must be written out statically. A `dynamic` block generates repeatable nested blocks from a map or list.

```hcl
variable "firewall_rules" {
  type = list(object({
    port        = number
    description = string
  }))
  default = [
    { port = 80,  description = "HTTP" },
    { port = 443, description = "HTTPS" },
    { port = 22,  description = "SSH" }
  ]
}

resource "aws_security_group" "web" {
  name        = "dynamic-web-sg"
  description = "Demonstrating dynamic ingress generation"

  dynamic "ingress" {
    for_each = var.firewall_rules
    iterator = rule # Optional: rename iterator from default 'ingress'
    content {
      description = rule.value.description
      from_port   = rule.value.port
      to_port     = rule.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

Inside the `content` block:

- `rule.key`: Current collection index or map key.
- `rule.value`: Current element value.
