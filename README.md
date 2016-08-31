# Markdown Spreadsheet

This is a very early release. Consider this in alpha state.

Idea is: take a markdown page, preprocess it and then render it as usual.

Sample:

```markdown
---
spreadsheet:
  a: 10
  b: 100
---

a + b = {{= a + b}}
```

Which should be rendered as

> a + b = 110

```markdown
---coffee
spreadsheet
  helpers:
    foo: (a,b) -> a + b
    bar: (a,b) -> a + b

---

{{foo 10 10}} {{bar 10 10}}
```

Idea:

Special names are `helpers` and `partials` and `context`.  If value is a string, 
it is interpreted as moduleName and is tried to be required.  If is Object, the value 
is taken as is.  A module is expected to export an object.  If it is a list, it may be
either object or module name and may be mixed.

What works:

- Inline works, require does not yet work



## Reference data

Data referencing works as described in handlebars documentation.

## Interacting with the context

```markdown
---
spreadsheet:
  a: 100
---

{{set a 200}}

{{a}}
```

results in

> 200

## Predefined Helpers

### set

```
{{set <var> [ '=' ] <expr> }}
```
